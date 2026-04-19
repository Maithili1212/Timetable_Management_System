package com.timetable;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/RejectSwap")
public class RejectSwap extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        
        // Error Check: Handle null or empty ID to prevent NumberFormatException
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect("viewSwapRequests.jsp?msg=invalid_id");
            return;
        }

        try (Connection con = DBConnection.getConnection()) {
            int requestId = Integer.parseInt(idParam);

            // Update the status to 'Rejected'
            // We only update the request status; the timetable remains unchanged
            String sql = "UPDATE swap_requests SET status = 'Rejected' WHERE request_id = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, requestId);
            
            int rowsAffected = ps.executeUpdate();
            
            if (rowsAffected > 0) {
                response.sendRedirect("viewSwapRequests.jsp?msg=rejected");
            } else {
                response.sendRedirect("viewSwapRequests.jsp?msg=notfound");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect("viewSwapRequests.jsp?msg=invalid_format");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("viewSwapRequests.jsp?msg=exception");
        }
    }
}