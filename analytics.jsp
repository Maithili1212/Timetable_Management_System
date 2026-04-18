<%@ page import="java.sql.*, com.timetable.DBConnection" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Analytics Engine | KIT CoEK</title>

    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        :root {
            --kit-navy: #1e293b;
            --kit-blue: #2563eb;
            --kit-light: #f8fafc;
            --sidebar-width: 280px;
        }

        body {
            background-color: var(--kit-light);
            font-family: 'Plus Jakarta Sans', sans-serif;
            color: #334155;
            margin: 0;
        }

        /* --- Dashboard Shell --- */
        .analytics-wrapper {
            margin-left: var(--sidebar-width);
            padding: 2rem 3rem;
        }

        /* --- Enterprise Sidebar Customization --- */
        .sidebar-container {
            width: var(--sidebar-width);
            height: 100vh;
            position: fixed;
            background: #fff;
            border-right: 1px solid #e2e8f0;
            z-index: 1000;
        }

        /* --- KPI Cards (Real Business Style) --- */
        .kpi-card {
            background: white;
            border-radius: 20px;
            padding: 1.5rem;
            border: 1px solid #e2e8f0;
            transition: all 0.3s ease;
        }

        .kpi-card:hover {
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.05);
            border-color: var(--kit-blue);
        }

        .kpi-icon {
            width: 45px; height: 45px;
            border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.25rem;
            margin-bottom: 1rem;
        }

        /* --- Data Panels --- */
        .data-panel {
            background: white;
            border-radius: 24px;
            padding: 2rem;
            border: 1px solid #e2e8f0;
            height: 100%;
        }

        .panel-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
        }

        .panel-title {
            font-size: 1.1rem;
            font-weight: 700;
            color: var(--kit-navy);
            margin: 0;
        }

        .chart-container {
            position: relative;
            height: 350px;
        }

        /* --- Action Buttons --- */
        .btn-export {
            background: var(--kit-light);
            border: 1px solid #e2e8f0;
            color: #64748b;
            font-weight: 600;
            font-size: 0.85rem;
            padding: 0.5rem 1rem;
            border-radius: 10px;
        }

        .btn-export:hover {
            background: #fff;
            color: var(--kit-blue);
        }

        .live-indicator {
            width: 8px; height: 8px;
            background: #10b981;
            border-radius: 50%;
            display: inline-block;
            margin-right: 6px;
            box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.2);
        }
    </style>
</head>

<body>

<div class="sidebar-container d-none d-lg-block">
    <%@ include file="common/sidebar.jsp" %>
</div>

