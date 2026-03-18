<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Login</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f2f2f2;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .login-container {
            background-color: #fff;
            padding: 40px 30px;
            border-radius: 12px;
            box-shadow: 0 0 15px rgba(0,0,0,0.2);
            width: 350px;
        }
        h2 {
            text-align: center;
            margin-bottom: 25px;
            color: #333;
        }
        input[type=text], input[type=password] {
            width: 100%;
            padding: 12px;
            margin: 8px 0 20px 0;
            border: 1px solid #ccc;
            border-radius: 5px;
            box-sizing: border-box;
        }
        input[type=submit] {
            width: 100%;
            padding: 12px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
        }
        input[type=submit]:hover {
            background-color: #45a049;
        }
        .error {
            color: red;
            text-align: center;
            margin-bottom: 15px;
            font-weight: bold;
        }
    </style>
</head>
<body>

<div class="login-container">
    <h2>Admin Login</h2>
    
    <% 
        String error = (String) request.getAttribute("errorMessage"); 
        String prevUsername = request.getParameter("username") != null ? request.getParameter("username") : "";
    %>
    <% if(error != null){ %>
        <div class="error"><%= error %></div>
    <% } %>
    
    <form action="LoginServlet" method="post">
        <label for="username">Username:</label>
        <input type="text" id="username" name="username" value="<%= prevUsername %>" required>
        
        <label for="password">Password:</label>
        <input type="password" id="password" name="password" required>
        
        <input type="submit" value="Login">
    </form>
</div>

</body>
</html>