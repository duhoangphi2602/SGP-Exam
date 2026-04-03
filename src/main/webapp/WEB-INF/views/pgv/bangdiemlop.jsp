<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Báo cáo bảng điểm</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <style>
        @media print { .no-print { display: none !important; } }
    </style>
</head>
<body class="bg-light">
    <%@ include file="../common/navbar.jsp" %>
    
    <div class="container mt-4">
        <div class="card shadow mb-4 no-print">
            <div class="card-header bg-dark text-white">Lọc bảng điểm</div>
            <div class="card-body">
                <form action="bang-diem-lop.htm" method="GET" class="row g-3">
                    <div class="col-md-4">
                        <label class="form-label">Lớp:</label>
                        <select name="maLop" class="form-select" required>
                            <option value="">-- Chọn lớp --</option>
                            <c:forEach var="l" items="${dsLop}">
                                <option value="${l.MALOP}" ${l.MALOP == selectedLop ? 'selected' : ''}>${l.TENLOP}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Môn học:</label>
                        <select name="maMH" class="form-select" required>
                            <option value="">-- Chọn môn --</option>
                            <c:forEach var="m" items="${dsMon}">
                                <option value="${m.MAMH}" ${m.MAMH == selectedMon ? 'selected' : ''}>${m.TENMH}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Lần thi:</label>
                        <select name="lan" class="form-select">
                            <option value="1" ${selectedLan == 1 ? 'selected' : ''}>1</option>
                            <option value="2" ${selectedLan == 2 ? 'selected' : ''}>2</option>
                        </select>
                    </div>
                    <div class="col-md-2 d-flex align-items-end">
                        <button type="submit" class="btn btn-primary w-100">Xem điểm</button>
                    </div>
                </form>
            </div>
        </div>

        <c:if test="${not empty bangdiem}">
            <div class="p-5 bg-white shadow rounded mt-3">
                <h2 class="text-center mb-0">BẢNG ĐIỂM HẾT MÔN</h2>
                <h5 class="text-center text-uppercase mt-2">MÔN: ${selectedMon} - LẦN: ${selectedLan}</h5>
                <hr>
                <table class="table table-bordered mt-4">
                    <thead class="table-dark">
                        <tr>
                            <th>Mã SV</th>
                            <th>Họ</th>
                            <th>Tên</th>
                            <th class="text-center">Điểm</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="b" items="${bangdiem}">
                            <tr>
                                <td>${b.MASV}</td>
                                <td>${b.HO}</td>
                                <td>${b.TEN}</td>
                                <td class="text-center fw-bold text-danger">
                                    ${b.DIEM != null ? b.DIEM : 'Vắng thi'}
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
                <div class="text-end mt-4 no-print">
                    <button onclick="window.print()" class="btn btn-success">In báo cáo</button>
                    <a href="home.htm" class="btn btn-outline-secondary">Quay lại</a>
                </div>
            </div>
        </c:if>
    </div>
</body>
</html>