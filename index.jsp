<%@ page import="java.sql.*, com.timetable.DBConnection" %>
<%
    int totalFaculty = 0, totalClasses = 0, totalSubjects = 0, totalStudents = 0, totalTimetable = 0;
    try (Connection conn = DBConnection.getConnection()) {
        String[] queries = {
            "SELECT COUNT(*) FROM faculty", "SELECT COUNT(*) FROM class",
            "SELECT COUNT(*) FROM subject", "SELECT COUNT(*) FROM student",
            "SELECT COUNT(*) FROM timetable"
        };
        int[] results = new int[5];
        for (int i = 0; i < queries.length; i++) {
            try (Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(queries[i])) {
                if (rs.next()) results[i] = rs.getInt(1);
            }
        }
        totalFaculty = results[0]; totalClasses = results[1]; 
        totalSubjects = results[2]; totalStudents = results[3]; totalTimetable = results[4];
    } catch (Exception e) { e.printStackTrace(); }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KIT CoEK | Admin Dashboard</title>
    
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">

    <style>
        :root {
            --sidebar-bg: #0f172a;
            --primary-blue: #4361ee;
            --accent-purple: #7209b7;
            --bg-body: #f1f5f9;
        }

        body {
            background-color: var(--bg-body);
            font-family: 'Plus Jakarta Sans', sans-serif;
            margin: 0;
            color: #1e293b;
        }

        /* --- SIDEBAR --- */
        .sidebar {
            width: 280px;
            height: 100vh;
            position: fixed;
            background: var(--sidebar-bg);
            padding: 1.5rem 1rem;
            z-index: 1000;
            overflow-y: auto;
        }

        .sidebar-brand {
            padding: 1rem;
            color: white;
            font-weight: 800;
            font-size: 1.3rem;
            display: flex;
            align-items: center;
            border-bottom: 1px solid rgba(255,255,255,0.1);
            margin-bottom: 1rem;
        }

        .nav-label {
            font-size: 0.65rem;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            color: #475569;
            margin: 1.2rem 0 0.5rem 1rem;
            font-weight: 800;
        }

        .nav-link-custom {
            display: flex;
            align-items: center;
            padding: 0.7rem 1rem;
            color: #cbd5e1;
            text-decoration: none;
            border-radius: 12px;
            margin-bottom: 3px;
            font-weight: 600;
            font-size: 0.9rem;
            transition: 0.3s;
        }

        .nav-link-custom:hover {
            background: rgba(255,255,255,0.05);
            color: white;
            transform: translateX(4px);
        }

        .nav-link-custom.active {
            background: var(--primary-blue);
            color: white;
            box-shadow: 0 4px 12px rgba(67, 97, 238, 0.4);
        }

        .nav-link-custom i { margin-right: 12px; font-size: 1.1rem; }

        /* --- CONTENT --- */
        .content-wrapper {
            margin-left: 280px;
            padding: 2.5rem;
        }

        /* --- WONDERFUL BENTO CARDS --- */
        .bento-card {
            background: white;
            border-radius: 28px;
            padding: 1.8rem;
            border: 1px solid rgba(0,0,0,0.05);
            transition: all 0.4s cubic-bezier(0.165, 0.84, 0.44, 1);
            height: 100%;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            position: relative;
        }

        .bento-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 40px rgba(0,0,0,0.08);
            border-color: var(--primary-blue);
        }

        .icon-box {
            width: 54px; height: 54px;
            border-radius: 16px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.4rem;
            margin-bottom: 1.2rem;
        }

        /* Icon Palette */
        .c-blue { background: #eff6ff; color: #2563eb; }
        .c-purple { background: #f5f3ff; color: #7c3aed; }
        .c-emerald { background: #ecfdf5; color: #059669; }
        .c-amber { background: #fff7ed; color: #ea580c; }
        .c-rose { background: #fff1f2; color: #e11d48; }
        .c-cyan { background: #ecfeff; color: #0891b2; }

        .btn-card {
            border-radius: 12px;
            font-weight: 700;
            font-size: 0.85rem;
            padding: 0.6rem;
            width: 100%;
            transition: 0.3s;
        }

        /* --- HEADER & STATS --- */
        .stat-box {
            background: white;
            padding: 1.5rem;
            border-radius: 20px;
            border: 1px solid #e2e8f0;
        }

        .ai-banner {
            background: var(--sidebar-bg);
            border-radius: 30px;
            padding: 3rem;
            color: white;
            margin-top: 2rem;
            border: 1px solid rgba(255,255,255,0.1);
        }
    </style>
</head>
<body>

<nav class="sidebar">
    <div class="sidebar-brand">
        <i class="bi bi-mortarboard-fill me-2 text-primary"></i> 
        KIT CoEK
    </div>

    <p class="nav-label">Core</p>
    <a href="#" class="nav-link-custom active"><i class="bi bi-speedometer2"></i> Dashboard</a>
    <a href="viewTimetable.jsp" class="nav-link-custom"><i class="bi bi-calendar3"></i> View Timetable</a>
    
    <p class="nav-label">Resource Management</p>
    <a href="addFaculty.jsp" class="nav-link-custom"><i class="bi bi-person-badge"></i> Faculty</a>
    <a href="addClass.jsp" class="nav-link-custom"><i class="bi bi-door-open"></i> Classes</a>
    <a href="addSubject.jsp" class="nav-link-custom"><i class="bi bi-book"></i> Subject</a>
    
    <p class="nav-label">Scheduling Tools</p>
    <a href="CreateTimetable.jsp" class="nav-link-custom"><i class="bi bi-plus-circle"></i> Create Timetable</a>
    <a href="dragDropTimetable.jsp" class="nav-link-custom"><i class="bi bi-cursor-move"></i> Visual Editor</a>
    <a href="viewSwapRequests.jsp" class="nav-link-custom"><i class="bi bi-arrow-repeat"></i> Swap Request</a>
    
    <p class="nav-label">Analytics &amp; Reports</p>
    <a href="facultyWorkload.jsp" class="nav-link-custom"><i class="bi bi-graph-up-arrow"></i> Workload</a>
    <a href="analytics.jsp" class="nav-link-custom"><i class="bi bi-pie-chart"></i> View Analytics</a>
    <a href="ExportPDFServlet" class="nav-link-custom"><i class="bi bi-file-earmark-pdf"></i> PDF Export</a>

    <div class="mt-4 pt-4 border-top border-secondary opacity-25"></div>
    <a href="LogoutServlet" class="nav-link-custom text-danger"><i class="bi bi-box-arrow-right"></i> Logout</a>
</nav>

<div class="content-wrapper">
    <header class="d-flex justify-content-between align-items-center mb-5">
        <div>
            <h1 class="fw-800 mb-1">KIT Admin Dashboard</h1>
            <p class="text-muted mb-0">KIT College of Engineering (Autonomous), Kolhapur</p>
        </div>
        <div class="bg-white border rounded-pill px-4 py-2 shadow-sm fw-bold text-primary">
            Master Portal 2026
        </div>
    </header>

    <div class="row g-4 mb-5">
        <div class="col-md-3"><div class="stat-box"><small class="text-muted fw-bold">FACULTY</small><h3 class="fw-800 mb-0"><%= totalFaculty %></h3></div></div>
        <div class="col-md-3"><div class="stat-box"><small class="text-muted fw-bold">ROOMS</small><h3 class="fw-800 mb-0"><%= totalClasses %></h3></div></div>
        <div class="col-md-3"><div class="stat-box"><small class="text-muted fw-bold">SUBJECTS</small><h3 class="fw-800 mb-0"><%= totalSubjects %></h3></div></div>
        <div class="col-md-3"><div class="stat-box"><small class="text-muted fw-bold">ACTIVE SLOTS</small><h3 class="fw-800 mb-0"><%= totalTimetable %></h3></div></div>
    </div>

    <h4 class="fw-800 mb-4">Operations Hub</h4>
    <div class="row g-4">
        <div class="col-lg-3 col-md-4">
            <div class="bento-card">
                <div class="icon-box c-blue"><i class="bi bi-people-fill"></i></div>
                <h6 class="fw-800">Faculty</h6>
                <p class="small text-muted mb-3">Manage staff and expertise profiles.</p>
                <a href="addFaculty.jsp" class="btn btn-outline-primary btn-card">Manage Faculty</a>
            </div>
        </div>
        <div class="col-lg-3 col-md-4">
            <div class="bento-card">
                <div class="icon-box c-emerald"><i class="bi bi-building"></i></div>
                <h6 class="fw-800">Classes</h6>
                <p class="small text-muted mb-3">Set room capacities and availability.</p>
                <a href="addClass.jsp" class="btn btn-outline-success btn-card">View Classes</a>
            </div>
        </div>
        <div class="col-lg-3 col-md-4">
            <div class="bento-card">
                <div class="icon-box c-purple"><i class="bi bi-journal-text"></i></div>
                <h6 class="fw-800">Subject</h6>
                <p class="small text-muted mb-3">Edit course codes and credits.</p>
                <a href="addSubject.jsp" class="btn btn-outline-secondary btn-card">Edit Subjects</a>
            </div>
        </div>
        <div class="col-lg-3 col-md-4">
            <div class="bento-card">
                <div class="icon-box c-amber"><i class="bi bi-calendar-plus"></i></div>
                <h6 class="fw-800">Create Timetable</h6>
                <p class="small text-muted mb-3">Add individual lecture slots manually.</p>
                <a href="CreateTimetable.jsp" class="btn btn-outline-warning btn-card">Add Manually</a>
            </div>
        </div>
        <div class="col-lg-3 col-md-4">
            <div class="bento-card">
                <div class="icon-box c-rose"><i class="bi bi-graph-up-arrow"></i></div>
                <h6 class="fw-800">Workload</h6>
                <p class="small text-muted mb-3">Analyze teacher utilization rates.</p>
                <a href="facultyWorkload.jsp" class="btn btn-outline-danger btn-card">View Load</a>
            </div>
        </div>
        <div class="col-lg-3 col-md-4">
            <div class="bento-card">
                <div class="icon-box c-cyan"><i class="bi bi-pie-chart-fill"></i></div>
                <h6 class="fw-800">View Analytics</h6>
                <p class="small text-muted mb-3">Visual performance metrics hub.</p>
                <a href="analytics.jsp" class="btn btn-outline-info btn-card">Open Analytics</a>
            </div>
        </div>
      <div class="col-lg-3 col-md-4">
    <div class="bento-card">
        <div class="icon-box c-blue">
            <i class="bi bi-arrows-move" style="font-size: 1.5rem;"></i>
        </div>
        <h6 class="fw-800 mt-2">Visual Editor</h6>
        <p class="small text-muted mb-3">Drag &amp; drop schedule refinement.</p>
        <a href="dragDropTimetable.jsp" class="btn btn-primary btn-card border-0">Launch Editor</a>
    </div>
</div>
        <div class="col-lg-3 col-md-4">
            <div class="bento-card">
                <div class="icon-box c-emerald"><i class="bi bi-table"></i></div>
                <h6 class="fw-800">View Timetable</h6>
                <p class="small text-muted mb-3">Browse the full master schedule.</p>
                <a href="viewTimetable.jsp" class="btn btn-success btn-card border-0">Open Master</a>
            </div>
        </div>
        <div class="col-lg-3 col-md-4">
            <div class="bento-card">
                <div class="icon-box c-amber"><i class="bi bi-arrow-repeat"></i></div>
                <h6 class="fw-800">Swap Request</h6>
                <p class="small text-muted mb-3">Handle lecture exchange queries.</p>
                <a href="viewSwapRequests.jsp" class="btn btn-warning btn-card border-0">Review Swaps</a>
            </div>
        </div>
        <div class="col-lg-3 col-md-4">
            <div class="bento-card">
                <div class="icon-box c-rose"><i class="bi bi-file-earmark-pdf-fill"></i></div>
                <h6 class="fw-800">PDF Export</h6>
                <p class="small text-muted mb-3">Generate printable schedules.</p>
                <a href="ExportPDFServlet" class="btn btn-dark btn-card">Download PDF</a>
            </div>
        </div>
    </div>

    <div class="ai-banner">
        <div class="row align-items-center">
            <div class="col-md-8">
                <h2 class="fw-800">AI Scheduling Algorithm</h2>
                <p class="opacity-75 mb-0">Solve all conflicts and optimize resources for KIT College with our genetic engine.</p>
            </div>
            <div class="col-md-4 text-md-end mt-3 mt-md-0">
                <a href="AutoGenerateServlet" class="btn btn-primary btn-lg px-5 rounded-pill fw-800 shadow">Run AI Generator</a>
            </div>
        </div>
    </div>

    <footer class="mt-5 py-4 text-center text-muted small border-top">
        &copy; 2026 KIT College of Engineering (Autonomous), Kolhapur &bull; Enterprise Portal
    </footer>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>