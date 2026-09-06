<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String name = request.getParameter("name");
    if (name == null || name.trim().isEmpty()) {
        name = "Patient";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registration Successful - ORDEXA</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #0b132b; min-height: 100vh; display: flex; justify-content: center; align-items: center; padding: 20px; }
        .card { background: #ffffff; padding: 40px 30px; border-radius: 18px; width: 100%; max-width: 420px; text-align: center; box-shadow: 0 15px 35px rgba(0,0,0,0.35); }
        .check-icon { font-size: 55px; color: #16a34a; margin-bottom: 15px; }
        h2 { font-size: 24px; color: #0f172a; margin-bottom: 8px; font-weight: 700; }
        p { color: #64748b; font-size: 14px; margin-bottom: 25px; line-height: 1.5; }
        .btn-group { display: flex; flex-direction: column; gap: 12px; }
        .btn { padding: 13px; border-radius: 8px; font-size: 15px; font-weight: 600; text-decoration: none; display: flex; align-items: center; justify-content: center; gap: 8px; transition: 0.2s; }
        .btn-join { background: #0284c7; color: white; }
        .btn-join:hover { background: #0369a1; }
        .btn-home { background: #f1f5f9; color: #334155; border: 1px solid #cbd5e1; }
        .btn-home:hover { background: #e2e8f0; }
    </style>
</head>
<body>

<div class="card">
    <div class="check-icon">
        <i class="fa-solid fa-circle-check"></i>
    </div>
    <h2>Successfully Registered!</h2>
    <p>Welcome, <strong><%= name %></strong>. Your profile has been created. You can now proceed to join a hospital queue.</p>

    <div class="btn-group">
        <!-- Join Queue Button -->
        <a href="use_service.jsp" class="btn btn-join">
            <i class="fa-solid fa-ticket"></i> Join Queue
        </a>

        <!-- Home Button -->
        <a href="index.jsp" class="btn btn-home">
            <i class="fa-solid fa-house"></i> Home
        </a>
    </div>
</div>

</body>
</html>