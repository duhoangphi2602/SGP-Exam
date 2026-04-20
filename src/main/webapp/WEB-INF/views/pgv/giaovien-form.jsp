<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Form Giáo viên</title>
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body>
	<%@ include file="../common/navbar.jsp"%>
	<div class="container mt-4">
		<h3>${action == 'them' ? 'Thêm' : 'Sửa'}Giáoviên</h3>

		<c:if test="${error != null}">
			<div class="alert alert-danger">${error}</div>
		</c:if>

		<form
			action="${action == 'them' ? 'giaovien-them.htm' : 'giaovien-sua.htm'}"
			method="post" class="col-md-5">
			<div class="mb-3">
				<label class="form-label">Mã giáo viên</label> <input type="text"
					name="maGV" value="${gv.maGV}" class="form-control"
					${action == 'sua' ? 'readonly' : 'required'} />
			</div>
			<div class="mb-3">
				<label class="form-label">Họ</label> <input type="text" name="ho"
					value="${gv.ho}" class="form-control" required />
			</div>
			<div class="mb-3">
				<label class="form-label">Tên</label> <input type="text" name="ten"
					value="${gv.ten}" class="form-control" required />
			</div>
			<div class="mb-3">
				<label class="form-label">Số điện thoại</label> <input type="text"
					name="soDTLL" value="${gv.soDTLL}" class="form-control" />
			</div>
			<div class="mb-3">
				<label class="form-label">Địa chỉ</label> <input type="text"
					name="diaChi" value="${gv.diaChi}" class="form-control" />
			</div>
			<button type="submit" class="btn btn-primary">Lưu</button>
			<a href="giaovien.htm" class="btn btn-secondary">Hủy</a>
		</form>
	</div>
	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
