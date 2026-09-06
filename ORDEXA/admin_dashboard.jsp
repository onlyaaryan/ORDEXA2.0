<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.queue.*" %>

<%
    // ==============================
    // SESSION VALIDATION
    // ==============================

    String adminUser = (String) session.getAttribute("adminUser");
    String hospitalCode = (String) session.getAttribute("hospitalCode");
    String hospitalName = (String) session.getAttribute("hospitalName");

    if (adminUser == null || hospitalCode == null) {
        response.sendRedirect("admin_login.jsp?error=unauthorized");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        Admin Dashboard -
        <%= (hospitalName != null) ? hospitalName : hospitalCode %>
    </title>

    <!-- Bootstrap -->
    <link
            href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
            rel="stylesheet">

    <!-- Font Awesome -->
    <link
            href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"
            rel="stylesheet">

    <!-- Google Font -->
    <link
            href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap"
            rel="stylesheet">

    <style>

        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f1f5f9;
            padding: 40px 0;
        }

        .admin-card {
            background: #ffffff;
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.05);
        }

    </style>

</head>

<body>

<div class="container col-lg-10">

    <div class="admin-card">

        <!-- ==============================
             HEADER
             ============================== -->

        <div class="d-flex justify-content-between align-items-center mb-4">

            <div>

                <h3 class="fw-bold m-0 text-primary">

                    <i class="fa-solid fa-sliders me-2"></i>

                    Counter Control Panel

                </h3>

                <!-- Hospital -->

                <span class="badge bg-primary mt-2 fs-6">

                    <i class="fa-solid fa-hospital me-1"></i>

                    <%= (hospitalName != null && !hospitalName.isEmpty())
                            ? hospitalName
                            : "Hospital" %>

                    (<%= hospitalCode %>)

                </span>

                <!-- Admin -->

                <span class="badge bg-secondary mt-2 fs-6">

                    <i class="fa-solid fa-user me-1"></i>

                    Admin: <%= adminUser %>

                </span>

            </div>


            <!-- Buttons -->

            <div>

                <a href="logout.jsp"
                   class="btn btn-outline-danger btn-sm rounded-pill px-3 me-2">

                    <i class="fa-solid fa-right-from-bracket me-1"></i>

                    Logout

                </a>


                <a href="index.jsp"
                   class="btn btn-outline-secondary btn-sm rounded-pill px-3">

                    <i class="fa-solid fa-house me-1"></i>

                    Home

                </a>

            </div>

        </div>


        <!-- ==============================
             QUEUE TABLE
             ============================== -->

        <div class="table-responsive">

            <table class="table table-hover align-middle">

                <thead class="table-light">

                <tr>

                    <th>Token #</th>

                    <th>Customer Name</th>

                    <th>Phone</th>

                    <th>Est. Wait Time</th>

                    <th>Status</th>

                    <th>Action</th>

                </tr>

                </thead>


                <tbody>

                <%

                    Connection con = null;
                    PreparedStatement ps = null;
                    ResultSet rs = null;

                    try {

                        // ==============================
                        // DATABASE CONNECTION
                        // ==============================

                        con = DBConnection.getConnection();


                        if (con == null) {

                            throw new Exception(
                                    "Database connection failed."
                            );

                        }


                        // ==============================
                        // FETCH ACTIVE TOKENS
                        // ==============================

                        String sql =
                                "SELECT " +
                                        "t.token_id, " +
                                        "t.token_number, " +
                                        "u.name, " +
                                        "u.phone, " +
                                        "t.status " +

                                        "FROM tokens t " +

                                        "JOIN users u " +
                                        "ON t.user_id = u.user_id " +

                                        "WHERE t.status IN ('WAITING', 'SERVING') " +

                                        "AND t.hospital_code = ? " +

                                        "ORDER BY t.token_id ASC";


                        ps = con.prepareStatement(sql);

                        ps.setString(1, hospitalCode);

                        rs = ps.executeQuery();


                        boolean hasTokens = false;
                        int waitingPosition = 0;
                        int avgServiceTime = 10; // Default 10 mins per person


                        // ==============================
                        // DISPLAY TOKENS
                        // ==============================

                        while (rs.next()) {

                            hasTokens = true;

                            int tokenId = rs.getInt("token_id");
                            String tokenNum = rs.getString("token_number");
                            String status = rs.getString("status");

                            // Calculate estimated waiting time dynamically based on position
                            int estTime = 0;
                            if ("WAITING".equals(status)) {
                                waitingPosition++;
                                estTime = waitingPosition * avgServiceTime;
                            } else if ("SERVING".equals(status)) {
                                estTime = 0; // Currently being served
                            }

                %>

                <tr>

                    <!-- TOKEN -->

                    <td class="fw-bold fs-5 text-primary">

                        #<%= tokenNum %>

                    </td>


                    <!-- CUSTOMER NAME -->

                    <td class="fw-semibold">

                        <%= rs.getString("name") %>

                    </td>


                    <!-- PHONE -->

                    <td class="text-muted">

                        <%= rs.getString("phone") %>

                    </td>


                    <!-- ESTIMATED WAIT TIME -->

                    <td>
                        <% if ("SERVING".equals(status)) { %>
                        <span class="badge bg-success-subtle text-success border border-success px-2 py-1">
                                <i class="fa-solid fa-bolt me-1"></i> Now Serving
                            </span>
                        <% } else { %>
                        <span class="badge bg-info-subtle text-info border border-info px-2 py-1">
                                <i class="fa-solid fa-clock me-1"></i> ~<%= estTime %> mins
                            </span>
                        <% } %>
                    </td>


                    <!-- STATUS -->

                    <td>

                        <% if ("SERVING".equals(status)) { %>

                        <span class="badge bg-success p-2">

                                <i class="fa-solid fa-spinner fa-spin me-1"></i>

                                Serving

                            </span>

                        <% } else { %>

                        <span class="badge bg-warning text-dark p-2">

                                <i class="fa-solid fa-clock me-1"></i>

                                Waiting

                            </span>

                        <% } %>

                    </td>


                    <!-- ACTION -->

                    <td>

                        <% if ("WAITING".equals(status)) { %>


                        <!-- SERVE BUTTON -->

                        <form
                                action="UpdateTokenStatusServlet"
                                method="POST"
                                style="display:inline;">

                            <input
                                    type="hidden"
                                    name="tokenId"
                                    value="<%= tokenId %>">


                            <input
                                    type="hidden"
                                    name="action"
                                    value="SERVE">


                            <button
                                    type="submit"
                                    class="btn btn-primary btn-sm rounded-pill px-3">

                                <i class="fa-solid fa-bell me-1"></i>

                                Call / Serve

                            </button>

                        </form>


                        <% } else if ("SERVING".equals(status)) { %>


                        <!-- COMPLETE BUTTON -->

                        <form
                                action="UpdateTokenStatusServlet"
                                method="POST"
                                style="display:inline;">

                            <input
                                    type="hidden"
                                    name="tokenId"
                                    value="<%= tokenId %>">


                            <input
                                    type="hidden"
                                    name="action"
                                    value="COMPLETE">


                            <button
                                    type="submit"
                                    class="btn btn-success btn-sm rounded-pill px-3">

                                <i class="fa-solid fa-check me-1"></i>

                                Complete

                            </button>

                        </form>


                        <% } %>

                    </td>

                </tr>


                <%

                    }


                    // ==============================
                    // NO TOKENS
                    // ==============================

                    if (!hasTokens) {

                %>

                <tr>

                    <td
                            colspan="6"
                            class="text-center py-4 text-muted">

                        No active queue tokens for Hospital

                        <%= (hospitalName != null)
                                ? hospitalName
                                : hospitalCode %>.

                    </td>

                </tr>

                <%

                        }

                    }


                    // ==============================
                    // ERROR
                    // ==============================

                    catch (Exception e) {

                        out.println(
                                "<tr>" +
                                        "<td colspan='6' class='text-danger'>" +
                                        "Error: " +
                                        e.getMessage() +
                                        "</td>" +
                                        "</tr>"
                        );

                    }


                    // ==============================
                    // CLOSE DATABASE RESOURCES
                    // ==============================

                    finally {

                        if (rs != null) {

                            try {
                                rs.close();
                            } catch (Exception ignored) {}

                        }


                        if (ps != null) {

                            try {
                                ps.close();
                            } catch (Exception ignored) {}

                        }


                        if (con != null) {

                            try {
                                con.close();
                            } catch (Exception ignored) {}

                        }

                    }

                %>

                </tbody>

            </table>

        </div>

    </div>

</div>

</body>

</html>