<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Đăng ký thi</title>
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body>
	<%@ include file="../common/navbar.jsp"%>
	<div class="container mt-4">
		<h3>Danh sách đăng ký thi</h3>

		<%
		String msg = (String) session.getAttribute("successMsg");
		if (msg != null) {
			session.removeAttribute("successMsg");
		%>

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
		<div class="alert alert-success alert-dismissible fade show">
			<%=msg%>
			<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
		</div>
		<%
		}
		%>

		<a href="dangkythi-them.htm" class="btn btn-primary mb-3">+ Đăng
			ký thi mới</a>

		<table class="table table-bordered table-hover">
			<thead class="table-dark">
				<tr>
					<th>Mã GV</th>
					<th>Môn học</th>
					<th>Lớp</th>
					<th>Trình độ</th>
					<th>Ngày thi</th>
					<th>Lần</th>
					<th>Số câu</th>
					<th>Thời gian</th>
					<th>Thao tác</th>
				</tr>
			</thead>
			<tbody>
				<c:forEach var="dk" items="${list}">
					<tr>
						<td>${dk.maGV}</td>
						<td>${dk.maMH}</td>
						<td>${dk.maLop}</td>
						<td>${dk.trinhDo}</td>
						<td>${dk.ngayThi}</td>
						<td>${dk.lan}</td>
						<td>${dk.soCauThi}</td>
						<td>${dk.thoiGian}phút</td>
						<td><a
							href="dangkythi-xoa.htm?maLop=${dk.maLop}&maMH=${dk.maMH}&lan=${dk.lan}"
							class="btn btn-sm btn-danger"
							onclick="return confirm('Xóa đăng ký này?')">Xóa</a></td>
					</tr>
				</c:forEach>
			</tbody>
		</table>

		<a href="${pageContext.request.contextPath}/logout.htm"
			class="btn btn-outline-danger">Đăng xuất</a>
	</div>
	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>