package com.queue;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/RegisterServlet")
public class RegisterUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name = request.getParameter("name");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (name == null || phone == null || name.trim().isEmpty() || phone.trim().isEmpty()) {
            response.sendRedirect("register.jsp?error=empty_fields");
            return;
        }

        name = name.trim();
        phone = phone.trim();
        if (email != null) email = email.trim();

        try (Connection con = DBConnection.getConnection()) {
            if (con == null) {
                response.sendRedirect("register.jsp?error=db_failed");
                return;
            }

            // 1. Check if user already exists with this phone number
            String checkSql = "SELECT user_id FROM users WHERE phone = ? LIMIT 1";
            try (PreparedStatement psCheck = con.prepareStatement(checkSql)) {
                psCheck.setString(1, phone);
                try (ResultSet rsCheck = psCheck.executeQuery()) {
                    if (rsCheck.next()) {
                        // User already exists! Redirect back with error
                        response.sendRedirect("register.jsp?error=already_registered");
                        return;
                    }
                }
            }

            // 2. Insert new user if not exists
            String insertSql = "INSERT INTO users (name, phone, email, password) VALUES (?, ?, ?, ?)";
            try (PreparedStatement psInsert = con.prepareStatement(insertSql)) {
                psInsert.setString(1, name);
                psInsert.setString(2, phone);
                psInsert.setString(3, email);
                psInsert.setString(4, password);
                psInsert.executeUpdate();
            }

            // Registration successful -> redirect to login or success page
            response.sendRedirect("reg_success.jsp?success=registered");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("register.jsp?error=server_error");
        }
    }
}