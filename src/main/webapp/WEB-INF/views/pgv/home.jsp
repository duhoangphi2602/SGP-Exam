<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Trang PGV</title>
    <link rel="stylesheet" 
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body>
    <%@ include file="../common/navbar.jsp" %>
    <div class="container mt-4">
        <h4>Chào mừng <strong>${sessionScope.username}</strong> — Phòng Giáo Vụ</h4>
        <hr>
        <div class="row mt-3">
            <div class="col-md-3">
                <div class="card text-white bg-primary mb-3">
                    <div class="card-body text-center">
                        <h5>Môn học</h5>
                        <a href="${pageContext.request.contextPath}/pgv/monhoc.htm" 
                           class="btn btn-light btn-sm">Quản lý</a>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-white bg-success mb-3">
                    <div class="card-body text-center">
                        <h5>Lớp & Sinh viên</h5>
                        <a href="${pageContext.request.contextPath}/pgv/lop.htm" 
                           class="btn btn-light btn-sm">Quản lý</a>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-white bg-warning mb-3">
                    <div class="card-body text-center">
                        <h5>Giáo viên</h5>
                        <a href="${pageContext.request.contextPath}/pgv/giaovien.htm" 
                           class="btn btn-light btn-sm">Quản lý</a>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-white bg-info mb-3">
                    <div class="card-body text-center">
                        <h5>Tài khoản</h5>
                        <a href="${pageContext.request.contextPath}/pgv/taikhoan.htm" 
                           class="btn btn-light btn-sm">Quản lý</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>