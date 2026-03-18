<!DOCTYPE html>

<html>
<head>
<title>Admin Login</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

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
}

/* Login Box */
.login-box{
width:400px;
margin:120px auto;
background:white;
padding:40px;
border-radius:10px;
box-shadow:0 8px 20px rgba(0,0,0,0.1);
}

/* Title */
.title{
font-size:26px;
font-weight:600;
text-align:center;
margin-bottom:25px;
}

</style>

</head>

<body>

<div class="header">
Timetable Management System
</div>

<div class="login-box">

<div class="title">Admin Login</div>

<form action="LoginServlet" method="post">

<div class="mb-3">
<label class="form-label">Username</label>
<input type="text" name="username" class="form-control" required>
</div>

<div class="mb-3">
<label class="form-label">Password</label>
<input type="password" name="password" class="form-control" required>
</div>

<button type="submit" class="btn btn-primary w-100">
Login
</button>

</form>

</div>

</body>
</html>
