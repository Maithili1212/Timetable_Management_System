package com.timetable;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/ApproveSwap")
public class ApproveSwap extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        
        // Error Check 1: Handle null or empty ID
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect("viewSwapRequests.jsp?msg=invalid_id");
            return;
        }

        Connection con = null;
        try {
            con = DBConnection.getConnection();
            // Start Transaction
            con.setAutoCommit(false);

            int requestId = Integer.parseInt(idParam);

            // Step 1: Get the details of the swap (to_faculty and timetable_id)
            String getRequestSql = "SELECT timetable_id, to_faculty FROM swap_requests WHERE request_id = ?";
            PreparedStatement psGet = con.prepareStatement(getRequestSql);
            psGet.setInt(1, requestId);
            ResultSet rs = psGet.executeQuery();

            if (rs.next()) {
                int timetableId = rs.getInt("timetable_id");
                int newFacultyId = rs.getInt("to_faculty");

                // Step 2: Update the Timetable table with the new faculty
                String updateTimetableSql = "UPDATE timetable SET faculty_id = ? WHERE timetable_id = ?";
                PreparedStatement psTime = con.prepareStatement(updateTimetableSql);
                psTime.setInt(1, newFacultyId);
                psTime.setInt(2, timetableId);
                psTime.executeUpdate();

                // Step 3: Update the Swap Request status to 'Approved'
                String updateStatusSql = "UPDATE swap_requests SET status = 'Approved' WHERE request_id = ?";
                PreparedStatement psStatus = con.prepareStatement(updateStatusSql);
                psStatus.setInt(1, requestId);
                psStatus.executeUpdate();

                // Commit the changes
                con.commit();
                response.sendRedirect("viewSwapRequests.jsp?msg=approved");
            } else {
                response.sendRedirect("viewSwapRequests.jsp?msg=notfound");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect("viewSwapRequests.jsp?msg=invalid_format");
        } catch (Exception e) {
            if (con != null) { 
                try { con.rollback(); } catch (Exception ex) { ex.printStackTrace(); } 
            }
            e.printStackTrace();
            response.sendRedirect("viewSwapRequests.jsp?msg=exception");
        } finally {
            if (con != null) { 
                try { con.close(); } catch (Exception e) { e.printStackTrace(); } 
            }
        }
    }
}