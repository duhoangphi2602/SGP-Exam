<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ include file="../common/navbar.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản lý Lớp</title>
    <link rel="stylesheet" 
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="container mt-4">
    <h3>Quản lý Lớp</h3>
    <a href="lop-them.htm" class="btn btn-primary mb-3">+ Thêm lớp</a>

    <table class="table table-bordered table-hover">
        <thead class="table-dark">
            <tr>
                <th>Mã lớp</th>
                <th>Tên lớp</th>
                <th>Thao tác</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="lop" items="${list}">
                <tr>
                    <td>${lop.maLop}</td>
                    <td>${lop.tenLop}</td>
                    <td>
                        <a href="lop-sinhvien.htm?ma=${lop.maLop}" 
                           class="btn btn-sm btn-info">Sinh viên</a>
                        <a href="lop-sua.htm?ma=${lop.maLop}" 
                           class="btn btn-sm btn-warning">Sửa</a>
                        <a href="lop-xoa.htm?ma=${lop.maLop}"
                           class="btn btn-sm btn-danger"
                           onclick="return confirm('Xóa lớp này?')">Xóa</a>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
    <a href="${pageContext.request.contextPath}/logout.htm" 
       class="btn btn-outline-danger">Đăng xuất</a>
</body>
</html>