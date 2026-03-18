package com.timetable;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import com.google.gson.Gson;

@WebServlet("/FetchSubjectsServlet")
public class FetchSubjectsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");

        try (Connection con = DBConnection.getConnection();
             Statement stmt = con.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT subject_id, subject_name FROM subject")) {

            List<Subject> subjects = new ArrayList<>();
            while (rs.next()) {
                subjects.add(new Subject(rs.getInt("subject_id"), rs.getString("subject_name")));
            }

            String json = new Gson().toJson(subjects);
            response.getWriter().write(json);

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    @SuppressWarnings("unused") // Gson uses fields via reflection
    private static class Subject {
        public int subject_id;
        public String subject_name;

        public Subject(int id, String name) {
            this.subject_id = id;
            this.subject_name = name;
        }
    }
}