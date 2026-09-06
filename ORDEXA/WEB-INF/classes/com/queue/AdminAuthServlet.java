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
import javax.servlet.http.HttpSession;

@WebServlet("/AdminAuthServlet")
public class AdminAuthServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String hospitalCode = request.getParameter("hospitalCode");
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (hospitalCode == null || username == null || password == null ||
                hospitalCode.trim().isEmpty() || username.trim().isEmpty() || password.trim().isEmpty()) {
            response.sendRedirect("admin_login.jsp?error=invalid");
            return;
        }

        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT * FROM admin WHERE hospital_code = ? AND username = ? AND password = ?";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, hospitalCode.trim());
                ps.setString(2, username.trim());
                ps.setString(3, password.trim());

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        HttpSession session = request.getSession();
                        session.setAttribute("adminHospitalCode", rs.getString("hospital_code"));
                        session.setAttribute("adminHospitalName", rs.getString("hospital_name"));
                        session.setAttribute("adminUser", rs.getString("username"));

                        response.sendRedirect("counter.jsp");
                    } else {
                        response.sendRedirect("admin_login.jsp?error=invalid");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin_login.jsp?error=invalid");
        }
    }
}