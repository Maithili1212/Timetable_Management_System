package com.timetable;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/FacultyServlet")
public class FacultyServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String name = request.getParameter("faculty_name");
        String dept = request.getParameter("department");

        Connection con = null;
        PreparedStatement ps = null;

        try {

            // Get DB connection
            con = DBConnection.getConnection();

            // Insert query
            ps = con.prepareStatement(
                "INSERT INTO faculty(faculty_name, department) VALUES (?, ?)"
            );

            ps.setString(1, name);
            ps.setString(2, dept);

            int i = ps.executeUpdate();

            if (i > 0) {
                // ✅ SUCCESS REDIRECT
                response.sendRedirect(
                    request.getContextPath() + "/addFaculty.jsp?msg=Faculty Added Successfully"
                );
            } else {
                // ❌ FAILURE REDIRECT
                response.sendRedirect(
                    request.getContextPath() + "/addFaculty.jsp?msg=Insert Failed"
                );
            }

        } catch (Exception e) {
            e.printStackTrace();

            // ❌ ERROR REDIRECT
            response.sendRedirect(
                request.getContextPath() + "/addFaculty.jsp?msg=Error Occurred"
            );

        } finally {
            // Close resources
            try {
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}