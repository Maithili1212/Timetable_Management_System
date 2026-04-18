<%@ page import="java.sql.*, com.timetable.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%-- 
    Include sidebar first to handle role declaration and session logic.
--%>
<%@ include file="common/sidebar.jsp" %>

<%
String timetableId = request.getParameter("timetable_id");

// Security check for Teacher role (Assuming your role variable is "TEACHER" or "FACULTY")
if (role == null || (!"TEACHER".equals(role) && !"FACULTY".equals(role))) {
    response.sendRedirect("login.jsp?msg=Unauthorized Access");
    return;
}

Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pro Scheduly | Request Swap</title>

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
            font-size: 20px;
            font-weight: 800;
            margin-bottom: 20px;
            color: var(--text-main);
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .title i {
            color: var(--primary);
            background: #f4f7fe;
            padding: 8px;
            border-radius: 10px;
        }

        .info-box {
            background: #f8fafc;
            border: 1px solid #eef2f7;
            border-radius: 16px;
            padding: 20px;
            margin-bottom: 25px;
        }

        .info-item {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
            padding-bottom: 8px;
            border-bottom: 1px dashed #e2e8f0;
        }

        .info-item:last-child { border: none; margin-bottom: 0; padding-bottom: 0; }

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
            padding: 14px;
            transition: 0.3s;
            color: white;
        }

        .btn-primary-custom:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(67, 97, 238, 0.3);
            color: white;
        }
    </style>
</head>

<body>

<nav class="navbar navbar-expand-lg sticky-top">
    <div class="container-fluid">
        <a class="navbar-brand d-flex align-items-center" href="teacherDashboard.jsp">
            <span class="brand-icon"><i class="bi bi-arrow-left-right"></i></span>
            <span style="font-weight: 800; color: var(--text-main);">SCHEDULY</span>
        </a>
    </div>
</nav>

<div class="container-fluid">
    <div class="row">
        <div class="col-lg-2 col-md-3 col-12 p-0 border-end" style="background: white; min-height: calc(100vh - 70px);">
        </div>

        <div class="col-lg-10 col-md-9 col-12 p-4 p-md-5">

            <div class="row mb-4">
                <div class="col-12">
                    <h2 class="fw-800" style="font-weight: 800; color: var(--text-main);">Request Lecture Swap</h2>
                    <p class="text-muted">Initiate an exchange request for your scheduled lecture.</p>
                </div>
            </div>

            <div class="row">
                <div class="col-lg-7">
                    <div class="form-box">
                        <div class="title">
                            <i class="bi bi-send"></i> Swap Details
                        </div>

                        <%
                        try {
                            con = DBConnection.getConnection();
                            // Updated to match your SQL schema columns (timetable_id, day_of_week)
                            ps = con.prepareStatement(
                                "SELECT t.day_of_week, ts.start_time, ts.end_time, t.room_no, s.subject_name, c.class_name " +
                                "FROM timetable t " +
                                "JOIN subject s ON t.subject_id = s.subject_id " +
                                "JOIN class c ON t.class_id = c.class_id " +
                                "JOIN time_slot ts ON t.slot_id = ts.slot_id " +
                                "WHERE t.timetable_id = ?"
                            );
                            ps.setString(1, timetableId);
                            rs = ps.executeQuery();

                            if(rs.next()){
                        %>

                        <div class="info-box">
                            <div class="info-item">
                                <span class="text-muted small fw-bold text-uppercase">Subject</span>
                                <span class="fw-bold"><%= rs.getString("subject_name") %></span>
                            </div>
                            <div class="info-item">
                                <span class="text-muted small fw-bold text-uppercase">Target Class</span>
                                <span class="fw-bold"><%= rs.getString("class_name") %></span>
                            </div>
                            <div class="info-item">
                                <span class="text-muted small fw-bold text-uppercase">Schedule</span>
                                <span class="fw-bold text-primary">
                                    <%= rs.getString("day_of_week") %>, 
                                    <%= rs.getTime("start_time") %> - <%= rs.getTime("end_time") %>
                                </span>
                            </div>
                            <div class="info-item">
                                <span class="text-muted small fw-bold text-uppercase">Location</span>
                                <span class="fw-bold"><i class="bi bi-geo-alt me-1 text-danger"></i>Room <%= rs.getString("room_no") %></span>
                            </div>
                        </div>

                        <%
                            }
                        } catch(Exception e){
                            out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
                        }
                        %>

                        <form action="SwapRequestServlet" method="post">
                            <input type="hidden" name="timetable_id" value="<%= timetableId %>">

                            <div class="mb-3">
                                <label class="small fw-bold text-muted mb-2">TARGET FACULTY</label>
                                <select name="to_faculty" class="form-select" required>
                                    <option value="">Select Faculty to swap with...</option>
                                    <%
                                    try {
                                        PreparedStatement psFac = con.prepareStatement("SELECT faculty_id, faculty_name FROM faculty ORDER BY faculty_name");
                                        ResultSet rsFac = psFac.executeQuery();
                                        while(rsFac.next()){
                                            out.println("<option value='"+rsFac.getInt("faculty_id")+"'>"+rsFac.getString("faculty_name")+"</option>");
                                        }
                                    } catch(Exception e){}
                                    %>
                                </select>
                            </div>

                            <div class="mb-4">
                                <label class="small fw-bold text-muted mb-2">REASON FOR SWAP</label>
                                <textarea name="reason" class="form-control" rows="4" placeholder="Briefly explain the reason for this request..." required></textarea>
                            </div>

                            <button type="submit" class="btn btn-primary-custom w-100">
                                <i class="bi bi-send-fill me-2"></i> Submit Request
                            </button>
                        </form>
                    </div>
                </div>

                <div class="col-lg-5">
                    <div class="form-box bg-light border-0">
                        <div class="title">
                            <i class="bi bi-info-circle"></i> Instructions
                        </div>
                        <ul class="text-muted small" style="line-height: 1.8;">
                            <li>Choose a faculty member who is familiar with the subject or class division.</li>
                            <li>Your request will be sent to the target faculty and then to the <strong>Admin</strong> for final approval.</li>
                            <li>You can track the status (Pending/Approved/Rejected) in your <strong>Notifications</strong>.</li>
                            <li>The swap only takes effect once the status changes to <strong>Approved</strong>.</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<%
// Cleanup
try { if(con != null) con.close(); } catch(Exception e){}
%>

<%@ include file="common/footer.jsp" %>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>