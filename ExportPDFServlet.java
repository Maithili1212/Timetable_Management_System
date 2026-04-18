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

@WebServlet("/ExportPDFServlet")
public class ExportPDFServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=KIT_Master_Timetable.pdf");

        // Use A4 Rotate to simulate the widescreen 1920x1080 feel
        Document document = new Document(PageSize.A4.rotate(), 20, 20, 20, 20);

        try {
            PdfWriter writer = PdfWriter.getInstance(document, response.getOutputStream());
            
            // --- BORDER EVENT ---
            writer.setPageEvent(new PdfPageEventHelper() {
                @Override
                public void onEndPage(PdfWriter writer, Document document) {
                    PdfContentByte canvas = writer.getDirectContent();
                    Rectangle rect = document.getPageSize();
                    canvas.setLineWidth(3f);
                    canvas.rectangle(rect.getLeft() + 10, rect.getBottom() + 10, rect.getWidth() - 20, rect.getHeight() - 20);
                    canvas.stroke();
                }
            });

            document.open();

            // --- HEADER ---
            Font mainTitleFont = new Font(Font.FontFamily.TIMES_ROMAN, 22, Font.BOLD);
            Paragraph p1 = new Paragraph("K.I.T's College of Engineering (Autonomous), Kolhapur", mainTitleFont);
            p1.setAlignment(Element.ALIGN_CENTER);
            document.add(p1);

            Font subTitleFont = new Font(Font.FontFamily.TIMES_ROMAN, 16, Font.BOLD);
            Paragraph p2 = new Paragraph("Department of CSE - AIML | Master Timetable", subTitleFont);
            p2.setAlignment(Element.ALIGN_CENTER);
            p2.setSpacingAfter(15f);
            document.add(p2);

            // --- DATA STRUCTURES (FIXED AMBIGUITY) ---
            java.util.List<String> slotHeaders = new ArrayList<>();
            java.util.List<Integer> slotIds = new ArrayList<>();
            Map<String, Map<Integer, String>> scheduleMap = new HashMap<>();
            java.util.List<String> days = Arrays.asList("Tuesday", "Wednesday", "Thursday", "Friday", "Saturday");

            // --- DATABASE LOGIC ---
            try (Connection con = DBConnection.getConnection()) {
                // Fetch Time Slots
                Statement stSlots = con.createStatement();
                ResultSet rsSlots = stSlots.executeQuery("SELECT * FROM time_slot ORDER BY slot_order");
                while(rsSlots.next()) {
                    slotIds.add(rsSlots.getInt("slot_id"));
                    slotHeaders.add(rsSlots.getString("start_time").substring(0,5) + "-" + rsSlots.getString("end_time").substring(0,5));
                }

                // Fetch Schedule using LEFT JOIN
                String query = "SELECT t.day_of_week, t.slot_id, t.room_no, s.subject_name, f.faculty_name " +
                               "FROM timetable t " +
                               "LEFT JOIN subject s ON t.subject_id = s.subject_id " +
                               "LEFT JOIN faculty f ON t.faculty_id = f.faculty_id";
                
                Statement st = con.createStatement();
                ResultSet rs = st.executeQuery(query);
                while (rs.next()) {
                    String dayKey = rs.getString("day_of_week").toUpperCase();
                    String subject = rs.getString("subject_name") != null ? rs.getString("subject_name") : "N/A";
                    String faculty = rs.getString("faculty_name") != null ? rs.getString("faculty_name") : "Staff";
                    
                    String cellContent = subject + "\n" + faculty + "\nRm: " + rs.getString("room_no");
                    scheduleMap.computeIfAbsent(dayKey, k -> new HashMap<>()).put(rs.getInt("slot_id"), cellContent);
                }
            }

            // --- TABLE BUILDING ---
            PdfPTable table = new PdfPTable(slotHeaders.size() + 1);
            table.setWidthPercentage(100);
            
            // Header Row
            addCell(table, "DAY / TIME", true, true);
            for (String header : slotHeaders) {
                addCell(table, header, true, true);
            }

            // Data Rows
            for (String day : days) {
                addCell(table, day.toUpperCase(), true, false); // Vertical Day Header
                
                for (Integer sid : slotIds) {
                    String content = scheduleMap.getOrDefault(day.toUpperCase(), new HashMap<>()).getOrDefault(sid, "--");
                    addCell(table, content, false, false);
                }
            }

            document.add(table);
            document.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void addCell(PdfPTable table, String text, boolean isHeader, boolean isTopRow) {
        Font f = new Font(Font.FontFamily.TIMES_ROMAN, isHeader ? 11 : 9, isHeader ? Font.BOLD : Font.NORMAL);
        PdfPCell cell = new PdfPCell(new Phrase(text, f));
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
        cell.setPadding(5);
        cell.setMinimumHeight(60f); // Higher cells for professional look
        
        if (isHeader) {
            cell.setBackgroundColor(isTopRow ? new BaseColor(230, 230, 230) : BaseColor.WHITE);
        } else if (text.equals("--")) {
            cell.setBackgroundColor(new BaseColor(250, 250, 250));
        }
        
        table.addCell(cell);
    }
}