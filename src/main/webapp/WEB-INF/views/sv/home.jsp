<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Trang Sinh viên</title>
    <link rel="stylesheet" 
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
    <%@ include file="../common/navbar.jsp" %>
    <div class="container mt-4">
        <h4>${sessionScope.hoTen} — Sinh viên</h4>
        <hr>
        <div class="row mt-3">
            <div class="col-md-6">
                <div class="card border-0 shadow-sm mb-4">
                    <div class="card-body text-center py-5">
                        <i class="fas fa-laptop-code fa-4x text-primary mb-3"></i>
                        <h5 class="card-title text-dark">Vào Phòng Thi</h5>
                        <p class="text-muted small mb-4">Tham gia ca thi đang mở</p>
                        <a href="${pageContext.request.contextPath}/sv/thi.htm" 
                           class="btn btn-primary px-5 py-2 fw-bold">VÀO THI</a>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card border-0 shadow-sm mb-4">
                    <div class="card-body text-center py-5">
                        <i class="fas fa-award fa-4x text-success mb-3"></i>
                        <h5 class="card-title text-dark">Xem Kết Quả</h5>
                        <p class="text-muted small mb-4">Xem điểm các bài thi đã làm</p>
                        <a href="${pageContext.request.contextPath}/sv/ketqua.htm" 
                           class="btn btn-outline-success px-5 py-2 fw-bold">XEM ĐIỂM</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>