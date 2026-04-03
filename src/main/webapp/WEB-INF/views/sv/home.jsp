<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Trang Sinh viên</title>
    <link rel="stylesheet" 
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body>
    <%@ include file="../common/navbar.jsp" %>
    <div class="container mt-4">
        <h4>Chào mừng <strong>${not empty sessionScope.hoTen ? sessionScope.hoTen : sessionScope.username}</strong> — Sinh viên</h4>
        <hr>
        <div class="row mt-3">
            <div class="col-md-6">
                <div class="card text-white bg-primary mb-3">
                    <div class="card-body text-center">
                        <h5>Thi</h5>
                        <a href="${pageContext.request.contextPath}/sv/thi.htm" 
                           class="btn btn-light btn-sm">Vào thi</a>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card text-white bg-success mb-3">
                    <div class="card-body text-center">
                        <h5>Xem kết quả</h5>
                        <a href="${pageContext.request.contextPath}/sv/xem-ket-qua.htm" 
                           class="btn btn-light btn-sm">Xem</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>