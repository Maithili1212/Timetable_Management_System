<%@ page import="java.sql.*, java.util.*, com.timetable.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    class ScheduleEntry {
        String code, name, faculty, room;
        boolean isLab;
        ScheduleEntry(String c, String n, String f, String r, boolean l) {
            this.code = c; this.name = n; this.faculty = f; this.room = r; this.isLab = l;
        }
    }

    Connection con = null;
    Map<Integer, Map<String, ScheduleEntry>> globalTimetable = new HashMap<>();
    List<String> days = Arrays.asList("Tuesday", "Wednesday", "Thursday", "Friday", "Saturday");
    
    try {
        con = DBConnection.getConnection();
        String mainQuery = "SELECT t.class_id, t.day_of_week, t.slot_id, t.room_no, t.is_lab, " +
                           "s.subject_name, s.subject_code, f.faculty_name " +
                           "FROM timetable t " +
                           "LEFT JOIN subject s ON t.subject_id = s.subject_id " +
                           "LEFT JOIN faculty f ON t.faculty_id = f.faculty_id";
        
        Statement stMain = con.createStatement();
        ResultSet rsMain = stMain.executeQuery(mainQuery);
        
        while(rsMain.next()) {
            int cid = rsMain.getInt("class_id");
            String key = rsMain.getString("day_of_week") + "_" + rsMain.getInt("slot_id");
            globalTimetable.computeIfAbsent(cid, k -> new HashMap<>()).put(key, new ScheduleEntry(
                rsMain.getString("subject_code"), rsMain.getString("subject_name"),
                rsMain.getString("faculty_name"), rsMain.getString("room_no"), rsMain.getBoolean("is_lab")
            ));
        }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Master Schedule &#124; K.I.T. Kolhapur</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        * { box-sizing: border-box; }
        body { 
            background-color: #f0f0f0; 
            margin: 0; display: flex; justify-content: center; align-items: center; 
            height: 100vh; overflow: hidden; font-family: 'Times New Roman', serif; 
        }
        
        .small-box-frame {
            width: 1024px; height: 600px; background: #fff;
            border: 4px solid #000; padding: 15px;
            display: flex; flex-direction: column;
            box-shadow: 0 10px 25px rgba(0,0,0,0.2);
            transform: scale(0.9); transform-origin: center;
        }

        .header { text-align: center; border-bottom: 2px solid #000; padding-bottom: 5px; position: relative; }
        .header h1 { font-size: 22px; font-weight: bold; margin: 0; text-transform: uppercase; }
        .header p { font-size: 14px; margin: 0; font-weight: bold; }

        /* Action Buttons Styling */
        .actions { position: absolute; right: 0; top: 0; display: flex; gap: 5px; }
        .btn-action { 
            font-size: 11px; font-weight: bold; padding: 2px 8px; border: 1.5px solid #000; 
            background: #fff; color: #000; text-decoration: none; cursor: pointer;
        }
        .btn-action:hover { background: #000; color: #fff; }

        .meta-bar { 
            background: #000; color: #fff; padding: 5px 15px; 
            display: flex; justify-content: space-between; 
            font-size: 12px; font-weight: bold; margin-top: 8px;
        }

        .grid-area { flex-grow: 1; margin-top: 8px; border: 1.5px solid #000; overflow: hidden; }
        .table { table-layout: fixed; width: 100%; border-collapse: collapse; margin: 0; }
        .table th, .table td { border: 1px solid #000 !important; text-align: center; vertical-align: middle; padding: 2px !important; }

        .col-time { width: 120px; background: #f5f5f5; font-size: 11px; font-weight: bold; }
        th:not(.col-time) { font-size: 13px; background: #eee; height: 35px; }

        .r-lec { height: 50px; }
        .r-break { height: 30px; background: #f9f9f9 !important; font-size: 11px; font-weight: bold; }

        .t-sub { font-size: 13px; font-weight: 900; display: block; line-height: 1; }
        .t-fac { font-size: 11px; font-weight: bold; display: block; margin-top: 1px; color: #333; }
        .t-rm { font-size: 10px; font-style: italic; display: block; }
        
        .lab-box { height: 100px; border: 2.5px solid #000 !important; }

        @media print {
            .small-box-frame { transform: scale(1); border: 1px solid #000; width: 100%; box-shadow: none; }
            .no-print { display: none; }
        }
    </style>
</head>
<body>

    <div class="small-box-frame">
        <div class="header">
            <div class="actions no-print">
                <button onclick="window.print()" class="btn-action"><i class="bi bi-printer"></i> PRINT</button>
                <a href="ExportPDFServlet" class="btn-action"><i class="bi bi-file-pdf"></i> PDF</a>
            </div>
            <h1>K.I.T's College of Engineering (Autonomous), Kolhapur</h1>
            <p>Master Timetable | Dept. of CSE - AIML</p>
        </div>

        <%
            Statement stClass = con.createStatement();
            ResultSet rsClasses = stClass.executeQuery("SELECT * FROM class LIMIT 1");
            if(rsClasses.next()) {
                int classId = rsClasses.getInt("class_id");
                Set<String> processedLabs = new HashSet<>();
        %>
        <div class="meta-bar">
            <span>CLASS: <%= rsClasses.getString("class_name").toUpperCase() %></span>
            <span>A.Y. 2025-2026</span>
            <span>DIV: <%= rsClasses.getString("division") %></span>
        </div>

        <div class="grid-area">
            <table class="table">
                <thead>
                    <tr>
                        <th class="col-time">TIME</th>
                        <% for(String d : days) { %> <th><%= d.toUpperCase() %></th> <% } %>
                    </tr>
                </thead>
                <tbody>
                <%
                    Statement stTime = con.createStatement();
                    ResultSet rsTime = stTime.executeQuery("SELECT * FROM time_slot ORDER BY slot_order");
                    while(rsTime.next()) {
                        int sid = rsTime.getInt("slot_id");
                        String type = rsTime.getString("slot_type");
                        String timeStr = rsTime.getString("start_time").substring(0, 5) + "-" + rsTime.getString("end_time").substring(0, 5);
                %>
                <tr class="<%= !"LECTURE".equals(type) ? "r-break" : "r-lec" %>">
                    <td class="col-time"><%= timeStr %></td>
                    <% 
                        for(String day : days) { 
                            String key = day + "_" + sid;
                            if(processedLabs.contains(key)) continue;

                            ScheduleEntry entry = globalTimetable.getOrDefault(classId, new HashMap<>()).get(key);
                            if(entry != null) {
                                if(entry.isLab) {
                                    processedLabs.add(day + "_" + (sid + 1));
                    %>
                            <td rowspan="2" class="lab-box">
                                <span style="font-size: 9px; font-weight: 900; text-decoration: underline;">LAB</span>
                                <span class="t-sub"><%= entry.code != null ? entry.code : "N/A" %></span>
                                <span class="t-fac"><%= entry.faculty != null ? entry.faculty : "Staff" %></span>
                                <span class="t-rm">Rm: <%= entry.room %></span>
                            </td>
                    <%          } else { %>
                            <td>
                                <span class="t-sub"><%= entry.code != null ? entry.code : "N/A" %></span>
                                <span class="t-fac"><%= entry.faculty != null ? entry.faculty : "Staff" %></span>
                                <span class="t-rm">Rm: <%= entry.room %></span>
                            </td>
                    <%          }
                            } else if(!"LECTURE".equals(type)) { %>
                                <td style="font-weight:bold;"><%= type %></td>
                            <% } else { %>
                                <td style="opacity: 0.1; font-size: 9px;">--</td>
                    <%      }
                        } %>
                </tr>
                <% } rsTime.close(); stTime.close(); %>
                </tbody>
            </table>
        </div>
        <% } rsClasses.close(); stClass.close(); %>
    </div>

</body>
</html>
<%
    } catch(Exception e) { e.printStackTrace(); } 
    finally { if(con != null) con.close(); }
%>