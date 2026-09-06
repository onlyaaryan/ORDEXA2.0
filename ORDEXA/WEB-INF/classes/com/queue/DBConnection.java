package com.queue;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    public static Connection getConnection() throws SQLException {

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC Driver not found.", e);
        }

        String url =
                "jdbc:mysql://mysql-1bb86359-ordexa1.a.aivencloud.com:14191/defaultdb"
                        + "?sslMode=REQUIRED"
                        + "&serverTimezone=UTC";

        String user = "avnadmin";

        // Aiven ka NEW password yaha daalo
        String password = "AVNS_9T-wEaaSv03_M6knKcf";

        return DriverManager.getConnection(url, user, password);
    }
}
