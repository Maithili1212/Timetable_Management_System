<%@ page import="java.sql.*, com.timetable.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    // Use different variable name to avoid conflict with sidebar.jsp
    String userRole = (String) session.getAttribute("role");

    String student = (String) session.getAttribute("studentUser");
    Integer classId = (Integer) session.getAttribute("class_id");

    // ================= AUTH CHECK =================
    if (userRole == null || !"STUDENT".equals(userRole)) {
        response.sendRedirect("login.jsp?msg=Access Denied");
        return;
    }

    if (student == null || classId == null) {
        response.sendRedirect("login.jsp?msg=Session Expired");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pro Scheduly | Student Dashboard</title>

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
            background: rgba(255, 255, 255, 0.85) !important;
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
            box-shadow: 0 4px 12px rgba(67, 97, 238, 0.3);
        }

        .sidebar-wrapper {
            background: white;
            min-height: calc(100vh - 70px);
            border-right: 1px solid #e9ecef;
        }

        .form-box {
            background: white;
            padding: 30px;
            border-radius: 24px;
            border: 1px solid rgba(255,255,255,0.3);
            box-shadow: var(--card-shadow);
            margin-bottom: 30px;
        }

        .welcome-card {
            background: linear-gradient(135deg, #2b3674, #4361ee);
            border-radius: 24px;
            padding: 40px;
            color: white;
            margin-bottom: 30px;
            position: relative;
            overflow: hidden;
            box-shadow: var(--card-shadow);
        }

        .welcome-card .bg-icon {
            position: absolute;
            right: 40px;
            bottom: -10px;
            font-size: 8rem;
            opacity: 0.1;
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

        .stat-card {
            background: #f8fafc;
            padding: 25px;
            border-radius: 20px;
            border: 1px solid #e2e8f0;
            transition: 0.3s ease;
            height: 100%;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            background: white;
            border-color: var(--primary);
        }

        .icon-circle {
            width: 45px;
            height: 45px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            margin-bottom: 15px;
        }

        .btn-action {
            border-radius: 12px;
            font-weight: 700;
            padding: 10px;
            transition: 0.3s;
        }

        .btn-action:hover {
            transform: translateY(-2px);
        }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg sticky-top">
    <div class="container-fluid">
        <a class="navbar-brand d-flex align-items-center" href="studentDashboard.jsp">
            <span class="brand-icon">
                <i class="bi bi-mortarboard-fill"></i>
            </span>
            <span style="font-weight: 800; letter-spacing: -0.5px; color: var(--text-main);">
                SCHEDULY
            </span>
        </a>

        <div class="ms-auto d-flex align-items-center">
            <div class="dropdown">
                <a class="d-flex align-items-center text-decoration-none dropdown-toggle"
                   href="#"
                   role="button"
                   data-bs-toggle="dropdown"
                   aria-expanded="false">

                    <span class="text-end me-3 d-none d-md-flex flex-column justify-content-center">
                        <span class="small fw-bold text-dark" style="line-height: 1;">
                            <%= student %>
                        </span>
                        <span class="text-muted" style="font-size: 0.7rem;">
                            Class ID: #<%= classId %>
                        </span>
                    </span>

                    <img src="https://ui-avatars.com/api/?name=<%= student %>&background=4361ee&color=fff"
                         class="rounded-circle border"
                         width="38"
                         height="38"
                         alt="Student Avatar">
                </a>

                <ul class="dropdown-menu dropdown-menu-end shadow border-0 mt-3 rounded-4">
                    <li>
                        <a class="dropdown-item py-2" href="profile.jsp">
                            <i class="bi bi-person me-2"></i> Profile
                        </a>
                    </li>
                    <li>
                        <a class="dropdown-item py-2" href="viewStudentTimetable.jsp">
                            <i class="bi bi-calendar-week me-2"></i> My Timetable
                        </a>
                    </li>
                    <li><hr class="dropdown-divider"></li>
                    <li>
                        <a class="dropdown-item py-2 text-danger fw-bold" href="LogoutServlet">
                            <i class="bi bi-box-arrow-right me-2"></i> Logout
                        </a>
                    </li>
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

            <div class="welcome-card">
                <div class="position-relative" style="z-index: 2;">
                    <h1 class="fw-800">Welcome, <%= student %> 👋</h1>
                    <p class="lead opacity-75">
                        Your academic schedule is ready for the week. Stay focused and keep learning.
                    </p>
                </div>
                <i class="bi bi-mortarboard bg-icon"></i>
            </div>

            <div class="form-box">
                <div class="title">
                    <i class="bi bi-grid-fill"></i>
                    Quick Overview
                </div>

                <div class="row g-4">

                    <div class="col-md-4">
                        <div class="stat-card">
                            <div class="icon-circle bg-primary bg-opacity-10 text-primary">
                                <i class="bi bi-calendar3"></i>
                            </div>

                            <h5 class="fw-bold">Daily Schedule</h5>
                            <p class="text-muted small">
                                Access your class timetable, lecture timings, and faculty details.
                            </p>

                            <a href="viewStudentTimetable.jsp" class="btn btn-primary btn-action w-100">
                                View My Timetable
                            </a>
                        </div>
                    </div>

                    <div class="col-md-4">
                        <div class="stat-card">
                            <div class="icon-circle bg-warning bg-opacity-10 text-warning">
                                <i class="bi bi-megaphone"></i>
                            </div>

                            <h5 class="fw-bold">Notice Board</h5>
                            <p class="text-muted small">
                                Check lecture swaps, holidays, exam schedules, and department updates.
                            </p>

                            <a href="notifications.jsp" class="btn btn-warning text-white btn-action w-100">
                                Check Alerts
                            </a>
                        </div>
                    </div>

                    <div class="col-md-4">
                        <div class="stat-card">
                            <div class="icon-circle bg-success bg-opacity-10 text-success">
                                <i class="bi bi-info-square"></i>
                            </div>

                            <h5 class="fw-bold">Class Information</h5>

                            <p class="text-muted small mb-1">
                                Current Class ID:
                                <strong><%= classId %></strong>
                            </p>

                            <p class="text-muted small mb-0">
                                Academic Year: 2026
                            </p>

                            <hr class="my-3 opacity-25">

                            <div class="d-flex align-items-center text-success small fw-bold">
                                <i class="bi bi-check-circle-fill me-2"></i>
                                Account Active
                            </div>
                        </div>
                    </div>

                </div>
            </div>

        </div>
    </div>
</div>

<%@ include file="common/footer.jsp" %>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>