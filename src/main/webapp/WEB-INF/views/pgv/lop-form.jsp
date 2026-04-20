<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Form Lớp</title>
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body>
	<%@ include file="../common/navbar.jsp"%>
	<div class="container mt-4">
		<h3>${lop.maLop == null ? 'Thêm' : 'Sửa'}Lớp</h3>

		<c:if test="${error != null}">
			<div class="alert alert-danger">${error}</div>
		</c:if>

		<form action="${lop.maLop == null ? 'lop-them.htm' : 'lop-sua.htm'}"
			method="post" class="col-md-4">
			<div class="mb-3">
				<label class="form-label">Mã lớp</label> <input type="text"
					name="maLop" value="${lop.maLop}" class="form-control"
					${lop.maLop != null ? 'readonly' : 'required'} />
			</div>
			<div class="mb-3">
				<label class="form-label">Tên lớp</label> <input type="text"
					name="tenLop" value="${lop.tenLop}" class="form-control" required />
			</div>
			<button type="submit" class="btn btn-primary">Lưu</button>
			<a href="lop.htm" class="btn btn-secondary">Hủy</a>
		</form>
	</div>
	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>