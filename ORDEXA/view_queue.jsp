<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>

<%@ page import="java.sql.*" %>
<%@ page import="com.queue.DBConnection" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.URLEncoder" %>

<%
    // =========================================================
    // PARAMETERS
    // =========================================================

    String selectedHospital =
            request.getParameter("hospitalCode");

    String joinedToken =
            request.getParameter("token");


    String currentHospitalName = "";

    String joinedDepartment = "";
    String joinedDoctor = "";
    String joinedStatus = "";

    int joinedTokenId = -1;

    int peopleAhead = 0;
    int estimatedMinutes = 0;
    int joinedDelayMinutes = 0;


    Map<String, String> hospitalMap =
            new LinkedHashMap<String, String>();


    // =========================================================
    // LOAD HOSPITALS
    // =========================================================

    try (Connection con =
                 DBConnection.getConnection()) {

        String hospQuery =
                "SELECT DISTINCT " +
                        "hospital_code, " +
                        "hospital_name " +
                        "FROM admin " +
                        "WHERE hospital_code IS NOT NULL " +
                        "AND hospital_code <> '' " +
                        "ORDER BY hospital_name ASC";

        try (PreparedStatement ps =
                     con.prepareStatement(hospQuery);
             ResultSet rs =
                     ps.executeQuery()) {

            while (rs.next()) {

                String code =
                        rs.getString(
                                "hospital_code"
                        );

                String name =
                        rs.getString(
                                "hospital_name"
                        );

                if (name == null ||
                        name.trim().isEmpty()) {

                    name = code;
                }

                hospitalMap.put(
                        code,
                        name
                );
            }
        }

    } catch (Exception e) {

        e.printStackTrace();
    }


    // =========================================================
    // CURRENT HOSPITAL NAME
    // =========================================================

    if (selectedHospital != null &&
            hospitalMap.containsKey(
                    selectedHospital)) {

        currentHospitalName =
                hospitalMap.get(
                        selectedHospital
                );

    } else if (selectedHospital != null) {

        currentHospitalName =
                selectedHospital;
    }


    // =========================================================
    // GET JOINED TOKEN
    // =========================================================

    if (selectedHospital != null &&
            !selectedHospital.trim().isEmpty() &&

            joinedToken != null &&
            !joinedToken.trim().isEmpty()) {

        try (Connection con =
                     DBConnection.getConnection()) {


            // =================================================
            // TOKEN DETAILS
            // =================================================

            String joinedQuery =
                    "SELECT " +
                            "t.token_id, " +
                            "t.token_number, " +
                            "t.department, " +
                            "t.doctor_name, " +
                            "t.status, " +
                            "t.delay_minutes " +

                            "FROM tokens t " +

                            "WHERE t.hospital_code = ? " +
                            "AND t.token_number = ? " +

                            "ORDER BY t.token_id DESC " +
                            "LIMIT 1";


            try (PreparedStatement ps =
                         con.prepareStatement(
                                 joinedQuery)) {

                ps.setString(
                        1,
                        selectedHospital
                );

                ps.setString(
                        2,
                        joinedToken
                );


                try (ResultSet rs =
                             ps.executeQuery()) {

                    if (rs.next()) {

                        joinedTokenId =
                                rs.getInt(
                                        "token_id"
                                );

                        joinedToken =
                                rs.getString(
                                        "token_number"
                                );

                        joinedDepartment =
                                rs.getString(
                                        "department"
                                );

                        joinedDoctor =
                                rs.getString(
                                        "doctor_name"
                                );

                        joinedStatus =
                                rs.getString(
                                        "status"
                                );

                        joinedDelayMinutes =
                                rs.getInt(
                                        "delay_minutes"
                                );
                    }
                }
            }


            // =================================================
            // PEOPLE AHEAD
            // =================================================

            if ("WAITING".equalsIgnoreCase(
                    joinedStatus)) {


                String aheadQuery =

                        "SELECT COUNT(*) " +

                                "FROM tokens t1 " +

                                "WHERE t1.hospital_code = ? " +
                                "AND t1.status = 'WAITING' " +

                                "AND (" +

                                "DATE_ADD(" +
                                "t1.created_at, " +
                                "INTERVAL COALESCE(" +
                                "t1.delay_minutes,0) MINUTE" +
                                ") " +

                                "< " +

                                "(" +

                                "SELECT DATE_ADD(" +
                                "t2.created_at, " +
                                "INTERVAL COALESCE(" +
                                "t2.delay_minutes,0) MINUTE" +
                                ") " +

                                "FROM tokens t2 " +

                                "WHERE t2.token_id = ?" +

                                ")" +

                                "OR " +

                                "(" +

                                "DATE_ADD(" +
                                "t1.created_at, " +
                                "INTERVAL COALESCE(" +
                                "t1.delay_minutes,0) MINUTE" +
                                ") " +

                                "= " +

                                "(" +

                                "SELECT DATE_ADD(" +
                                "t2.created_at, " +
                                "INTERVAL COALESCE(" +
                                "t2.delay_minutes,0) MINUTE" +
                                ") " +

                                "FROM tokens t2 " +

                                "WHERE t2.token_id = ?" +

                                ")" +

                                "AND t1.token_id < ?" +

                                ")" +

                                ")";


                try (PreparedStatement ps =
                             con.prepareStatement(
                                     aheadQuery)) {

                    ps.setString(
                            1,
                            selectedHospital
                    );

                    ps.setInt(
                            2,
                            joinedTokenId
                    );

                    ps.setInt(
                            3,
                            joinedTokenId
                    );

                    ps.setInt(
                            4,
                            joinedTokenId
                    );


                    try (ResultSet rs =
                                 ps.executeQuery()) {

                        if (rs.next()) {

                            peopleAhead =
                                    rs.getInt(1);
                        }
                    }
                }


                // =================================================
                // ESTIMATED WAIT (Includes travel buffer time)
                // =================================================

                estimatedMinutes =
                        (peopleAhead * 5)
                                + joinedDelayMinutes;
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

    <title>Live Queue Board - ORDEXA</title>

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
            color: #ffffff;
            min-height: 100vh;
            padding: 30px 20px;
        }

        .header {
            text-align: center;
            margin-bottom: 25px;
        }

        .header h1 {
            font-size: 32px;
            color: #fca311;
        }

        .header p {
            color: #94a3b8;
            margin-top: 6px;
        }

        .container {
            width: 100%;
            max-width: 600px;
            margin: auto;
        }


        /* =====================================================
           JOINED CARD
           ===================================================== */

        .joined-card {
            background: linear-gradient(
                    145deg,
                    #12352a,
                    #132a3e
            );

            border: 1px solid #22c55e;
            border-radius: 16px;
            padding: 25px;
            margin-bottom: 25px;
        }

        .joined-title {
            color: #4ade80;
            font-size: 20px;
            font-weight: 800;
            margin-bottom: 20px;
        }

        .your-token {
            background: #0b132b;
            border-radius: 12px;
            padding: 20px;
            text-align: center;
            margin-bottom: 18px;
        }

        .your-token-label {
            color: #94a3b8;
            font-size: 13px;
        }

        .your-token-number {
            color: #fca311;
            font-size: 34px;
            font-weight: 900;
            margin-top: 5px;
        }

        .queue-info {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }

        .info-box {
            background: #1c2541;
            padding: 13px;
            border-radius: 9px;
        }

        .info-label {
            color: #94a3b8;
            font-size: 12px;
            margin-bottom: 4px;
        }

        .info-value {
            color: #f8fafc;
            font-size: 14px;
            font-weight: 700;
        }

        .queue-position {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            margin-top: 12px;
        }

        .position-box {
            background: #1c2541;
            padding: 15px;
            border-radius: 9px;
            text-align: center;
        }

        .position-number {
            font-size: 25px;
            color: #38bdf8;
            font-weight: 800;
        }

        .position-label {
            color: #94a3b8;
            font-size: 12px;
            margin-top: 3px;
        }


        /* =====================================================
           DELAY DISPLAY
           ===================================================== */

        .delay-display {
            margin-top: 12px;
            background: #3b2f0b;
            border: 1px solid #fca311;
            color: #fbbf24;
            padding: 12px;
            border-radius: 9px;
            text-align: center;
            font-size: 14px;
            font-weight: 700;
        }


        /* =====================================================
           USER DELAY BUTTONS
           ===================================================== */

        .delay-section {
            margin-top: 15px;
        }

        .delay-button {
            width: 100%;
            padding: 12px;
            background: #fca311;
            color: #0b132b;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 800;
            cursor: pointer;
        }

        .delay-options {
            display: none;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
            margin-top: 10px;
        }

        .delay-option {
            padding: 11px;
            background: #1c2541;
            color: white;
            border: 1px solid #475569;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 700;
            width: 100%;
        }

        .delay-option:hover {
            border-color: #fca311;
            color: #fca311;
        }


        /* =====================================================
           SERVING
           ===================================================== */

        .serving-message {
            background: #14532d;
            color: #4ade80;
            padding: 12px;
            border-radius: 8px;
            text-align: center;
            font-weight: 700;
            margin-top: 12px;
        }


        /* =====================================================
           HOSPITAL FILTER
           ===================================================== */

        .filter-box {
            background: #1c2541;
            padding: 12px 20px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 15px;
        }

        .filter-box select {
            padding: 9px 14px;
            background: #0b132b;
            color: white;
            border: 1px solid #475569;
            border-radius: 6px;
            flex: 1;
        }

        .filter-box button {
            padding: 9px 16px;
            background: #0284c7;
            color: white;
            border: none;
            border-radius: 6px;
            font-weight: 600;
        }

        .hospital-tag {
            background: #1e293b;
            border: 1px solid #38bdf8;
            padding: 10px 18px;
            border-radius: 8px;
            color: #38bdf8;
            font-weight: 600;
            margin-bottom: 30px;
        }


        /* =====================================================
           LIVE QUEUE
           ===================================================== */

        .section-title {
            color: #f8fafc;
            font-size: 20px;
            margin-bottom: 15px;
        }

        .board-grid {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .token-card {
            background: #1c2541;
            padding: 20px 25px;
            border-radius: 12px;
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            border-left: 5px solid #38bdf8;
            gap: 15px;
        }

        .token-card.serving {
            border-left-color: #22c55e;
            background: #132a3e;
        }

        .token-left {
            flex: 1;
        }

        .token-number {
            font-size: 22px;
            font-weight: 800;
            color: #fca311;
        }

        .patient-name {
            font-size: 16px;
            font-weight: 600;
            margin-top: 4px;
        }

        .doctor-info {
            font-size: 13px;
            color: #cbd5e1;
            margin-top: 4px;
        }

        .queue-extra-info {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 10px;
        }

        .queue-extra-info span {
            background: #0f172a;
            border: 1px solid #334155;
            padding: 6px 9px;
            border-radius: 6px;
            color: #94a3b8;
            font-size: 12px;
        }

        .queue-extra-info strong {
            color: #fca311;
            margin-left: 3px;
        }

        .delay-value {
            color: #fbbf24 !important;
        }

        .status-badge {
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 700;
            white-space: nowrap;
        }

        .status-waiting {
            background: #334155;
            color: #94a3b8;
        }

        .status-serving {
            background: #14532d;
            color: #4ade80;
        }

        .notice-card {
            background: #1c2541;
            padding: 25px;
            border-radius: 10px;
            text-align: center;
            color: #cbd5e1;
            border-left: 4px solid #fca311;
        }

        .nav-link {
            margin: 35px auto 0;
            color: #94a3b8;
            text-decoration: none;
            display: flex;
            width: fit-content;
            padding: 10px 20px;
            border: 1px solid #334155;
            border-radius: 6px;
        }

        @media(max-width:500px) {

            .header h1 {
                font-size: 25px;
            }

            .queue-info {
                grid-template-columns: 1fr;
            }

            .filter-box {
                flex-direction: column;
                align-items: stretch;
            }

            .token-card {
                padding: 16px;
            }

            .status-badge {
                font-size: 11px;
            }

        }

    </style>

</head>

<body>


<div class="header">

    <h1>
        <i class="fa-solid fa-bullhorn"></i>
        Live Queue Display Board
    </h1>

    <p>
        Real-time patient counter & queue updates
    </p>

</div>


<div class="container">


    <!-- =====================================================
         JOINED TOKEN
         ===================================================== -->

    <%
        if (joinedToken != null &&
                !joinedToken.trim().isEmpty()) {
    %>

    <div class="joined-card">

        <div class="joined-title">

            <i class="fa-solid fa-circle-check"></i>

            Joined Queue Successfully

        </div>


        <div class="your-token">

            <div class="your-token-label">
                Your Token
            </div>

            <div class="your-token-number">
                #<%= joinedToken %>
            </div>

        </div>


        <div class="queue-info">

            <div class="info-box">

                <div class="info-label">
                    Hospital
                </div>

                <div class="info-value">
                    <%= currentHospitalName %>
                </div>

            </div>


            <div class="info-box">

                <div class="info-label">
                    Department
                </div>

                <div class="info-value">

                    <%= joinedDepartment != null &&
                            !joinedDepartment.isEmpty()
                            ? joinedDepartment
                            : "-" %>

                </div>

            </div>


            <div class="info-box">

                <div class="info-label">
                    Doctor
                </div>

                <div class="info-value">

                    <%= joinedDoctor != null &&
                            !joinedDoctor.isEmpty()
                            ? joinedDoctor
                            : "-" %>

                </div>

            </div>


            <div class="info-box">

                <div class="info-label">
                    Status
                </div>

                <div class="info-value">

                    <%= joinedStatus != null &&
                            !joinedStatus.isEmpty()
                            ? joinedStatus
                            : "-" %>

                </div>

            </div>

        </div>


        <%
            if ("WAITING".equalsIgnoreCase(
                    joinedStatus)) {
        %>

        <div class="queue-position">

            <div class="position-box">

                <div class="position-number">
                    <%= peopleAhead %>
                </div>

                <div class="position-label">
                    People Ahead
                </div>

            </div>


            <div class="position-box">

                <div class="position-number">

                    <%= estimatedMinutes %> min

                </div>

                <div class="position-label">
                    Estimated Wait (Includes Travel Time)
                </div>

            </div>

        </div>


        <%
            if (joinedDelayMinutes > 0) {
        %>

        <div class="delay-display">

            <i class="fa-solid fa-clock"></i>

            Travel / Delay Buffer:
            +<%= joinedDelayMinutes %> minutes

        </div>

        <%
            }
        %>


        <!-- =====================================================
             RUNNING LATE
             ===================================================== -->

        <div class="delay-section">

            <button type="button"
                    class="delay-button"
                    onclick="toggleDelayOptions()">

                <i class="fa-solid fa-clock"></i>

                I'm Running Late

            </button>


            <div id="delayOptions"
                 class="delay-options">


                <!-- +5 -->

                <form action="UpdateTokenStatusServlet"
                      method="post" style="display:contents;">

                    <input type="hidden"
                           name="tokenId"
                           value="<%= joinedTokenId %>">

                    <input type="hidden"
                           name="hospitalCode"
                           value="<%= selectedHospital %>">

                    <input type="hidden"
                           name="token"
                           value="<%= joinedToken %>">

                    <input type="hidden"
                           name="action"
                           value="DELAY">

                    <input type="hidden"
                           name="delay"
                           value="5">

                    <button type="submit"
                            class="delay-option">

                        +5 Minutes

                    </button>

                </form>


                <!-- +10 -->

                <form action="UpdateTokenStatusServlet"
                      method="post" style="display:contents;">

                    <input type="hidden"
                           name="tokenId"
                           value="<%= joinedTokenId %>">

                    <input type="hidden"
                           name="hospitalCode"
                           value="<%= selectedHospital %>">

                    <input type="hidden"
                           name="token"
                           value="<%= joinedToken %>">

                    <input type="hidden"
                           name="action"
                           value="DELAY">

                    <input type="hidden"
                           name="delay"
                           value="10">

                    <button type="submit"
                            class="delay-option">

                        +10 Minutes

                    </button>

                </form>


                <!-- +15 -->

                <form action="UpdateTokenStatusServlet"
                      method="post" style="display:contents;">

                    <input type="hidden"
                           name="tokenId"
                           value="<%= joinedTokenId %>">

                    <input type="hidden"
                           name="hospitalCode"
                           value="<%= selectedHospital %>">

                    <input type="hidden"
                           name="token"
                           value="<%= joinedToken %>">

                    <input type="hidden"
                           name="action"
                           value="DELAY">

                    <input type="hidden"
                           name="delay"
                           value="15">

                    <button type="submit"
                            class="delay-option">

                        +15 Minutes

                    </button>

                </form>


                <!-- +30 -->

                <form action="UpdateTokenStatusServlet"
                      method="post" style="display:contents;">

                    <input type="hidden"
                           name="tokenId"
                           value="<%= joinedTokenId %>">

                    <input type="hidden"
                           name="hospitalCode"
                           value="<%= selectedHospital %>">

                    <input type="hidden"
                           name="token"
                           value="<%= joinedToken %>">

                    <input type="hidden"
                           name="action"
                           value="DELAY">

                    <input type="hidden"
                           name="delay"
                           value="30">

                    <button type="submit"
                            class="delay-option">

                        +30 Minutes

                    </button>

                </form>

            </div>

        </div>


        <%
        }
        else if ("SERVING".equalsIgnoreCase(
                joinedStatus)) {
        %>

        <div class="serving-message">

            <i class="fa-solid fa-stethoscope"></i>

            Your token is being served now!

        </div>

        <%
        }
        else if ("COMPLETED".equalsIgnoreCase(
                joinedStatus)) {
        %>

        <div class="serving-message">

            <i class="fa-solid fa-circle-check"></i>

            Your token has been completed.

        </div>

        <%
            }
        %>

    </div>

    <%
        }
    %>


    <!-- =====================================================
         HOSPITAL FILTER
         ===================================================== -->

    <form action="view_queue.jsp"
          method="get"
          class="filter-box">

        <label>
            <i class="fa-solid fa-hospital"></i>
            Hospital:
        </label>


        <select name="hospitalCode"
                onchange="this.form.submit()"
                required>

            <option value="">
                -- Choose Hospital --
            </option>

            <%
                for (Map.Entry<String,String> entry :
                        hospitalMap.entrySet()) {
            %>

            <option value="<%= entry.getKey() %>"
                    <%= selectedHospital != null &&
                            selectedHospital.equalsIgnoreCase(
                                    entry.getKey())
                            ? "selected"
                            : "" %>>

                <%= entry.getValue() %>
                (<%= entry.getKey() %>)

            </option>

            <%
                }
            %>

        </select>


        <button type="submit">
            Switch
        </button>

    </form>


    <%
        if (selectedHospital != null &&
                !selectedHospital.trim().isEmpty()) {
    %>

    <div class="hospital-tag">

        <i class="fa-solid fa-square-h"></i>

        Active Facility:

        <strong style="color:white;">
            <%= currentHospitalName %>
        </strong>

    </div>

    <%
        }
    %>


    <!-- =====================================================
         LIVE QUEUE
         ===================================================== -->

    <%
        if (selectedHospital == null ||
                selectedHospital.trim().isEmpty()) {
    %>

    <div class="notice-card">

        <i class="fa-solid fa-circle-info"></i>

        Please select a hospital to view
        its live queue.

    </div>

    <%
    }
    else {
    %>

    <div class="section-title">

        <i class="fa-solid fa-list-ol"></i>

        Live Queue (Sorted by Expected Arrival & Priority)

    </div>


    <div class="board-grid">

        <%
            boolean hasTokens = false;

            try (Connection con =
                         DBConnection.getConnection()) {


                String tokenQuery =

                        "SELECT " +

                                "t.token_id, " +
                                "t.token_number, " +
                                "u.name, " +
                                "t.status, " +
                                "t.doctor_name, " +
                                "t.department, " +
                                "COALESCE(t.delay_minutes,0) " +
                                "AS delay_minutes, " +

                                "(" +

                                "SELECT COUNT(*) " +

                                "FROM tokens t2 " +

                                "WHERE t2.hospital_code = " +
                                "t.hospital_code " +

                                "AND t2.status = 'WAITING' " +

                                "AND (" +

                                "DATE_ADD(" +
                                "t2.created_at, " +
                                "INTERVAL COALESCE(" +
                                "t2.delay_minutes,0) MINUTE" +
                                ") " +

                                "< " +

                                "DATE_ADD(" +
                                "t.created_at, " +
                                "INTERVAL COALESCE(" +
                                "t.delay_minutes,0) MINUTE" +
                                ") " +

                                "OR (" +

                                "DATE_ADD(" +
                                "t2.created_at, " +
                                "INTERVAL COALESCE(" +
                                "t2.delay_minutes,0) MINUTE" +
                                ") " +

                                "= " +

                                "DATE_ADD(" +
                                "t.created_at, " +
                                "INTERVAL COALESCE(" +
                                "t.delay_minutes,0) MINUTE" +
                                ") " +

                                "AND t2.token_id < " +
                                "t.token_id" +

                                ")" +

                                ")" +

                                ") AS people_ahead " +

                                "FROM tokens t " +

                                "JOIN users u " +
                                "ON t.user_id = u.user_id " +

                                "WHERE t.hospital_code = ? " +

                                "AND t.status IN " +
                                "('WAITING','SERVING') " +

                                "ORDER BY " +

                                "CASE " +
                                "WHEN t.status = 'SERVING' " +
                                "THEN 0 ELSE 1 END, " +

                                "DATE_ADD(" +
                                "t.created_at, " +
                                "INTERVAL COALESCE(" +
                                "t.delay_minutes,0) MINUTE" +
                                ") ASC, " +

                                "t.token_id ASC";


                try (PreparedStatement ps =
                             con.prepareStatement(
                                     tokenQuery)) {

                    ps.setString(
                            1,
                            selectedHospital
                    );


                    try (ResultSet rs =
                                 ps.executeQuery()) {


                        while (rs.next()) {

                            hasTokens = true;


                            String tNum =
                                    rs.getString(
                                            "token_number"
                                    );

                            String patientName =
                                    rs.getString(
                                            "name"
                                    );

                            String status =
                                    rs.getString(
                                            "status"
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

                            int userPeopleAhead =
                                    rs.getInt(
                                            "people_ahead"
                                    );


                            boolean isServing =
                                    "SERVING".equalsIgnoreCase(
                                            status
                                    );


                            int userEstimatedMinutes =
                                    isServing
                                            ? 0
                                            : (userPeopleAhead * 5)
                                            + delayMinutes;
        %>


        <div class="token-card
            <%= isServing
                ? "serving"
                : "" %>">


            <div class="token-left">


                <div class="token-number">

                    #<%= tNum %>

                </div>


                <div class="patient-name">

                    <%= patientName %>

                </div>


                <div class="doctor-info">

                    Doctor:

                    <%= doctorName != null
                            ? doctorName
                            : "-" %>

                    <br>

                    Department:

                    <%= department != null
                            ? department
                            : "-" %>

                </div>


                <div class="queue-extra-info">


            <span>

                <i class="fa-solid fa-hourglass-half"></i>

                Estimated Wait:

                <strong>

                    <%= userEstimatedMinutes %>
                    min

                </strong>

            </span>


                    <span>

                <i class="fa-solid fa-clock"></i>

                Travel Buffer:

                <strong class="delay-value">

                    +<%= delayMinutes %>
                    min

                </strong>

            </span>


                    <% if (!isServing) { %>

                    <span>

                <i class="fa-solid fa-users"></i>

                Ahead:

                <strong>

                    <%= userPeopleAhead %>

                </strong>

            </span>

                    <% } %>


                </div>


            </div>


            <span class="status-badge
                <%= isServing
                    ? "status-serving"
                    : "status-waiting" %>">

        <i class="fa-solid
            <%= isServing
                ? "fa-stethoscope"
                : "fa-clock" %>">
        </i>

        <%= status %>

    </span>


        </div>


        <%
                    }

                }
            }

        }
        catch (Exception e) {

            e.printStackTrace();
        %>

        <div class="notice-card"
             style="color:#ef4444;">

            Error loading queue.

        </div>

        <%
            }


            if (!hasTokens) {
        %>

        <div class="notice-card">

            <i class="fa-solid fa-mug-hot"></i>

            No active tokens for

            <strong>
                <%= currentHospitalName %>
            </strong>

            right now.

        </div>

        <%
            }
        %>

    </div>

    <%
        }
    %>


</div>


<a href="index.jsp"
   class="nav-link">

    <i class="fa-solid fa-house"></i>

    Back to Home

</a>


<script>

    function toggleDelayOptions() {

        const options =
            document.getElementById(
                "delayOptions"
            );

        if (!options) {
            return;
        }

        if (options.style.display === "grid") {

            options.style.display =
                "none";

        } else {

            options.style.display =
                "grid";
        }
    }

</script>


</body>

</html>