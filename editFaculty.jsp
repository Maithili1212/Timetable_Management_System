<%@ page import="java.sql.*, com.timetable.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    String idParam = request.getParameter("id");
    if (idParam == null) {
        response.sendRedirect("addFaculty.jsp?msg=Invalid Faculty ID");
        return;
    }

    int id = Integer.parseInt(idParam);
    String name = "";
    String dept = "";

    // Using try-with-resources for automatic cleanup
    try (Connection con = DBConnection.getConnection()) {
        PreparedStatement ps = con.prepareStatement("SELECT * FROM faculty WHERE faculty_id=?");
        ps.setInt(1, id);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            name = rs.getString("faculty_name");
            dept = rs.getString("department");
        } else {
            response.sendRedirect("addFaculty.jsp?msg=Faculty Not Found");
            return;
        }
    } catch (Exception e) {
        response.sendRedirect("addFaculty.jsp?msg=Error Loading Data");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pro Scheduly | Edit Faculty</title>

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
            max-width: 550px;
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

        .btn-update {
            background: var(--primary);
            border: none;
            border-radius: 12px;
            padding: 12px;
            font-weight: 700;
            margin-top: 10px;
        }

        .btn-back {
            color: var(--text-main);
            text-decoration: none;
            font-weight: 600;
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
        <a href="addFaculty.jsp" class="btn-back">
            <i class="bi bi-arrow-left"></i> Return to Faculty List
        </a>

        <div class="title">
            <i class="bi bi-person-gear"></i>
            Edit Faculty Profile
        </div>

        <form action="UpdateFacultyServlet" method="post">
            <input type="hidden" name="faculty_id" value="<%= id %>">

            <div class="mb-4">
                <label class="form-label">Full Name</label>
                <input type="text" name="faculty_name" class="form-control" 
                       value="<%= name %>" required>
            </div>

            <div class="mb-4">
                <label class="form-label">Department</label>
                <select name="department" class="form-control" required>
                    <option value="Computer Science" <%= dept.equals("Computer Science") ? "selected" : "" %>>Computer Science</option>
                    <option value="Information Technology" <%= dept.equals("Information Technology") ? "selected" : "" %>>Information Technology</option>
                    <option value="Mathematics" <%= dept.equals("Mathematics") ? "selected" : "" %>>Mathematics</option>
                    <option value="Physics" <%= dept.equals("Physics") ? "selected" : "" %>>Physics</option>
                </select>
            </div>

            <button type="submit" class="btn btn-primary btn-update w-100 shadow-sm">
                Update Profile
            </button>
        </form>
    </div>
</div>

</body>
</html>