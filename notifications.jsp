<%@ page import="java.sql.*, com.timetable.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    String userRole = (String) session.getAttribute("role");
    Integer userId = null;

    // ================= AUTH CHECK =================
    if (userRole == null) {
        response.sendRedirect("login.jsp?msg=Please Login First");
        return;
    }

    // ================= ROLE RESOLUTION =================
    // Ensure this matches the session keys used in your Dashboard/Login files
    String userType = userRole.toLowerCase();

    if ("TEACHER".equals(userRole) || "FACULTY".equals(userRole)) {
        userId = (Integer) session.getAttribute("faculty_id");
        if(userId == null) userId = (Integer) session.getAttribute("teacherId");
    } 
    else if ("STUDENT".equals(userRole)) {
        userId = (Integer) session.getAttribute("class_id");
    } 
    else if ("ADMIN".equals(userRole)) {
        userId = 1; // Default Admin ID
    }

    if (userId == null) {
        response.sendRedirect("login.jsp?msg=Session Expired");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pro Scheduly | Notifications</title>

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

        .notification-card {
            background: white;
            padding: 30px;
            border-radius: 24px;
            border: 1px solid rgba(255, 255, 255, 0.3);
            box-shadow: var(--card-shadow);
        }

        .title-section {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 30px;
        }

        .title-icon {
            background: #f4f7fe;
            color: var(--primary);
            padding: 12px;
            border-radius: 14px;
            font-size: 1.5rem;
        }

        .notification-item {
            padding: 20px;
            border-radius: 16px;
            border: 1px solid #f1f5f9;
            margin-bottom: 15px;
            transition: all 0.3s ease;
            display: flex;
            align-items: flex-start;
            gap: 15px;
            position: relative;
        }

        .notification-item:hover {
            background: #f8fafc;
            transform: translateX(5px);
            border-color: var(--primary);
        }

        /* Unread dot style */
        .unread::after {
            content: '';
            position: absolute;
            top: 20px;
            right: 20px;
            width: 10px;
            height: 10px;
            background: var(--primary);
            border-radius: 50%;
        }

        .icon-box {
            background: #eef2ff;
            color: var(--primary);
            min-width: 45px;
            height: 45px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
        }

        .msg-content { flex: 1; }

        .msg-text {
            font-weight: 600;
            margin-bottom: 4px;
            font-size: 1rem;
            color: var(--text-main);
        }

        .msg-time {
            font-size: 0.8rem;
            color: var(--text-muted);
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .empty-state {
            padding: 60px 0;
            text-align: center;
        }
    </style>
</head>

<body>

<nav class="navbar navbar-expand-lg sticky-top">
    <div class="container-fluid">
        <a class="navbar-brand d-flex align-items-center" href="dashboard.jsp">
            <span class="brand-icon"><i class="bi bi-bell-fill"></i></span>
            <span style="font-weight: 800; letter-spacing: -0.5px; color: var(--text-main);">SCHEDULY</span>
        </a>

        <div class="ms-auto d-flex align-items-center">
             <span class="small fw-bold text-dark me-3 d-none d-md-inline">ID: #<%= userId %></span>
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

            <div class="notification-card">
                <div class="title-section">
                    <div class="title-icon"><i class="bi bi-chat-left-dots"></i></div>
                    <div>
                        <h2 class="fw-800 m-0" style="font-weight: 800;">Recent Updates</h2>
                        <p class="text-muted m-0">Stay informed about schedule changes and swap requests.</p>
                    </div>
                </div>

                <div class="notification-feed">
                <%
                    try (Connection con = DBConnection.getConnection()) {
                        // SQL remains the same, but sorted by most recent
                        PreparedStatement ps = con.prepareStatement(
                            "SELECT message, created_at FROM notifications " +
                            "WHERE user_type = ? AND user_id = ? " +
                            "ORDER BY created_at DESC"
                        );

                        ps.setString(1, userType);
                        ps.setInt(2, userId);

                        ResultSet rs = ps.executeQuery();
                        boolean found = false;

                        while (rs.next()) {
                            found = true;
                            Timestamp ts = rs.getTimestamp("created_at");
                            // Simple format for the timestamp
                            String timeStr = new java.text.SimpleDateFormat("MMM dd, yyyy HH:mm").format(ts);
                %>
                    <div class="notification-item">
                        <div class="icon-box shadow-sm">
                            <i class="bi bi-lightning-charge-fill"></i>
                        </div>
                        <div class="msg-content">
                            <div class="msg-text"><%= rs.getString("message") %></div>
                            <div class="msg-time">
                                <i class="bi bi-clock"></i>
                                <%= timeStr %>
                            </div>
                        </div>
                    </div>
                <%
                        }

                        if (!found) {
                %>
                    <div class="empty-state">
                        <img src="https://cdn-icons-png.flaticon.com/512/10534/10534125.png" width="80" class="mb-3 opacity-25" alt="No Data">
                        <h5 class="fw-bold text-muted">All caught up!</h5>
                        <p class="text-muted small">You don't have any notifications at the moment.</p>
                    </div>
                <%
                        }
                    } catch(Exception e) {
                %>
                    <div class="alert alert-danger rounded-4 border-0 shadow-sm">
                        <i class="bi bi-exclamation-octagon me-2"></i> Database Connection Error: <%= e.getMessage() %>
                    </div>
                <%
                    }
                %>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="common/footer.jsp" %>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>