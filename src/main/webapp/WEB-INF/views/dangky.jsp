<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Đăng ký tài khoản</title>
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/favicon.svg" />
</head>
<body class="bg-light">
<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-4">
            <div class="card shadow">
                <div class="card-header text-center bg-success text-white">
                    <h4>Đăng ký tài khoản Sinh viên</h4>
                </div>
                <div class="card-body">

                    <c:if test="${error != null}">
                        <div class="alert alert-danger">${error}</div>
                    </c:if>
                    <c:if test="${success != null}">
                        <div class="alert alert-success">${success}</div>
                    </c:if>

                    <form action="dangky.htm" method="post">
                        <div class="mb-3">
                            <label class="form-label">Mã sinh viên</label>
                            <input type="text" name="masv"
                                   class="form-control" required/>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Mật khẩu mới</label>
                            <input type="password" name="passwordMoi"
                                   class="form-control" required/>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Xác nhận mật khẩu</label>
                            <input type="password" name="xacNhan"
                                   class="form-control" required/>
                        </div>
                        <button type="submit"
                                class="btn btn-success w-100">Đăng ký</button>
                    </form>
                    <hr>
                    <div class="text-center">
                        <a href="login.htm">← Quay lại đăng nhập</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>