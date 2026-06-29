<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Chi tiết bài thi</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/favicon.svg" />
</head>
<body>
    <%@ include file="../common/navbar.jsp" %>
    <div class="container mt-4">
        <!-- Header: Nút Quay lại -->
        <div class="mb-4 d-print-none">
            <a href="${pageContext.request.contextPath}/sv/ketqua.htm" class="btn btn-secondary">
                <i class="bi bi-arrow-left"></i> Quay lại
            </a>
        </div>

        <!-- Bố cục in ấn theo mẫu -->
        <div class="print-header mb-4">
            <h4 class="text-center fw-bold text-uppercase mb-4">Kết Quả Thi Chi Tiết</h4>
            <div class="row">
                <div class="col-8">
                    <p class="mb-1">Lớp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: <strong>${lop.tenLop} (${lop.maLop})</strong></p>
                    <p class="mb-1">Họ tên&nbsp;&nbsp;: <strong>${sv.ho} ${sv.ten}</strong></p>
                    <p class="mb-1">Môn thi: <strong>${monHoc.tenMH} (${monHoc.maMH})</strong></p>
                    <p class="mb-1">Ngày thi: <strong>${ngayThi}</strong></p>
                </div>
                <div class="col-4">
                    <p class="mb-1"><br></p>
                    <p class="mb-1">Mã số SV: <strong>${sv.maSV}</strong></p>
                    <p class="mb-1"><br></p>
                    <p class="mb-1">Lần thi: <strong>${lan}</strong></p>
                </div>
            </div>
            <div class="mt-3 fs-5 text-danger fw-bold">
                Điểm bài thi: ${diem}
            </div>
        </div>

        <!-- THÊM MỚI: Kiểm tra nếu không có dữ liệu chi tiết -->
        <c:if test="${empty chiTiet}">
            <div class="alert alert-warning shadow-sm border-warning d-print-none" role="alert">
                <h5 class="alert-heading">⚠️ Không có dữ liệu chi tiết!</h5>
                <p>Bài thi này có thể đã được thực hiện từ trước khi hệ thống cập nhật tính năng lưu vết chi tiết, hoặc dữ liệu đã bị dọn dẹp.</p>
            </div>
            <div class="d-none d-print-block text-center text-danger fw-bold mt-5">
                (Không có dữ liệu chi tiết câu hỏi cho bài thi này)
            </div>
        </c:if>

        <c:if test="${not empty chiTiet}">
            <table class="table table-bordered printable-table mt-3">
                <thead>
                    <tr class="text-center bg-light">
                        <th width="5%">STT</th>
                        <th width="35%">Nội dung câu hỏi</th>
                        <th width="10%">A</th>
                        <th width="10%">B</th>
                        <th width="10%">C</th>
                        <th width="10%">D</th>
                        <th width="8%">Trả lời<br>của SV</th>
                        <th width="8%">Đáp án</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="cau" items="${chiTiet}">
                        <tr>
                            <td class="text-center align-middle">${cau.STT}</td>
                            <td class="align-middle">${cau.NOIDUNG}</td>
                            <td class="align-middle">${cau.A}</td>
                            <td class="align-middle">${cau.B}</td>
                            <td class="align-middle">${cau.C}</td>
                            <td class="align-middle">${cau.D}</td>
                            <td class="text-center align-middle fw-bold ${cau.DACHON != null && cau.DACHON.trim() == cau.DAP_AN.trim() ? 'text-success' : 'text-danger'}">
                                ${cau.DACHON != null ? cau.DACHON.trim() : '-'}
                            </td>
                            <td class="text-center align-middle fw-bold text-primary">${cau.DAP_AN.trim()}</td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:if>
    </div>

    <style>
        .print-header { border-bottom: 2px solid #000; padding-bottom: 15px; }
        .bg-light { background-color: #f8f9fa !important; }
        .text-danger { color: #dc3545 !important; }
        .text-success { color: #198754 !important; }
        .text-primary { color: #0d6efd !important; }
    </style>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>