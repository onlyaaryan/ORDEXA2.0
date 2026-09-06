<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ORDEXA - Admin Portal</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #0f172a; display: flex; justify-content: center; align-items: center; min-height: 100vh; }
        .login-card { background: #ffffff; padding: 40px; border-radius: 12px; width: 100%; max-width: 420px; box-shadow: 0 10px 25px rgba(0, 0, 0, 0.3); text-align: center; }
        .icon-box { font-size: 45px; color: #0284c7; margin-bottom: 15px; }
        h2 { color: #1e293b; font-size: 26px; margin-bottom: 8px; }
        p.subtitle { color: #64748b; font-size: 14px; margin-bottom: 25px; }
        .alert { padding: 12px; border-radius: 6px; font-size: 14px; margin-bottom: 20px; text-align: center; }
        .alert-error { background-color: #fee2e2; color: #dc2626; border: 1px solid #fca5a5; }
        .alert-success { background-color: #dcfce7; color: #16a34a; border: 1px solid #86efac; }
        .input-group { text-align: left; margin-bottom: 18px; }
        .input-group label { display: block; font-size: 14px; font-weight: 600; color: #334155; margin-bottom: 6px; }
        .input-box { display: flex; align-items: center; border: 1px solid #cbd5e1; border-radius: 6px; padding: 10px 12px; background-color: #f8fafc; }
        .input-box i { color: #64748b; margin-right: 10px; font-size: 16px; }
        .input-box input { border: none; outline: none; width: 100%; background: transparent; font-size: 14px; color: #1e293b; }
        .submit-btn { width: 100%; padding: 12px; background-color: #0284c7; border: none; border-radius: 6px; color: #ffffff; font-size: 16px; font-weight: 600; cursor: pointer; margin-top: 10px; }
        .submit-btn:hover { background-color: #0369a1; }
        .links-container { margin-top: 22px; font-size: 14px; color: #64748b; }
        .links-container a { color: #0284c7; text-decoration: none; font-weight: 600; }
        .links-container a:hover { text-decoration: underline; }
        .back-home { display: inline-block; margin-top: 15px; font-size: 13px; color: #64748b; text-decoration: none; }
    </style>
</head>
<body>
<div class="login-card">
    <div class="icon-box"><i class="fa-solid fa-hospital-user"></i></div>
    <h2>Admin Portal</h2>
    <p class="subtitle">Enter credentials to manage hospital queue</p>

    <%
        String error = request.getParameter("error");
        String registered = request.getParameter("registered");
        if ("invalid".equals(error)) {
    %>
    <div class="alert alert-error">Invalid Hospital Code, Username, or Password.</div>
    <% } else if ("true".equals(registered)) { %>
    <div class="alert alert-success">Admin registered successfully! Please log in.</div>
    <% } %>

    <form action="AdminAuthServlet" method="post">
        <div class="input-group">
            <label>Hospital Code</label>
            <div class="input-box">
                <i class="fa-solid fa-building"></i>
                <input type="text" name="hospitalCode" placeholder="e.g. HOSP101" required>
            </div>
        </div>
        <div class="input-group">
            <label>Username</label>
            <div class="input-box">
                <i class="fa-solid fa-user"></i>
                <input type="text" name="username" placeholder="admin" required>
            </div>
        </div>
        <div class="input-group">
            <label>Password</label>
            <div class="input-box">
                <i class="fa-solid fa-lock"></i>
                <input type="password" name="password" placeholder="••••••••" required>
            </div>
        </div>
        <button type="submit" class="submit-btn">Login to Dashboard</button>
    </form>

    <div class="links-container">
        Don't have an admin account?
        <a href="admin_register.jsp">Sign Up</a>
    </div>
    <div>
        <a href="index.jsp" class="back-home"><i class="fa-solid fa-arrow-left"></i> Back to Home</a>
    </div>
</div>
</body>
</html>