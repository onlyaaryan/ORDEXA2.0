<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.queue.DBConnection" %>
<%@ page import="java.sql.*" %>
<%
    String selectedHospital = request.getParameter("hospitalCode");
    if (selectedHospital == null) selectedHospital = "";

    String selectedDept = request.getParameter("department");
    if (selectedDept == null) selectedDept = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>ORDEXA - Book Token</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', sans-serif; }
        body { background-color: #0b132b; color: #f8fafc; display: flex; justify-content: center; align-items: center; min-height: 100vh; padding: 20px; }
        .card { background: #1c2541; padding: 35px; border-radius: 14px; width: 100%; max-width: 450px; border: 1px solid #334155; box-shadow: 0 10px 25px rgba(0,0,0,0.4); }
        h2 { color: #38bdf8; margin-bottom: 20px; text-align: center; font-size: 22px; }
        .input-group { margin-bottom: 16px; text-align: left; }
        .input-group label { display: block; font-size: 14px; margin-bottom: 6px; color: #cbd5e1; font-weight: 600; }
        .input-group select, .input-group input { width: 100%; padding: 10px 12px; background: #0b132b; border: 1px solid #475569; border-radius: 6px; color: white; outline: none; font-size: 14px; }
        .input-hint { font-size: 12px; color: #94a3b8; margin-top: 4px; display: block; }
        .btn { width: 100%; padding: 12px; background: #0284c7; border: none; border-radius: 6px; color: white; font-weight: 600; cursor: pointer; margin-top: 10px; font-size: 15px; transition: 0.2s; }
        .btn:hover { background: #0369a1; }
        .back-link { display: block; text-align: center; margin-top: 15px; color: #94a3b8; text-decoration: none; font-size: 13px; }
        .back-link:hover { color: white; }
    </style>
</head>
<body>
<div class="card">
    <h2><i class="fa-solid fa-ticket"></i> Book Queue Token</h2>

    <form action="use_service.jsp" method="get" id="mainForm">
        <!-- Step 1: Select Hospital -->
        <div class="input-group">
            <label>Select Hospital</label>
            <select name="hospitalCode" onchange="document.getElementById('mainForm').submit()" required>
                <option value="">-- Choose Hospital --</option>
                <%
                    try (Connection con = DBConnection.getConnection();
                         Statement st = con.createStatement();
                         ResultSet rs = st.executeQuery("SELECT DISTINCT hospital_code, hospital_name FROM admin")) {
                        while(rs.next()) {
                            String hCode = rs.getString("hospital_code");
                            String hName = rs.getString("hospital_name");
                %>
                <option value="<%= hCode %>" <%= hCode.equals(selectedHospital) ? "selected" : "" %>><%= hName %> (<%= hCode %>)</option>
                <%
                        }
                    } catch(Exception e) { e.printStackTrace(); }
                %>
            </select>
        </div>

        <!-- Step 2: Department Selection -->
        <div class="input-group">
            <label>Department / Ward</label>
            <select name="department" onchange="document.getElementById('mainForm').submit()" required>
                <option value="">-- Select Department --</option>
                <%
                    if (!selectedHospital.isEmpty()) {
                        try (Connection con = DBConnection.getConnection();
                             PreparedStatement ps = con.prepareStatement("SELECT department_name FROM hospital_departments WHERE hospital_code = ?")) {
                            ps.setString(1, selectedHospital);
                            try (ResultSet rs = ps.executeQuery()) {
                                while(rs.next()) {
                                    String dName = rs.getString("department_name");
                %>
                <option value="<%= dName %>" <%= dName.equals(selectedDept) ? "selected" : "" %>><%= dName %></option>
                <%
                                }
                            }
                        } catch(Exception e) { e.printStackTrace(); }
                    }
                %>
            </select>
        </div>
    </form>

    <!-- Step 3: Main Token Generation Form -->
    <form action="GenerateTokenServlet" method="post">
        <input type="hidden" name="hospitalCode" value="<%= selectedHospital %>">
        <input type="hidden" name="department" value="<%= selectedDept %>">

        <div class="input-group">
            <label>Registered Phone Number</label>
            <input type="text" name="phone" placeholder="Enter your phone" required>
        </div>

        <div class="input-group">
            <label>Doctor Name</label>
            <select name="doctorName" required>
                <option value="">-- Select Doctor --</option>
                <%
                    if (!selectedHospital.isEmpty() && !selectedDept.isEmpty()) {
                        try (Connection con = DBConnection.getConnection();
                             PreparedStatement ps = con.prepareStatement("SELECT doctor_name FROM hospital_doctors WHERE hospital_code = ? AND department_name = ?")) {
                            ps.setString(1, selectedHospital);
                            ps.setString(2, selectedDept);
                            try (ResultSet rs = ps.executeQuery()) {
                                while(rs.next()) {
                                    String docName = rs.getString("doctor_name");
                %>
                <option value="<%= docName %>"><%= docName %></option>
                <%
                                }
                            }
                        } catch(Exception e) { e.printStackTrace(); }
                    }
                %>
            </select>
        </div>

        <!-- Step 4: Initial Travel / Arrival Time Input -->
        <div class="input-group">
            <label>Travel Time / Distance (Minutes Away)</label>
            <input type="number" name="arrivalMinutes" min="0" max="180" value="0" placeholder="e.g., 20" required>
            <span class="input-hint">Enter roughly how many minutes you'll take to reach.</span>
        </div>

        <button type="submit" class="btn">Generate Token</button>
    </form>

    <a href="index.jsp" class="back-link"><i class="fa-solid fa-arrow-left"></i> Back to Home</a>
</div>
</body>
</html>