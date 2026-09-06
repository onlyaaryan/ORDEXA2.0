<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.queue.DBConnection" %>
<%
    boolean isRegistered = false;
    String registeredName = "";
    String errorMsg = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String name = request.getParameter("name");
        String phone = request.getParameter("phone");

        if (name == null || phone == null || name.trim().isEmpty() || phone.trim().isEmpty()) {
            errorMsg = "Please fill in all details.";
        } else {
            name = name.trim();
            phone = phone.trim();
            try (Connection con = DBConnection.getConnection()) {

                // 1. Check if phone number already exists
                String checkSql = "SELECT user_id, name FROM users WHERE phone = ?";
                try (PreparedStatement psCheck = con.prepareStatement(checkSql)) {
                    psCheck.setString(1, phone);
                    try (ResultSet rs = psCheck.executeQuery()) {
                        if (rs.next()) {
                            // Phone already exists -> Show Error
                            errorMsg = "This phone number is already registered! Please login instead.";
                        } else {
                            // 2. Insert new user if not exists
                            String insertSql = "INSERT INTO users (name, phone) VALUES (?, ?)";
                            try (PreparedStatement psIns = con.prepareStatement(insertSql)) {
                                psIns.setString(1, name);
                                psIns.setString(2, phone);
                                psIns.executeUpdate();
                            }

                            // Session store user info
                            session.setAttribute("userPhone", phone);
                            session.setAttribute("userName", name);

                            isRegistered = true;
                            registeredName = name;
                        }
                    }
                }

            } catch (Exception e) {
                errorMsg = "Database error: " + e.getMessage();
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - ORDEXA</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #0b132b; display: flex; justify-content: center; align-items: center; min-height: 100vh; padding: 20px; }
        .card { background: #ffffff; padding: 35px 30px; border-radius: 16px; width: 100%; max-width: 400px; box-shadow: 0 15px 35px rgba(0,0,0,0.35); text-align: center; }
        .title { color: #16a34a; font-size: 24px; font-weight: 700; margin-bottom: 8px; display: flex; align-items: center; justify-content: center; gap: 10px; }
        .subtitle { font-size: 13px; color: #64748b; margin-bottom: 22px; }
        .input-group { text-align: left; margin-bottom: 18px; }
        .input-group label { display: block; font-size: 14px; font-weight: 600; color: #1e293b; margin-bottom: 6px; }
        .input-box { display: flex; align-items: center; border: 1px solid #cbd5e1; border-radius: 8px; padding: 10px 14px; background: #f8fafc; }
        .input-box i { color: #64748b; margin-right: 12px; font-size: 16px; }
        .input-box input { border: none; outline: none; width: 100%; background: transparent; font-size: 14px; color: #1e293b; }
        .submit-btn { width: 100%; padding: 12px; background: #16a34a; border: none; border-radius: 8px; color: #ffffff; font-size: 16px; font-weight: 600; cursor: pointer; margin-top: 10px; transition: 0.2s; }
        .submit-btn:hover { background: #15803d; }
        .alert { background-color: #fee2e2; color: #b91c1c; padding: 10px; border-radius: 6px; font-size: 13px; margin-bottom: 15px; }
        .success-icon { font-size: 55px; color: #16a34a; margin-bottom: 15px; }
        .success-title { font-size: 22px; color: #0f172a; font-weight: 700; margin-bottom: 8px; }
        .success-desc { font-size: 14px; color: #64748b; margin-bottom: 25px; line-height: 1.4; }
        .btn-group { display: flex; flex-direction: column; gap: 12px; }
        .btn { padding: 12px; border-radius: 8px; font-size: 15px; font-weight: 600; text-decoration: none; display: flex; align-items: center; justify-content: center; gap: 8px; transition: 0.2s; }
        .btn-join { background: #0284c7; color: #ffffff; }
        .btn-join:hover { background: #0369a1; }
        .btn-home { background: #f1f5f9; color: #334155; border: 1px solid #cbd5e1; }
        .btn-home:hover { background: #e2e8f0; }
        .footer-links { margin-top: 20px; display: flex; justify-content: space-between; font-size: 13px; align-items: center; border-top: 1px solid #e2e8f0; padding-top: 15px; }
        .footer-links a { text-decoration: none; }
    </style>
</head>
<body>

<div class="card">
    <% if (isRegistered) { %>
    <div class="success-icon">
        <i class="fa-solid fa-circle-check"></i>
    </div>
    <div class="success-title">Successfully Registered!</div>
    <p class="success-desc">Welcome <strong><%= registeredName %></strong>, your profile has been created.</p>

    <div class="btn-group">
        <a href="use_service.jsp" class="btn btn-join">
            <i class="fa-solid fa-ticket"></i> Join Queue
        </a>
        <a href="index.jsp" class="btn btn-home">
            <i class="fa-solid fa-house"></i> Back to Home
        </a>
    </div>
    <% } else { %>
    <div class="title"><i class="fa-solid fa-user-plus"></i> Register Patient</div>
    <p class="subtitle">One-time registration for hospital queue system</p>

    <% if (!errorMsg.isEmpty()) { %>
    <div class="alert"><%= errorMsg %></div>
    <% } %>

    <form action="register.jsp" method="post">
        <div class="input-group">
            <label>Full Name</label>
            <div class="input-box">
                <i class="fa-solid fa-user"></i>
                <input type="text" name="name" placeholder="John Doe" required>
            </div>
        </div>

        <div class="input-group">
            <label>Phone Number</label>
            <div class="input-box">
                <i class="fa-solid fa-phone"></i>
                <input type="tel" name="phone" placeholder="9876543210" required>
            </div>
        </div>

        <button type="submit" class="submit-btn">Register</button>
    </form>

    <div class="footer-links">
        <a href="index.jsp" style="color: #64748b;"><i class="fa-solid fa-arrow-left"></i> Home</a>
        <a href="login.jsp" style="color: #0284c7; font-weight: 600;">Existing User? Login <i class="fa-solid fa-arrow-right"></i></a>
    </div>
    <% } %>
</div>

</body>
</html>