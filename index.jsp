<!DOCTYPE html>
<html>
<head>
<title>Timetable Management System</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Bootstrap Icons -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">

<style>

body{
background:#f4f6f9;
font-family:'Segoe UI',sans-serif;
margin:0;
}

/* Header */
.header{
background:#1f2937;
color:white;
padding:25px;
text-align:center;
font-size:30px;
font-weight:600;
letter-spacing:1px;
}

/* Dashboard container */
.dashboard{
width:95%;
margin:auto;
margin-top:80px;
}

/* Cards */
.card-box{
background:white;
padding:55px 35px;
border-radius:14px;
box-shadow:0 8px 20px rgba(0,0,0,0.08);
transition:0.3s;
text-align:center;
min-height:260px;
}

.card-box:hover{
transform:translateY(-10px);
box-shadow:0 15px 35px rgba(0,0,0,0.15);
}

/* Icons */
.icon{
font-size:60px;
margin-bottom:20px;
color:#2c3e50;
}

/* Card title */
.card-title{
font-size:22px;
font-weight:600;
margin-bottom:20px;
}

/* Button */
.btn{
border-radius:30px;
padding:12px 30px;
font-size:16px;
}

</style>

</head>

<body>

<div class="header">
Timetable Management System
</div>

<div class="dashboard">

<div class="row g-4">

<div class="col-lg-3 col-md-6">
<div class="card-box">
<div class="icon">
<i class="bi bi-person-badge-fill"></i>
</div>
<div class="card-title">Faculty Management</div>
<a href="addFaculty.jsp" class="btn btn-primary">Add Faculty</a>
</div>
</div>

<div class="col-lg-3 col-md-6">
<div class="card-box">
<div class="icon">
<i class="bi bi-book-fill"></i>
</div>
<div class="card-title">Subject Management</div>
<a href="addSubject.jsp" class="btn btn-success">Add Subject</a>
</div>
</div>

<div class="col-lg-3 col-md-6">
<div class="card-box">
<div class="icon">
<i class="bi bi-building"></i>
</div>
<div class="card-title">Class Management</div>
<a href="addClass.jsp" class="btn btn-warning">Add Class</a>
</div>
</div>

<div class="col-lg-3 col-md-6">
<div class="card-box">
<div class="icon">
<i class="bi bi-calendar-week"></i>
</div>
<div class="card-title">View Timetable</div>
<a href="viewTimetable.jsp" class="btn btn-info">View Timetable</a>
</div>
</div>


<div style="text-align:center; margin:20px;">
    <a href="AutoGenerateServlet" class="btn btn-danger">
        Auto Generate Timetable
    </a>
</div>

</div>

</div>

</body>

</html>