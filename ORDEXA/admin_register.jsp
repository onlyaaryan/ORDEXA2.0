<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ORDEXA - Admin Registration</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #0f172a; display: flex; justify-content: center; align-items: center; min-height: 100vh; }
        .card { background: #ffffff; padding: 40px; border-radius: 12px; width: 100%; max-width: 420px; box-shadow: 0 10px 25px rgba(0, 0, 0, 0.3); text-align: center; }
        .icon-box { font-size: 45px; color: #16a34a; margin-bottom: 15px; }
        h2 { color: #1e293b; font-size: 24px; margin-bottom: 8px; }
        p.subtitle { color: #64748b; font-size: 14px; margin-bottom: 25px; }
        .input-group { text-align: left; margin-bottom: 16px; }
        .input-group label { display: block; font-size: 14px; font-weight: 600; color: #334155; margin-bottom: 6px; }
        .input-box { display: flex; align-items: center; border: 1px solid #cbd5e1; border-radius: 6px; padding: 10px 12px; background-color: #f8fafc; }
        .input-box i { color: #64748b; margin-right: 10px; font-size: 16px; }
        .input-box input { border: none; outline: none; width: 100%; background: transparent; font-size: 14px; color: #1e293b; }
        .btn { width: 100%; padding: 12px; background-color: #16a34a; border: none; border-radius: 6px; color: white; font-size: 16px; font-weight: 600; cursor: pointer; margin-top: 10px; }
        .btn:hover { background-color: #15803d; }
        .links { margin-top: 20px; font-size: 14px; }
        .links a { color: #0284c7; text-decoration: none; font-weight: 600; }
    </style>
</head>
<body>
<div class="card">
    <div class="icon-box"><i class="fa-solid fa-user-plus"></i></div>
    <h2>Create Admin Account</h2>
    <p class="subtitle">Register to manage queues for your hospital</p>

    <form action="AdminRegisterServlet" method="post">
        <div class="input-group">
            <label>Hospital Code</label>
            <div class="input-box">
                <i class="fa-solid fa-building"></i>
                <input type="text" name="hospitalCode" placeholder="e.g. HOSP101" required>
            </div>
        </div>
        <div class="input-group">
            <label>Hospital Full Name</label>
            <div class="input-box">
                <i class="fa-solid fa-hospital"></i>
                <input type="text" name="hospitalName" placeholder="e.g. Apollo Hospital" required>
            </div>
        </div>
        <div class="input-group">
            <label>Username</label>
            <div class="input-box">
                <i class="fa-solid fa-user"></i>
                <input type="text" name="username" placeholder="Choose a username" required>
            </div>
        </div>
        <div class="input-group">
            <label>Password</label>
            <div class="input-box">
                <i class="fa-solid fa-lock"></i>
                <input type="password" name="password" placeholder="Create password" required>
            </div>
        </div>
        <button type="submit" class="btn">Register Admin</button>
    </form>

    <div class="links">
        Already have an account? <a href="admin_login.jsp">Log In</a>
    </div>
</div>
</body>
</html>