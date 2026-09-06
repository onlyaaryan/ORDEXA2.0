<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>

<%@ page import="com.queue.DBConnection" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.URLEncoder" %>

<%
    // =========================================================
    // SESSION CHECK
    // =========================================================

    String adminUser =
            (String) session.getAttribute("adminUser");

    String hospitalCode =
            (String) session.getAttribute("hospitalCode");

    String hospitalName =
            (String) session.getAttribute("hospitalName");

    if (adminUser == null ||
            hospitalCode == null ||
            hospitalCode.trim().isEmpty()) {

        response.sendRedirect(
                "admin_login.jsp?error=unauthorized"
        );

        return;
    }

    hospitalCode = hospitalCode.trim();

    if (hospitalName == null ||
            hospitalName.trim().isEmpty()) {

        hospitalName = "Hospital";
    }


    // =========================================================
    // DOCTOR FILTER
    // =========================================================

    String selectedDoctor =
            request.getParameter("doctorFilter");

    if (selectedDoctor == null) {
        selectedDoctor = "";
    }

    selectedDoctor = selectedDoctor.trim();


    // =========================================================
    // DATABASE ACTIONS
    // =========================================================

    String action =
            request.getParameter("action");

    String tokenIdStr =
            request.getParameter("tokenId");


    if (action != null &&
            tokenIdStr != null) {

        try {

            int tokenId =
                    Integer.parseInt(tokenIdStr);


            // =================================================
            // SERVE
            // =================================================

            if ("serve".equalsIgnoreCase(action)) {

                String resetSql =
                        "UPDATE tokens " +
                                "SET status = 'COMPLETED' " +
                                "WHERE hospital_code = ? " +
                                "AND status = 'SERVING'";

                String serveSql =
                        "UPDATE tokens " +
                                "SET status = 'SERVING' " +
                                "WHERE token_id = ? " +
                                "AND hospital_code = ?";

                try (Connection actionCon =
                             DBConnection.getConnection()) {

                    try (PreparedStatement ps =
                                 actionCon.prepareStatement(resetSql)) {

                        ps.setString(1, hospitalCode);
                        ps.executeUpdate();
                    }

                    try (PreparedStatement ps =
                                 actionCon.prepareStatement(serveSql)) {

                        ps.setInt(1, tokenId);
                        ps.setString(2, hospitalCode);

                        ps.executeUpdate();
                    }
                }


                String redirect =
                        "counter.jsp";

                if (!selectedDoctor.isEmpty()) {

                    redirect +=
                            "?doctorFilter=" +
                                    URLEncoder.encode(
                                            selectedDoctor,
                                            "UTF-8"
                                    );
                }

                response.sendRedirect(redirect);
                return;
            }


            // =================================================
            // COMPLETE
            // =================================================

            if ("complete".equalsIgnoreCase(action)) {

                String sql =
                        "UPDATE tokens " +
                                "SET status = 'COMPLETED' " +
                                "WHERE token_id = ? " +
                                "AND hospital_code = ?";

                try (Connection actionCon =
                             DBConnection.getConnection();
                     PreparedStatement ps =
                             actionCon.prepareStatement(sql)) {

                    ps.setInt(1, tokenId);
                    ps.setString(2, hospitalCode);

                    ps.executeUpdate();
                }


                String redirect =
                        "counter.jsp";

                if (!selectedDoctor.isEmpty()) {

                    redirect +=
                            "?doctorFilter=" +
                                    URLEncoder.encode(
                                            selectedDoctor,
                                            "UTF-8"
                                    );
                }

                response.sendRedirect(redirect);
                return;
            }

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                    "counter.jsp?error=database"
            );

            return;
        }
    }


    // =========================================================
    // CURRENT SERVING
    // =========================================================

    String currentServingToken = "None";
    String currentServingUser = "N/A";
    String currentDept = "-";
    String currentDoc = "-";

    int servingTokenId = -1;


    // =========================================================
    // DATABASE CONNECTION
    // =========================================================

    try (Connection con =
                 DBConnection.getConnection()) {

        if (con == null) {
            throw new Exception(
                    "Database connection failed."
            );
        }


        // =====================================================
        // CURRENT SERVING
        // =====================================================

        String currentSql =
                "SELECT " +
                        "t.token_id, " +
                        "t.token_number, " +
                        "t.department, " +
                        "t.doctor_name, " +
                        "u.name AS user_name " +
                        "FROM tokens t " +
                        "JOIN users u " +
                        "ON t.user_id = u.user_id " +
                        "WHERE t.hospital_code = ? " +
                        "AND t.status = 'SERVING' ";

        if (!selectedDoctor.isEmpty()) {

            currentSql +=
                    "AND t.doctor_name = ? ";
        }

        currentSql +=
                "ORDER BY t.token_id DESC LIMIT 1";


        try (PreparedStatement ps =
                     con.prepareStatement(currentSql)) {

            ps.setString(1, hospitalCode);

            if (!selectedDoctor.isEmpty()) {

                ps.setString(
                        2,
                        selectedDoctor
                );
            }

            try (ResultSet rs =
                         ps.executeQuery()) {

                if (rs.next()) {

                    currentServingToken =
                            rs.getString(
                                    "token_number"
                            );

                    currentServingUser =
                            rs.getString(
                                    "user_name"
                            );

                    currentDept =
                            rs.getString(
                                    "department"
                            );

                    currentDoc =
                            rs.getString(
                                    "doctor_name"
                            );

                    servingTokenId =
                            rs.getInt(
                                    "token_id"
                            );
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

    <title>ORDEXA - Admin Counter Panel</title>

    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI',
            Tahoma,
            Geneva,
            Verdana,
            sans-serif;
        }

        body {
            background-color: #0b132b;
            color: #f8fafc;
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            width: 100%;
            max-width: 1100px;
            margin: auto;
        }

        .navbar {
            background: #1c2541;
            padding: 15px 25px;
            border-radius: 12px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            border: 1px solid #334155;
            flex-wrap: wrap;
            gap: 15px;
        }

        .navbar h2 {
            font-size: 20px;
            color: #38bdf8;
        }

        .nav-links {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .nav-links a {
            color: white;
            padding: 8px 14px;
            border-radius: 6px;
            text-decoration: none;
            font-size: 14px;
            font-weight: 600;
        }

        .btn-manage {
            background: #0ea5e9;
        }

        .btn-home {
            background: #334155;
        }

        .btn-logout {
            background: #ef4444;
        }

        .filter-bar {
            background: #1c2541;
            padding: 15px 25px;
            border-radius: 12px;
            margin-bottom: 20px;
            border: 1px solid #334155;
            display: flex;
            align-items: center;
            gap: 15px;
            flex-wrap: wrap;
        }

        .filter-bar select {
            padding: 9px 12px;
            background: #0b132b;
            color: white;
            border: 1px solid #475569;
            border-radius: 6px;
            min-width: 220px;
        }

        .dashboard-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        .card {
            background: #1c2541;
            padding: 25px;
            border-radius: 14px;
            border: 1px solid #334155;
            box-shadow: 0 10px 20px rgba(0,0,0,0.3);
        }

        .card h3 {
            font-size: 18px;
            margin-bottom: 15px;
            color: #94a3b8;
            border-bottom: 1px solid #334155;
            padding-bottom: 10px;
        }

        .current-token-display {
            text-align: center;
            padding: 15px 0;
        }

        .token-number {
            font-size: 50px;
            font-weight: 800;
            color: #22c55e;
        }

        .user-info {
            font-size: 15px;
            color: #cbd5e1;
            margin: 15px 0;
            line-height: 1.6;
        }

        .action-buttons {
            display: flex;
            gap: 10px;
            justify-content: center;
        }

        .action-btn {
            padding: 10px 18px;
            border-radius: 6px;
            border: none;
            font-weight: 600;
            text-decoration: none;
            color: white;
            font-size: 14px;
        }

        .btn-complete {
            background: #16a34a;
        }

        .queue-wrapper {
            max-height: 450px;
            overflow-y: auto;
        }

        .queue-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }

        .queue-table th,
        .queue-table td {
            padding: 10px;
            text-align: left;
            border-bottom: 1px solid #334155;
            font-size: 13px;
        }

        .queue-table th {
            color: #94a3b8;
        }

        .badge {
            background: #eab308;
            color: #0f172a;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 700;
        }

        .btn-call {
            background: #0284c7;
            color: white;
            padding: 6px 12px;
            border-radius: 6px;
            text-decoration: none;
            font-size: 12px;
            font-weight: 600;
        }

        .delay-text {
            color: #fbbf24;
            font-size: 12px;
            font-weight: 700;
            margin-top: 4px;
        }

        .delay-controls {
            display: flex;
            gap: 5px;
            flex-wrap: wrap;
            margin-top: 6px;
        }

        .delay-btn {
            border: 1px solid #475569;
            background: #0f172a;
            color: #fca311;
            border-radius: 5px;
            padding: 5px 7px;
            font-size: 11px;
            font-weight: 700;
            cursor: pointer;
        }

        .delay-btn:hover {
            background: #fca311;
            color: #0b132b;
        }

        .empty {
            text-align: center;
            color: #64748b;
            padding: 25px;
        }

        .error {
            background: #7f1d1d;
            border: 1px solid #ef4444;
            color: white;
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 20px;
        }

        @media(max-width:768px) {

            .dashboard-grid {
                grid-template-columns: 1fr;
            }

            .navbar {
                align-items: flex-start;
            }
        }

    </style>

</head>

<body>

<div class="container">

    <!-- =====================================================
         NAVBAR
         ===================================================== -->

    <div class="navbar">

        <h2>
            <i class="fa-solid fa-hospital-user"></i>

            <%= hospitalName %>
            (<%= hospitalCode %>)
        </h2>

        <div class="nav-links">

            <a href="manage_doctors.jsp"
               class="btn-manage">

                <i class="fa-solid fa-stethoscope"></i>
                Manage Wards & Doctors

            </a>

            <a href="index.jsp"
               class="btn-home">

                <i class="fa-solid fa-house"></i>
                Home

            </a>

            <a href="logout.jsp"
               class="btn-logout">

                <i class="fa-solid fa-power-off"></i>
                Logout

            </a>

        </div>

    </div>


    <!-- =====================================================
         ERROR
         ===================================================== -->

    <%
        String pageError =
                request.getParameter("error");

        if (pageError != null) {
    %>

    <div class="error">

        <%
            if ("database".equals(pageError)) {
                out.print("Database error occurred.");
            }
            else if ("invalid_token".equals(pageError)) {
                out.print("Invalid token.");
            }
            else if ("token_not_found".equals(pageError)) {
                out.print("Token not found.");
            }
            else if ("invalid_delay".equals(pageError)) {
                out.print("Invalid delay value.");
            }
            else {
                out.print("An error occurred.");
            }
        %>

    </div>

    <%
        }
    %>


    <!-- =====================================================
         DOCTOR FILTER
         ===================================================== -->

    <form method="get"
          action="counter.jsp"
          class="filter-bar">

        <label>
            <i class="fa-solid fa-filter"></i>
            Filter by Doctor:
        </label>

        <select name="doctorFilter"
                onchange="this.form.submit()">

            <option value="">
                -- All Doctors --
            </option>

            <%
                String doctorSql =
                        "SELECT DISTINCT doctor_name " +
                                "FROM hospital_doctors " +
                                "WHERE hospital_code = ? " +
                                "AND doctor_name IS NOT NULL " +
                                "AND doctor_name <> '' " +
                                "ORDER BY doctor_name";

                try (PreparedStatement psDoctor =
                             con.prepareStatement(doctorSql)) {

                    psDoctor.setString(1, hospitalCode);

                    try (ResultSet rsDoctor =
                                 psDoctor.executeQuery()) {

                        while (rsDoctor.next()) {

                            String doctorName =
                                    rsDoctor.getString(
                                            "doctor_name"
                                    );

                            if (doctorName == null) {
                                continue;
                            }

                            doctorName =
                                    doctorName.trim();
            %>

            <option value="<%= doctorName %>"
                    <%= doctorName.equals(
                            selectedDoctor)
                            ? "selected"
                            : "" %>>

                <%= doctorName %>

            </option>

            <%
                        }
                    }

                } catch (Exception e) {

                    e.printStackTrace();
                }
            %>

        </select>

    </form>


    <!-- =====================================================
         DASHBOARD
         ===================================================== -->

    <div class="dashboard-grid">


        <!-- =====================================================
             CURRENT SERVING
             ===================================================== -->

        <div class="card">

            <h3>
                <i class="fa-solid fa-bullhorn"></i>
                Currently Serving
            </h3>

            <div class="current-token-display">

                <div class="token-number">
                    <%= currentServingToken %>
                </div>

                <div class="user-info">

                    Patient:
                    <strong>
                        <%= currentServingUser %>
                    </strong>

                    <br>

                    Department:
                    <strong>
                        <%= currentDept %>
                    </strong>

                    <br>

                    Doctor:
                    <strong>
                        <%= currentDoc %>
                    </strong>

                </div>

                <%
                    if (servingTokenId != -1) {
                %>

                <div class="action-buttons">

                    <a href="counter.jsp?action=complete&tokenId=<%= servingTokenId %><%= selectedDoctor.isEmpty() ? "" : "&doctorFilter=" + URLEncoder.encode(selectedDoctor,"UTF-8") %>"
                       class="action-btn btn-complete">

                        <i class="fa-solid fa-check"></i>
                        Complete

                    </a>

                </div>

                <%
                } else {
                %>

                <p style="color:#64748b;">
                    No active token being served.
                </p>

                <%
                    }
                %>

            </div>

        </div>


        <!-- =====================================================
             WAITING QUEUE
             ===================================================== -->

        <div class="card">

            <h3>
                <i class="fa-solid fa-list-ol"></i>
                Waiting Queue
            </h3>

            <div class="queue-wrapper">

                <table class="queue-table">

                    <thead>

                    <tr>

                        <th>Token</th>
                        <th>Patient</th>
                        <th>Doctor / Dept</th>
                        <th>Delay</th>
                        <th>Action</th>

                    </tr>

                    </thead>

                    <tbody>

                    <%
                        String waitSql =
                                "SELECT " +
                                        "t.token_id, " +
                                        "t.token_number, " +
                                        "t.department, " +
                                        "t.doctor_name, " +
                                        "t.delay_minutes, " +
                                        "u.name AS user_name " +

                                        "FROM tokens t " +

                                        "JOIN users u " +
                                        "ON t.user_id = u.user_id " +

                                        "WHERE t.hospital_code = ? " +
                                        "AND t.status = 'WAITING' ";

                        if (!selectedDoctor.isEmpty()) {

                            waitSql +=
                                    "AND t.doctor_name = ? ";
                        }

                        waitSql +=

                                "ORDER BY " +

                                        "DATE_ADD(" +
                                        "t.created_at, " +
                                        "INTERVAL COALESCE(" +
                                        "t.delay_minutes,0) MINUTE" +
                                        ") ASC, " +

                                        "t.token_id ASC";


                        try (PreparedStatement psWaiting =
                                     con.prepareStatement(waitSql)) {

                            psWaiting.setString(
                                    1,
                                    hospitalCode
                            );

                            if (!selectedDoctor.isEmpty()) {

                                psWaiting.setString(
                                        2,
                                        selectedDoctor
                                );
                            }

                            try (ResultSet rs =
                                         psWaiting.executeQuery()) {

                                boolean hasWaiting = false;

                                while (rs.next()) {

                                    hasWaiting = true;

                                    int tokenId =
                                            rs.getInt(
                                                    "token_id"
                                            );

                                    String tokenNumber =
                                            rs.getString(
                                                    "token_number"
                                            );

                                    String userName =
                                            rs.getString(
                                                    "user_name"
                                            );

                                    String doctorName =
                                            rs.getString(
                                                    "doctor_name"
                                            );

                                    String department =
                                            rs.getString(
                                                    "department"
                                            );

                                    int delayMinutes =
                                            rs.getInt(
                                                    "delay_minutes"
                                            );

                                    String encodedDoctor =
                                            URLEncoder.encode(
                                                    selectedDoctor,
                                                    "UTF-8"
                                            );
                    %>

                    <tr>

                        <td>

    <span class="badge">
        <%= tokenNumber %>
    </span>

                        </td>


                        <td>

                            <%= userName %>

                        </td>


                        <td>

                            <%= doctorName != null
                                    ? doctorName
                                    : "-" %>

                            <br>

                            <small style="color:#94a3b8;">

                                <%= department != null
                                        ? department
                                        : "-" %>

                            </small>

                        </td>


                        <!-- =================================================
                             DELAY CONTROLS
                             ================================================= -->

                        <td>

                            <div class="delay-text">

                                <i class="fa-solid fa-clock"></i>

                                +<%= delayMinutes %> min

                            </div>


                            <div class="delay-controls">

                                <!-- +5 -->

                                <form action="UpdateTokenStatusServlet"
                                      method="post">

                                    <input type="hidden"
                                           name="tokenId"
                                           value="<%= tokenId %>">

                                    <input type="hidden"
                                           name="hospitalCode"
                                           value="<%= hospitalCode %>">

                                    <input type="hidden"
                                           name="action"
                                           value="DELAY">

                                    <input type="hidden"
                                           name="delay"
                                           value="5">

                                    <button type="submit"
                                            class="delay-btn">

                                        +5

                                    </button>

                                </form>


                                <!-- +10 -->

                                <form action="UpdateTokenStatusServlet"
                                      method="post">

                                    <input type="hidden"
                                           name="tokenId"
                                           value="<%= tokenId %>">

                                    <input type="hidden"
                                           name="hospitalCode"
                                           value="<%= hospitalCode %>">

                                    <input type="hidden"
                                           name="action"
                                           value="DELAY">

                                    <input type="hidden"
                                           name="delay"
                                           value="10">

                                    <button type="submit"
                                            class="delay-btn">

                                        +10

                                    </button>

                                </form>


                                <!-- -5 -->

                                <form action="UpdateTokenStatusServlet"
                                      method="post">

                                    <input type="hidden"
                                           name="tokenId"
                                           value="<%= tokenId %>">

                                    <input type="hidden"
                                           name="hospitalCode"
                                           value="<%= hospitalCode %>">

                                    <input type="hidden"
                                           name="action"
                                           value="DELAY">

                                    <input type="hidden"
                                           name="delay"
                                           value="-5">

                                    <button type="submit"
                                            class="delay-btn">

                                        -5

                                    </button>

                                </form>

                            </div>

                        </td>


                        <!-- =================================================
                             CALL
                             ================================================= -->

                        <td>

                            <a href="counter.jsp?action=serve&tokenId=<%= tokenId %>&doctorFilter=<%= encodedDoctor %>"
                               class="btn-call">

                                <i class="fa-solid fa-phone"></i>
                                Call

                            </a>

                        </td>

                    </tr>

                    <%
                        }

                        if (!hasWaiting) {
                    %>

                    <tr>

                        <td colspan="5"
                            class="empty">

                            No patients waiting in queue.

                        </td>

                    </tr>

                    <%
                            }

                        }

                    } catch (Exception e) {

                        e.printStackTrace();
                    %>

                    <tr>

                        <td colspan="5"
                            style="text-align:center;
           color:#ef4444;
           padding:20px;">

                            Unable to load queue.

                        </td>

                    </tr>

                    <%
                        }
                    %>

                    </tbody>

                </table>

            </div>

        </div>

    </div>

</div>

</body>

</html>

<%

    } catch (Exception e) {

        e.printStackTrace();

        out.println(
                "<h2 style='color:red;" +
                        "text-align:center;" +
                        "margin-top:50px;'>" +
                        "Counter panel database error." +
                        "</h2>"
        );
    }

%>