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
		<h3>Đăng ký thi</h3>

		<%-- Thông báo --%>
		<c:if test="${not empty sessionScope.successMsg}">
			<div class="alert alert-success alert-dismissible fade show">
				${sessionScope.successMsg}
				<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
			</div>
			<c:remove var="successMsg" scope="session" />
		</c:if>

		<c:if test="${not empty successMsg}">
			<div class="alert alert-success alert-dismissible fade show">
				${successMsg}
				<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
			</div>
		</c:if>

		<c:if test="${not empty error}">
			<div class="alert alert-danger alert-dismissible fade show">
				${error}
				<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
			</div>
		</c:if>

		<c:if test="${not empty sessionScope.errorMsg}">
			<div class="alert alert-danger alert-dismissible fade show">
				${sessionScope.errorMsg}
				<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
			</div>
			<c:remove var="errorMsg" scope="session" />
		</c:if>

		<%-- PHẦN 1: Form đăng ký / sửa --%>
		<div class="card mb-4">
			<div class="card-header bg-primary text-white">
				<h5 class="mb-0">${isEdit ? 'Sửa đăng ký thi' : 'Đăng ký thi mới'}</h5>
			</div>
			<div class="card-body">
				<form
					action="${isEdit ? 'dangkythi-sua.htm' : 'dangkythi-them.htm'}"
					method="post" class="row g-3">

					<c:choose>
						<c:when test="${isEdit}">
							<%-- Khóa chính readonly khi sửa --%>
							<input type="hidden" name="maLop" value="${dk.maLop}" />
							<input type="hidden" name="maMH" value="${dk.maMH}" />
							<input type="hidden" name="lan" value="${dk.lan}" />

							<div class="col-md-3">
								<label class="form-label">Lớp</label> <input type="text"
									class="form-control" value="${dk.maLop}" readonly />
							</div>
							<div class="col-md-3">
								<label class="form-label">Môn học</label> <input type="text"
									class="form-control" value="${dk.maMH}" readonly />
							</div>
							<div class="col-md-2">
								<label class="form-label">Lần thi</label> <input type="text"
									class="form-control" value="${dk.lan}" readonly />
							</div>
						</c:when>
						<c:otherwise>
							<%-- Dropdown khi thêm mới --%>
							<div class="col-md-3">
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
							<div class="col-md-3">
								<label class="form-label">Môn học</label> <select name="maMH"
									class="form-select" required>
									<option value="">-- Chọn môn --</option>
									<c:forEach var="mh" items="${dsMonHoc}">
										<option value="${mh.maMH}"
											${mh.maMH == dk.maMH ? 'selected' : ''}>${mh.tenMH}
										</option>
									</c:forEach>
								</select>
							</div>
							<div class="col-md-2">
								<label class="form-label">Lần thi</label> <select name="lan"
									class="form-select" required>
									<option value="1" ${dk.lan == 1 ? 'selected' : ''}>Lần
										1</option>
									<option value="2" ${dk.lan == 2 ? 'selected' : ''}>Lần
										2</option>
								</select>
							</div>
						</c:otherwise>
					</c:choose>

					<div class="col-md-2">
						<label class="form-label">Trình độ</label> <select name="trinhDo"
							class="form-select" required>
							<option value="">-- Chọn --</option>
							<option value="A" ${dk.trinhDo == 'A' ? 'selected' : ''}>A
								- ĐH Chuyên</option>
							<option value="B" ${dk.trinhDo == 'B' ? 'selected' : ''}>B
								- ĐH Không chuyên</option>
							<option value="C" ${dk.trinhDo == 'C' ? 'selected' : ''}>C
								- Cao đẳng</option>
						</select>
					</div>

					<div class="col-md-2">
						<label class="form-label">Số câu (10-100)</label> <input
							type="number" name="soCauThi" value="${dk.soCauThi}"
							class="form-control" min="10" max="100" required />
					</div>

					<div class="col-md-2">
						<label class="form-label">Ngày thi</label> <input type="date"
							name="ngayThi" value="${dk.ngayThi}" class="form-control"
							required />
					</div>

					<div class="col-md-2">
						<label class="form-label">Thời gian (5-60 phút)</label> <input
							type="number" name="thoiGian" value="${dk.thoiGian}"
							class="form-control" min="5" max="60" required />
					</div>

					<div class="col-12">
						<button type="submit" class="btn btn-primary">${isEdit ? 'Lưu thay đổi' : 'Đăng ký'}
						</button>
						<c:if test="${isEdit}">
							<a href="dangkythi.htm" class="btn btn-secondary">Hủy</a>
						</c:if>
					</div>
				</form>
			</div>
		</div>

		<%-- PHẦN 2: Danh sách ca thi --%>
		<div class="card">
			<div class="card-header bg-secondary text-white">
				<h5 class="mb-0">Danh sách ca thi</h5>
			</div>
			<div class="card-body">
				<table class="table table-bordered table-hover align-middle">
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
								<td><c:if test="${dk.coTheSua == 1}">
										<a
											href="dangkythi.htm?maLop=${dk.maLop}&maMH=${dk.maMH}&lan=${dk.lan}"
											class="btn btn-sm btn-warning">Sửa</a>
									</c:if> <a
									href="dangkythi-xoa.htm?maLop=${dk.maLop}&maMH=${dk.maMH}&lan=${dk.lan}"
									class="btn btn-sm btn-danger"
									onclick="return confirm('Xóa đăng ký này?')">Xóa</a></td>
							</tr>
						</c:forEach>
						<c:if test="${empty list}">
							<tr>
								<td colspan="9" class="text-center text-muted">Chưa có ca
									thi nào</td>
							</tr>
						</c:if>
					</tbody>
				</table>
			</div>
		</div>
	</div>
	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>