<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Bảng Điểm</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body>
    <%@ include file="../common/navbar.jsp" %>
    <div class="container mt-4">
        <h4 class="text-primary fw-bold">DANH SÁCH CA THI</h4>
        <hr>

        <!-- Form lọc (phụ) -->
        <div class="card shadow-sm mb-4">
            <div class="card-body bg-light">
                <form action="${pageContext.request.contextPath}/gv/bangdiem.htm" method="GET" class="row g-3 align-items-end">
                    <div class="col-md-3">
                        <label class="form-label fw-bold">Lớp</label>
                        <select name="maLop" class="form-select">
                            <option value="">-- Tất cả lớp --</option>
                            <c:forEach var="lop" items="${dsLop}">
                                <option value="${lop.maLop}"
                                    ${maLopSelected == lop.maLop.trim() ? 'selected' : ''}>
                                    ${lop.maLop} - ${lop.tenLop}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-bold">Môn học</label>
                        <select name="maMH" class="form-select">
                            <option value="">-- Tất cả môn --</option>
                            <c:forEach var="mh" items="${dsMH}">
                                <option value="${mh.maMH}"
                                    ${maMHSelected == mh.maMH.trim() ? 'selected' : ''}>
                                    ${mh.maMH} - ${mh.tenMH}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label fw-bold">Lần thi</label>
                        <select name="lan" class="form-select">
                            <option value="">-- Tất cả --</option>
                            <option value="1" ${lanSelected == 1 ? 'selected' : ''}>Lần 1</option>
                            <option value="2" ${lanSelected == 2 ? 'selected' : ''}>Lần 2</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <button type="submit" class="btn btn-primary w-100">Lọc</button>
                    </div>
                    <div class="col-md-2">
                        <a href="${pageContext.request.contextPath}/gv/bangdiem.htm"
                           class="btn btn-outline-secondary w-100">Xóa bộ lọc</a>
                    </div>
                </form>
            </div>
        </div>

        <!-- Bảng danh sách ca thi -->
        <c:choose>
            <c:when test="${empty dsCaThi}">
                <div class="alert alert-info">Không có ca thi nào phù hợp.</div>
            </c:when>
            <c:otherwise>
                <table class="table table-bordered table-hover shadow-sm">
                    <thead class="table-dark">
                        <tr>
                            <th class="text-center">STT</th>
                            <th>Lớp</th>
                            <th>Môn học</th>
                            <th class="text-center">Lần</th>
                            <th class="text-center">Ngày thi</th>
                            <th class="text-center">Trình độ</th>
                            <th class="text-center">Đã thi / Tổng</th>
                            <th class="text-center">Điểm TB</th>
                            <th class="text-center">Chi tiết</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="ca" items="${dsCaThi}" varStatus="st">
                            <tr>
                                <td class="text-center">${st.index + 1}</td>
                                <td>
                                    <strong>${ca.MALOP}</strong><br>
                                    <small class="text-muted">${ca.TENLOP}</small>
                                </td>
                                <td>
                                    <strong>${ca.MAMH}</strong><br>
                                    <small class="text-muted">${ca.TENMH}</small>
                                </td>
                                <td class="text-center">${ca.LAN}</td>
                                <td class="text-center">${ca.NGAYTHI}</td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${ca.TRINHDO == 'A'}">
                                            <span class="badge bg-danger">A - ĐH Chuyên ngành</span>
                                        </c:when>
                                        <c:when test="${ca.TRINHDO == 'B'}">
                                            <span class="badge bg-warning text-dark">B - ĐH Không chuyên</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-info text-dark">C - Cao đẳng</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${ca.SO_DA_THI == 0}">
                                            <span class="text-muted">0 / ${ca.TONG_SV}</span>
                                        </c:when>
                                        <c:when test="${ca.SO_DA_THI == ca.TONG_SV}">
                                            <span class="text-success fw-bold">${ca.SO_DA_THI} / ${ca.TONG_SV}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-warning fw-bold">${ca.SO_DA_THI} / ${ca.TONG_SV}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${ca.SO_DA_THI == 0}">
                                            <span class="text-muted">-</span>
                                        </c:when>
                                        <c:otherwise>
                                            <strong>
                                                <fmt:formatNumber value="${ca.DIEM_TB}" maxFractionDigits="2"/>
                                            </strong>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-center">
                                    <a href="${pageContext.request.contextPath}/gv/bangdiem-chitiet.htm?maLop=${ca.MALOP}&maMH=${ca.MAMH}&lan=${ca.LAN}"
                                       class="btn btn-sm btn-primary">Xem</a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
