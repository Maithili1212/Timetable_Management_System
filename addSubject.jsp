<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<title>Add Subject</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
body{
background:#eef2f7;
font-family:'Segoe UI',sans-serif;
}
.header{
background:#1f2937;
color:white;
padding:20px;
text-align:center;
font-size:28px;
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
</style>

</head>

<body>

<!-- ✅ NAVBAR -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
<div class="container-fluid">

<a class="navbar-brand" href="index.jsp">Timetable System</a>

<button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
<span class="navbar-toggler-icon"></span>
</button>

<div class="collapse navbar-collapse" id="navbarNav">
<ul class="navbar-nav ms-auto">

<li class="nav-item">
<a class="nav-link" href="addFaculty.jsp">Faculty</a>
</li>

<li class="nav-item">
<a class="nav-link active" href="addSubject.jsp">Subject</a>
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

</div>
</nav>

<div class="header">Timetable Management System</div>

<div class="main-container">

<!-- FORM -->
<div class="form-box">

<h3>Add Subject</h3>

<!-- MESSAGE -->
<%
String msg = request.getParameter("msg");
if (msg != null) {
%>
<div class="alert alert-success"><%= msg %></div>
<%
}
%>

<form action="<%=request.getContextPath()%>/SubjectServlet" method="post">

<input type="text" name="subject_name" placeholder="Subject Name" class="form-control mb-2" required>

<!-- 🔥 DROPDOWN INSTEAD OF MANUAL ID -->
<select name="faculty_id" class="form-control mb-2" required>
<option value="">Select Faculty</option>

<%
Connection con1=null;
Statement st1=null;
ResultSet rs1=null;

try{
Class.forName("com.mysql.cj.jdbc.Driver");

con1=DriverManager.getConnection(
"jdbc:mysql://localhost:3306/timetable_db",
"root",
"2772006");

st1=con1.createStatement();

rs1=st1.executeQuery("SELECT * FROM faculty");

while(rs1.next()){
%>

<option value="<%=rs1.getInt("faculty_id")%>">
<%=rs1.getString("faculty_name")%>
</option>

<%
}
}catch(Exception e){
out.println("Error loading faculty");
}
%>

</select>

<input type="number" name="hours" placeholder="Hours per week" class="form-control mb-2" required>

<button type="submit" class="btn btn-primary">Add Subject</button>

</form>

</div>

<!-- TABLE -->
<div class="form-box">

<h3>Subject List</h3>

<table class="table table-bordered">

<tr>
<th>ID</th>
<th>Subject</th>
<th>Faculty</th>
<th>Hours</th>
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

rs=st.executeQuery(
"SELECT s.subject_id, s.subject_name, s.hours_per_week, f.faculty_name " +
"FROM subject s JOIN faculty f ON s.faculty_id = f.faculty_id");

while(rs.next()){
%>

<tr>
<td><%=rs.getInt("subject_id")%></td>
<td><%=rs.getString("subject_name")%></td>
<td><%=rs.getString("faculty_name")%></td>
<td><%=rs.getInt("hours_per_week")%></td>
</tr>

<%
}

} catch(Exception e){
out.println("<tr><td colspan='4'>Error loading data</td></tr>");
}
%>

</table>

</div>

</div>

<!-- ✅ Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
