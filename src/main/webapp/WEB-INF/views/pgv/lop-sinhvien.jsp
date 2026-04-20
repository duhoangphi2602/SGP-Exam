<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Sinh viên lớp ${lop.tenLop}</title>
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body>
	<%@ include file="../common/navbar.jsp"%>
	<div class="container mt-4">
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
		<h3>Lớp: ${lop.tenLop} (${lop.maLop})</h3>
		<a href="sv-them.htm?maLop=${lop.maLop}" class="btn btn-primary mb-3">+
			Thêm sinh viên</a> <a href="lop.htm" class="btn btn-secondary mb-3">←
			Quay lại</a>

		<table class="table table-bordered table-hover">
			<thead class="table-dark">
				<tr>
					<th>Mã SV</th>
					<th>Họ</th>
					<th>Tên</th>
					<th>Ngày sinh</th>
					<th>Địa chỉ</th>
					<th>Thao tác</th>
				</tr>
			</thead>
			<tbody>
				<c:forEach var="sv" items="${dssv}">
					<tr>
						<td>${sv.maSV}</td>
						<td>${sv.ho}</td>
						<td>${sv.ten}</td>
						<td>${sv.ngaySinh}</td>
						<td>${sv.diaChi}</td>
						<td><a href="sv-sua.htm?ma=${sv.maSV}"
							class="btn btn-sm btn-warning">Sửa</a> <a
							href="sv-xoa.htm?ma=${sv.maSV}&maLop=${lop.maLop}"
							class="btn btn-sm btn-danger"
							onclick="return confirm('Xóa sinh viên này?')">Xóa</a></td>
					</tr>
				</c:forEach>
			</tbody>
		</table>
	</div>
	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>