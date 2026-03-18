package com.timetable;

import java.io.IOException;
import java.sql.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/CreateTimetableServlet")
public class CreateTimetableServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {

            Class.forName("com.mysql.cj.jdbc.Driver");

            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/timetable_db",
                    "root",
                    "2772006");

            // ✅ GET DATA SAFELY
            int class_id = Integer.parseInt(request.getParameter("class_id"));
            int subject_id = Integer.parseInt(request.getParameter("subject_id"));
            int faculty_id = Integer.parseInt(request.getParameter("faculty_id"));
            String day = request.getParameter("day");
            String time_slot = request.getParameter("timeslot");
            int room_no = Integer.parseInt(request.getParameter("room_no"));

            // 🔥 CONFLICT CHECK
            String checkQuery = "SELECT * FROM timetable WHERE day=? AND time_slot=? AND (faculty_id=? OR room_no=?)";

            PreparedStatement checkPs = con.prepareStatement(checkQuery);
            checkPs.setString(1, day);
            checkPs.setString(2, time_slot);
            checkPs.setInt(3, faculty_id);
            checkPs.setInt(4, room_no);

            ResultSet rs = checkPs.executeQuery();

            if (rs.next()) {
                con.close();
                response.sendRedirect(
                        request.getContextPath() + "/CreateTimetable.jsp?msg=Conflict Detected!"
                );
                return;
            }

            // ✅ INSERT
            String query = "INSERT INTO timetable (class_id, subject_id, faculty_id, day, room_no, time_slot) VALUES (?, ?, ?, ?, ?, ?)";

            PreparedStatement ps = con.prepareStatement(query);
            ps.setInt(1, class_id);
            ps.setInt(2, subject_id);
            ps.setInt(3, faculty_id);
            ps.setString(4, day);
            ps.setInt(5, room_no);
            ps.setString(6, time_slot);

            ps.executeUpdate();

            con.close();

            // ✅ SUCCESS
            response.sendRedirect(
                    request.getContextPath() + "/viewTimetable.jsp?msg=Timetable Generated Successfully"
            );

        } catch (NumberFormatException e) {
            response.getWriter().println("Invalid number input");
        } catch (Exception e) {

            // 🔥 SHOW REAL ERROR (for debugging)
            response.setContentType("text/html");
            e.printStackTrace(response.getWriter());
        }
    }
}