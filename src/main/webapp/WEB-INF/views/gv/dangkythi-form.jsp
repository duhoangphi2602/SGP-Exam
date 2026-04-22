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
		<h3>${isEdit ? 'Sửa đăng ký thi' : 'Đăng ký thi mới'}</h3>

		<c:choose>
			<c:when test="${error != null}">
				<div class="alert alert-danger">${error}</div>
			</c:when>
			<c:when test="${successMsg != null}">
				<div class="alert alert-success">${successMsg}</div>
			</c:when>
		</c:choose>

		<form action="${isEdit ? 'dangkythi-sua.htm' : 'dangkythi-them.htm'}"
			method="post" class="col-md-5">

			<%-- Nếu sửa: truyền khóa chính qua hidden, hiển thị readonly --%>
			<c:choose>
				<c:when test="${isEdit}">
					<input type="hidden" name="maLop" value="${dk.maLop}" />
					<input type="hidden" name="maMH" value="${dk.maMH}" />
					<input type="hidden" name="lan" value="${dk.lan}" />

					<div class="mb-3">
						<label class="form-label">Lớp</label> <input type="text"
							class="form-control" value="${dk.maLop}" readonly />
					</div>
					<div class="mb-3">
						<label class="form-label">Môn học</label> <input type="text"
							class="form-control" value="${dk.maMH}" readonly />
					</div>
					<div class="mb-3">
						<label class="form-label">Lần thi</label> <input type="text"
							class="form-control" value="${dk.lan}" readonly />
					</div>
				</c:when>
				<c:otherwise>
					<div class="mb-3">
						<label class="form-label">Lớp</label> <select name="maLop"
							class="form-select" required>
							<option value="">-- Chọn lớp --</option>
							<c:forEach var="lop" items="${dsLop}">
								<option value="${lop.maLop}"
									${lop.maLop == dk.maLop ? 'selected' : ''}>
									${lop.tenLop}</option>
							</c:forEach>
						</select>
					</div>
					<div class="mb-3">
						<label class="form-label">Môn học</label> <select name="maMH"
							class="form-select" required>
							<option value="">-- Chọn môn --</option>
							<c:forEach var="mh" items="${dsMonHoc}">
								<option value="${mh.maMH}"
									${mh.maMH == dk.maMH ? 'selected' : ''}>${mh.tenMH}</option>
							</c:forEach>
						</select>
					</div>
					<div class="mb-3">
						<label class="form-label">Lần thi</label> <select name="lan"
							class="form-select" required>
							<option value="1" ${dk.lan == 1 ? 'selected' : ''}>Lần 1</option>
							<option value="2" ${dk.lan == 2 ? 'selected' : ''}>Lần 2</option>
						</select>
					</div>
				</c:otherwise>
			</c:choose>

			<%-- Các field được sửa --%>
			<div class="mb-3">
				<label class="form-label">Trình độ</label> <select name="trinhDo"
					class="form-select" required>
					<option value="">-- Chọn trình độ --</option>
					<option value="A" ${dk.trinhDo == 'A' ? 'selected' : ''}>A
						- ĐH Chuyên ngành</option>
					<option value="B" ${dk.trinhDo == 'B' ? 'selected' : ''}>B
						- ĐH Không chuyên</option>
					<option value="C" ${dk.trinhDo == 'C' ? 'selected' : ''}>C
						- Cao đẳng</option>
				</select>
			</div>

			<div class="mb-3">
				<label class="form-label">Số câu thi (10-100)</label> <input
					type="number" name="soCauThi" value="${dk.soCauThi}"
					class="form-control" min="10" max="100" required />
			</div>

			<div class="mb-3">
				<label class="form-label">Ngày thi</label> <input type="date"
					name="ngayThi" value="${dk.ngayThi}" class="form-control" required />
			</div>

			<div class="mb-3">
				<label class="form-label">Thời gian thi (5-60 phút)</label> <input
					type="number" name="thoiGian" value="${dk.thoiGian}"
					class="form-control" min="5" max="60" required />
			</div>

			<button type="submit" class="btn btn-primary">${isEdit ? 'Lưu thay đổi' : 'Đăng ký'}
			</button>
			<a href="dangkythi.htm" class="btn btn-secondary">Hủy</a>
		</form>
	</div>
	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>