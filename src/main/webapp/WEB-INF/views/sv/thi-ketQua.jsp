<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Nộp bài thành công</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="bg-light">
    <%@ include file="../common/navbar.jsp" %>
    
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="card shadow-lg border-0 text-center rounded-4">
                    <div class="card-header bg-success bg-gradient text-white py-3 rounded-top-4">
                        <h4 class="mb-0">🎉 Nộp bài thành công!</h4>
                    </div>
                    <div class="card-body py-5">
                        <h1 class="display-1 text-danger fw-bold mb-3">${diem}</h1>
                        <h5 class="text-secondary fw-bold">ĐIỂM SỐ CỦA BẠN</h5>
                        
                        <hr class="w-25 mx-auto my-4 text-muted">
                        
                        <p class="fs-5 text-dark">
                            Bạn đã trả lời đúng <strong class="text-success">${soCauDung} / ${soCauThi}</strong> câu hỏi.
                        </p>
                        
                        <div class="mt-5">
                            <!-- Nút điều hướng sang trang lịch sử thi -->
                            <a href="${pageContext.request.contextPath}/sv/ketqua.htm" class="btn btn-primary btn-lg px-4 me-2 shadow-sm">
                                Lịch sử bài làm
                            </a>
                            <!-- Nút điều hướng về trang chủ -->
                            <a href="${pageContext.request.contextPath}/sv/home.htm" class="btn btn-outline-secondary btn-lg px-4 shadow-sm">
                                Về trang chủ
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>