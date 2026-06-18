<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Xem Bảng Điểm</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body>
    <%@ include file="../common/navbar.jsp" %>
    <div class="container mt-4">
        <h4 class="text-primary fw-bold">TRA CỨU BẢNG ĐIỂM LỚP</h4>
        <hr>

        <!-- Form chọn điều kiện lọc -->
        <div class="card shadow-sm mb-4">
            <div class="card-body bg-light">
                <form action="${pageContext.request.contextPath}/gv/bangdiem.htm" method="GET" class="row g-3 align-items-end">
                    
                    <div class="col-md-4">
                        <label class="form-label fw-bold">Chọn Lớp</label>
                        <select name="maLop" class="form-select" required>
                            <option value="">-- Chọn Lớp --</option>
                            <c:forEach var="lop" items="${dsLop}">
                                <option value="${lop.maLop}" ${maLopSelected == lop.maLop.trim() ? 'selected' : ''}>
                                    ${lop.maLop} - ${lop.tenLop}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="col-md-4">
                        <label class="form-label fw-bold">Chọn Môn Học</label>
                        <select name="maMH" class="form-select" required>
                            <option value="">-- Chọn Môn --</option>
                            <c:forEach var="mh" items="${dsMH}">
                                <option value="${mh.maMH}" ${maMHSelected == mh.maMH.trim() ? 'selected' : ''}>
                                    ${mh.maMH} - ${mh.tenMH}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="col-md-2">
                        <label class="form-label fw-bold">Lần thi</label>
                        <select name="lan" class="form-select" required>
                            <option value="1" ${lanSelected == 1 ? 'selected' : ''}>Lần 1</option>
                            <option value="2" ${lanSelected == 2 ? 'selected' : ''}>Lần 2</option>
                        </select>
                    </div>

                    <div class="col-md-2">
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="bi bi-search"></i> Xem điểm
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Bảng hiển thị điểm -->
        <c:if test="${bangDiem != null}">
            <h5 class="mt-4 mb-3">Kết quả:</h5>
            <table class="table table-bordered table-hover shadow-sm">
                <thead class="table-dark">
                    <tr>
                        <th width="5%" class="text-center">STT</th>
                        <th width="15%">Mã SV</th>
                        <th width="30%">Họ</th>
                        <th width="20%">Tên</th>
                        <th width="15%" class="text-center">Điểm thi</th>
                        <th width="15%" class="text-center">Ghi chú</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="sv" items="${bangDiem}" varStatus="loop">
                        <tr>
                            <td class="text-center align-middle">${loop.index + 1}</td>
                            <td class="align-middle fw-bold">${sv.MASV}</td>
                            <td class="align-middle">${sv.HO}</td>
                            <td class="align-middle">${sv.TEN}</td>
                            
                            <c:choose>
                                <c:when test="${sv.DIEM != null}">
                                    <td class="text-center align-middle fs-5 fw-bold text-danger">${sv.DIEM}</td>
                                    <td class="text-center align-middle text-success">Đã thi</td>
                                </c:when>
                                <c:otherwise>
                                    <td class="text-center align-middle fst-italic text-muted">-</td>
                                    <td class="text-center align-middle text-secondary fst-italic">Chưa thi</td>
                                </c:otherwise>
                            </c:choose>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty bangDiem}">
                        <tr>
                            <td colspan="6" class="text-center py-4 text-danger fw-bold">
                                Không tìm thấy sinh viên nào trong lớp này!
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </c:if>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>