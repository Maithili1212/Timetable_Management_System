package com.timetable;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/UpdateTimetableServlet")
public class UpdateTimetableServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String classIdStr = request.getParameter("class_id");
        String day = request.getParameter("day");
        String timeSlot = request.getParameter("time_slot");
        String subjectIdStr = request.getParameter("subject_id");
        String facultyIdStr = request.getParameter("faculty_id");
        boolean isLab = request.getParameter("is_lab") != null;

        try (Connection con = DBConnection.getConnection()) {

            String sql = "UPDATE timetable SET subject_id=?, faculty_id=?, is_lab=? " +
                         "WHERE class_id=? AND day=? AND time_slot=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(subjectIdStr));
            ps.setInt(2, Integer.parseInt(facultyIdStr));
            ps.setBoolean(3, isLab);
            ps.setInt(4, Integer.parseInt(classIdStr));
            ps.setString(5, day);
            ps.setString(6, timeSlot);

            int updatedRows = ps.executeUpdate();

            // If no row updated, insert new
            if (updatedRows == 0) {
                sql = "INSERT INTO timetable (class_id, subject_id, faculty_id, day, time_slot, is_lab) " +
                      "VALUES (?, ?, ?, ?, ?, ?)";
                ps = con.prepareStatement(sql);
                ps.setInt(1, Integer.parseInt(classIdStr));
                ps.setInt(2, Integer.parseInt(subjectIdStr));
                ps.setInt(3, Integer.parseInt(facultyIdStr));
                ps.setString(4, day);
                ps.setString(5, timeSlot);
                ps.setBoolean(6, isLab);
                ps.executeUpdate();
            }

            response.sendRedirect("viewTimetable.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        }
    }
}