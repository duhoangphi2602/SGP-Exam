<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Trang PGV</title>
    <link rel="stylesheet" 
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/favicon.svg" />
</head>
<body>
    <%@ include file="../common/navbar.jsp" %>
    <div class="container mt-4">
        <h4>${sessionScope.hoTen} — Phòng Giáo Vụ</h4>
        <hr>
        <div class="row mt-3">
            <div class="col-md-3">
                <div class="card border-0 shadow-sm mb-4">
                    <div class="card-body text-center py-4">
                        <i class="fas fa-book fa-3x text-primary mb-3"></i>
                        <h5 class="card-title text-dark">Môn học</h5>
                        <p class="text-muted small">Quản lý môn học</p>
                        <a href="${pageContext.request.contextPath}/pgv/monhoc.htm" 
                           class="btn btn-outline-primary btn-sm px-4">Quản lý</a>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card border-0 shadow-sm mb-4">
                    <div class="card-body text-center py-4">
                        <i class="fas fa-users fa-3x text-success mb-3"></i>
                        <h5 class="card-title text-dark">Lớp & Sinh viên</h5>
                        <p class="text-muted small">Quản lý lớp học</p>
                        <a href="${pageContext.request.contextPath}/pgv/lop.htm" 
                           class="btn btn-outline-success btn-sm px-4">Quản lý</a>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card border-0 shadow-sm mb-4">
                    <div class="card-body text-center py-4">
                        <i class="fas fa-chalkboard-teacher fa-3x text-warning mb-3"></i>
                        <h5 class="card-title text-dark">Giáo viên</h5>
                        <p class="text-muted small">Quản lý giáo viên</p>
                        <a href="${pageContext.request.contextPath}/pgv/giaovien.htm" 
                           class="btn btn-outline-warning btn-sm px-4">Quản lý</a>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card border-0 shadow-sm mb-4">
                    <div class="card-body text-center py-4">
                        <i class="fas fa-user-shield fa-3x text-info mb-3"></i>
                        <h5 class="card-title text-dark">Tài khoản</h5>
                        <p class="text-muted small">Quản lý tài khoản</p>
                        <a href="${pageContext.request.contextPath}/pgv/taikhoan.htm" 
                           class="btn btn-outline-info btn-sm px-4">Quản lý</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>