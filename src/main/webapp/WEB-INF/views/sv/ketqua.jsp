<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Lịch sử thi</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/favicon.svg" />
</head>
<body>
    <%@ include file="../common/navbar.jsp" %>
    <div class="container mt-4">
        <h4>Lịch sử thi trắc nghiệm</h4>
        <hr>
        
        <table class="table table-bordered table-striped mt-3">
            <thead class="table-dark">
                <tr>
                    <th>Mã MH</th>
                    <th>Tên Môn Học</th>
                    <th class="text-center">Lần Thi</th>
                    <th class="text-center">Ngày Thi</th>
                    <th class="text-center">Điểm Số</th>
                    <th class="text-center">Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="kq" items="${dsKetQua}">
                    <tr>
                        <td>${kq.MAMH}</td>
                        <td>${kq.TENMH}</td>
                        <td class="text-center">${kq.LAN}</td>
                        <td class="text-center">${kq.NGAYTHI}</td>
                        <td class="text-center fw-bold text-danger">${kq.DIEM}</td>
                        <td class="text-center">
                            <a href="${pageContext.request.contextPath}/sv/ketqua-chitiet.htm?maMH=${kq.MAMH.trim()}&lan=${kq.LAN}" 
                               class="btn btn-sm btn-info text-white">Xem chi tiết</a>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty dsKetQua}">
                    <tr>
                        <td colspan="6" class="text-center text-muted">Bạn chưa tham gia bài thi nào.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>
        <a href="${pageContext.request.contextPath}/sv/home.htm" class="btn btn-secondary">Quay lại</a>
    </div>
</body>
</html>