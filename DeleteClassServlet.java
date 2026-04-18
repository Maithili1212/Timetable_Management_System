package com.timetable;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/DeleteClassServlet")
public class DeleteClassServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Connection con = null;
        PreparedStatement ps = null;

        try {
            int id = Integer.parseInt(request.getParameter("id"));

            con = DBConnection.getConnection();

            String sql = "DELETE FROM class WHERE class_id=?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, id);

            int status = ps.executeUpdate();

            if (status > 0) {
                response.sendRedirect("addClass.jsp?msg=Class Deleted Successfully");
            } else {
                response.sendRedirect("addClass.jsp?msg=Class Not Found");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("addClass.jsp?msg=Error While Deleting Class");

        } finally {
            try { if (ps != null) ps.close(); } catch (Exception ignored) {}
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }
    }
}