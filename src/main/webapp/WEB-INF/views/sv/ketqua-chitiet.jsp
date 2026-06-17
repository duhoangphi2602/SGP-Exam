<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Chi tiết bài thi</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body>
    <%@ include file="../common/navbar.jsp" %>
    <div class="container mt-4">
        <h4>Chi tiết bài làm - Môn: ${maMH} - Lần thi: ${lan}</h4>
        <hr>
        
        <div class="mt-4">
            <!-- THÊM MỚI: Kiểm tra nếu không có dữ liệu chi tiết -->
            <c:if test="${empty chiTiet}">
                <div class="alert alert-warning shadow-sm border-warning" role="alert">
                    <h5 class="alert-heading">⚠️ Không có dữ liệu chi tiết!</h5>
                    <p>Bài thi này có thể đã được thực hiện từ trước khi hệ thống cập nhật tính năng lưu vết chi tiết, hoặc dữ liệu đã bị dọn dẹp.</p>
                    <hr>
                    <p class="mb-0">Hệ thống chỉ có thể hiển thị chi tiết cho các bài thi <b>mới thực hiện</b> kể từ bây giờ.</p>
                </div>
            </c:if>

            <!-- Vòng lặp hiển thị câu hỏi như cũ -->
            <c:forEach var="cau" items="${chiTiet}">
                <div class="card mb-3 shadow-sm">
                    <div class="card-header fw-bold bg-light">
                        Câu ${cau.STT}: ${cau.NOIDUNG}
                    </div>
                    <div class="card-body">
                        <!-- Đáp án A -->
                        <div class="mb-2 p-2 border rounded 
                            ${cau.DAP_AN.trim() == 'A' ? 'bg-success bg-opacity-25 border-success' : ''} 
                            ${cau.DACHON != null && cau.DACHON.trim() == 'A' && cau.DAP_AN.trim() != 'A' ? 'bg-danger bg-opacity-25 border-danger' : ''}">
                            <strong>A.</strong> ${cau.A} 
                            <c:if test="${cau.DACHON != null && cau.DACHON.trim() == 'A'}">
                                <span class="badge bg-primary ms-2">Bạn đã chọn</span>
                            </c:if>
                            <c:if test="${cau.DAP_AN.trim() == 'A'}">
                                <span class="badge bg-success ms-2">Đáp án đúng</span>
                            </c:if>
                        </div>

                        <!-- Đáp án B -->
                        <div class="mb-2 p-2 border rounded 
                            ${cau.DAP_AN.trim() == 'B' ? 'bg-success bg-opacity-25 border-success' : ''} 
                            ${cau.DACHON != null && cau.DACHON.trim() == 'B' && cau.DAP_AN.trim() != 'B' ? 'bg-danger bg-opacity-25 border-danger' : ''}">
                            <strong>B.</strong> ${cau.B} 
                            <c:if test="${cau.DACHON != null && cau.DACHON.trim() == 'B'}">
                                <span class="badge bg-primary ms-2">Bạn đã chọn</span>
                            </c:if>
                            <c:if test="${cau.DAP_AN.trim() == 'B'}">
                                <span class="badge bg-success ms-2">Đáp án đúng</span>
                            </c:if>
                        </div>

                        <!-- Đáp án C -->
                        <div class="mb-2 p-2 border rounded 
                            ${cau.DAP_AN.trim() == 'C' ? 'bg-success bg-opacity-25 border-success' : ''} 
                            ${cau.DACHON != null && cau.DACHON.trim() == 'C' && cau.DAP_AN.trim() != 'C' ? 'bg-danger bg-opacity-25 border-danger' : ''}">
                            <strong>C.</strong> ${cau.C} 
                            <c:if test="${cau.DACHON != null && cau.DACHON.trim() == 'C'}">
                                <span class="badge bg-primary ms-2">Bạn đã chọn</span>
                            </c:if>
                            <c:if test="${cau.DAP_AN.trim() == 'C'}">
                                <span class="badge bg-success ms-2">Đáp án đúng</span>
                            </c:if>
                        </div>

                        <!-- Đáp án D -->
                        <div class="mb-2 p-2 border rounded 
                            ${cau.DAP_AN.trim() == 'D' ? 'bg-success bg-opacity-25 border-success' : ''} 
                            ${cau.DACHON != null && cau.DACHON.trim() == 'D' && cau.DAP_AN.trim() != 'D' ? 'bg-danger bg-opacity-25 border-danger' : ''}">
                            <strong>D.</strong> ${cau.D} 
                            <c:if test="${cau.DACHON != null && cau.DACHON.trim() == 'D'}">
                                <span class="badge bg-primary ms-2">Bạn đã chọn</span>
                            </c:if>
                            <c:if test="${cau.DAP_AN.trim() == 'D'}">
                                <span class="badge bg-success ms-2">Đáp án đúng</span>
                            </c:if>
                        </div>
                        
                        <c:if test="${cau.DACHON == null}">
                            <div class="text-danger mt-2 fst-italic"><small><i class="bi bi-info-circle"></i> Bạn đã bỏ trống câu này!</small></div>
                        </c:if>
                    </div>
                </div>
            </c:forEach>
        </div>
        <a href="${pageContext.request.contextPath}/sv/ketqua.htm" class="btn btn-secondary mb-5">Quay lại danh sách</a>
    </div>
</body>
</html>