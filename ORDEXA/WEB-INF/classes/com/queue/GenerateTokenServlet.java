package com.queue;

import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDateTime;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/GenerateTokenServlet")
public class GenerateTokenServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String phone = request.getParameter("phone");
        String hospitalCode = request.getParameter("hospitalCode");
        String department = request.getParameter("department");
        String doctorName = request.getParameter("doctorName");
        String arrivalMinutesParam = request.getParameter("arrivalMinutes");

        if (isEmpty(phone)
                || isEmpty(hospitalCode)
                || isEmpty(department)
                || isEmpty(doctorName)
                || isEmpty(arrivalMinutesParam)) {

            showError(response, "All fields are required.");
            return;
        }

        phone = phone.trim();
        hospitalCode = hospitalCode.trim().toUpperCase();
        department = department.trim();
        doctorName = doctorName.trim();

        int arrivalMinutes;

        try {
            arrivalMinutes = Integer.parseInt(arrivalMinutesParam.trim());
        } catch (NumberFormatException e) {
            showError(response, "Invalid arrival time.");
            return;
        }

        /*
         * User should give a reasonable approximate arrival time.
         * 0 to 240 minutes.
         */
        if (arrivalMinutes < 0 || arrivalMinutes > 240) {
            showError(
                    response,
                    "Arrival time must be between 0 and 240 minutes."
            );
            return;
        }

        try (Connection con = DBConnection.getConnection()) {

            if (con == null) {
                showError(response, "Database connection failed.");
                return;
            }

            // =====================================================
            // FIND REGISTERED USER
            // =====================================================

            int userId = -1;

            String userSql =
                    "SELECT user_id " +
                            "FROM users " +
                            "WHERE phone = ? " +
                            "LIMIT 1";

            try (PreparedStatement ps =
                         con.prepareStatement(userSql)) {

                ps.setString(1, phone);

                try (ResultSet rs = ps.executeQuery()) {

                    if (rs.next()) {
                        userId = rs.getInt("user_id");
                    }
                }
            }

            if (userId == -1) {

                showError(
                        response,
                        "Phone number is not registered. " +
                                "<a href='register.jsp'>Register Here</a>"
                );

                return;
            }

            // =====================================================
            // GENERATE SEQUENCE
            // =====================================================

            int tokenSeq = 1;

            String countSql =
                    "SELECT COUNT(*) " +
                            "FROM tokens " +
                            "WHERE hospital_code = ? " +
                            "AND department = ?";

            try (PreparedStatement ps =
                         con.prepareStatement(countSql)) {

                ps.setString(1, hospitalCode);
                ps.setString(2, department);

                try (ResultSet rs = ps.executeQuery()) {

                    if (rs.next()) {
                        tokenSeq = rs.getInt(1) + 1;
                    }
                }
            }

            // =====================================================
            // CLEAN HOSPITAL CODE
            // =====================================================

            String cleanHospital =
                    hospitalCode.replaceAll("[^A-Z0-9]", "");

            if (cleanHospital.isEmpty()) {
                cleanHospital = "HOS";
            }

            if (cleanHospital.length() > 3) {
                cleanHospital =
                        cleanHospital.substring(0, 3);
            }

            // =====================================================
            // CLEAN DEPARTMENT
            // =====================================================

            String cleanDepartment =
                    department
                            .replaceAll("[^a-zA-Z]", "")
                            .toUpperCase();

            if (cleanDepartment.isEmpty()) {
                cleanDepartment = "GEN";
            }

            if (cleanDepartment.length() > 3) {
                cleanDepartment =
                        cleanDepartment.substring(0, 3);
            }

            // =====================================================
            // TOKEN NUMBER
            // =====================================================

            String formattedSeq =
                    String.format("%03d", tokenSeq);

            String tokenNumber =
                    cleanHospital +
                            cleanDepartment +
                            formattedSeq;

            // =====================================================
            // EXPECTED ARRIVAL TIME
            // =====================================================

            LocalDateTime expectedArrival =
                    LocalDateTime.now()
                            .plusMinutes(arrivalMinutes);

            Timestamp expectedArrivalTimestamp =
                    Timestamp.valueOf(expectedArrival);

            // =====================================================
            // INSERT TOKEN
            // =====================================================

            String insertSql =
                    "INSERT INTO tokens " +
                            "(hospital_code, user_id, token_number, " +
                            "status, department, doctor_name, " +
                            "expected_arrival_time, delay_minutes) " +
                            "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

            try (PreparedStatement ps =
                         con.prepareStatement(insertSql)) {

                ps.setString(1, hospitalCode);
                ps.setInt(2, userId);
                ps.setString(3, tokenNumber);
                ps.setString(4, "WAITING");
                ps.setString(5, department);
                ps.setString(6, doctorName);
                ps.setTimestamp(7, expectedArrivalTimestamp);
                ps.setInt(8, arrivalMinutes); // Updated to pass the travel/arrival time correctly

                ps.executeUpdate();
            }

            // =====================================================
            // REDIRECT TO QUEUE
            // =====================================================

            response.sendRedirect(
                    "view_queue.jsp?hospitalCode=" +
                            URLEncoder.encode(
                                    hospitalCode,
                                    "UTF-8"
                            ) +
                            "&token=" +
                            URLEncoder.encode(
                                    tokenNumber,
                                    "UTF-8"
                            )
            );

        } catch (Exception e) {

            e.printStackTrace();

            showError(
                    response,
                    "Token generation failed.<br><br>" +
                            "<b>Error:</b> " +
                            escapeHtml(e.getMessage())
            );
        }
    }

    // =============================================================
    // EMPTY CHECK
    // =============================================================

    private boolean isEmpty(String value) {

        return value == null ||
                value.trim().isEmpty();
    }

    // =============================================================
    // ERROR PAGE
    // =============================================================

    private void showError(HttpServletResponse response,
                           String message)
            throws IOException {

        response.setContentType(
                "text/html;charset=UTF-8"
        );

        response.getWriter().println(

                "<html>" +

                        "<head>" +
                        "<title>Token Error</title>" +
                        "</head>" +

                        "<body style='font-family:Arial;padding:40px;'>" +

                        "<h2 style='color:red;'>" +
                        "Token Generation Failed" +
                        "</h2>" +

                        "<p>" +
                        message +
                        "</p>" +

                        "<br>" +

                        "<a href='use_service.jsp'>" +
                        "Go Back" +
                        "</a>" +

                        "</body>" +

                        "</html>"
        );
    }

    // =============================================================
    // HTML ESCAPE
    // =============================================================

    private String escapeHtml(String text) {

        if (text == null) {
            return "Unknown error";
        }

        return text
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
}