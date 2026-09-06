<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>

<%@ page import="com.queue.DBConnection" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="java.util.Map" %>

<%
    // =========================================================
    // LOGOUT
    // =========================================================

    if ("logout".equals(request.getParameter("action"))) {
        session.invalidate();
        response.sendRedirect("index.jsp");
        return;
    }


    // =========================================================
    // USER SESSION
    // =========================================================

    String loggedInUser = (String) session.getAttribute("userName");
    String userPhone = (String) session.getAttribute("userPhone");

    boolean isLoggedIn =
            loggedInUser != null &&
                    !loggedInUser.trim().isEmpty();


    // =========================================================
    // ADMIN SESSION
    // =========================================================

    String adminUser = (String) session.getAttribute("adminUser");
    String adminHospitalName =
            (String) session.getAttribute("adminHospitalName");
    String adminHospitalCode =
            (String) session.getAttribute("hospitalCode");

    boolean isAdminLoggedIn =
            adminUser != null &&
                    !adminUser.trim().isEmpty();


    // =========================================================
    // HOSPITAL LIST
    // =========================================================

    Map<String, String> hospitalMap =
            new LinkedHashMap<String, String>();

    String hospitalQuery =
            "SELECT hospital_code, hospital_name " +
                    "FROM admin " +
                    "WHERE hospital_code IS NOT NULL " +
                    "AND TRIM(hospital_code) <> '' " +
                    "GROUP BY hospital_code, hospital_name " +
                    "ORDER BY hospital_name ASC";

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(hospitalQuery);
         ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {

            String code = rs.getString("hospital_code");
            String name = rs.getString("hospital_name");

            if (code != null && !code.trim().isEmpty()) {

                if (name == null || name.trim().isEmpty()) {
                    name = code;
                }

                hospitalMap.put(code.trim(), name.trim());
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
    }


    // =========================================================
    // ACTIVE QUEUE VARIABLES
    // =========================================================

    String activeToken = null;
    String activeHospital = null;
    String activeHospitalName = null;
    String activeDepartment = null;
    String activeDoctor = null;
    String activeStatus = null;

    int activeTokenId = 0;
    int peopleAhead = 0;
    int estimatedWait = 0;


    // =========================================================
    // GET USER'S ACTIVE QUEUE
    // =========================================================

    if (isLoggedIn &&
            userPhone != null &&
            !userPhone.trim().isEmpty()) {

        String activeQueueQuery =
                "SELECT t.token_id, " +
                        "t.token_number, " +
                        "t.hospital_code, " +
                        "t.department, " +
                        "t.doctor_name, " +
                        "t.status, " +
                        "a.hospital_name " +
                        "FROM tokens t " +
                        "JOIN users u ON t.user_id = u.user_id " +
                        "LEFT JOIN admin a " +
                        "ON t.hospital_code = a.hospital_code " +
                        "WHERE u.phone = ? " +
                        "AND t.status IN ('WAITING','SERVING') " +
                        "ORDER BY t.token_id DESC " +
                        "LIMIT 1";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps =
                     con.prepareStatement(activeQueueQuery)) {

            ps.setString(1, userPhone.trim());

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {

                    activeTokenId =
                            rs.getInt("token_id");

                    activeToken =
                            rs.getString("token_number");

                    activeHospital =
                            rs.getString("hospital_code");

                    activeHospitalName =
                            rs.getString("hospital_name");

                    activeDepartment =
                            rs.getString("department");

                    activeDoctor =
                            rs.getString("doctor_name");

                    activeStatus =
                            rs.getString("status");


                    // =================================================
                    // PEOPLE AHEAD
                    // =================================================

                    if ("WAITING".equals(activeStatus)) {

                        String aheadQuery =
                                "SELECT COUNT(*) " +
                                        "FROM tokens " +
                                        "WHERE hospital_code = ? " +
                                        "AND status = 'WAITING' " +
                                        "AND token_id < ? " +
                                        "AND (department = ? OR " +
                                        "(department IS NULL AND ? IS NULL)) " +
                                        "AND (doctor_name = ? OR " +
                                        "(doctor_name IS NULL AND ? IS NULL))";

                        try (PreparedStatement aps =
                                     con.prepareStatement(aheadQuery)) {

                            aps.setString(1, activeHospital);
                            aps.setInt(2, activeTokenId);
                            aps.setString(3, activeDepartment);
                            aps.setString(4, activeDepartment);
                            aps.setString(5, activeDoctor);
                            aps.setString(6, activeDoctor);

                            try (ResultSet ars =
                                         aps.executeQuery()) {

                                if (ars.next()) {
                                    peopleAhead =
                                            ars.getInt(1);
                                }
                            }
                        }


                        // =============================================
                        // ESTIMATED WAIT
                        // =============================================

                        estimatedWait = peopleAhead * 5;
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>


<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>ORDEXA - Queue Management System</title>

    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">


    <style>

        /* =====================================================
           GLOBAL
           ===================================================== */

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
            flex-direction: column;
            align-items: center;

            padding: 30px 20px;
        }


        /* =====================================================
           TOP NAVBAR
           ===================================================== */

        .top-navbar {
            width: 100%;
            max-width: 1050px;

            display: flex;
            justify-content: flex-start;
            align-items: center;

            margin-bottom: 15px;
        }


        .user-status {
            display: inline-flex;
            align-items: center;
            gap: 12px;

            background: #1c2541;
            border: 1px solid #334155;

            padding: 8px 16px;
            border-radius: 8px;

            color: #cbd5e1;
            font-size: 14px;
        }


        .user-status strong {
            color: #38bdf8;
        }


        .logout-btn {
            background: #ef4444;
            color: white;

            padding: 6px 14px;
            border-radius: 6px;

            text-decoration: none;
            font-size: 13px;
            font-weight: 600;

            display: inline-flex;
            align-items: center;
            gap: 6px;

            transition: 0.2s;
        }


        .logout-btn:hover {
            background: #dc2626;
        }


        /* =====================================================
           MAIN CARD
           ===================================================== */

        .main-card {
            width: 100%;
            max-width: 1050px;

            background: #1c2541;

            border-radius: 20px;
            padding: 40px 35px;

            border: 1px solid rgba(255,255,255,0.05);

            box-shadow:
                    0 20px 40px rgba(0,0,0,0.4);

            text-align: center;
        }


        /* =====================================================
           HEADER
           ===================================================== */

        .header h1 {
            color: white;

            font-size: 32px;
            font-weight: 700;

            margin-bottom: 8px;

            display: flex;
            justify-content: center;
            align-items: center;

            gap: 12px;
        }


        .header h1 i {
            color: #38bdf8;
        }


        .header p {
            color: #94a3b8;
            font-size: 15px;

            margin-bottom: 30px;
        }


        /* =====================================================
           DASHBOARD
           ===================================================== */

        .dashboard-layout {
            display: grid;

            grid-template-columns:
                minmax(0, 1fr) 300px;

            gap: 22px;

            align-items: start;
            text-align: left;
        }


        .main-content {
            min-width: 0;
        }


        /* =====================================================
           LIVE QUEUE
           ===================================================== */

        .live-bar {
            background: #0b132b;

            border: 1px solid #3b82f6;
            border-radius: 12px;

            padding: 16px 20px;

            display: flex;
            justify-content: center;
            align-items: center;

            gap: 15px;
            flex-wrap: wrap;

            margin-bottom: 25px;
        }


        .live-bar label {
            color: #f8fafc;

            font-weight: 600;
            font-size: 15px;

            display: flex;
            align-items: center;
            gap: 8px;
        }


        .live-bar select {
            padding: 10px 16px;

            background: #1c2541;
            color: white;

            border: 1px solid #475569;
            border-radius: 8px;

            font-size: 14px;

            outline: none;

            min-width: 250px;
            cursor: pointer;
        }


        .live-bar button {
            padding: 10px 20px;

            background: #0284c7;
            color: white;

            border: none;
            border-radius: 8px;

            font-weight: 600;
            cursor: pointer;

            display: flex;
            align-items: center;
            gap: 8px;

            transition: 0.2s;
        }


        .live-bar button:hover {
            background: #0369a1;
        }


        /* =====================================================
           PORTAL GRID
           ===================================================== */

        .grid-container {
            display: grid;

            grid-template-columns:
                repeat(auto-fit, minmax(180px, 1fr));

            gap: 20px;
        }


        .portal-card {
            background: white;

            border-radius: 14px;
            padding: 30px 20px;

            text-decoration: none;
            color: #1e293b;

            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;

            text-align: center;

            box-shadow:
                    0 10px 20px rgba(0,0,0,0.15);

            transition:
                    transform 0.25s ease,
                    box-shadow 0.25s ease;
        }


        .portal-card:hover {
            transform: translateY(-6px);

            box-shadow:
                    0 15px 30px rgba(0,0,0,0.25);
        }


        .icon-box {
            font-size: 34px;
            color: #0284c7;

            margin-bottom: 16px;
        }


        .portal-card h3 {
            color: #0f172a;

            font-size: 18px;
            font-weight: 700;

            margin-bottom: 8px;
        }


        .portal-card p {
            color: #64748b;

            font-size: 13px;
            line-height: 1.4;
        }


        /* =====================================================
           ACTIVE QUEUE
           ===================================================== */

        .active-queue-card {
            background: #0b132b;

            border: 1px solid #334155;
            border-radius: 16px;

            padding: 22px;

            box-shadow:
                    0 10px 25px rgba(0,0,0,0.2);
        }


        .queue-card-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;

            gap: 10px;

            margin-bottom: 22px;
        }


        .queue-label {
            color: #38bdf8;

            font-size: 11px;
            font-weight: 700;

            letter-spacing: 1px;
        }


        .queue-card-header h2 {
            color: white;

            font-size: 27px;

            margin-top: 6px;
        }


        /* =====================================================
           STATUS
           ===================================================== */

        .status-badge {
            padding: 5px 9px;

            border-radius: 20px;

            font-size: 10px;
            font-weight: 700;
        }


        .status-badge.waiting {
            background: #422006;
            color: #fbbf24;
        }


        .status-badge.serving {
            background: #052e16;
            color: #4ade80;
        }


        /* =====================================================
           QUEUE INFO
           ===================================================== */

        .queue-info {
            display: flex;
            flex-direction: column;

            gap: 15px;

            margin-bottom: 20px;
        }


        .info-row {
            display: flex;
            align-items: center;

            gap: 12px;
        }


        .info-row > i {
            color: #38bdf8;

            width: 18px;

            text-align: center;
        }


        .info-row div {
            display: flex;
            flex-direction: column;

            gap: 2px;

            min-width: 0;
        }


        .info-row small {
            color: #64748b;
            font-size: 11px;
        }


        .info-row strong {
            color: #e2e8f0;

            font-size: 13px;

            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }


        /* =====================================================
           QUEUE STATS
           ===================================================== */

        .queue-stats {
            display: grid;

            grid-template-columns: 1fr 1fr;

            gap: 10px;

            margin-bottom: 18px;
        }


        .stat-box {
            background: #1c2541;

            border-radius: 10px;

            padding: 13px 8px;

            text-align: center;
        }


        .stat-box i {
            color: #38bdf8;

            display: block;

            margin-bottom: 7px;
        }


        .stat-box strong {
            display: block;

            color: white;

            font-size: 16px;
        }


        .stat-box span {
            display: block;

            color: #64748b;

            font-size: 10px;

            margin-top: 3px;
        }


        /* =====================================================
           SERVING
           ===================================================== */

        .serving-message {
            background: #052e16;

            border: 1px solid #166534;

            color: #86efac;

            padding: 13px;

            border-radius: 10px;

            font-size: 12px;

            text-align: center;

            margin-bottom: 18px;
        }


        /* =====================================================
           VIEW QUEUE BUTTON
           ===================================================== */

        .view-queue-btn {
            display: flex;

            justify-content: center;
            align-items: center;

            gap: 8px;

            width: 100%;

            padding: 11px;

            background: #0284c7;
            color: white;

            border-radius: 8px;

            text-decoration: none;

            font-size: 13px;
            font-weight: 600;

            transition: 0.2s;
        }


        .view-queue-btn:hover {
            background: #0369a1;
        }


        /* =====================================================
           MOBILE
           ===================================================== */

        @media (max-width: 850px) {

            .dashboard-layout {
                grid-template-columns: 1fr;
            }

            .active-queue-card {
                order: -1;
            }
        }


        @media (max-width: 600px) {

            body {
                padding: 20px 12px;
            }

            .main-card {
                padding: 30px 20px;
            }

            .header h1 {
                font-size: 25px;
            }

            .live-bar select {
                width: 100%;
                min-width: 0;
            }

            .live-bar button {
                width: 100%;
                justify-content: center;
            }

            .user-status {
                flex-wrap: wrap;
            }

            .grid-container {
                grid-template-columns: 1fr;
            }
        }

    </style>

</head>


<body>


<!-- =========================================================
     USER / ADMIN STATUS
     ========================================================= -->

<% if (isAdminLoggedIn) { %>

<div class="top-navbar">

    <div class="user-status"
         style="border-color:#16a34a;">

        <span>

            <i class="fa-solid fa-user-shield"
               style="color:#22c55e;"></i>

            Admin:

            <strong>
                <%= adminUser %>
            </strong>

            <% if (adminHospitalName != null &&
                    !adminHospitalName.trim().isEmpty()) { %>

                (<%= adminHospitalName %>)

            <% } %>

        </span>


        <a href="counter.jsp"
           class="logout-btn"
           style="background:#0284c7;">

            Dashboard

        </a>


        <a href="index.jsp?action=logout"
           class="logout-btn">

            <i class="fa-solid fa-arrow-right-from-bracket"></i>

            Logout

        </a>

    </div>

</div>


<% } else if (isLoggedIn) { %>

<div class="top-navbar">

    <div class="user-status">

        <span>

            <i class="fa-solid fa-circle-user"></i>

            Active:

            <strong>
                <%= loggedInUser %>
            </strong>

        </span>


        <a href="index.jsp?action=logout"
           class="logout-btn">

            <i class="fa-solid fa-arrow-right-from-bracket"></i>

            Logout

        </a>

    </div>

</div>

<% } %>


<!-- =========================================================
     MAIN CARD
     ========================================================= -->

<div class="main-card">


    <!-- HEADER -->

    <div class="header">

        <h1>

            <i class="fa-solid fa-users-gear"></i>

            ORDEXA Queue System

        </h1>

        <p>
            Fast, seamless, and efficient digital queue control.
        </p>

    </div>


    <!-- =====================================================
         LOGGED-IN USER WITH ACTIVE QUEUE
         ===================================================== -->

    <% if (isLoggedIn && activeToken != null) { %>

    <div class="dashboard-layout">


        <div class="main-content">

            <% } %>


            <!-- =================================================
                 LIVE QUEUE
                 ================================================= -->

            <form action="view_queue.jsp"
                  method="get"
                  class="live-bar">

                <label for="directHospSelect">

                    <i class="fa-solid fa-tower-broadcast"
                       style="color:#38bdf8;"></i>

                    Check Live Queue:

                </label>


                <select name="hospitalCode"
                        id="directHospSelect"
                        required>

                    <option value="">
                        -- Select Hospital Code --
                    </option>


                    <% for (Map.Entry<String, String> entry
                            : hospitalMap.entrySet()) { %>

                    <option value="<%= entry.getKey() %>">

                        <%= entry.getKey() %>
                        -
                        <%= entry.getValue() %>

                    </option>

                    <% } %>

                </select>


                <button type="submit">

                    <i class="fa-solid fa-eye"></i>

                    View Status

                </button>

            </form>


            <!-- =================================================
                 PORTAL CARDS
                 ================================================= -->

            <div class="grid-container">


                <!-- REGISTER USER -->

                <% if (!isLoggedIn && !isAdminLoggedIn) { %>

                <a href="register.jsp"
                   class="portal-card">

                    <div class="icon-box">

                        <i class="fa-solid fa-user-plus"></i>

                    </div>

                    <h3>
                        Register User
                    </h3>

                    <p>
                        One-time user profile registration.
                    </p>

                </a>

                <% } %>


                <!-- USE SERVICE -->

                <a href="use_service.jsp"
                   class="portal-card">

                    <div class="icon-box">

                        <i class="fa-solid fa-ticket"></i>

                    </div>

                    <h3>
                        Use Service
                    </h3>

                    <p>
                        Select hospital and book a queue token.
                    </p>

                </a>


                <!-- ADMIN -->

                <a href="<%= isAdminLoggedIn
                        ? "counter.jsp"
                        : "admin_login.jsp" %>"
                   class="portal-card">

                    <div class="icon-box"
                         style="color:<%= isAdminLoggedIn
                                ? "#16a34a"
                                : "#0284c7" %>">

                        <i class="fa-solid fa-<%= isAdminLoggedIn
                                ? "gauge-high"
                                : "user-shield" %>"></i>

                    </div>


                    <h3>

                        <%= isAdminLoggedIn
                                ? "Admin Dashboard"
                                : "Admin Counter" %>

                    </h3>


                    <p>

                        <%= isAdminLoggedIn
                                ? "Return to active management panel."
                                : "Call next tokens and manage waiting lines." %>

                    </p>

                </a>

            </div>


            <% if (isLoggedIn && activeToken != null) { %>

        </div>


        <!-- =================================================
             MY ACTIVE QUEUE
             ================================================= -->

        <div class="active-queue-card">


            <div class="queue-card-header">

                <div>

                    <span class="queue-label">

                        <i class="fa-solid fa-ticket"></i>

                        MY ACTIVE QUEUE

                    </span>


                    <h2>
                        <%= activeToken %>
                    </h2>

                </div>


                <span class="status-badge
                    <%= "SERVING".equals(activeStatus)
                            ? "serving"
                            : "waiting" %>">

                    <%= activeStatus %>

                </span>

            </div>


            <!-- QUEUE INFORMATION -->

            <div class="queue-info">


                <div class="info-row">

                    <i class="fa-solid fa-hospital"></i>

                    <div>

                        <small>
                            Hospital
                        </small>

                        <strong>

                            <%= activeHospitalName != null &&
                                    !activeHospitalName.trim().isEmpty()
                                    ? activeHospitalName
                                    : activeHospital %>

                        </strong>

                    </div>

                </div>


                <div class="info-row">

                    <i class="fa-solid fa-building"></i>

                    <div>

                        <small>
                            Department
                        </small>

                        <strong>

                            <%= activeDepartment != null &&
                                    !activeDepartment.trim().isEmpty()
                                    ? activeDepartment
                                    : "N/A" %>

                        </strong>

                    </div>

                </div>


                <div class="info-row">

                    <i class="fa-solid fa-user-doctor"></i>

                    <div>

                        <small>
                            Doctor
                        </small>

                        <strong>

                            <%= activeDoctor != null &&
                                    !activeDoctor.trim().isEmpty()
                                    ? activeDoctor
                                    : "N/A" %>

                        </strong>

                    </div>

                </div>

            </div>


            <!-- WAITING -->

            <% if ("WAITING".equals(activeStatus)) { %>

            <div class="queue-stats">


                <div class="stat-box">

                    <i class="fa-solid fa-users"></i>

                    <strong>
                        <%= peopleAhead %>
                    </strong>

                    <span>
                        People Ahead
                    </span>

                </div>


                <div class="stat-box">

                    <i class="fa-solid fa-clock"></i>

                    <strong>
                        <%= estimatedWait %> min
                    </strong>

                    <span>
                        Est. Wait
                    </span>

                </div>


            </div>

            <% } %>


            <!-- SERVING -->

            <% if ("SERVING".equals(activeStatus)) { %>

            <div class="serving-message">

                <i class="fa-solid fa-bullhorn"></i>

                Your token is being served now!

            </div>

            <% } %>


            <!-- VIEW QUEUE -->

            <a href="view_queue.jsp?hospitalCode=<%= activeHospital %>&token=<%= activeToken %>"
               class="view-queue-btn">

                <i class="fa-solid fa-eye"></i>

                View My Queue

            </a>


        </div>


    </div>

    <% } %>


</div>


</body>

</html>