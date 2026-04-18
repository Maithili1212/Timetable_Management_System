package com.timetable;

import java.sql.Connection;

public class TestConnection {

    public static void main(String[] args) {
        try {
            Connection con = DBConnection.getConnection();

            if (con != null) {
                System.out.println("Connection OK");
            } else {
                System.out.println("Connection FAILED");
            }

        } catch (Exception e) {  // Handles ClassNotFoundException and SQLException
            e.printStackTrace();
        }
    }
}