<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ include file="../common/navbar.jsp"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Quản lý Giáo viên</title>
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="container mt-4">
	<h3>Quản lý Giáo viên</h3>
	<%
	String errorMsg = (String) session.getAttribute("errorMsg");
	if (errorMsg != null) {
		session.removeAttribute("errorMsg");
	%>
	<div class="alert alert-danger alert-dismissible fade show">
		<%=errorMsg%>
		<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
	</div>
	<%
	}
	%>

	<%
	String successMsg = (String) session.getAttribute("successMsg");
	if (successMsg != null) {
		session.removeAttribute("successMsg");
	%>
	<div class="alert alert-success alert-dismissible fade show">
		<%=successMsg%>
		<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
	</div>
	<%
	}
	%>
	<form action="giaovien.htm" method="get" class="row g-2 mb-3">
		<div class="col-auto">
			<input type="text" name="timkiem" value="${timkiem}"
				class="form-control" placeholder="Tìm theo tên" />
		</div>
		<div class="col-auto">
			<button type="submit" class="btn btn-secondary">Tìm</button>
			<a href="giaovien.htm" class="btn btn-outline-secondary">Xóa bộ
				lọc</a>
		</div>
	</form>

	<a href="giaovien-them.htm" class="btn btn-primary mb-3">+ Thêm
		giáo viên</a>

	<table class="table table-bordered table-hover">
		<thead class="table-dark">
			<tr>
				<th>Mã GV</th>
				<th>Họ</th>
				<th>Tên</th>
				<th>SĐT</th>
				<th>Địa chỉ</th>
				<th>Thao tác</th>
			</tr>
		</thead>
		<tbody>
			<c:forEach var="gv" items="${list}">
				<tr>
					<td>${gv.maGV}</td>
					<td>${gv.ho}</td>
					<td>${gv.ten}</td>
					<td>${gv.soDTLL}</td>
					<td>${gv.diaChi}</td>
					<td><a href="giaovien-sua.htm?ma=${gv.maGV}"
						class="btn btn-sm btn-warning">Sửa</a> <a
						href="giaovien-xoa.htm?ma=${gv.maGV}"
						class="btn btn-sm btn-danger"
						onclick="return confirm('Xóa giáo viên này?')">Xóa</a></td>
				</tr>
			</c:forEach>
		</tbody>
	</table>

	<a href="${pageContext.request.contextPath}/logout.htm"
		class="btn btn-outline-danger">Đăng xuất</a>
</body>
</html>