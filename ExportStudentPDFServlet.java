package com.timetable;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

// iText Library Imports
import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;

@WebServlet("/ExportStudentPDFServlet")
public class ExportStudentPDFServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // Use the days consistent with your DB ENUM
    private final String[] days = {"Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String student = (String) session.getAttribute("studentUser");
        Integer classId = (Integer) session.getAttribute("class_id");

        if (classId == null || student == null) {
            response.sendRedirect("login.jsp?msg=Session Expired");
            return;
        }

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=KIT_Student_Timetable.pdf");

        // Set Landscape orientation to match the 16:9 widescreen feel
        Document doc = new Document(PageSize.A4.rotate(), 30, 30, 30, 30);

        try {
            PdfWriter writer = PdfWriter.getInstance(doc, response.getOutputStream());
            
            // --- ADD DOUBLE BORDER PAGE EVENT ---
            writer.setPageEvent(new PdfPageEventHelper() {
                @Override
                public void onEndPage(PdfWriter writer, Document document) {
                    PdfContentByte canvas = writer.getDirectContent();
                    Rectangle rect = document.getPageSize();
                    // Outer Border
                    rect.setBorder(Rectangle.BOX);
                    rect.setBorderWidth(5);
                    rect.setBorderColor(BaseColor.BLACK);
                    canvas.rectangle(rect);
                    // Inner Border (Double Effect)
                    canvas.setLineWidth(1f);
                    canvas.rectangle(20, 20, rect.getWidth() - 40, rect.getHeight() - 40);
                    canvas.stroke();
                }
            });

            doc.open();

            // 1. Institutional Header (Consistent with your JSP)
            Font mainTitleFont = new Font(Font.FontFamily.TIMES_ROMAN, 22, Font.BOLD);
            Paragraph p1 = new Paragraph("K.I.T's College of Engineering (Autonomous), Kolhapur", mainTitleFont);
            p1.setAlignment(Element.ALIGN_CENTER);
            doc.add(p1);

            Font subTitleFont = new Font(Font.FontFamily.TIMES_ROMAN, 16, Font.BOLD);
            Paragraph p2 = new Paragraph("Department of CSE - AIML | Student Schedule", subTitleFont);
            p2.setAlignment(Element.ALIGN_CENTER);
            doc.add(p2);

            // Metadata Strip (Black bar equivalent)
            Font metaFont = new Font(Font.FontFamily.TIMES_ROMAN, 12, Font.BOLD, BaseColor.WHITE);
            PdfPTable metaTable = new PdfPTable(1);
            metaTable.setWidthPercentage(100);
            metaTable.setSpacingBefore(10f);
            metaTable.setSpacingAfter(10f);
            
            PdfPCell metaCell = new PdfPCell(new Phrase("STUDENT: " + student.toUpperCase() + "  |  A.Y. 2025-26  |  CLASS ID: #" + classId, metaFont));
            metaCell.setBackgroundColor(BaseColor.BLACK);
            metaCell.setPadding(5);
            metaCell.setHorizontalAlignment(Element.ALIGN_CENTER);
            metaTable.addCell(metaCell);
            doc.add(metaTable);

            // 2. Data Structures
         // Use the full package path to resolve ambiguity
            java.util.List<String> slotHeaders = new java.util.ArrayList<>();
            Map<String, Map<Integer, String>> timetableGrid = new HashMap<>();

            try (Connection con = DBConnection.getConnection()) {
                // Fetch dynamic time slots
                Statement stSlots = con.createStatement();
                ResultSet rsSlots = stSlots.executeQuery("SELECT * FROM time_slot ORDER BY slot_order");
                while (rsSlots.next()) {
                    slotHeaders.add(rsSlots.getString("start_time").substring(0, 5) + "-" + rsSlots.getString("end_time").substring(0, 5));
                }

                // Fetch data with LEFT JOIN to prevent missing subjects
                String sql = "SELECT t.day_of_week, t.slot_id, t.room_no, s.subject_name, f.faculty_name " +
                             "FROM timetable t " +
                             "LEFT JOIN subject s ON t.subject_id = s.subject_id " +
                             "LEFT JOIN faculty f ON t.faculty_id = f.faculty_id " +
                             "WHERE t.class_id = ?";
                
                PreparedStatement ps = con.prepareStatement(sql);
                ps.setInt(1, classId);
                ResultSet rs = ps.executeQuery();

                while (rs.next()) {
                    String d = rs.getString("day_of_week").trim().toUpperCase();
                    String content = rs.getString("subject_name") + "\n" + 
                                     rs.getString("faculty_name") + "\nRm: " + 
                                     rs.getString("room_no");

                    timetableGrid.computeIfAbsent(d, k -> new HashMap<>()).put(rs.getInt("slot_id"), content);
                }
            }

            // 3. Table Construction
            PdfPTable table = new PdfPTable(slotHeaders.size() + 1);
            table.setWidthPercentage(100);

            // Table Header Row
            addStyledCell(table, "Day / Time", true, true);
            for (String header : slotHeaders) {
                addStyledCell(table, header, true, true);
            }

            // Body Rows
            for (String day : days) {
                addStyledCell(table, day.toUpperCase(), true, false); // Day Header (Left Column)

                for (int i = 1; i <= slotHeaders.size(); i++) {
                    String cellContent = timetableGrid.getOrDefault(day.toUpperCase(), new HashMap<>())
                                                      .getOrDefault(i, "--");
                    addStyledCell(table, cellContent, false, false);
                }
            }

            doc.add(table);
            doc.close();

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(500, "PDF Generation Failed");
        }
    }

    private void addStyledCell(PdfPTable table, String text, boolean isHeader, boolean isTopRow) {
        Font font = new Font(Font.FontFamily.TIMES_ROMAN, isHeader ? 11 : 9, isHeader ? Font.BOLD : Font.NORMAL);
        
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setPadding(6);
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
        cell.setMinimumHeight(55f); // Consistent with 1080px row scaling
        
        if (isHeader) {
            // Light grey for top headers, white for side headers
            cell.setBackgroundColor(isTopRow ? new BaseColor(230, 230, 230) : BaseColor.WHITE);
        } else if (text.equals("--")) {
            cell.setBackgroundColor(new BaseColor(250, 250, 250));
        }
        
        table.addCell(cell);
    }
}