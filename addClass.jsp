
<%@ page import="java.sql.*, com.timetable.DBConnection" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pro Scheduly | Add Class</title>

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

        .badge-sem {
            background: rgba(67, 97, 238, 0.1);
            color: var(--primary);
            font-weight: 700;
            padding: 6px 12px;
            border-radius: 8px;
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
                    <i class="bi bi-building-add"></i> Create New Class
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

                <form action="ClassServlet" method="post">
                    <div class="row g-3">

                        <div class="col-md-3">
                            <label class="small fw-bold text-muted mb-2">CLASS NAME</label>
                            <input type="text" name="class_name" class="form-control" placeholder="SY AIML" required>
                        </div>

                        <div class="col-md-2">
                            <label class="small fw-bold text-muted mb-2">SEMESTER</label>
                            <input type="number" name="semester" class="form-control" min="1" max="8" required>
                        </div>

                        <div class="col-md-2">
                            <label class="small fw-bold text-muted mb-2">DIVISION</label>
                            <input type="text" name="division" class="form-control" placeholder="A" required>
                        </div>

                        <div class="col-md-2">
                            <label class="small fw-bold text-muted mb-2">DEPARTMENT</label>
                            <input type="text" name="department" class="form-control" placeholder="AIML" required>
                        </div>

                        <div class="col-md-2">
                            <label class="small fw-bold text-muted mb-2">ACADEMIC YEAR</label>
                            <input type="text" name="academic_year" class="form-control" placeholder="2025-26" required>
                        </div>

                        <div class="col-md-1 d-flex align-items-end">
                            <button type="submit" class="btn btn-primary btn-primary-custom w-100">
                                <i class="bi bi-plus-lg"></i>
                            </button>
                        </div>
                    </div>
                </form>
            </div>

            <div class="form-box">
                <div class="title">
                    <i class="bi bi-list-task"></i> Available Classes
                </div>

                <div class="table-responsive">
                    <table id="myTable" class="table table-hover align-middle">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Class</th>
                                <th>Semester</th>
                                <th>Division</th>
                                <th>Department</th>
                                <th>Academic Year</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                        try {
                            Connection con = DBConnection.getConnection();
                            Statement st = con.createStatement();
                            ResultSet rs = st.executeQuery("SELECT * FROM class ORDER BY class_id DESC");

                            while(rs.next()) {
                        %>
                            <tr>
                                <td>#<%= rs.getInt("class_id") %></td>
                                <td><strong><%= rs.getString("class_name") %></strong></td>
                                <td>
                                    <span class="badge-sem">Semester <%= rs.getInt("semester") %></span>
                                </td>
                                <td><%= rs.getString("division") %></td>
                                <td><%= rs.getString("department") %></td>
                                <td><%= rs.getString("academic_year") %></td>
                                <td>
                                    <a href="editClass.jsp?id=<%= rs.getInt("class_id") %>" class="btn btn-warning btn-sm text-white">
                                        <i class="bi bi-pencil-square"></i>
                                    </a>

                                    <a href="DeleteClassServlet?id=<%= rs.getInt("class_id") %>"
                                       class="btn btn-danger btn-sm"
                                       onclick="return confirm('Are you sure you want to delete this class?')">
                                        <i class="bi bi-trash"></i>
                                    </a>
                                </td>
                            </tr>
                        <%
                            }

                            rs.close();
                            st.close();
                            con.close();
                        } catch(Exception e) {
                            out.println("<tr><td colspan='7' class='text-danger'>" + e.getMessage() + "</td></tr>");
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
    $('#myTable').DataTable({
        pageLength: 5,
        lengthMenu: [5, 10, 25, 50]
    });
});
</script>

</body>
</html>

