<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>
<head>
<title>Add Faculty</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<style>

body{
background:#eef2f7;
font-family:'Segoe UI',sans-serif;
margin:0;
}

.header{
background:#1f2937;
color:white;
padding:20px;
text-align:center;
font-size:28px;
font-weight:600;
}

.main-container{
width:95%;
margin:auto;
margin-top:40px;
}

.form-box{
background:white;
padding:40px;
border-radius:10px;
box-shadow:0 8px 20px rgba(0,0,0,0.08);
margin-bottom:30px;
}

.title{
font-size:28px;
font-weight:600;
margin-bottom:30px;
}

.form-control{
height:50px;
font-size:16px;
}

.btn-primary{
height:50px;
border-radius:25px;
font-size:16px;
}

</style>

</head>

<body>

<!-- NAVBAR -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
<div class="container-fluid">

<a class="navbar-brand" href="index.jsp">
Timetable System
</a>

<ul class="navbar-nav ms-auto">

<li class="nav-item">
<a class="nav-link active" href="addFaculty.jsp">Faculty</a>
</li>

<li class="nav-item">
<a class="nav-link" href="addSubject.jsp">Subject</a>
</li>

<li class="nav-item">
<a class="nav-link" href="addClass.jsp">Class</a>
</li>

<li class="nav-item">
<a class="nav-link" href="CreateTimetable.jsp">Create Timetable</a>
</li>

<li class="nav-item">
<a class="nav-link" href="viewTimetable.jsp">View Timetable</a>
</li>

</ul>

</div>
</nav>

<!-- HEADER -->
<div class="header">
Timetable Management System
</div>

<div class="main-container">

<!-- ADD FACULTY FORM -->
<div class="form-box">

<div class="title">Add Faculty</div>

<!-- ✅ MESSAGE ALERT -->
<%
String msg = request.getParameter("msg");
if (msg != null) {
%>
<div class="alert alert-success alert-dismissible fade show" role="alert">
    <%= msg %>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>
<%
}
%>

<form action="FacultyServlet" method="post">

<div class="row align-items-end">

<div class="col-md-5">
<label class="form-label">Faculty Name</label>
<input type="text" name="faculty_name" class="form-control" required>
</div>

<div class="col-md-5">
<label class="form-label">Department</label>
<input type="text" name="department" class="form-control" required>
</div>

<div class="col-md-2">
<button type="submit" class="btn btn-primary w-100">
Add
</button>
</div>

</div>

</form>

</div>


<!-- FACULTY LIST TABLE -->
<div class="form-box">

<h3 class="mb-3">Faculty List</h3>

<table class="table table-bordered table-striped">

<tr>
<th>ID</th>
<th>Faculty Name</th>
<th>Department</th>
</tr>

<%

Connection con=null;
Statement st=null;
ResultSet rs=null;

try {

Class.forName("com.mysql.cj.jdbc.Driver");

con=DriverManager.getConnection(
"jdbc:mysql://localhost:3306/timetable_db",
"root",
"your password");

st=con.createStatement();

rs=st.executeQuery("SELECT * FROM faculty");

while(rs.next()){
%>

<tr>
<td><%=rs.getInt("faculty_id")%></td>
<td><%=rs.getString("faculty_name")%></td>
<td><%=rs.getString("department")%></td>
</tr>

<%
}

} catch(Exception e){
out.println("<tr><td colspan='3'>Error loading data</td></tr>");
} finally {
try {
if(rs!=null) rs.close();
if(st!=null) st.close();
if(con!=null) con.close();
} catch(Exception e){}
}
%>

</table>

</div>

</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
