<%@ page contentType="text/html;charset=UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Đăng nhập</title>
    <link rel="stylesheet" 
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="bg-light">
<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-4">
            <div class="card shadow">
                <div class="card-header text-center bg-primary text-white">
                    <h4>Hệ thống Thi Trắc Nghiệm</h4>
                </div>
                <div class="card-body">
                    <!-- Hiển thị lỗi nếu có -->
                    <% if(request.getAttribute("error") != null) { %>
                        <div class="alert alert-danger">
                            ${error}
                        </div>
                    <% } %>

                    <form action="login.htm" method="post">
                        <div class="mb-3">
                            <label class="form-label">Tên đăng nhập</label>
                            <input type="text" name="username" 
                                   class="form-control" required/>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Mật khẩu</label>
                            <input type="password" name="password" 
                                   class="form-control" required/>
                        </div>
                        <button type="submit" 
                                class="btn btn-primary w-100">Đăng nhập</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>