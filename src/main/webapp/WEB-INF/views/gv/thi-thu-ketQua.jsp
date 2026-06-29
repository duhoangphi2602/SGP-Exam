<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Kết quả thi thử</title>
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <style>
        .dung { background-color: #d1e7dd; }
        .sai { background-color: #f8d7da; }
        .bo-qua { background-color: #fff3cd; }
    </style>
    <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/favicon.svg" />
</head>
<body>
    <%@ include file="../common/navbar.jsp"%>
    <div class="container mt-4">
        <h3>Kết quả thi thử</h3>

        <!-- Tổng kết -->
        <div class="card mb-4">
            <div class="card-body text-center">
                <h2 class="text-primary">${diem} / 10</h2>
                <p class="mb-1">Số câu đúng: <strong class="text-success">${soCauDung}</strong> / ${soCauThi}</p>
                <p class="mb-0">Số câu sai/bỏ qua: <strong class="text-danger">${soCauThi - soCauDung}</strong></p>
            </div>
        </div>

        <!-- Chi tiết từng câu -->
        <h5>Chi tiết từng câu:</h5>
        <c:forEach var="row" items="${ketQuaTungCau}" varStatus="st">
            <div class="card mb-3 ${row.dungKhong ? 'dung' : (row.dapAnChon == '(Bỏ qua)' ? 'bo-qua' : 'sai')}">
                <div class="card-body">
                    <p><strong>Câu ${st.index + 1}:</strong> ${row.noiDung}</p>
                    <p class="mb-1">A. ${row.a}</p>
                    <p class="mb-1">B. ${row.b}</p>
                    <p class="mb-1">C. ${row.c}</p>
                    <p class="mb-1">D. ${row.d}</p>
                    <hr>
                    <p class="mb-1">
                        Bạn chọn: <strong
                            class="${row.dungKhong ? 'text-success' : 'text-danger'}">
                            ${row.dapAnChon}
                        </strong>
                    </p>
                    <c:if test="${!row.dungKhong}">
                        <p class="mb-0">
                            Đáp án đúng: <strong class="text-success">${row.dapAnDung}</strong>
                        </p>
                    </c:if>
                </div>
            </div>
        </c:forEach>

        <div class="mt-3 mb-5">
            <a href="thi-thu.htm" class="btn btn-primary">Thi thử lại</a>
            <a href="bode.htm" class="btn btn-secondary">Về bộ đề</a>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>