<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.queue.*" %>

<%
    // ==============================
    // USER SESSION VALIDATION
    // ==============================
    String userName = (String) session.getAttribute("userName");
    Integer userId = (Integer) session.getAttribute("userId");

    // Fallback ya check agar user login nahi hai
    if (userName == null || userId == null) {
        // Agar session mein username nahi hai toh login/auth page par redirect karein
        // response.sendRedirect("user_auth.jsp?error=unauthorized");
        // return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Patient Dashboard - ORDEXA</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Google Font -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f1f5f9;
            padding: 40px 0;
        }
        .user-card {
            background: #ffffff;
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.05);
        }
    </style>
</head>
<body>

<div class="container col-lg-8">
    <div class="user-card">

        <!-- HEADER -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h3 class="fw-bold m-0 text-primary">
                    <i class="fa-solid fa-hospital-user me-2"></i> Patient Dashboard
                </h3>
                <span class="badge bg-secondary mt-2 fs-6">
                    <i class="fa-solid fa-user me-1"></i> Welcome, <%= (userName != null) ? userName : "Guest" %>
                </span>
            </div>
            <div>
                <a href="index.jsp" class="btn btn-outline-secondary btn-sm rounded-pill px-3">
                    <i class="fa-solid fa-house me-1"></i> Home
                </a>
            </div>
        </div>

        <!-- ACTIVE QUEUE STATUS SECTION -->
        <%
            Connection con = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            boolean hasActiveToken = false;

            String tokenNumber = "";
            String status = "";
            String hospitalCode = "";
            int peopleAhead = 0;
            int avgServiceTime = 10; // Default 10 mins
            int estimatedWaitTime = 0;

            try {
                con = DBConnection.getConnection();
                if (con != null && userId != null) {
                    // Fetch active token for this user
                    String sql = "SELECT t.* FROM tokens t WHERE t.user_id = ? AND t.status IN ('WAITING', 'SERVING') LIMIT 1";
                    ps = con.prepareStatement(sql);
                    ps.setInt(1, userId);
                    rs = ps.executeQuery();

                    if (rs.next()) {
                        hasActiveToken = true;
                        tokenNumber = rs.getString("token_number");
                        status = rs.getString("status");
                        hospitalCode = rs.getString("hospital_code");

                        // Calculate people ahead if status is WAITING
                        if ("WAITING".equals(status)) {
                            PreparedStatement countPs = con.prepareStatement(
                                    "SELECT COUNT(*) FROM tokens WHERE hospital_code = ? AND status = 'WAITING' AND token_id < ?"
                            );
                            countPs.setString(1, hospitalCode);
                            countPs.setInt(2, rs.getInt("token_id"));
                            ResultSet countRs = countPs.executeQuery();
                            if (countRs.next()) {
                                peopleAhead = countRs.getInt(1);
                            }
                            countRs.close();
                            countPs.close();

                            estimatedWaitTime = peopleAhead * avgServiceTime;
                        }
                    }
                }
            } catch (Exception e) {
                out.println("<div class='alert alert-danger'>Error loading queue status: " + e.getMessage() + "</div>");
            } finally {
                if (rs != null) try { rs.close(); } catch(Exception ignored){}
                if (ps != null) try { ps.close(); } catch(Exception ignored){}
                if (con != null) try { con.close(); } catch(Exception ignored){}
            }
        %>

        <% if (hasActiveToken) { %>
        <div class="card border-0 bg-light p-4 rounded-4 text-center">
            <h5 class="text-muted mb-2">Your Active Token</h5>
            <h1 class="display-4 fw-bold text-primary mb-3">#<%= tokenNumber %></h1>

            <div class="row g-3 mb-4">
                <div class="col-md-4">
                    <div class="p-3 bg-white rounded-3 shadow-sm">
                        <span class="text-muted d-block small">Status</span>
                        <span class="fw-bold text-<%= "SERVING".equals(status) ? "success" : "warning" %>">
                                <%= status %>
                            </span>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="p-3 bg-white rounded-3 shadow-sm">
                        <span class="text-muted d-block small">People Ahead</span>
                        <span class="fw-bold text-dark"><%= peopleAhead %></span>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="p-3 bg-white rounded-3 shadow-sm">
                        <span class="text-muted d-block small">Est. Wait Time</span>
                        <span class="fw-bold text-info">~<%= estimatedWaitTime %> mins</span>
                    </div>
                </div>
            </div>

            <!-- DELAY OPTION BUTTON ("I'm Running Late") -->
            <% if ("WAITING".equals(status)) { %>
            <div class="d-flex justify-content-center gap-2">
                <button class="btn btn-outline-warning rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#delayModal">
                    <i class="fa-solid fa-clock-rotate-left me-1"></i> I'm Running Late
                </button>
            </div>
            <% } %>
        </div>
        <% } else { %>
        <div class="text-center py-5">
            <div class="text-muted mb-3">
                <i class="fa-solid fa-ticket fa-3x"></i>
            </div>
            <h5>You are not in any active queue right now.</h5>
            <p class="text-muted">Select a hospital counter or service department to join the queue.</p>
            <a href="use_service.jsp" class="btn btn-primary rounded-pill px-4 mt-2">
                <i class="fa-solid fa-plus me-1"></i> Join Queue
            </a>
        </div>
        <% } %>

    </div>
</div>

<!-- Delay Modal Placeholder -->
<div class="modal fade" id="delayModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Select Delay Time</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body text-center">
                <p class="text-muted">Need a few extra minutes? Choose your delay duration:</p>
                <div class="d-grid gap-2 col-8 mx-auto">
                    <button class="btn btn-outline-primary delay-btn" data-mins="5">+5 Minutes</button>
                    <button class="btn btn-outline-primary delay-btn" data-mins="10">+10 Minutes</button>
                    <button class="btn btn-outline-primary delay-btn" data-mins="15">+15 Minutes</button>
                    <button class="btn btn-outline-primary delay-btn" data-mins="30">+30 Minutes</button>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>