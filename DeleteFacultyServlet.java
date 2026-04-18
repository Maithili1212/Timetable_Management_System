package com.timetable;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/DeleteFacultyServlet")
public class DeleteFacultyServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Connection con = null;
        PreparedStatement ps = null;

        try {
            String idParam = request.getParameter("id");

            if (idParam == null || idParam.trim().isEmpty()) {
                response.sendRedirect("addFaculty.jsp?msg=Invalid Faculty ID");
                return;
            }

            int id = Integer.parseInt(idParam.trim());

            con = DBConnection.getConnection();

            String sql = "DELETE FROM faculty WHERE faculty_id=?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, id);

            int status = ps.executeUpdate();

            if (status > 0) {
                response.sendRedirect("addFaculty.jsp?msg=Faculty Deleted Successfully");
            } else {
                response.sendRedirect("addFaculty.jsp?msg=Faculty Not Found");
            }

        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect("addFaculty.jsp?msg=Invalid ID Format");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("addFaculty.jsp?msg=Error While Deleting Faculty");

        } finally {
            try { if (ps != null) ps.close(); } catch (Exception ignored) {}
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }
    }
}