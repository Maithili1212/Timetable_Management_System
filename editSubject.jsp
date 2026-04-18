<%@ page import="java.sql.*, com.timetable.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    String idParam = request.getParameter("id");
    if (idParam == null) {
        response.sendRedirect("addSubject.jsp?msg=Invalid Subject ID");
        return;
    }

    int id = Integer.parseInt(idParam);
    String subjectName = "";
    int hours = 0;
    int currentFacultyId = 0;

    try (Connection con = DBConnection.getConnection()) {
        // Fetch current subject details
        PreparedStatement ps = con.prepareStatement("SELECT * FROM subject WHERE subject_id=?");
        ps.setInt(1, id);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            subjectName = rs.getString("subject_name");
            hours = rs.getInt("hours_per_week");
            currentFacultyId = rs.getInt("faculty_id");
        } else {
            response.sendRedirect("addSubject.jsp?msg=Subject Not Found");
            return;
        }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pro Scheduly | Edit Subject</title>

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
            margin: 60px auto;
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
            margin-bottom: 8px;
        }

        .form-control {
            border-radius: 12px;
            padding: 12px 15px;
            border: 1px solid #e0e5f2;
            margin-bottom: 20px;
        }

        .btn-update {
            background: var(--primary);
            border: none;
            border-radius: 12px;
            padding: 14px;
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
        <a href="addSubject.jsp" class="btn-back">
            <i class="bi bi-arrow-left"></i> Back to Subjects
        </a>

        <div class="title">
            <i class="bi bi-book"></i>
            Edit Subject Details
        </div>

        <form action="UpdateSubjectServlet" method="post">
            <input type="hidden" name="subject_id" value="<%= id %>">

            <label class="form-label">Subject Name</label>
            <input type="text" name="subject_name" class="form-control" 
                   value="<%= subjectName %>" placeholder="e.g. Data Structures" required>

            <label class="form-label">Hours Per Week</label>
            <input type="number" name="hours" class="form-control" 
                   value="<%= hours %>" min="1" max="10" required>

            <label class="form-label">Assigned Faculty</label>
            <select name="faculty_id" class="form-control" required>
                <%
                    Statement st = con.createStatement();
                    ResultSet rsFac = st.executeQuery("SELECT faculty_id, faculty_name FROM faculty ORDER BY faculty_name ASC");
                    boolean hasFaculty = false;
                    while(rsFac.next()){
                        hasFaculty = true;
                        int fId = rsFac.getInt("faculty_id");
                        String fName = rsFac.getString("faculty_name");
                %>
                    <option value="<%= fId %>" <%= (fId == currentFacultyId) ? "selected" : "" %>>
                        <%= fName %>
                    </option>
                <%
                    }
                    if(!hasFaculty) {
                %>
                    <option disabled>No faculty found. Please add faculty first.</option>
                <% } %>
            </select>

            <button type="submit" class="btn btn-primary btn-update w-100 mt-2">
                Update Subject
            </button>
        </form>
    </div>
</div>

</body>
</html>
<%
    } catch (Exception e) {
        response.sendRedirect("addSubject.jsp?msg=Error: " + e.getMessage());
    }
%>