<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KIT CoEK | Pro Scheduly Portal</title>

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css"/>

    <style>
        :root {
            /* KIT Official Blue Palette */
            --kit-blue-dark: #1a237e; /* Navy Blue */
            --kit-blue-light: #4361ee;
            --text-dark: #1e293b;
            --bg-glass: rgba(255, 255, 255, 0.94);
        }

        body, html {
            margin: 0; padding: 0; height: 100%; width: 100%;
            font-family: 'Inter', sans-serif;
            overflow: hidden;
            background-color: #000;
        }

        /* Live Background of KIT College */
        #site-background {
            position: fixed;
            top: 0; left: 0; width: 100%; height: 100%;
            z-index: 1; border: none;
            filter: brightness(0.4) contrast(1.1); 
        }

        /* Blue Gradient Overlay */
        .overlay-layer {
            position: fixed;
            top: 0; left: 0; width: 100%; height: 100%;
            background: linear-gradient(135deg, rgba(26, 35, 126, 0.4) 0%, rgba(15, 23, 42, 0.6) 100%);
            z-index: 2;
        }

        .login-container {
            position: relative;
            z-index: 3;
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .login-card {
            width: 100%; max-width: 420px;
            background: var(--bg-glass);
            backdrop-filter: blur(12px);
            padding: 45px 40px; border-radius: 20px;
            border: 1px solid rgba(255, 255, 255, 0.4);
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.5);
        }

        .brand-header {
            text-align: center;
            margin-bottom: 35px;
        }

        .brand-header h2 {
            font-weight: 800;
            color: var(--kit-blue-dark);
            letter-spacing: -1px;
            margin-bottom: 5px;
            text-transform: uppercase;
        }

        .kit-subtext {
            font-size: 0.75rem;
            font-weight: 700;
            color: var(--kit-blue-light);
            text-transform: uppercase;
            letter-spacing: 1.5px;
        }

        /* Segmented Role Selector */
        .role-selector {
            display: flex;
            background: #f1f5f9;
            padding: 6px;
            border-radius: 14px;
            margin-bottom: 30px;
        }

        .role-item {
            flex: 1;
            text-align: center;
            padding: 12px 5px;
            font-size: 0.7rem;
            font-weight: 800;
            cursor: pointer;
            border-radius: 10px;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            color: #64748b;
            text-transform: uppercase;
        }

        .role-item.active {
            background: white;
            color: var(--kit-blue-dark);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
        }

        /* Form Controls */
        .form-group { margin-bottom: 20px; }
        
        .form-label {
            font-weight: 700;
            font-size: 0.75rem;
            color: var(--text-dark);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 8px;
            display: block;
        }

        .form-control {
            border-radius: 10px;
            padding: 14px;
            border: 1px solid #cbd5e1;
            font-size: 0.95rem;
            background: #fff;
            transition: 0.3s;
        }

        .form-control:focus {
            border-color: var(--kit-blue-light);
            box-shadow: 0 0 0 4px rgba(67, 97, 238, 0.15);
            outline: none;
        }

        /* Action Button */
        .btn-kit {
            background: linear-gradient(135deg, var(--kit-blue-dark) 0%, var(--kit-blue-light) 100%);
            color: white;
            border: none;
            padding: 16px;
            border-radius: 12px;
            font-weight: 700;
            width: 100%;
            margin-top: 10px;
            transition: 0.3s;
            text-transform: uppercase;
            letter-spacing: 1px;
            box-shadow: 0 10px 20px rgba(26, 35, 126, 0.2);
        }

        .btn-kit:hover {
            transform: translateY(-2px);
            box-shadow: 0 15px 25px rgba(26, 35, 126, 0.3);
            filter: brightness(1.1);
        }

        .footer-links {
            margin-top: 30px;
            text-align: center;
            font-size: 0.75rem;
            border-top: 1px solid #e2e8f0;
            padding-top: 20px;
        }
    </style>
</head>
<body>

    <iframe id="site-background" src="https://www.kitcoek.in/"></iframe>
    
    <div class="overlay-layer"></div>

    <div class="login-container">
        <div class="login-card animate__animated animate__fadeInUp">
            <div class="brand-header">
                <h2>PRO SCHEDULY</h2>
                <div class="kit-subtext">KIT College of Engineering</div>
            </div>

            <div class="role-selector">
                <div class="role-item active" onclick="updatePortal('student', this)">Student</div>
                <div class="role-item" onclick="updatePortal('teacher', this)">Teacher</div>
                <div class="role-item" onclick="updatePortal('admin', this)">Admin</div>
            </div>

            <form action="LoginServlet" method="post">
                <input type="hidden" name="userRole" id="userRole" value="student">
                
                <div class="form-group">
                    <label class="form-label">Username</label>
                    <input type="text" name="username" class="form-control" placeholder="Enter your username" required>
                </div>

                <div class="form-group">
                    <div class="d-flex justify-content-between">
                        <label class="form-label">Password</label>
                        <a href="#" class="text-decoration-none small fw-bold" style="color: var(--kit-blue-light); font-size: 0.7rem;">Forgot?</a>
                    </div>
                    <input type="password" name="password" class="form-control" placeholder="••••••••" required>
                </div>

                <button type="submit" class="btn btn-kit" id="submit-btn">
                    Login to Student Portal
                </button>
            </form>
            
            <div class="footer-links">
                <p class="text-muted mb-2">Centralized Academic Management System</p>
                <a href="https://www.kitcoek.in/" class="text-decoration-none fw-bold" style="color: var(--kit-blue-dark);">Visit Official KIT Website</a>
            </div>
        </div>
    </div>

    <script>
        function updatePortal(role, el) {
            // UI Toggle
            document.querySelectorAll('.role-item').forEach(item => item.classList.remove('active'));
            el.classList.add('active');
            
            // Hidden Input for Form Submission
            document.getElementById('userRole').value = role;
            
            // Dynamic Button Label
            const display = role.charAt(0).toUpperCase() + role.slice(1);
            document.getElementById('submit-btn').innerText = `Login to ${display} Portal`;
        }
    </script>
</body>
</html>