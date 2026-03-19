<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ include file="../common/navbar.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Đăng ký thi</title>
    <link rel="stylesheet" 
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="container mt-4">
    <h3>Đăng ký thi</h3>

    <c:if test="${error != null}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <form action="dangkythi-them.htm" method="post" class="col-md-5">

        <div class="mb-3">
            <label class="form-label">Lớp</label>
            <select name="maLop" class="form-select" required>
                <option value="">-- Chọn lớp --</option>
                <c:forEach var="lop" items="${dsLop}">
                    <option value="${lop.maLop}"
                        ${lop.maLop == dk.maLop ? 'selected' : ''}>
                        ${lop.tenLop}
                    </option>
                </c:forEach>
            </select>
        </div>

        <div class="mb-3">
            <label class="form-label">Môn học</label>
            <select name="maMH" class="form-select" required>
                <option value="">-- Chọn môn --</option>
                <c:forEach var="mh" items="${dsMonHoc}">
                    <option value="${mh.maMH}"
                        ${mh.maMH == dk.maMH ? 'selected' : ''}>
                        ${mh.tenMH}
                    </option>
                </c:forEach>
            </select>
        </div>

        <div class="mb-3">
            <label class="form-label">Trình độ</label>
            <select name="trinhDo" class="form-select" required>
                <option value="">-- Chọn trình độ --</option>
                <option value="A" ${dk.trinhDo == 'A' ? 'selected' : ''}>A - ĐH Chuyên ngành</option>
                <option value="B" ${dk.trinhDo == 'B' ? 'selected' : ''}>B - ĐH Không chuyên</option>
                <option value="C" ${dk.trinhDo == 'C' ? 'selected' : ''}>C - Cao đẳng</option>
            </select>
        </div>

        <div class="mb-3">
            <label class="form-label">Lần thi</label>
            <select name="lan" class="form-select" required>
                <option value="1" ${dk.lan == 1 ? 'selected' : ''}>Lần 1</option>
                <option value="2" ${dk.lan == 2 ? 'selected' : ''}>Lần 2</option>
            </select>
        </div>

        <div class="mb-3">
            <label class="form-label">Số câu thi (10-100)</label>
            <input type="number" name="soCauThi" value="${dk.soCauThi}"
                   class="form-control" min="10" max="100" required/>
        </div>

        <div class="mb-3">
            <label class="form-label">Ngày thi</label>
            <input type="date" name="ngayThi" value="${dk.ngayThi}"
                   class="form-control" required/>
        </div>

        <div class="mb-3">
            <label class="form-label">Thời gian thi (5-60 phút)</label>
            <input type="number" name="thoiGian" value="${dk.thoiGian}"
                   class="form-control" min="5" max="60" required/>
        </div>

        <button type="submit" class="btn btn-primary">Đăng ký</button>
        <a href="dangkythi.htm" class="btn btn-secondary">Hủy</a>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
