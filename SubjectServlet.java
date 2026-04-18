package com.timetable;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/SubjectServlet")
public class SubjectServlet extends HttpServlet {

    // ✅ FIX ADDED HERE
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String subject_name = request.getParameter("subject_name");
        String faculty_id = request.getParameter("faculty_id");
        String hours = request.getParameter("hours");

        try {

            Class.forName("com.mysql.cj.jdbc.Driver");

            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/timetable_db",
                    "root",
                    "2772006");

            PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO subject(subject_name, faculty_id, hours_per_week) VALUES(?,?,?)");

            ps.setString(1, subject_name);
            ps.setInt(2, Integer.parseInt(faculty_id));
            ps.setInt(3, Integer.parseInt(hours));

            int i = ps.executeUpdate();

            if (i > 0) {
                response.sendRedirect(request.getContextPath() + "/addSubject.jsp?msg=Success");
            } else {
                response.sendRedirect(request.getContextPath() + "/addSubject.jsp?msg=Failed");
            }

            con.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}