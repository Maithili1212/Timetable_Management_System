package com.timetable;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;

@WebServlet("/ExportPDFServlet")
public class ExportPDFServlet extends HttpServlet {

    private static final long serialVersionUID = 1L; // ✅ fix warning

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=timetable.pdf");

        Connection con = null;

        try {

            // ✅ Create PDF
            Document document = new Document();
            PdfWriter.getInstance(document, response.getOutputStream());
            document.open();

            // ✅ Title
            Font font = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD);
            Paragraph title = new Paragraph("Timetable Report\n\n", font);
            title.setAlignment(Element.ALIGN_CENTER);
            document.add(title);

            // ✅ DB Connection
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/timetable_db",
                    "root",
                    "2772006");

            String query = "SELECT c.class_name, t.day, t.time_slot, "
                    + "s.subject_name, f.faculty_name, t.room_no "
                    + "FROM timetable t "
                    + "JOIN class c ON t.class_id = c.class_id "
                    + "JOIN subject s ON t.subject_id = s.subject_id "
                    + "JOIN faculty f ON t.faculty_id = f.faculty_id "
                    + "ORDER BY c.class_name, t.day, t.time_slot";

            Statement st = con.createStatement();
            ResultSet rs = st.executeQuery(query);

            // ✅ Table
            PdfPTable table = new PdfPTable(6);
            table.setWidthPercentage(100);

            table.addCell("Class");
            table.addCell("Day");
            table.addCell("Time");
            table.addCell("Subject");
            table.addCell("Faculty");
            table.addCell("Room");

            while (rs.next()) {
                table.addCell(rs.getString("class_name"));
                table.addCell(rs.getString("day"));
                table.addCell(rs.getString("time_slot"));
                table.addCell(rs.getString("subject_name"));
                table.addCell(rs.getString("faculty_name"));
                table.addCell(String.valueOf(rs.getInt("room_no")));
            }

            document.add(table);

            // ✅ Close everything
            rs.close();
            st.close();
            con.close();
            document.close();

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error generating PDF: " + e.getMessage());
        }
    }
}