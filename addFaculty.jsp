
<%@ page import="java.sql.*, com.timetable.DBConnection" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pro Scheduly | Add Faculty</title>

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
            width: 38px;
            height: 38px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 10px;
            color: white;
            margin-right: 12px;
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

        .dept-badge {
            background: rgba(114, 9, 183, 0.1);
            color: var(--secondary);
            font-weight: 700;
            padding: 6px 12px;
            border-radius: 8px;
            font-size: 0.85rem;
        }

        .btn-action {
            width: 35px;
            height: 35px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 10px;
            margin: 0 2px;
        }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg sticky-top">
    <div class="container-fluid">
        <a class="navbar-brand d-flex align-items-center" href="dashboard.jsp">
            <span class="brand-icon"><i class="bi bi-grid-fill"></i></span>
            <span style="font-weight:800; color: var(--text-main);">SCHEDULY</span>
        </a>
    </div>
</nav>

<div class="container-fluid">
    <div class="row">

        <div class="col-lg-2 col-md-3 col-12 p-0 border-end" style="background: white; min-height: calc(100vh - 70px);">
            <%@ include file="common/sidebar.jsp" %>
        </div>

        <div class="col-lg-10 col-md-9 col-12 p-4 p-md-5">

            <div class="form-box">
                <div class="title">
                    <i class="bi bi-person-plus-fill"></i> Add New Faculty
                </div>

                <%
                String msg = request.getParameter("msg");
                if (msg != null) {
                %>
                    <div class="alert alert-success rounded-4 mb-4">
                        <%= msg %>
                    </div>
                <%
                }
                %>

                <form action="FacultyServlet" method="post">
                    <div class="row g-3">

                        <div class="col-md-4">
                            <label class="small fw-bold text-muted mb-2">FULL NAME</label>
                            <input type="text" name="faculty_name" class="form-control" required>
                        </div>

                        <div class="col-md-3">
                            <label class="small fw-bold text-muted mb-2">DEPARTMENT</label>
                            <input type="text" name="department" class="form-control" required>
                        </div>

                        <div class="col-md-2">
                            <label class="small fw-bold text-muted mb-2">DESIGNATION</label>
                            <input type="text" name="designation" class="form-control" placeholder="Professor">
                        </div>

                        <div class="col-md-3">
                            <label class="small fw-bold text-muted mb-2">EMAIL</label>
                            <input type="email" name="email" class="form-control">
                        </div>

                        <div class="col-md-3">
                            <label class="small fw-bold text-muted mb-2">PHONE</label>
                            <input type="text" name="phone" class="form-control">
                        </div>

                        <div class="col-md-3">
                            <label class="small fw-bold text-muted mb-2">PASSWORD</label>
                            <input type="password" name="password" class="form-control" required>
                        </div>

                        <div class="col-md-3 d-flex align-items-end">
                            <button type="submit" class="btn btn-primary btn-primary-custom w-100">
                                <i class="bi bi-plus-lg me-2"></i> Register Faculty
                            </button>
                        </div>
                    </div>
                </form>
            </div>

            <div class="form-box">
                <div class="title">
                    <i class="bi bi-people-fill"></i> Faculty Members
                </div>

                <div class="table-responsive">
                    <table id="myTable" class="table table-hover align-middle">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Department</th>
                                <th>Designation</th>
                                <th>Email</th>
                                <th>Phone</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                        try {
                            Connection con = DBConnection.getConnection();
                            Statement st = con.createStatement();
                            ResultSet rs = st.executeQuery("SELECT * FROM faculty ORDER BY faculty_id DESC");

                            while (rs.next()) {
                        %>
                            <tr>
                                <td>#<%= rs.getInt("faculty_id") %></td>
                                <td><strong><%= rs.getString("faculty_name") %></strong></td>
                                <td>
                                    <span class="dept-badge"><%= rs.getString("department") %></span>
                                </td>
                                <td><%= rs.getString("designation") %></td>
                                <td><%= rs.getString("email") %></td>
                                <td><%= rs.getString("phone") %></td>
                                <td>
                                    <a href="editFaculty.jsp?id=<%= rs.getInt("faculty_id") %>" class="btn btn-warning btn-action text-white">
                                        <i class="bi bi-pencil-square"></i>
                                    </a>

                                    <a href="DeleteFacultyServlet?id=<%= rs.getInt("faculty_id") %>"
                                       class="btn btn-danger btn-action"
                                       onclick="return confirm('Are you sure you want to delete this faculty member?')">
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
