<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản lý Môn học</title>
    <link rel="stylesheet" 
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="container mt-4">
    <h3>Quản lý Môn học</h3>

    <!-- Tìm kiếm -->
    <form action="monhoc.htm" method="get" class="row g-2 mb-3">
        <div class="col-auto">
            <input type="text" name="timkiem" value="${timkiem}"
                   class="form-control" placeholder="Tìm theo tên môn học"/>
        </div>
        <div class="col-auto">
            <button type="submit" class="btn btn-secondary">Tìm</button>
            <a href="monhoc.htm" class="btn btn-outline-secondary">Xóa bộ lọc</a>
        </div>
    </form>

    <!-- Nút thêm -->
    <a href="monhoc-them.htm" class="btn btn-primary mb-3">+ Thêm môn học</a>

    <!-- Bảng danh sách -->
    <table class="table table-bordered table-hover">
        <thead class="table-dark">
            <tr>
                <th>Mã MH</th>
                <th>Tên môn học</th>
                <th>Thao tác</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="mh" items="${list}">
                <tr>
                    <td>${mh.maMH}</td>
                    <td>${mh.tenMH}</td>
                    <td>
                        <a href="monhoc-sua.htm?ma=${mh.maMH}" 
                           class="btn btn-sm btn-warning">Sửa</a>
                        <a href="monhoc-xoa.htm?ma=${mh.maMH}"
                           class="btn btn-sm btn-danger"
                           onclick="return confirm('Xóa môn học này?')">Xóa</a>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>

    <a href="${pageContext.request.contextPath}/logout.htm" 
       class="btn btn-outline-danger">Đăng xuất</a>
</body>
</html>