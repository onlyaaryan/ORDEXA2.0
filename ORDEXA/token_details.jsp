<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String tokenNum = request.getParameter("tokenNum");
    String name = request.getParameter("name");
    String hospitalCode = request.getParameter("hospitalCode");
    String hospitalName = request.getParameter("hospitalName");

    if (tokenNum == null || hospitalCode == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    if (hospitalName == null || hospitalName.trim().isEmpty()) {
        hospitalName = hospitalCode;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Your Token Receipt - ORDEXA</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #0b132b; min-height: 100vh; display: flex; justify-content: center; align-items: center; padding: 20px; }
        .receipt-card { background: #ffffff; padding: 35px 30px; border-radius: 18px; width: 100%; max-width: 400px; text-align: center; box-shadow: 0 15px 35px rgba(0,0,0,0.35); }
        .success-icon { font-size: 50px; color: #16a34a; margin-bottom: 12px; }
        .receipt-title { font-size: 20px; font-weight: 700; color: #0f172a; margin-bottom: 4px; }
        .hospital-badge { display: inline-block; background: #e0f2fe; color: #0284c7; padding: 5px 12px; border-radius: 20px; font-size: 13px; font-weight: 600; margin-bottom: 20px; }
        .token-circle { background: #f8fafc; border: 2px dashed #0284c7; border-radius: 14px; padding: 20px; margin-bottom: 20px; }
        .token-num { font-size: 42px; font-weight: 800; color: #0284c7; }
        .patient-label { font-size: 15px; color: #334155; font-weight: 600; margin-top: 5px; }
        .btn-group { display: flex; flex-direction: column; gap: 10px; margin-top: 15px; }
        .btn { padding: 12px; border-radius: 8px; font-size: 15px; font-weight: 600; text-decoration: none; display: flex; align-items: center; justify-content: center; gap: 8px; transition: 0.2s; }
        .btn-live { background: #0284c7; color: white; }
        .btn-live:hover { background: #0369a1; }
        .btn-home { background: #f1f5f9; color: #334155; border: 1px solid #cbd5e1; }
        .btn-home:hover { background: #e2e8f0; }
    </style>
</head>
<body>

<div class="receipt-card">
    <div class="success-icon"><i class="fa-solid fa-circle-check"></i></div>
    <div class="receipt-title">Token Confirmed!</div>
    <div class="hospital-badge"><i class="fa-solid fa-hospital"></i> <%= hospitalName %> (<%= hospitalCode %>)</div>

    <div class="token-circle">
        <div class="token-num">#<%= tokenNum %></div>
        <div class="patient-label"><i class="fa-solid fa-user"></i> <%= (name != null) ? name : "Patient" %></div>
    </div>

    <div class="btn-group">
        <a href="view_queue.jsp?hospitalCode=<%= hospitalCode %>" class="btn btn-live">
            <i class="fa-solid fa-tower-broadcast"></i> View Live Status
        </a>
        <a href="index.jsp" class="btn btn-home">
            <i class="fa-solid fa-house"></i> Back to Home
        </a>
    </div>
</div>

</body>
</html>