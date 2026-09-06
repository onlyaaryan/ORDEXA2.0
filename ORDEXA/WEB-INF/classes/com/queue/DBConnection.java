package com.queue;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {
    public static Connection getConnection() {
        Connection con = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String url = "jdbc:mysql://mysql-1bb86359-ordexa1.a.aivencloud.com:14191/defaultdb?useSSL=true&requireSSL=true&serverTimezone=UTC";
            String user = "avnadmin";
            String password = "AVNS_9T-wEaaSv03_M6knKcf";

            con = DriverManager.getConnection(url, user, password);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return con;
    }
}