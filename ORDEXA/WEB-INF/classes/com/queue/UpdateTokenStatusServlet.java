package com.queue;

import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/UpdateTokenStatusServlet")
public class UpdateTokenStatusServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String tokenIdParam =
                request.getParameter("tokenId");

        String action =
                request.getParameter("action");

        String hospitalCode =
                request.getParameter("hospitalCode");

        String token =
                request.getParameter("token");

        if (tokenIdParam == null
                || action == null
                || hospitalCode == null) {

            response.sendRedirect("counter.jsp");
            return;
        }

        int tokenId;

        try {

            tokenId =
                    Integer.parseInt(tokenIdParam);

        } catch (NumberFormatException e) {

            response.sendRedirect("counter.jsp");
            return;
        }

        try (Connection con =
                     DBConnection.getConnection()) {

            if (con == null) {

                throw new Exception(
                        "Unable to establish database connection."
                );
            }

            // =====================================================
            // SERVE
            // =====================================================

            if ("SERVE".equalsIgnoreCase(action)) {

                String resetServing =
                        "UPDATE tokens " +
                                "SET status = 'COMPLETED' " +
                                "WHERE status = 'SERVING' " +
                                "AND hospital_code = ?";

                try (PreparedStatement ps =
                             con.prepareStatement(resetServing)) {

                    ps.setString(1, hospitalCode);

                    ps.executeUpdate();
                }

                String updateServe =
                        "UPDATE tokens " +
                                "SET status = 'SERVING' " +
                                "WHERE token_id = ? " +
                                "AND hospital_code = ?";

                try (PreparedStatement ps =
                             con.prepareStatement(updateServe)) {

                    ps.setInt(1, tokenId);
                    ps.setString(2, hospitalCode);

                    ps.executeUpdate();
                }
            }

            // =====================================================
            // COMPLETE
            // =====================================================

            else if ("COMPLETE".equalsIgnoreCase(action)) {

                String updateComplete =
                        "UPDATE tokens " +
                                "SET status = 'COMPLETED' " +
                                "WHERE token_id = ? " +
                                "AND hospital_code = ?";

                try (PreparedStatement ps =
                             con.prepareStatement(
                                     updateComplete)) {

                    ps.setInt(1, tokenId);
                    ps.setString(2, hospitalCode);

                    ps.executeUpdate();
                }
            }

            // =====================================================
            // DELAY
            // =====================================================

            else if ("DELAY".equalsIgnoreCase(action)) {

                String delayParam =
                        request.getParameter("delay");

                if (delayParam == null) {

                    response.sendRedirect(
                            "counter.jsp"
                    );

                    return;
                }

                int delay;

                try {

                    delay =
                            Integer.parseInt(
                                    delayParam
                            );

                } catch (NumberFormatException e) {

                    response.sendRedirect(
                            "counter.jsp"
                    );

                    return;
                }

                String updateDelay =
                        "UPDATE tokens " +
                                "SET delay_minutes = " +
                                "GREATEST(" +
                                "0, COALESCE(delay_minutes, 0) + ?" +
                                ") " +
                                "WHERE token_id = ? " +
                                "AND hospital_code = ? " +
                                "AND status = 'WAITING'";

                try (PreparedStatement ps =
                             con.prepareStatement(
                                     updateDelay)) {

                    ps.setInt(1, delay);
                    ps.setInt(2, tokenId);
                    ps.setString(3, hospitalCode);

                    ps.executeUpdate();
                }
            }

            // =====================================================
            // REDIRECT
            // =====================================================

            if (token != null
                    && !token.trim().isEmpty()) {

                response.sendRedirect(
                        "view_queue.jsp?hospitalCode=" +
                                URLEncoder.encode(
                                        hospitalCode,
                                        "UTF-8"
                                ) +
                                "&token=" +
                                URLEncoder.encode(
                                        token,
                                        "UTF-8"
                                )
                );

            } else {

                response.sendRedirect(
                        "counter.jsp?hospitalCode=" +
                                URLEncoder.encode(
                                        hospitalCode,
                                        "UTF-8"
                                )
                );
            }

        } catch (Exception e) {

            e.printStackTrace();

            response.getWriter().println(
                    "Error updating token: " +
                            e.getMessage()
            );
        }
    }
}