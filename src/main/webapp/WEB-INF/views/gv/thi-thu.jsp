<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Thi thử</title>
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/favicon.svg" />
</head>
<body>
    <%@ include file="../common/navbar.jsp"%>
    <div class="container mt-4">
        <h3>Thi thử</h3>

        <c:if test="${not empty warningMsg}">
            <div class="alert alert-warning">${warningMsg}</div>
        </c:if>

        <%
        String errorMsg = (String) session.getAttribute("errorMsg");
        if (errorMsg != null) { session.removeAttribute("errorMsg"); %>
            <div class="alert alert-danger">${errorMsg}</div>
        <% } %>

        <c:choose>
            <c:when test="${empty dsCaThi}">
                <div class="alert alert-info">
                    Bạn chưa có ca thi nào được đăng ký. Vui lòng đăng ký ca thi trước.
                </div>
                <a href="dangkythi.htm" class="btn btn-primary">Đăng ký thi</a>
            </c:when>
            <c:otherwise>
                <table class="table table-bordered table-hover">
                    <thead class="table-dark">
                        <tr>
                            <th>Mã lớp</th>
                            <th>Môn học</th>
                            <th>Trình độ</th>
                            <th>Lần thi</th>
                            <th>Số câu</th>
                            <th>Thời gian</th>
                            <th>Ngày thi</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="dk" items="${dsCaThi}">
                            <tr>
                                <td>${dk.maLop}</td>
                                <td>${dk.maMH}</td>
                                <td>${dk.trinhDo}</td>
                                <td>${dk.lan}</td>
                                <td>${dk.soCauThi}</td>
                                <td>${dk.thoiGian} phút</td>
                                <td>${dk.ngayThi}</td>
                                <td>
                                    <form action="thi-thu-batdau.htm" method="post" style="display:inline" id="formThiThu_${dk.maLop}_${dk.maMH}_${dk.lan}">
                                        <input type="hidden" name="maLop" value="${dk.maLop}">
                                        <input type="hidden" name="maMH" value="${dk.maMH}">
                                        <input type="hidden" name="lan" value="${dk.lan}">
                                        <button type="button" class="btn btn-sm btn-success"
                                                onclick="thiThu('formThiThu_${dk.maLop}_${dk.maMH}_${dk.lan}')">
                                            ▶ Thi thử
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </div>
    <script>
    function thiThu(formId) {
        showConfirmModal('Bắt đầu thi thử ca này?', function() {
            document.getElementById(formId).submit();
        });
    }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>