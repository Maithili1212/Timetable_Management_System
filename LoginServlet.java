package com.timetable;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        Connection con = null;

        try {
            con = DBConnection.getConnection();
            HttpSession session = request.getSession();

            // ================= 1. ADMIN LOGIN =================
            PreparedStatement ps1 = con.prepareStatement(
                "SELECT * FROM admin WHERE username=? AND password=?"
            );
            ps1.setString(1, username);
            ps1.setString(2, password);

            ResultSet rs1 = ps1.executeQuery();

            if (rs1.next()) {

                session.setAttribute("role", "ADMIN");
                session.setAttribute("adminUser", username);

                rs1.close();
                ps1.close();

                response.sendRedirect("index.jsp"); // ✅ FIXED
                return;
            }

            rs1.close();
            ps1.close();

            // ================= 2. TEACHER LOGIN =================
            PreparedStatement ps2 = con.prepareStatement(
                "SELECT * FROM faculty WHERE faculty_name=? AND password=?"
            );
            ps2.setString(1, username);
            ps2.setString(2, password);

            ResultSet rs2 = ps2.executeQuery();

            if (rs2.next()) {

                session.setAttribute("role", "TEACHER");
                session.setAttribute("teacherId", rs2.getInt("faculty_id"));
                session.setAttribute("teacherName", rs2.getString("faculty_name"));

                rs2.close();
                ps2.close();

                response.sendRedirect("teacherDashboard.jsp");
                return;
            }

            rs2.close();
            ps2.close();

            // ================= 3. STUDENT LOGIN =================
            PreparedStatement ps3 = con.prepareStatement(
                "SELECT * FROM student WHERE username=? AND password=?"
            );
            ps3.setString(1, username);
            ps3.setString(2, password);

            ResultSet rs3 = ps3.executeQuery();

            if (rs3.next()) {

                session.setAttribute("role", "STUDENT");
                session.setAttribute("studentUser", username);
                session.setAttribute("class_id", rs3.getInt("class_id"));

                rs3.close();
                ps3.close();

                response.sendRedirect("studentDashboard.jsp");
                return;
            }

            rs3.close();
            ps3.close();

            // ================= INVALID LOGIN =================
            response.sendRedirect("login.jsp?msg=Invalid Username or Password");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?msg=Server Error");

        } finally {
            try {
                if (con != null) con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}