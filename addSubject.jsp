
<%@ page import="java.sql.*, com.timetable.DBConnection" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pro Scheduly | Add Subject</title>

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
            background: rgba(255,255,255,0.8) !important;
            backdrop-filter: blur(12px);
            border-bottom: 1px solid rgba(0,0,0,0.05);
            padding: 0.8rem 2rem;
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
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .form-control, .form-select {
            border-radius: 12px;
            padding: 12px 15px;
            border: 1px solid #e2e8f0;
        }

        .btn-primary-custom {
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            border: none;
            border-radius: 12px;
            font-weight: 700;
            padding: 12px;
        }

        .badge-lab {
            background: rgba(114, 9, 183, 0.1);
            color: var(--secondary);
            padding: 6px 10px;
            border-radius: 8px;
            font-size: 0.8rem;
            font-weight: 700;
        }

        .badge-theory {
            background: rgba(67, 97, 238, 0.1);
            color: var(--primary);
            padding: 6px 10px;
            border-radius: 8px;
            font-size: 0.8rem;
            font-weight: 700;
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

            <div class="form-box">
                <div class="title">
                    <i class="bi bi-journal-plus"></i> Register New Subject
                </div>

                <%
                String msg = request.getParameter("msg");
                if(msg != null){
                %>
                    <div class="alert alert-success rounded-4 mb-4">
                        <%= msg %>
                    </div>
                <%
                }
                %>

                <form action="<%=request.getContextPath()%>/SubjectServlet" method="post">
                    <div class="row g-3">

                        <div class="col-md-2">
                            <label class="small fw-bold text-muted mb-2">SUBJECT CODE</label>
                            <input type="text" name="subject_code" class="form-control" placeholder="DAA301" required>
                        </div>

                        <div class="col-md-3">
                            <label class="small fw-bold text-muted mb-2">SUBJECT NAME</label>
                            <input type="text" name="subject_name" class="form-control" placeholder="Data Structures" required>
                        </div>

                        <div class="col-md-3">
                            <label class="small fw-bold text-muted mb-2">ASSIGN FACULTY</label>
                            <select name="faculty_id" class="form-select" required>
                                <option value="">Choose Faculty</option>
                                <%
                                Connection con = DBConnection.getConnection();
                                Statement st = con.createStatement();
                                ResultSet rs = st.executeQuery("SELECT faculty_id, faculty_name FROM faculty ORDER BY faculty_name ASC");
                                while(rs.next()) {
                                %>
                                <option value="<%= rs.getInt("faculty_id") %>">
                                    <%= rs.getString("faculty_name") %>
                                </option>
                                <% } %>
                            </select>
                        </div>

                        <div class="col-md-2">
                            <label class="small fw-bold text-muted mb-2">HOURS/WEEK</label>
                            <input type="number" name="hours_per_week" class="form-control" min="1" required>
                        </div>

                        <div class="col-md-2">
                            <label class="small fw-bold text-muted mb-2">SUBJECT TYPE</label>
                            <select name="is_lab" class="form-select" required>
                                <option value="false">Theory</option>
                                <option value="true">Lab</option>
                            </select>
                        </div>

                        <div class="col-md-2 d-flex align-items-end">
                            <button type="submit" class="btn btn-primary btn-primary-custom w-100">
                                <i class="bi bi-plus-lg me-2"></i> Add
                            </button>
                        </div>
                    </div>
                </form>
            </div>

            <div class="form-box">
                <div class="title">
                    <i class="bi bi-table"></i> Subject List
                </div>

                <div class="table-responsive">
                    <table id="myTable" class="table table-hover align-middle">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Code</th>
                                <th>Subject Name</th>
                                <th>Faculty</th>
                                <th>Hours</th>
                                <th>Type</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                        Statement st2 = con.createStatement();
                        ResultSet rs2 = st2.executeQuery(
                            "SELECT s.subject_id, s.subject_code, s.subject_name, s.hours_per_week, s.is_lab, f.faculty_name " +
                            "FROM subject s " +
                            "LEFT JOIN faculty f ON s.faculty_id = f.faculty_id " +
                            "ORDER BY s.subject_id DESC"
                        );

                        while(rs2.next()) {
                        %>
                            <tr>
                                <td>#<%= rs2.getInt("subject_id") %></td>
                                <td><strong><%= rs2.getString("subject_code") %></strong></td>
                                <td><%= rs2.getString("subject_name") %></td>
                                <td><%= rs2.getString("faculty_name") %></td>
                                <td><%= rs2.getInt("hours_per_week") %> hrs/week</td>
                                <td>
                                    <% if(rs2.getBoolean("is_lab")) { %>
                                        <span class="badge-lab">LAB</span>
                                    <% } else { %>
                                        <span class="badge-theory">THEORY</span>
                                    <% } %>
                                </td>
                                <td>
                                    <a href="editSubject.jsp?id=<%= rs2.getInt("subject_id") %>" class="btn btn-warning btn-sm text-white">
                                        <i class="bi bi-pencil-square"></i>
                                    </a>

                                    <a href="DeleteSubjectServlet?id=<%= rs2.getInt("subject_id") %>"
                                       class="btn btn-danger btn-sm"
                                       onclick="return confirm('Are you sure you want to delete this subject?')">
                                        <i class="bi bi-trash"></i>
                                    </a>
                                </td>
                            </tr>
                        <%
                        }

                        rs.close();
                        rs2.close();
                        st.close();
                        st2.close();
                        con.close();
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
    $('#myTable').DataTable({
        pageLength: 5,
        lengthMenu: [5, 10, 25, 50]
    });
});
</script>

</body>
</html>
