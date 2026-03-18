package com.timetable;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import com.google.gson.Gson;

@WebServlet("/FetchFacultiesServlet")
public class FetchFacultiesServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");

        try (Connection con = DBConnection.getConnection();
             Statement stmt = con.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT faculty_id, faculty_name FROM faculty")) {

            List<Faculty> faculties = new ArrayList<>();
            while (rs.next()) {
                faculties.add(new Faculty(rs.getInt("faculty_id"), rs.getString("faculty_name")));
            }

            String json = new Gson().toJson(faculties);
            response.getWriter().write(json);

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    @SuppressWarnings("unused") // Gson uses fields via reflection
    private static class Faculty {
        public int faculty_id;
        public String faculty_name;

        public Faculty(int id, String name) {
            this.faculty_id = id;
            this.faculty_name = name;
        }
    }
}