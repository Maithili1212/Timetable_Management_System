package com.timetable;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.http.*;


public class SwapRequestServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int timetable_id = Integer.parseInt(request.getParameter("timetable_id"));
        int to_faculty = Integer.parseInt(request.getParameter("to_faculty"));
        String reason = request.getParameter("reason");

        try {
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/timetable_db","root",""
            );

            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO swap_requests(from_faculty, to_faculty, timetable_id, reason, status) VALUES (?,?,?,?, 'PENDING')"
            );

            ps.setInt(1, 1); // you can replace with session faculty_id
            ps.setInt(2, to_faculty);
            ps.setInt(3, timetable_id);
            ps.setString(4, reason);

            ps.executeUpdate();

            response.sendRedirect("teacherDashboard.jsp");

        } catch(Exception e) {
            e.printStackTrace();
        }
    }
}