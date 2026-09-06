<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.queue.DBConnection" %>
<%@ page import="java.sql.*" %>
<%
    String hospitalCode = (String) session.getAttribute("adminHospitalCode");
    if (hospitalCode == null) {
        hospitalCode = (String) session.getAttribute("hospitalCode");
    }

    String hospitalName = (String) session.getAttribute("adminHospitalName");
    if (hospitalName == null) {
        hospitalName = (String) session.getAttribute("hospitalName");
    }
    if (hospitalName == null) {
        hospitalName = hospitalCode;
    }

    if (hospitalCode == null) {
        response.sendRedirect("admin_login.jsp?error=unauthorized");
        return;
    }

    String msg = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String type = request.getParameter("type");
        if ("dept".equals(type)) {
            String deptName = request.getParameter("departmentName");
            if (deptName != null && !deptName.trim().isEmpty()) {
                try (Connection con = DBConnection.getConnection();
                     PreparedStatement ps = con.prepareStatement("INSERT INTO hospital_departments (hospital_code, department_name) VALUES (?, ?)")) {
                    ps.setString(1, hospitalCode);
                    ps.setString(2, deptName.trim());
                    ps.executeUpdate();
                    msg = "Department added successfully!";
                } catch (Exception e) { e.printStackTrace(); msg = "Error: Department might already exist."; }
            }
        } else if ("doc".equals(type)) {
            String deptName = request.getParameter("departmentName");
            String docName = request.getParameter("doctorName");
            if (deptName != null && docName != null && !docName.trim().isEmpty()) {
                try (Connection con = DBConnection.getConnection();
                     PreparedStatement ps = con.prepareStatement("INSERT INTO hospital_doctors (hospital_code, department_name, doctor_name) VALUES (?, ?, ?)")) {
                    ps.setString(1, hospitalCode);
                    ps.setString(2, deptName);
                    ps.setString(3, docName.trim());
                    ps.executeUpdate();
                    msg = "Doctor added successfully!";
                } catch (Exception e) { e.printStackTrace(); msg = "Error adding doctor."; }
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Manage Doctors & Wards - ORDEXA</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', sans-serif; }
        body { background-color: #0b132b; color: #f8fafc; padding: 20px; display: flex; flex-direction: column; align-items: center; min-height: 100vh; }
        .container { width: 100%; max-width: 650px; background: #1c2541; padding: 30px; border-radius: 12px; border: 1px solid #334155; margin-bottom: 30px; }
        h2 { color: #38bdf8; margin-bottom: 20px; text-align: center; font-size: 22px; }
        .form-section { margin-bottom: 25px; padding-bottom: 20px; border-bottom: 1px solid #334155; }
        .input-group { margin-bottom: 15px; }
        .input-group label { display: block; font-size: 14px; margin-bottom: 5px; color: #cbd5e1; }
        .input-group input, .input-group select { width: 100%; padding: 10px; background: #0b132b; border: 1px solid #475569; border-radius: 6px; color: white; outline: none; }
        .btn { width: 100%; padding: 10px; background: #0284c7; border: none; border-radius: 6px; color: white; font-weight: 600; cursor: pointer; }
        .btn:hover { background: #0369a1; }
        .alert { background: #1e293b; color: #38bdf8; padding: 10px; border-radius: 6px; margin-bottom: 15px; text-align: center; font-size: 14px; border: 1px solid #334155; }
        .list-section { margin-top: 25px; border-top: 1px solid #334155; padding-top: 20px; }
        .list-table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        .list-table th, .list-table td { padding: 10px; text-align: left; border-bottom: 1px solid #334155; font-size: 14px; }
        .list-table th { color: #94a3b8; font-weight: 600; }
        .back-link { display: inline-block; margin-top: 15px; color: #94a3b8; text-decoration: none; font-size: 13px; }
        .back-link:hover { color: white; }
    </style>
</head>
<body>
<div class="container">
    <h2><i class="fa-solid fa-stethoscope"></i> Manage Wards & Doctors (<%= hospitalName %>)</h2>

    <% if (!msg.isEmpty()) { %>
    <div class="alert"><%= msg %></div>
    <% } %>

    <!-- Add Department Form -->
    <div class="form-section">
        <h3 style="font-size: 16px; margin-bottom: 10px; color: #f1f5f9;">Add New Department / Ward</h3>
        <form method="post" action="manage_doctors.jsp">
            <input type="hidden" name="type" value="dept">
            <div class="input-group">
                <label>Department Name (e.g., General, Cardiology)</label>
                <input type="text" name="departmentName" placeholder="Enter department name" required>
            </div>
            <button type="submit" class="btn">Add Department</button>
        </form>
    </div>

    <!-- Add Doctor Form -->
    <div class="form-section">
        <h3 style="font-size: 16px; margin-bottom: 10px; color: #f1f5f9;">Add Doctor to Department</h3>
        <form method="post" action="manage_doctors.jsp">
            <input type="hidden" name="type" value="doc">
            <div class="input-group">
                <label>Select Department</label>
                <select name="departmentName" required>
                    <option value="">-- Choose Department --</option>
                    <%
                        try (Connection con = DBConnection.getConnection();
                             PreparedStatement ps = con.prepareStatement("SELECT department_name FROM hospital_departments WHERE hospital_code = ?")) {
                            ps.setString(1, hospitalCode);
                            try (ResultSet rs = ps.executeQuery()) {
                                while (rs.next()) {
                    %>
                    <option value="<%= rs.getString("department_name") %>"><%= rs.getString("department_name") %></option>
                    <%
                                }
                            }
                        } catch(Exception e) { e.printStackTrace(); }
                    %>
                </select>
            </div>
            <div class="input-group">
                <label>Doctor Name (e.g., Dr. Raj)</label>
                <input type="text" name="doctorName" placeholder="Enter doctor name" required>
            </div>
            <button type="submit" class="btn">Add Doctor</button>
        </form>
    </div>

    <!-- Existing Departments & Doctors List -->
    <div class="list-section">
        <h3 style="font-size: 16px; margin-bottom: 10px; color: #38bdf8;"><i class="fa-solid id-card"></i> Configured Doctors & Wards</h3>
        <table class="list-table">
            <thead>
            <tr>
                <th>Department / Ward</th>
                <th>Doctor Name</th>
            </tr>
            </thead>
            <tbody>
            <%
                try (Connection con = DBConnection.getConnection();
                     PreparedStatement ps = con.prepareStatement("SELECT department_name, doctor_name FROM hospital_doctors WHERE hospital_code = ? ORDER BY department_name")) {
                    ps.setString(1, hospitalCode);
                    try (ResultSet rs = ps.executeQuery()) {
                        boolean hasAny = false;
                        while (rs.next()) {
                            hasAny = true;
            %>
            <tr>
                <td><strong><%= rs.getString("department_name") %></strong></td>
                <td><%= rs.getString("doctor_name") %></td>
            </tr>
            <%
                }
                if (!hasAny) {
            %>
            <tr>
                <td colspan="2" style="text-align: center; color: #64748b; padding: 15px;">No doctors added yet.</td>
            </tr>
            <%
                        }
                    }
                } catch(Exception e) { e.printStackTrace(); }
            %>
            </tbody>
        </table>
    </div>

    <a href="counter.jsp" class="back-link"><i class="fa-solid fa-arrow-left"></i> Back to Counter Panel</a>
</div>
</body>
</html>