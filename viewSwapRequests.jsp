<%@ page import="java.sql.*, com.timetable.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pro Scheduly | Swap Requests</title>

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
            background: rgba(255, 255, 255, 0.8) !important;
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

        .form-box {
            background: white;
            padding: 30px;
            border-radius: 24px;
            border: 1px solid rgba(255, 255, 255, 0.3);
            box-shadow: var(--card-shadow);
            margin-bottom: 30px;
        }

        .title {
            font-size: 20px; font-weight: 800; margin-bottom: 20px;
            color: var(--text-main); display: flex; align-items: center; gap: 12px;
        }

        .title i { color: var(--primary); background: #f4f7fe; padding: 8px; border-radius: 10px; }

        .status-badge {
            padding: 6px 14px; border-radius: 8px; font-size: 0.75rem;
            font-weight: 700; text-transform: uppercase;
        }

        .pending { background: rgba(255, 193, 7, 0.1); color: #ffc107; }
        .approved { background: rgba(25, 135, 84, 0.1); color: #198754; }
        .rejected { background: rgba(220, 53, 69, 0.1); color: #dc3545; }

        .btn-action { border-radius: 10px; font-weight: 700; padding: 8px 16px; font-size: 0.85rem; transition: 0.2s; }
        .btn-action:hover { transform: translateY(-2px); }

        .dataTables_filter { display: none; }
    </style>
</head>

<body>

<nav class="navbar navbar-expand-lg sticky-top">
    <div class="container-fluid">
        <a class="navbar-brand d-flex align-items-center" href="dashboard.jsp">
            <span class="brand-icon"><i class="bi bi-grid-fill"></i></span>
            <span style="font-weight: 800; letter-spacing: -0.5px; color: var(--text-main);">SCHEDULY</span>
        </a>

        <div class="ms-auto d-flex align-items-center">
            <div class="dropdown">
                <a class="d-flex align-items-center text-decoration-none dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                    <span class="text-end me-3 d-none d-md-flex flex-column justify-content-center">
                        <span class="small fw-bold text-dark" style="line-height: 1;">Admin User</span>
                        <span class="text-muted" style="font-size: 0.7rem;">Super Admin</span>
                    </span>
                    <img src="https://ui-avatars.com/api/?name=Admin&background=4361ee&color=fff" class="rounded-circle border" width="38">
                </a>
                <ul class="dropdown-menu dropdown-menu-end shadow border-0 mt-3 rounded-4">
                    <li><a class="dropdown-item py-2" href="profile.jsp"><i class="bi bi-person me-2"></i> Profile</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item py-2 text-danger fw-bold" href="LogoutServlet"><i class="bi bi-box-arrow-right me-2"></i> Logout</a></li>
                </ul>
            </div>
        </div>
    </div>
</nav>

<div class="container-fluid">
    <div class="row">

        <div class="col-lg-2 col-md-3 col-12 p-0 border-end" style="background: white; min-height: calc(100vh - 70px);">
            <%@ include file="common/sidebar.jsp" %>
        </div>

        <div class="col-lg-10 col-md-9 col-12 p-4 p-md-5">

            <div class="row mb-4">
                <div class="col-12">
                    <h2 class="fw-800" style="font-weight: 800; color: var(--text-main);">Swap Request Management</h2>
                    <p class="text-muted">Review and process lecture exchange requests from faculty members.</p>
                </div>
            </div>

            <div class="form-box">
                <div class="d-md-flex justify-content-between align-items-center mb-4">
                    <div class="title mb-0">
                        <i class="bi bi-arrow-repeat"></i> Request Queue
                    </div>
                    <div class="mt-3 mt-md-0" style="min-width: 300px;">
                        <div class="input-group shadow-sm" style="border-radius: 12px; overflow: hidden;">
                            <span class="input-group-text bg-white border-end-0">
                                <i class="bi bi-search text-muted"></i>
                            </span>
                            <input type="text" id="searchInput" class="form-control border-start-0" placeholder="Search requests...">
                        </div>
                    </div>
                </div>

                <div class="table-responsive">
                    <table id="myTable" class="table table-hover align-middle">
                        <thead>
                            <tr>
                                <th>Request ID</th>
                                <th>Schedule Info</th>
                                <th>From Faculty</th>
                                <th>To Faculty</th>
                                <th>Reason</th>
                                <th>Status</th>
                                <th class="text-end">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                        try (Connection con = DBConnection.getConnection()) {
                            // Joining with faculty, subject, and time_slot for a better UI
                            String sql = "SELECT sr.*, f1.faculty_name as from_name, f2.faculty_name as to_name, " +
                                         "s.subject_name, t.day_of_week, ts.start_time " +
                                         "FROM swap_requests sr " +
                                         "JOIN faculty f1 ON sr.from_faculty = f1.faculty_id " +
                                         "JOIN faculty f2 ON sr.to_faculty = f2.faculty_id " +
                                         "JOIN timetable t ON sr.timetable_id = t.timetable_id " +
                                         "JOIN subject s ON t.subject_id = s.subject_id " +
                                         "JOIN time_slot ts ON t.slot_id = ts.slot_id " +
                                         "ORDER BY sr.request_id DESC";
                            
                            Statement st = con.createStatement();
                            ResultSet rs = st.executeQuery(sql);

                            while(rs.next()){
                                String status = rs.getString("status");
                                String badgeClass = status.toLowerCase();
                        %>
                            <tr>
                                <td class="fw-bold text-muted">#<%=rs.getInt("request_id")%></td>
                                <td>
                                    <div class="small fw-bold text-primary"><%=rs.getString("subject_name")%></div>
                                    <div class="text-muted" style="font-size: 0.75rem;">
                                        <%=rs.getString("day_of_week")%> | <%=rs.getString("start_time").substring(0,5)%>
                                    </div>
                                </td>
                                <td class="fw-bold"><%=rs.getString("from_name")%></td>
                                <td class="fw-bold"><%=rs.getString("to_name")%></td>
                                <td class="small text-muted"><%=rs.getString("reason")%></td>
                                <td><span class="status-badge <%=badgeClass%>"><%=status%></span></td>
                                <td class="text-end">
                                    <% if("Pending".equalsIgnoreCase(status)) { %>
                                        <a href="ApproveSwap?id=<%=rs.getInt("request_id")%>" class="btn btn-success btn-action me-1">
                                            <i class="bi bi-check-lg"></i>
                                        </a>
                                        <a href="RejectSwap?id=<%=rs.getInt("request_id")%>" class="btn btn-danger btn-action">
                                            <i class="bi bi-x-lg"></i>
                                        </a>
                                    <% } else { %>
                                        <span class="text-muted small fw-bold">PROCESSED</span>
                                    <% } %>
                                </td>
                            </tr>
                        <%
                            }
                        } catch(Exception e) { 
                            out.println("<tr><td colspan='7' class='text-danger'>Error loading requests.</td></tr>");
                        }
                        %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="common/footer.jsp" %>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>

<script>
$(document).ready(function() {
    var table = $('#myTable').DataTable({
        pageLength: 10,
        dom: 'rtip', // Hides default search box
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