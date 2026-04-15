<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Trang Giáo viên</title>
    <link rel="stylesheet" 
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body>
    <%@ include file="../common/navbar.jsp" %>
    <div class="container mt-4">
        <h4>${sessionScope.hoTen} — Giáo viên</h4>
        <hr>
        <div class="row mt-3">
            <div class="col-md-4">
                <div class="card text-white bg-primary mb-3">
                    <div class="card-body text-center">
                        <h5>Bộ đề thi</h5>
                        <a href="${pageContext.request.contextPath}/gv/bode.htm" 
                           class="btn btn-light btn-sm">Quản lý</a>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card text-white bg-success mb-3">
                    <div class="card-body text-center">
                        <h5>Đăng ký thi</h5>
                        <a href="${pageContext.request.contextPath}/gv/dangkythi.htm" 
                           class="btn btn-light btn-sm">Quản lý</a>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card text-white bg-warning mb-3">
                    <div class="card-body text-center">
                        <h5>Bảng điểm</h5>
                        <a href="${pageContext.request.contextPath}/gv/bangdiem.htm" 
                           class="btn btn-light btn-sm">Xem</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>