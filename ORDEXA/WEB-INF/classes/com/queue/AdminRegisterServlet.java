package com.queue;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/AdminRegisterServlet")
public class AdminRegisterServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        String hospitalCode = request.getParameter("hospitalCode");
        String hospitalName = request.getParameter("hospitalName");
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // Validate input
        if (isEmpty(hospitalCode) ||
                isEmpty(hospitalName) ||
                isEmpty(username) ||
                isEmpty(password)) {

            showError(response, "All fields are required.");
            return;
        }

        hospitalCode = hospitalCode.trim();
        hospitalName = hospitalName.trim();
        username = username.trim();

        String sql =
                "INSERT INTO admin " +
                        "(hospital_code, hospital_name, username, password) " +
                        "VALUES (?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            if (con == null) {
                showError(response, "Database connection failed.");
                return;
            }

            ps.setString(1, hospitalCode);
            ps.setString(2, hospitalName);
            ps.setString(3, username);
            ps.setString(4, password);

            int rows = ps.executeUpdate();

            if (rows > 0) {

                // Registration successful
                response.sendRedirect("admin_login.jsp?registered=true");

            } else {

                showError(response,
                        "Registration failed. No record was inserted.");
            }

        } catch (SQLException e) {

            e.printStackTrace();

            String message;

            if (e.getErrorCode() == 1062) {
                message = "Username or Hospital Code already exists.";
            } else {
                message = "Database Error: " + e.getMessage();
            }

            showError(response, message);

        } catch (Exception e) {

            e.printStackTrace();

            showError(response,
                    "Registration Error: " + e.getMessage());
        }
    }

    // Check empty/null values
    private boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }

    // Display error page
    private void showError(HttpServletResponse response,
                           String message)
            throws IOException {

        response.getWriter().println(
                "<html>" +
                        "<head>" +
                        "<title>Admin Registration Error</title>" +
                        "</head>" +

                        "<body style='font-family:Arial;padding:40px'>" +

                        "<h2 style='color:red'>" +
                        "Admin Registration Failed" +
                        "</h2>" +

                        "<hr>" +

                        "<p><b>Error:</b></p>" +

                        "<pre>" +
                        escapeHtml(message) +
                        "</pre>" +

                        "<br>" +

                        "<a href='admin_register.jsp'>" +
                        "Go Back to Registration" +
                        "</a>" +

                        "</body>" +
                        "</html>"
        );
    }

    // Prevent HTML injection in displayed error
    private String escapeHtml(String text) {

        if (text == null) {
            return "Unknown error";
        }

        return text
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }
}