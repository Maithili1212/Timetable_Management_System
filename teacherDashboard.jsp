<%@ page import="java.sql.*, com.timetable.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    // Adjusting to match your faculty table primary key naming
    Integer facultyId = (Integer) session.getAttribute("faculty_id");
    if (facultyId == null) {
        // Fallback for different session naming
        facultyId = (Integer) session.getAttribute("teacherId");
    }

    if (facultyId == null) {
        response.sendRedirect("login.jsp?msg=Session Expired");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pro Scheduly | Teacher Dashboard</title>

    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">

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

        .navbar {
            background: rgba(255, 255, 255, 0.85) !important;
            backdrop-filter: blur(12px);
            border-bottom: 1px solid rgba(0,0,0,0.05);
            padding: 0.8rem 2rem;
            z-index: 1000;
        }

        .brand-icon {
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            width: 38px; height: 38px;
            display: flex; align-items: center; justify-content: center;
            border-radius: 10px; color: white; margin-right: 12px;
            box-shadow: 0 4px 12px rgba(67, 97, 238, 0.3);
        }

        .header-card {
            background: linear-gradient(135deg, #2b3674, #4361ee);
            border-radius: 24px;
            padding: 35px;
            color: white;
            margin-bottom: 30px;
            box-shadow: var(--card-shadow);
        }

        .form-box {
            background: white;
            padding: 30px;
            border-radius: 24px;
            box-shadow: var(--card-shadow);
            margin-bottom: 30px;
        }

        .title {
            font-size: 20px;
            font-weight: 800;
            color: var(--text-main);
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .title i {
            color: var(--primary);
            background: #eef2ff;
            padding: 8px;
            border-radius: 10px;
        }

        .badge-time {
            background: rgba(67, 97, 238, 0.1);
            color: var(--primary);
            padding: 6px 12px;
            border-radius: 8px;
            font-weight: 700;
            font-size: 0.85rem;
        }

        .table thead th {
            color: var(--text-muted);
            font-size: 0.75rem;
            text-transform: uppercase;
            border: none;
            padding: 15px;
        }

        .table tbody td {
            padding: 16px 15px;
            vertical-align: middle;
        }

        .dataTables_filter { display: none; }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg sticky-top">
    <div class="container-fluid">
        <a class="navbar-brand d-flex align-items-center" href="teacherDashboard.jsp">
            <span class="brand-icon"><i class="bi bi-grid-fill"></i></span>
            <span style="font-weight:800; letter-spacing:-0.5px; color: var(--text-main);">SCHEDULY</span>
        </a>

        <div class="ms-auto d-flex align-items-center">
            <span class="small fw-bold text-dark me-3">Faculty ID: #<%= facultyId %></span>
            <a href="LogoutServlet" class="btn btn-outline-danger btn-sm rounded-pill px-3">
                <i class="bi bi-box-arrow-right me-1"></i> Logout
            </a>
        </div>
    </div>
</nav>

<div class="container-fluid">
    <div class="row">

        <div class="col-lg-2 col-md-3 col-12 p-0 border-end" style="background: white; min-height: calc(100vh - 70px);">
            <%@ include file="common/sidebar.jsp" %>
        </div>

        <div class="col-lg-10 col-md-9 col-12 p-4 p-md-5">

            <div class="header-card">
                <h1 class="fw-bold mb-2">Welcome Back, Professor</h1>
                <p class="mb-0 opacity-75">Manage your daily lecture schedule and classroom assignments.</p>
            </div>

            <div class="form-box">
                <div class="d-flex flex-wrap justify-content-between align-items-center mb-4">
                    <div class="title mb-3 mb-md-0">
                        <i class="bi bi-calendar-week"></i>
                        Daily Lecture Assignments
                    </div>

                    <div style="min-width: 280px;">
                        <div class="input-group">
                            <span class="input-group-text bg-white border-end-0">
                                <i class="bi bi-search text-muted"></i>
                            </span>
                            <input type="text" id="searchInput" class="form-control border-start-0" placeholder="Search lectures...">
                        </div>
                    </div>
                </div>

                <div class="table-responsive">
                    <table id="myTable" class="table table-hover align-middle">
                        <thead>
                            <tr>
                                <th>Day</th>
                                <th>Subject</th>
                                <th>Class</th>
                                <th>Time</th>
                                <th>Room</th>
                                <th class="text-end">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            try (Connection con = DBConnection.getConnection()) {
                                // Updated Query to match your provided SQL schema
                                String sql = "SELECT t.timetable_id, t.day_of_week, ts.start_time, ts.end_time, t.room_no, s.subject_name, c.class_name " +
                                             "FROM timetable t " +
                                             "JOIN subject s ON t.subject_id = s.subject_id " +
                                             "JOIN class c ON t.class_id = c.class_id " +
                                             "JOIN time_slot ts ON t.slot_id = ts.slot_id " +
                                             "WHERE t.faculty_id = ? " +
                                             "ORDER BY FIELD(t.day_of_week, 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'), ts.start_time";

                                PreparedStatement ps = con.prepareStatement(sql);
                                ps.setInt(1, facultyId);
                                ResultSet rs = ps.executeQuery();

                                boolean found = false;
                                while(rs.next()) {
                                    found = true;
                                    String timeRange = rs.getString("start_time").substring(0,5) + " - " + rs.getString("end_time").substring(0,5);
                            %>
                            <tr>
                                <td class="fw-bold"><%= rs.getString("day_of_week") %></td>
                                <td>
                                    <div class="d-flex align-items-center">
                                        <div class="bg-primary bg-opacity-10 text-primary rounded-3 p-2 me-3">
                                            <i class="bi bi-book"></i>
                                        </div>
                                        <span class="fw-bold"><%= rs.getString("subject_name") %></span>
                                    </div>
                                </td>
                                <td><span class="fw-semibold text-muted"><%= rs.getString("class_name") %></span></td>
                                <td><span class="badge-time"><%= timeRange %></span></td>
                                <td>
                                    <i class="bi bi-geo-alt-fill text-danger me-1"></i>
                                    Room <%= rs.getString("room_no") %>
                                </td>
                                <td class="text-end">
                                    <a href="requestSwap.jsp?timetable_id=<%= rs.getInt("timetable_id") %>" class="btn btn-outline-primary btn-sm rounded-pill px-3 fw-bold">
                                        <i class="bi bi-arrow-left-right me-1"></i> Swap
                                    </a>
                                </td>
                            </tr>
                            <%
                                }
                                if(!found) {
                            %>
                            <tr>
                                <td colspan="6" class="text-center py-5 text-muted">
                                    <i class="bi bi-calendar-x fs-1 d-block mb-3"></i>
                                    No lectures assigned yet for this semester.
                                </td>
                            </tr>
                            <%
                                }
                            } catch(Exception e) {
                                out.println("<tr><td colspan='6' class='text-danger text-center'>Error: " + e.getMessage() + "</td></tr>");
                            }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>

<script>
$(document).ready(function() {
    var table = $('#myTable').DataTable({
        pageLength: 10,
        dom: 'rtip', // Hides default search box since we have a custom one
        language: {
            paginate: {
                next: '<i class="bi bi-chevron-right"></i>',
                previous: '<i class="bi bi-chevron-left"></i>'
            }
        }
    });

    $('#searchInput').on('keyup', function() {
        table.search(this.value).draw();
    });
});
</script>

</body>
</html>