<%@ page import="java.sql.*, com.timetable.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
String userRole = (String) session.getAttribute("role");
if (userRole == null) { response.sendRedirect("login.jsp?msg=Please Login First"); return; }
Integer facultyId = (Integer) session.getAttribute("faculty_id");
if(facultyId == null) facultyId = (Integer) session.getAttribute("teacherId");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Analytics Hub | KIT CoEK</title>

    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        :root {
            --kit-navy: #0f172a;
            --kit-blue: #2563eb;
            --kit-slate: #64748b;
            --kit-bg: #f8fafc;
            --sidebar-width: 280px;
        }

        body { background-color: var(--kit-bg); font-family: 'Plus Jakarta Sans', sans-serif; color: #334155; }

        /* --- Global Layout --- */
        .main-wrapper { margin-left: var(--sidebar-width); transition: 0.3s; }
        
        /* --- Sidebar Integration --- */
        .sidebar-container {
            width: var(--sidebar-width); height: 100vh;
            position: fixed; background: white; border-right: 1px solid #e2e8f0;
            z-index: 1000;
        }

        /* --- Header / Top Nav --- */
        .top-nav {
            background: white; border-bottom: 1px solid #e2e8f0;
            padding: 1rem 3rem; display: flex; align-items: center; justify-content: space-between;
        }

        /* --- KPI Cards (Real Business Style) --- */
        .kpi-card {
            background: white; border: 1px solid #e2e8f0; border-radius: 16px;
            padding: 24px; display: flex; align-items: center; gap: 20px;
            transition: transform 0.2s ease;
        }
        .kpi-card:hover { transform: translateY(-3px); box-shadow: 0 10px 15px -3px rgba(0,0,0,0.05); }
        
        .kpi-icon {
            width: 54px; height: 54px; border-radius: 12px;
            display: flex; align-items: center; justify-content: center; font-size: 1.5rem;
        }

        /* --- Panel styling --- */
        .content-panel {
            background: white; border: 1px solid #e2e8f0; border-radius: 20px;
            padding: 30px; margin-bottom: 30px;
        }

        .panel-header {
            display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px;
        }

        .chart-container { position: relative; height: 400px; width: 100%; }

        /* --- Badges & Text --- */
        .text-header { font-size: 1.75rem; font-weight: 800; color: var(--kit-navy); letter-spacing: -0.5px; }
        .badge-soft { padding: 6px 12px; border-radius: 8px; font-weight: 700; font-size: 0.75rem; text-transform: uppercase; }
        .badge-blue { background: #eff6ff; color: #2563eb; }

    </style>
</head>

<body>

<div class="sidebar-container">
    <%@ include file="common/sidebar.jsp" %>
</div>

<div class="main-wrapper">
    <header class="top-nav">
        <div>
            <span class="badge-soft badge-blue">Academic Session 2026</span>
            <div class="text-header mt-1">Resource Utilization</div>
        </div>
        <div class="d-flex align-items-center gap-3">
            <div class="text-end me-2">
                <div class="fw-800 small text-dark"><%= (userRole != null) ? userRole.toUpperCase() : "FACULTY" %></div>
                <div class="text-muted small">ID: #<%= facultyId %></div>
            </div>
            <a href="LogoutServlet" class="btn btn-outline-danger btn-sm rounded-pill px-4 fw-700">Sign Out</a>
        </div>
    </header>

    <div class="p-5">
        <%
            // DATA PROCESSING (Business Logic)
            StringBuilder labels = new StringBuilder();
            StringBuilder dataPoints = new StringBuilder();
            int totalLectures = 0;
            int totalHours = 0;

            try (Connection con = DBConnection.getConnection()) {
                String sql;
                if ("ADMIN".equalsIgnoreCase(userRole)) {
                    sql = "SELECT f.faculty_name as label, COUNT(*) AS workload FROM timetable t " +
                          "JOIN faculty f ON t.faculty_id = f.faculty_id GROUP BY f.faculty_name";
                } else {
                    sql = "SELECT day_of_week as label, COUNT(*) AS workload FROM timetable " +
                          "WHERE faculty_id = ? GROUP BY day_of_week " +
                          "ORDER BY FIELD(day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday')";
                }

                PreparedStatement ps = con.prepareStatement(sql);
                if (!"ADMIN".equalsIgnoreCase(userRole)) ps.setInt(1, facultyId);

                ResultSet rs = ps.executeQuery();
                while(rs.next()){
                    labels.append("'").append(rs.getString("label")).append("',");
                    int val = rs.getInt("workload");
                    dataPoints.append(val).append(",");
                    totalLectures += val;
                }
                totalHours = totalLectures * 1; // Assuming 1hr per slot
            } catch(Exception e) { out.println("Error: " + e.getMessage()); }

            String chartLabels = labels.length() > 0 ? labels.substring(0, labels.length()-1) : "";
            String chartData = dataPoints.length() > 0 ? dataPoints.substring(0, dataPoints.length()-1) : "";
        %>

        <div class="row g-4 mb-5">
            <div class="col-md-4">
                <div class="kpi-card">
                    <div class="kpi-icon" style="background: #eff6ff; color: #2563eb;"><i class="bi bi-calendar4-week"></i></div>
                    <div>
                        <div class="text-muted small fw-700 text-uppercase">Weekly Sessions</div>
                        <div class="h3 fw-800 m-0"><%= totalLectures %></div>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="kpi-card">
                    <div class="kpi-icon" style="background: #f0fdf4; color: #16a34a;"><i class="bi bi-clock-history"></i></div>
                    <div>
                        <div class="text-muted small fw-700 text-uppercase">Contact Hours</div>
                        <div class="h3 fw-800 m-0"><%= totalHours %> Hrs</div>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="kpi-card">
                    <div class="kpi-icon" style="background: #fff7ed; color: #ea580c;"><i class="bi bi-graph-up-arrow"></i></div>
                    <div>
                        <div class="text-muted small fw-700 text-uppercase">Load Capacity</div>
                        <div class="h3 fw-800 m-0">82%</div>
                    </div>
                </div>
            </div>
        </div>

        <div class="content-panel">
            <div class="panel-header">
                <div>
                    <h5 class="fw-800 m-0"><%= "ADMIN".equalsIgnoreCase(userRole) ? "Faculty Performance Matrix" : "Weekly Activity Heatmap" %></h5>
                    <p class="text-muted small m-0">Live data insights from Scheduly Intelligence Engine</p>
                </div>
                <button class="btn btn-light btn-sm fw-700 border" onclick="window.print()">
                    <i class="bi bi-download me-2"></i>Export Report
                </button>
            </div>
            
            <div class="chart-container">
                <canvas id="workloadChart"></canvas>
            </div>
        </div>

    </div>
</div>

<script>
Chart.defaults.font.family = "'Plus Jakarta Sans', sans-serif";
Chart.defaults.color = '#64748b';

const ctx = document.getElementById('workloadChart').getContext('2d');
const gradient = ctx.createLinearGradient(0, 0, 0, 400);
gradient.addColorStop(0, 'rgba(37, 99, 235, 1)');
gradient.addColorStop(1, 'rgba(37, 99, 235, 0.1)');

new Chart(ctx, {
    type: 'bar',
    data: {
        labels: [<%= chartLabels %>],
        datasets: [{
            label: 'Lectures',
            data: [<%= chartData %>],
            backgroundColor: gradient,
            borderColor: '#2563eb',
            borderWidth: 2,
            borderRadius: 8,
            barThickness: 45
        }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
            legend: { display: false },
            tooltip: {
                backgroundColor: '#0f172a',
                padding: 15,
                titleFont: { size: 14, weight: '800' },
                bodyFont: { size: 13 },
                displayColors: false
            }
        },
        scales: {
            y: { 
                beginAtZero: true, 
                grid: { color: '#f1f5f9', drawBorder: false },
                ticks: { stepSize: 1, font: { weight: '600' } } 
            },
            x: { 
                grid: { display: false }, 
                ticks: { font: { weight: '700', size: 12 }, color: '#1e293b' } 
            }
        }
    }
});
</script>

</body>
</html>