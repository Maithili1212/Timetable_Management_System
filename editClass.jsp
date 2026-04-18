<%@ page import="java.sql.*, com.timetable.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    String idParam = request.getParameter("id");
    if (idParam == null) {
        response.sendRedirect("addClass.jsp?msg=Invalid Class ID");
        return;
    }

    int id = Integer.parseInt(idParam);
    String className = "";
    int semester = 1;

    try (Connection con = DBConnection.getConnection()) {
        PreparedStatement ps = con.prepareStatement("SELECT * FROM class WHERE class_id=?");
        ps.setInt(1, id);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            className = rs.getString("class_name");
            semester = rs.getInt("semester");
        } else {
            response.sendRedirect("addClass.jsp?msg=Class Not Found");
            return;
        }
    } catch (Exception e) {
        response.sendRedirect("addClass.jsp?msg=Error: " + e.getMessage());
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pro Scheduly | Edit Class</title>

    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">

    <style>
        :root {
            --primary: #4361ee;
            --secondary: #7209b7;
            --bg-light: #f0f2f5;
            --text-main: #2b3674;
            --card-shadow: 0 20px 40px rgba(0,0,0,0.04);
        }

        body {
            background-color: var(--bg-light);
            font-family: 'Plus Jakarta Sans', sans-serif;
            color: var(--text-main);
        }

        .edit-card {
            background: white;
            padding: 40px;
            border-radius: 24px;
            box-shadow: var(--card-shadow);
            border: 1px solid rgba(255, 255, 255, 0.3);
            max-width: 500px;
            margin: 80px auto;
        }

        .title {
            font-size: 24px;
            font-weight: 800;
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 30px;
        }

        .title i {
            color: var(--primary);
            background: #f4f7fe;
            padding: 10px;
            border-radius: 12px;
        }

        .form-label {
            font-weight: 700;
            font-size: 0.9rem;
            color: var(--text-main);
        }

        .form-control {
            border-radius: 12px;
            padding: 12px 15px;
            border: 1px solid #e0e5f2;
        }

        .form-control:focus {
            box-shadow: 0 0 0 4px rgba(67, 97, 238, 0.1);
            border-color: var(--primary);
        }

        .btn-update {
            background: var(--primary);
            border: none;
            border-radius: 12px;
            padding: 12px;
            font-weight: 700;
            transition: 0.3s;
        }

        .btn-update:hover {
            background: var(--secondary);
            transform: translateY(-2px);
        }

        .btn-back {
            color: var(--text-main);
            text-decoration: none;
            font-weight: 600;
            font-size: 0.9rem;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>

<div class="container">
    <div class="edit-card">
        <a href="addClass.jsp" class="btn-back">
            <i class="bi bi-arrow-left"></i> Back to Classes
        </a>

        <div class="title">
            <i class="bi bi-pencil-square"></i>
            Edit Class Details
        </div>

        <form action="UpdateClassServlet" method="post">
            <input type="hidden" name="class_id" value="<%= id %>">

            <div class="mb-4">
                <label class="form-label">Class Identifier / Name</label>
                <input type="text" name="class_name" class="form-control" 
                       value="<%= className %>" placeholder="e.g. FY-CS-A" required>
            </div>

            <div class="mb-4">
                <label class="form-label">Semester</label>
                <input type="number" name="semester" class="form-control" 
                       value="<%= semester %>" min="1" max="8" required>
            </div>

            <button type="submit" class="btn btn-primary btn-update w-100">
                Save Changes
            </button>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>