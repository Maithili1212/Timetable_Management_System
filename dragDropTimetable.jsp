<%@ page import="java.sql.*, java.util.*, com.timetable.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Connection con = null;
    Map<String, String[]> timetable = new HashMap<>(); 
    List<String> days = Arrays.asList("Tuesday", "Wednesday", "Thursday", "Friday", "Saturday");
    
    try {
        con = DBConnection.getConnection();
        String query = "SELECT t.day_of_week, t.slot_id, s.subject_code, f.faculty_name, s.subject_id, f.faculty_id " +
                       "FROM timetable t JOIN subject s ON t.subject_id = s.subject_id " +
                       "JOIN faculty f ON t.faculty_id = f.faculty_id WHERE t.class_id = 1";
        ResultSet rs = con.createStatement().executeQuery(query);
        while(rs.next()) {
            timetable.put(rs.getString("day_of_week") + "_" + rs.getInt("slot_id"), 
                new String[]{rs.getString("subject_code"), rs.getString("faculty_name")});
        }
%>
<!DOCTYPE html>
<html>
<head>
    <title>K.I.T. Designer | Drag, Drop &amp;Clear</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background: #f1f5f9; font-family: 'Segoe UI', sans-serif; padding: 20px; }
        .editor-container { display: flex; gap: 20px; justify-content: center; align-items: flex-start; }
        
        .subject-bank { width: 260px; background: white; border: 2px solid #334155; padding: 15px; border-radius: 10px; position: sticky; top: 20px; }
        .draggable-item { 
            background: #f8fafc; border: 1px solid #cbd5e1; padding: 12px; margin-bottom: 10px; 
            cursor: grab; font-weight: 700; border-radius: 8px; text-align: center;
        }
        .draggable-item:active { cursor: grabbing; }

        .master-frame { width: 980px; background: #fff; border: 4px solid #000; padding: 20px; box-shadow: 0 10px 25px rgba(0,0,0,0.1); }
        .header { text-align: center; border-bottom: 2px solid #000; margin-bottom: 20px; }
        
        .tt-table { width: 100%; border-collapse: collapse; table-layout: fixed; }
        .tt-table th, .tt-table td { border: 1px solid #000 !important; text-align: center; vertical-align: middle; height: 80px; }
        
        .drop-zone { background: #fff; cursor: pointer; transition: 0.2s; }
        .drop-zone.hover { background: #f0fdf4 !important; border: 2px dashed #22c55e !important; }
        
        .slot-sub { font-weight: 800; display: block; font-size: 15px; color: #1e40af; }
        .slot-fac { font-size: 11px; color: #64748b; }
        .tip { font-size: 10px; color: #94a3b8; display: block; margin-top: 5px; }
    </style>
</head>
<body>

<div class="editor-container">
    <div class="subject-bank">
        <h6 class="text-center fw-bold border-bottom pb-2">SUBJECTS</h6>
        <%
            ResultSet rsSub = con.createStatement().executeQuery("SELECT s.subject_id, s.subject_code, s.faculty_id, f.faculty_name FROM subject s JOIN faculty f ON s.faculty_id = f.faculty_id");
            while(rsSub.next()) {
        %>
            <div class="draggable-item" draggable="true" 
                 data-subid="<%= rsSub.getInt("subject_id") %>" 
                 data-facid="<%= rsSub.getInt("faculty_id") %>"
                 data-code="<%= rsSub.getString("subject_code") %>"
                 data-facname="<%= rsSub.getString("faculty_name") %>">
                <%= rsSub.getString("subject_code") %>
            </div>
        <% } %>
        <hr>
        <p class="small text-muted text-center"><b>Hint:</b> Double-click a slot to clear it.</p>
        <button class="btn btn-dark btn-sm w-100 fw-bold" onclick="location.reload()">REFRESH VIEW</button>
    </div>

    <div class="master-frame">
        <div class="header">
            <h2 class="fw-bold">K.I.T's College of Engineering, Kolhapur</h2>
            <p class="fw-bold mb-2">SY-AIML Timetable Designer</p>
        </div>

        <table class="tt-table">
            <thead>
                <tr class="table-dark">
                    <th style="width: 120px;">TIME</th>
                    <% for(String d : days) { %> <th><%= d.toUpperCase() %></th> <% } %>
                </tr>
            </thead>
            <tbody>
                <%
                    ResultSet rsTime = con.createStatement().executeQuery("SELECT * FROM time_slot ORDER BY slot_order");
                    while(rsTime.next()) {
                        int sid = rsTime.getInt("slot_id");
                        String type = rsTime.getString("slot_type");
                        String timeStr = rsTime.getString("start_time").substring(0, 5);
                %>
                <tr>
                    <td class="bg-light fw-bold small"><%= timeStr %></td>
                    <% for(String day : days) { 
                        String key = day + "_" + sid;
                        String[] data = timetable.get(key);
                    %>
                        <td class="drop-zone" data-day="<%= day %>" data-slot="<%= sid %>" title="Double-click to clear">
                            <% if(!"LECTURE".equals(type)) { %>
                                <span class="text-muted small fw-bold"><%= type %></span>
                            <% } else if(data != null) { %>
                                <div class="slot-content">
                                    <span class="slot-sub"><%= data[0] %></span>
                                    <span class="slot-fac"><%= data[1] %></span>
                                </div>
                            <% } %>
                        </td>
                    <% } %>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</div>

<script>
    const draggables = document.querySelectorAll('.draggable-item');
    const zones = document.querySelectorAll('.drop-zone');

    draggables.forEach(dr => {
        dr.addEventListener('dragstart', () => dr.classList.add('dragging'));
        dr.addEventListener('dragend', () => dr.classList.remove('dragging'));
    });

    zones.forEach(zone => {
        zone.addEventListener('dragover', e => {
            e.preventDefault();
            zone.classList.add('hover');
        });

        zone.addEventListener('dragleave', () => zone.classList.remove('hover'));

        // DROP ACTION (SAVE/UPDATE)
        zone.addEventListener('drop', e => {
            e.preventDefault();
            zone.classList.remove('hover');
            const dr = document.querySelector('.dragging');
            if(!dr) return;

            const payload = new URLSearchParams({
                action: "SAVE",
                class_id: "1",
                subject_id: dr.dataset.subid,
                faculty_id: dr.dataset.facid,
                slot_id: zone.dataset.slot,
                day: zone.dataset.day
            });

            fetch('<%= request.getContextPath() %>/UpdateTimetableServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: payload
            })
            .then(res => res.text())
            .then(msg => {
                if(msg.trim().includes('success')) {
                    zone.innerHTML = `<div class="slot-content">
                        <span class="slot-sub">${dr.dataset.code}</span>
                        <span class="slot-fac">${dr.dataset.facname}</span>
                    </div>`;
                } else { alert(msg); }
            });
        });

        // DOUBLE CLICK ACTION (DELETE)
        zone.addEventListener('dblclick', () => {
            if(!zone.querySelector('.slot-sub')) return;

            if(confirm("Are you sure you want to clear this slot?")) {
                const payload = new URLSearchParams({
                    action: "DELETE",
                    class_id: "1",
                    slot_id: zone.dataset.slot,
                    day: zone.dataset.day
                });

                fetch('<%= request.getContextPath() %>/UpdateTimetableServlet', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: payload
                })
                .then(res => res.text())
                .then(msg => {
                    if(msg.trim().includes('success')) {
                        zone.innerHTML = "";
                    } else { alert(msg); }
                });
            }
        });
    });
</script>
</body>
</html>
<%
    } catch(Exception e) { e.printStackTrace(); } 
    finally { if(con != null) con.close(); }
%>



