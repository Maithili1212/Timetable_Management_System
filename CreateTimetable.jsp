<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<title>Create Timetable</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
body{
background:#eef2f7;
font-family:'Segoe UI';
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
}
</style>
</head>

<body>

<!-- ✅ NAVBAR -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
  <div class="container-fluid">
    
    <a class="navbar-brand fw-bold" href="#">TMS</a>

    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
      <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="navbarNav">
      <ul class="navbar-nav ms-auto">

        <li class="nav-item">
          <a class="nav-link" href="dashboard.jsp">Dashboard</a>
        </li>

        <li class="nav-item">
          <a class="nav-link" href="addClass.jsp">Add Class</a>
        </li>

        <li class="nav-item">
          <a class="nav-link" href="addSubject.jsp">Add Subject</a>
        </li>

        <li class="nav-item">
          <a class="nav-link" href="addFaculty.jsp">Add Faculty</a>
        </li>

        <li class="nav-item">
          <a class="nav-link active fw-bold text-warning" href="createTimetable.jsp">Create Timetable</a>
        </li>

      </ul>
    </div>

  </div>
</nav>

<!-- HEADER -->
<div class="header">Timetable Management System</div>

<div class="main-container">
<div class="form-box">

<h3>Create Timetable</h3>

<!-- MESSAGE -->
<%
String msg = request.getParameter("msg");
if (msg != null) {
%>
<div class="alert alert-warning"><%= msg %></div>
<%
}
%>

<form action="<%=request.getContextPath()%>/CreateTimetableServlet" method="post">

<div class="row">

<%
Connection con = null;
Statement st = null;
ResultSet rs1 = null, rs2 = null, rs3 = null;

try {
Class.forName("com.mysql.cj.jdbc.Driver");

con = DriverManager.getConnection(
"jdbc:mysql://localhost:3306/timetable_db",
"root",
"your password");

st = con.createStatement();
%>

<!-- CLASS -->
<div class="col-md-4 mb-3">
<label>Class</label>
<select name="class_id" class="form-control" required>
<option value="">Select</option>
<%
rs1 = st.executeQuery("SELECT * FROM class");
while(rs1.next()){
%>
<option value="<%=rs1.getInt("class_id")%>">
<%=rs1.getString("class_name")%>
</option>
<% } %>
</select>
</div>

<!-- SUBJECT -->
<div class="col-md-4 mb-3">
<label>Subject</label>
<select name="subject_id" class="form-control" required>
<option value="">Select</option>
<%
rs2 = st.executeQuery("SELECT * FROM subject");
while(rs2.next()){
%>
<option value="<%=rs2.getInt("subject_id")%>">
<%=rs2.getString("subject_name")%>
</option>
<% } %>
</select>
</div>

<!-- FACULTY -->
<div class="col-md-4 mb-3">
<label>Faculty</label>
<select name="faculty_id" class="form-control" required>
<option value="">Select</option>
<%
rs3 = st.executeQuery("SELECT * FROM faculty");
while(rs3.next()){
%>
<option value="<%=rs3.getInt("faculty_id")%>">
<%=rs3.getString("faculty_name")%>
</option>
<% } %>
</select>
</div>

<%
} catch(Exception e){
out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
} finally {
try { if(rs1!=null) rs1.close(); } catch(Exception e){}
try { if(rs2!=null) rs2.close(); } catch(Exception e){}
try { if(rs3!=null) rs3.close(); } catch(Exception e){}
try { if(st!=null) st.close(); } catch(Exception e){}
try { if(con!=null) con.close(); } catch(Exception e){}
}
%>

<!-- DAY -->
<div class="col-md-4 mb-3">
<label>Day</label>
<select name="day" class="form-control" required>
<option>Mon</option>
<option>Tue</option>
<option>Wed</option>
<option>Thu</option>
<option>Fri</option>
<option>Sat</option>
</select>
</div>

<!-- TIME -->
<div class="col-md-4 mb-3">
<label>Time Slot</label>
<input type="text" name="timeslot" class="form-control" required>
</div>

<!-- ROOM -->
<div class="col-md-4 mb-3">
<label>Room No</label>
<input type="number" name="room_no" class="form-control" required>
</div>

</div>

<button type="submit" class="btn btn-primary mt-3">Generate Timetable</button>

</form>

</div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
