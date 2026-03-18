package com.timetable;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ClassServlet")
public class ClassServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String className = request.getParameter("class_name");
        String semester = request.getParameter("semester");

        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = DBConnection.getConnection();

            ps = con.prepareStatement(
                "INSERT INTO class(class_name, semester) VALUES (?, ?)"
            );

            ps.setString(1, className);
            ps.setInt(2, Integer.parseInt(semester));

            ps.executeUpdate();

            // ✅ FIXED REDIRECT
            response.sendRedirect(
                request.getContextPath() + "/addClass.jsp?msg=Class Added Successfully"
            );

        } catch (Exception e) {
            e.printStackTrace();

            response.sendRedirect(
                request.getContextPath() + "/addClass.jsp?msg=Error Occurred"
            );

        } finally {
            try {
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }
    }
}