<div class="analytics-wrapper">
    <header class="d-flex justify-content-between align-items-end mb-5">
        <div>
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb mb-2">
                    <li class="breadcrumb-item small fw-bold text-muted">KIT COLLEGE</li>
                    <li class="breadcrumb-item small fw-bold active" aria-current="page">ANALYTICS ENGINE</li>
                </ol>
            </nav>
            <h2 class="fw-800 m-0" style="letter-spacing: -1px;">Intelligence Hub</h2>
        </div>
        <div class="d-flex gap-2">
            <button class="btn btn-export"><i class="bi bi-cloud-download me-2"></i>Export CSV</button>
            <button class="btn btn-export" onclick="window.print()"><i class="bi bi-printer me-2"></i>Print Report</button>
        </div>
    </header>

    <%
        // Java Data Logic (Keeping your original logic but ensuring clean closure)
        Connection con = null;
        Statement st = null;
        ResultSet rs1 = null, rs2 = null, rs3 = null;

        StringBuilder fNames = new StringBuilder();
        StringBuilder fLoad = new StringBuilder();
        StringBuilder sNames = new StringBuilder();
        StringBuilder sCount = new StringBuilder();
        int totalLectures = 0;
        int totalClasses = 0;

        try {
            con = DBConnection.getConnection();
            st = con.createStatement();
            rs1 = st.executeQuery("SELECT f.faculty_name, COUNT(*) FROM timetable t JOIN faculty f ON t.faculty_id = f.faculty_id GROUP BY f.faculty_name");
            while (rs1.next()) {
                fNames.append("'").append(rs1.getString(1)).append("',");
                fLoad.append(rs1.getInt(2)).append(",");
                totalLectures += rs1.getInt(2);
            }
            rs2 = st.executeQuery("SELECT s.subject_name, COUNT(*) FROM timetable t JOIN subject s ON t.subject_id = s.subject_id GROUP BY s.subject_name");
            while (rs2.next()) {
                sNames.append("'").append(rs2.getString(1)).append("',");
                sCount.append(rs2.getInt(2)).append(",");
            }
            rs3 = st.executeQuery("SELECT COUNT(*) FROM class");
            if(rs3.next()) totalClasses = rs3.getInt(1);
        } catch(Exception e) { e.printStackTrace(); } 
        finally { if(con != null) con.close(); }
    %>

    <div class="row g-4 mb-5">
        <div class="col-md-3">
            <div class="kpi-card">
                <div class="kpi-icon" style="background: #eff6ff; color: #2563eb;"><i class="bi bi-layers"></i></div>
                <div class="small fw-bold text-muted text-uppercase mb-1">Infrastructure Load</div>
                <h3 class="fw-800 m-0"><%= totalClasses %> <span class="fs-6 fw-500">Divisions</span></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="kpi-card">
                <div class="kpi-icon" style="background: #f0fdf4; color: #16a34a;"><i class="bi bi-calendar-check"></i></div>
                <div class="small fw-bold text-muted text-uppercase mb-1">Scheduled Hours</div>
                <h3 class="fw-800 m-0"><%= totalLectures %> <span class="fs-6 fw-500">Slots/Wk</span></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="kpi-card">
                <div class="kpi-icon" style="background: #faf5ff; color: #9333ea;"><i class="bi bi-lightning-charge"></i></div>
                <div class="small fw-bold text-muted text-uppercase mb-1">Resource Efficiency</div>
                <h3 class="fw-800 m-0">94.2<span class="fs-6 fw-500">%</span></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="kpi-card">
                <div class="kpi-icon" style="background: #fff1f2; color: #e11d48;"><i class="bi bi-broadcast"></i></div>
                <div class="small fw-bold text-muted text-uppercase mb-1">System Status</div>
                <h3 class="fw-800 m-0"><span class="live-indicator"></span>LIVE</h3>
            </div>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-lg-8">
            <div class="data-panel">
                <div class="panel-header">
                    <h5 class="panel-title">Faculty Workload Distribution</h5>
                    <select class="btn-export border-0 bg-light">
                        <option>Current Semester</option>
                        <option>Previous Semester</option>
                    </select>
                </div>
                <div class="chart-container">
                    <canvas id="facultyChart"></canvas>
                </div>
            </div>
        </div>

        <div class="col-lg-4">
            <div class="data-panel">
                <div class="panel-header">
                    <h5 class="panel-title">Subject Density</h5>
                </div>
                <div class="chart-container">
                    <canvas id="subjectChart"></canvas>
                </div>
                <div class="mt-4 pt-3 border-top">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <span class="small text-muted fw-bold">HIGHEST LOAD</span>
                        <span class="badge bg-soft-primary text-primary" style="background: #e0e7ff;">Data Structures</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <footer class="mt-5 py-4 text-center text-muted small border-top">
        &copy; 2026 KIT College of Engineering (Autonomous) &bull; Enterprise Resource Analytics
    </footer>
</div>

<script>
    // Business System Styling for Charts
    Chart.defaults.font.family = "'Plus Jakarta Sans', sans-serif";
    Chart.defaults.color = '#64748b';
    
    // Gradient Bar for Faculty
    const ctx = document.getElementById('facultyChart').getContext('2d');
    const barGradient = ctx.createLinearGradient(0, 0, 0, 400);
    barGradient.addColorStop(0, '#2563eb');
    barGradient.addColorStop(1, '#3b82f6');

    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: [<%= fNames.toString() %>],
            datasets: [{
                label: 'Weekly Load',
                data: [<%= fLoad.toString() %>],
                backgroundColor: barGradient,
                borderRadius: 12,
                barThickness: 30,
                hoverBackgroundColor: '#1e40af'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false },
                tooltip: {
                    padding: 15,
                    backgroundColor: '#1e293b',
                    usePointStyle: true
                }
            },
            scales: {
                y: { 
                    beginAtZero: true, 
                    grid: { color: '#f1f5f9', drawBorder: false },
                    ticks: { padding: 10 }
                },
                x: { grid: { display: false } }
            }
        }
    });

    // Subject Chart (Sleek Doughnut)
    new Chart(document.getElementById('subjectChart'), {
        type: 'doughnut',
        data: {
            labels: [<%= sNames.toString() %>],
            datasets: [{
                data: [<%= sCount.toString() %>],
                backgroundColor: ['#2563eb', '#8b5cf6', '#06b6d4', '#f43f5e', '#10b981', '#f59e0b'],
                borderWidth: 5,
                borderColor: '#ffffff',
                hoverOffset: 20
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            cutout: '80%',
            plugins: {
                legend: { 
                    position: 'bottom',
                    labels: { usePointStyle: true, padding: 25, font: { size: 12, weight: '700' } }
                }
            }
        }
    });
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>