
<%@ page import="java.sql.*, com.timetable.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pro Scheduly | Create Timetable</title>

    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">

    <style>
        :root {
            --primary: #4361ee;
            --secondary: #7209b7;
            --bg-light: #f0f2f5;
            --text-main: #2b3674;
            --text-muted: #a3aed0;
            --card-shadow: 0 20px 40px rgba(0,0,0,0.04);
        }

        body {
            background-color: var(--bg-light);
            font-family: 'Plus Jakarta Sans', sans-serif;
            color: var(--text-main);
        }

        .form-box {
            background: white;
            padding: 35px;
            border-radius: 24px;
            box-shadow: var(--card-shadow);
        }

        .title {
            font-size: 22px;
            font-weight: 800;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .form-control, .form-select {
            border-radius: 12px;
            padding: 12px 15px;
            border: 1px solid #e2e8f0;
        }

        .btn-generate {
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            border: none;
            border-radius: 14px;
            font-weight: 800;
            padding: 15px 30px;
            color: white;
        }
    </style>
</head>
<body>

<div class="container-fluid">
    <div class="row">

        <div class="col-lg-2 col-md-3 col-12 p-0 border-end" style="background:white; min-height:100vh;">
            <%@ include file="common/sidebar.jsp" %>
        </div>

        <div class="col-lg-10 col-md-9 col-12 p-4 p-md-5">

            <div class="mb-4">
                <h2 style="font-weight:800;">Create Timetable Entry</h2>
                <p class="text-muted">Assign subjects, faculty, rooms and time slots for each class.</p>
            </div>

            <%
            String msg = request.getParameter("msg");
            if(msg != null){
            %>
                <div class="alert alert-info rounded-4 mb-4">
                    <%= msg %>
                </div>
            <%
            }
            %>

            <div class="form-box">
                <div class="title">
                    <i class="bi bi-calendar-plus"></i> Configure Timetable Slot
                </div>

                <form action="TimetableServlet" method="post">
                    <div class="row g-4">

                    <%
                    Connection con = null;
                    Statement st1 = null, st2 = null, st3 = null, st4 = null;
                    ResultSet rs1 = null, rs2 = null, rs3 = null, rs4 = null;

                    try {
                        con = DBConnection.getConnection();

                        st1 = con.createStatement();
                        st2 = con.createStatement();
                        st3 = con.createStatement();
                        st4 = con.createStatement();

                        rs1 = st1.executeQuery("SELECT class_id, class_name FROM class ORDER BY class_name ASC");
                        rs2 = st2.executeQuery("SELECT subject_id, subject_name, subject_code FROM subject ORDER BY subject_name ASC");
                        rs3 = st3.executeQuery("SELECT faculty_id, faculty_name FROM faculty ORDER BY faculty_name ASC");
                        rs4 = st4.executeQuery("SELECT slot_id, start_time, end_time, slot_type FROM time_slot WHERE slot_type='LECTURE' ORDER BY slot_order ASC");
                    %>

                        <div class="col-md-4">
                            <label class="form-label">Class</label>
                            <select name="class_id" class="form-select" required>
                                <option value="">Select Class</option>
                                <% while(rs1.next()) { %>
                                    <option value="<%= rs1.getInt("class_id") %>">
                                        <%= rs1.getString("class_name") %>
                                    </option>
                                <% } %>
                            </select>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label">Subject</label>
                            <select name="subject_id" class="form-select" required>
                                <option value="">Select Subject</option>
                                <% while(rs2.next()) { %>
                                    <option value="<%= rs2.getInt("subject_id") %>">
                                        <%= rs2.getString("subject_code") %> - <%= rs2.getString("subject_name") %>
                                    </option>
                                <% } %>
                            </select>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label">Faculty</label>
                            <select name="faculty_id" class="form-select" required>
                                <option value="">Select Faculty</option>
                                <% while(rs3.next()) { %>
                                    <option value="<%= rs3.getInt("faculty_id") %>">
                                        <%= rs3.getString("faculty_name") %>
                                    </option>
                                <% } %>
                            </select>
                        </div>

                        <div class="col-md-3">
                            <label class="form-label">Day of Week</label>
                            <select name="day_of_week" class="form-select" required>
                                <option value="">Select Day</option>
                                <option value="Tuesday">Tuesday</option>
                                <option value="Wednesday">Wednesday</option>
                                <option value="Thursday">Thursday</option>
                                <option value="Friday">Friday</option>
                                <option value="Saturday">Saturday</option>
                            </select>
                        </div>

                        <div class="col-md-3">
                            <label class="form-label">Time Slot</label>
                            <select name="slot_id" class="form-select" required>
                                <option value="">Select Slot</option>
                                <% while(rs4.next()) { %>
                                    <option value="<%= rs4.getInt("slot_id") %>">
                                        <%= rs4.getString("start_time") %> - <%= rs4.getString("end_time") %>
                                    </option>
                                <% } %>
                            </select>
                        </div>

                        <div class="col-md-2">
                            <label class="form-label">Room No</label>
                            <input type="text" name="room_no" class="form-control" placeholder="101" required>
                        </div>

                        <div class="col-md-2">
                            <label class="form-label">Is Lab?</label>
                            <select name="is_lab" class="form-select" required>
                                <option value="false">No</option>
                                <option value="true">Yes</option>
                            </select>
                        </div>

                        <div class="col-md-2">
                            <label class="form-label">Double Slot?</label>
                            <select name="is_double_slot" class="form-select" required>
                                <option value="false">No</option>
                                <option value="true">Yes</option>
                            </select>
                        </div>

                        <div class="col-md-12">
                            <label class="form-label">Remarks</label>
                            <textarea name="remarks" class="form-control" rows="3" placeholder="Optional notes about this timetable entry"></textarea>
                        </div>

                    <%
                    } catch(Exception e) {
                        out.println("<div class='alert alert-danger'>" + e.getMessage() + "</div>");
                    } finally {
                        try { if(rs1 != null) rs1.close(); } catch(Exception e) {}
                        try { if(rs2 != null) rs2.close(); } catch(Exception e) {}
                        try { if(rs3 != null) rs3.close(); } catch(Exception e) {}
                        try { if(rs4 != null) rs4.close(); } catch(Exception e) {}
                        try { if(st1 != null) st1.close(); } catch(Exception e) {}
                        try { if(st2 != null) st2.close(); } catch(Exception e) {}
                        try { if(st3 != null) st3.close(); } catch(Exception e) {}
                        try { if(st4 != null) st4.close(); } catch(Exception e) {}
                        try { if(con != null) con.close(); } catch(Exception e) {}
                    }
                    %>

                    </div>

                    <div class="mt-4">
                        <button type="submit" class="btn btn-generate">
                            <i class="bi bi-save me-2"></i> Save Timetable Entry
                        </button>
                    </div>
                </form>
            </div>

        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
