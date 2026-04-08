<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<!DOCTYPE html>
<html>
<head>
<title>View Timetable</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
body{
font-family:Arial;
background:#f4f6f9;
margin:0;
}

.header{
background:#1f2937;
color:white;
padding:20px;
text-align:center;
font-size:28px;
font-weight:bold;
}

h2{
text-align:center;
margin-top:20px;
}

/* TABLE DESIGN */
table{
width:90%;
margin:auto;
border-collapse:collapse;
margin-bottom:40px;
background:white;
border-radius:10px;
overflow:hidden;
box-shadow:0 4px 10px rgba(0,0,0,0.1);
}

th{
background:#111827;
color:white;
padding:12px;
}

td{
border:1px solid #ddd;
padding:10px;
text-align:center;
height:80px;
transition:0.3s;
}

/* HOVER EFFECT */
td:hover{
transform:scale(1.05);
box-shadow:0 4px 10px rgba(0,0,0,0.2);
}

/* SUBJECT COLORS */
.sub1{background:#dbeafe;}
.sub2{background:#dcfce7;}
.sub3{background:#fef9c3;}
.sub4{background:#fde2e2;}
.sub5{background:#ede9fe;}

/* FREE SLOT */
.free{
color:#9ca3af;
font-style:italic;
}
</style>
</head>

<body>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
<div class="container-fluid">
<a class="navbar-brand" href="index.jsp">Timetable System</a>

<ul class="navbar-nav ms-auto">
<li class="nav-item"><a class="nav-link" href="addFaculty.jsp">Faculty</a></li>
<li class="nav-item"><a class="nav-link" href="addSubject.jsp">Subject</a></li>
<li class="nav-item"><a class="nav-link" href="addClass.jsp">Class</a></li>
<li class="nav-item"><a class="nav-link" href="CreateTimetable.jsp">Create Timetable</a></li>
<li class="nav-item"><a class="nav-link" href="viewTimetable.jsp">View Timetable</a></li>
</ul>
</div>
</nav>

<div class="header">Timetable Management System</div>

<div style="text-align:center; margin:20px;">
    <a href="ExportPDFServlet" class="btn btn-success">
        Download Timetable PDF
    </a>
</div>

<h2>Class Timetable</h2>

<%
Connection con=null;
PreparedStatement ps=null;
ResultSet rs=null;

try{

Class.forName("com.mysql.cj.jdbc.Driver");

con=DriverManager.getConnection(
"jdbc:mysql://localhost:3306/timetable_db",
"root",
"your password"
);

/* GET ALL CLASSES */
Statement st=con.createStatement();
rs=st.executeQuery("SELECT * FROM class");

List<Integer> classIds=new ArrayList<>();
Map<Integer,String> classNames=new HashMap<>();

while(rs.next()){
classIds.add(rs.getInt("class_id"));
classNames.put(rs.getInt("class_id"),rs.getString("class_name"));
}

rs.close();
st.close();

/* DAYS & TIMES */
String[] days = {"Mon","Tue","Wed","Thu","Fri"};
String[] times = {"9-10","10-11","11-12","1-2","2-3"};

/* LOOP FOR EACH CLASS */
for(int classId:classIds){
%>

<h4 style="text-align:center;">Class: <%=classNames.get(classId)%></h4>

<table>

<tr>
<th>Time</th>
<th>Monday</th>
<th>Tuesday</th>
<th>Wednesday</th>
<th>Thursday</th>
<th>Friday</th>
</tr>

<%
for(String t:times){
%>

<tr>
<td><%=t%></td>

<%
for(String d:days){

ps=con.prepareStatement(
"SELECT s.subject_name,f.faculty_name,t.room_no "+
"FROM timetable t "+
"JOIN subject s ON t.subject_id=s.subject_id "+
"JOIN faculty f ON t.faculty_id=f.faculty_id "+
"WHERE t.class_id=? AND t.day=? AND t.time_slot=?"
);

ps.setInt(1,classId);
ps.setString(2,d);
ps.setString(3,t);

rs=ps.executeQuery();

if(rs.next()){

String subject = rs.getString("subject_name");

/* COLOR LOGIC */
String colorClass="sub1";
if(subject.equalsIgnoreCase("Java")) colorClass="sub1";
else if(subject.equalsIgnoreCase("DBMS")) colorClass="sub2";
else if(subject.equalsIgnoreCase("OS")) colorClass="sub3";
else if(subject.equalsIgnoreCase("CN")) colorClass="sub4";
else colorClass="sub5";
%>

<td class="<%=colorClass%>">
<b><%=subject%></b><br>
<%=rs.getString("faculty_name")%><br>
<span style="color:#2563eb;">
Room: <%=rs.getInt("room_no")%>
</span>
</td>

<%
}else{
%>

<td class="free">-</td>

<%
}

rs.close();
ps.close();

}
%>

</tr>

<%
}
%>

</table>

<%
}

}catch(Exception e){
out.println("<pre style='color:red;'>");
e.printStackTrace(new java.io.PrintWriter(out));
out.println("</pre>");
}
%>

</body>
</html>
