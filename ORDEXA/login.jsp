<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>

<%@ page import="java.sql.*" %>
<%@ page import="com.queue.DBConnection" %>

<%
    String errorMsg = "";

    // =========================================================
    // LOGIN PROCESS
    // =========================================================

    if ("POST".equalsIgnoreCase(request.getMethod())) {

        String name = request.getParameter("name");
        String phone = request.getParameter("phone");

        // Trim input safely
        name = name != null ? name.trim() : "";
        phone = phone != null ? phone.trim() : "";

        // Validate
        if (name.isEmpty() || phone.isEmpty()) {

            errorMsg = "Please enter both name and phone number.";

        } else {

            String sql =
                    "SELECT user_id, name, phone " +
                            "FROM users " +
                            "WHERE name = ? AND phone = ? " +
                            "LIMIT 1";

            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {

                ps.setString(1, name);
                ps.setString(2, phone);

                try (ResultSet rs = ps.executeQuery()) {

                    if (rs.next()) {

                        // =================================================
                        // LOGIN SUCCESS
                        // =================================================

                        session.setAttribute(
                                "userName",
                                rs.getString("name")
                        );

                        session.setAttribute(
                                "userPhone",
                                rs.getString("phone")
                        );


                        // =================================================
                        // DIRECT HOME PAGE REDIRECT
                        // =================================================

                        response.sendRedirect(
                                request.getContextPath() + "/index.jsp"
                        );

                        return;

                    } else {

                        errorMsg =
                                "Invalid name or phone number. " +
                                        "Please register if you don't have an account.";
                    }
                }

            } catch (Exception e) {

                e.printStackTrace();

                errorMsg =
                        "Database error. Please try again.";
            }
        }
    }
%>


<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Patient Login - ORDEXA</title>

    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">


    <style>

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;

            font-family:
                    'Segoe UI',
                    Tahoma,
                    Geneva,
                    Verdana,
                    sans-serif;
        }


        body {

            background: #0b132b;

            min-height: 100vh;

            display: flex;

            justify-content: center;

            align-items: center;

            padding: 20px;
        }


        .card {

            width: 100%;
            max-width: 400px;

            background: #ffffff;

            padding: 35px 30px;

            border-radius: 16px;

            box-shadow:
                    0 15px 35px rgba(0,0,0,0.35);

            text-align: center;
        }


        .title {

            color: #0284c7;

            font-size: 24px;

            font-weight: 700;

            margin-bottom: 8px;

            display: flex;

            align-items: center;

            justify-content: center;

            gap: 10px;
        }


        .subtitle {

            font-size: 13px;

            color: #64748b;

            margin-bottom: 22px;
        }


        .input-group {

            text-align: left;

            margin-bottom: 18px;
        }


        .input-group label {

            display: block;

            font-size: 14px;

            font-weight: 600;

            color: #1e293b;

            margin-bottom: 6px;
        }


        .input-box {

            display: flex;

            align-items: center;

            border: 1px solid #cbd5e1;

            border-radius: 8px;

            padding: 10px 14px;

            background: #f8fafc;
        }


        .input-box:focus-within {

            border-color: #0284c7;

            box-shadow:
                    0 0 0 2px rgba(2,132,199,0.1);
        }


        .input-box i {

            color: #64748b;

            margin-right: 12px;

            font-size: 16px;
        }


        .input-box input {

            border: none;

            outline: none;

            width: 100%;

            background: transparent;

            font-size: 14px;

            color: #1e293b;
        }


        .submit-btn {

            width: 100%;

            padding: 12px;

            background: #0284c7;

            border: none;

            border-radius: 8px;

            color: #ffffff;

            font-size: 16px;

            font-weight: 600;

            cursor: pointer;

            margin-top: 10px;

            transition: 0.2s;
        }


        .submit-btn:hover {

            background: #0369a1;
        }


        .alert {

            background: #fee2e2;

            color: #b91c1c;

            padding: 10px;

            border-radius: 6px;

            font-size: 13px;

            margin-bottom: 15px;
        }


        .footer-links {

            margin-top: 20px;

            display: flex;

            justify-content: space-between;

            align-items: center;

            gap: 10px;

            border-top: 1px solid #e2e8f0;

            padding-top: 15px;

            font-size: 13px;
        }


        .footer-links a {

            text-decoration: none;
        }


        @media (max-width: 450px) {

            .card {

                padding: 30px 22px;
            }


            .footer-links {

                flex-direction: column;

                gap: 12px;
            }
        }

    </style>

</head>


<body>


<div class="card">


    <!-- =====================================================
         TITLE
         ===================================================== -->

    <div class="title">

        <i class="fa-solid fa-right-to-bracket"></i>

        Patient Login

    </div>


    <p class="subtitle">

        Enter your credentials to access ORDEXA

    </p>


    <!-- =====================================================
         ERROR MESSAGE
         ===================================================== -->

    <% if (!errorMsg.isEmpty()) { %>

    <div class="alert">

        <%= errorMsg %>

    </div>

    <% } %>


    <!-- =====================================================
         LOGIN FORM
         ===================================================== -->

    <form action="login.jsp"
          method="post">


        <div class="input-group">

            <label>
                Full Name
            </label>

            <div class="input-box">

                <i class="fa-solid fa-user"></i>

                <input type="text"
                       name="name"
                       placeholder="John Doe"
                       autocomplete="name"
                       required>

            </div>

        </div>


        <div class="input-group">

            <label>
                Phone Number
            </label>

            <div class="input-box">

                <i class="fa-solid fa-phone"></i>

                <input type="tel"
                       name="phone"
                       placeholder="9876543210"
                       inputmode="numeric"
                       autocomplete="tel"
                       required>

            </div>

        </div>


        <button type="submit"
                class="submit-btn">

            Login

        </button>


    </form>


    <!-- =====================================================
         FOOTER LINKS
         ===================================================== -->

    <div class="footer-links">


        <a href="index.jsp"
           style="color:#64748b;">

            <i class="fa-solid fa-arrow-left"></i>

            Home

        </a>


        <a href="register.jsp"
           style="color:#16a34a;font-weight:600;">

            New user? Register

            <i class="fa-solid fa-arrow-right"></i>

        </a>


    </div>


</div>


</body>

</html>mav