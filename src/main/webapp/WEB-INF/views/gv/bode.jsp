<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Bộ đề thi</title>
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body>
	<%@ include file="../common/navbar.jsp"%>
	<div class="container mt-4">
		<h3>Quản lý Bộ đề thi</h3>

		<!-- Thông báo thành công -->
		<%
		String msg = (String) session.getAttribute("successMsg");
		if (msg != null) {
			session.removeAttribute("successMsg");
		%>
		<div class="alert alert-success alert-dismissible fade show"
			role="alert">
			<%=msg%>
			<button type="button" class="btn-close" data-bs-dismiss="alert"></button>
		</div>
		<%
		}
		%>
		<!-- Lọc -->
		<form action="bode.htm" method="get" class="row g-2 mb-3">
			<div class="col-auto">
				<select name="maMH" class="form-select">
					<option value="">-- Chọn môn --</option>
					<c:forEach var="mh" items="${dsMonHoc}">
						<option value="${mh.maMH}" ${mh.maMH == maMH ? 'selected' : ''}>
							${mh.tenMH}</option>
					</c:forEach>
				</select>
			</div>
			<div class="col-auto">
				<select name="trinhDo" class="form-select">
					<option value="">-- Trình độ --</option>
					<option value="A" ${trinhDo == 'A' ? 'selected' : ''}>A -
						ĐH Chuyên ngành</option>
					<option value="B" ${trinhDo == 'B' ? 'selected' : ''}>B -
						ĐH Không chuyên</option>
					<option value="C" ${trinhDo == 'C' ? 'selected' : ''}>C -
						Cao đẳng</option>
				</select>
			</div>

			<%-- Tìm theo nội dung - tất cả đều dùng được --%>
			<div class="col-auto">
				<input type="text" name="noiDung" value="${noiDung}"
					class="form-control" placeholder="Tìm theo nội dung..." />
			</div>

			<%-- Lọc theo GV - chỉ PGV --%>
			<c:if test="${sessionScope.role == 'PGV'}">
				<div class="col-auto">
					<select name="maGVLoc" class="form-select">
						<option value="">-- Lọc theo GV --</option>
						<c:forEach var="gv" items="${dsGiaoVien}">
							<option value="${gv.maGV}"
								${gv.maGV == maGVLoc ? 'selected' : ''}>${gv.maGV}-
								${gv.ho} ${gv.ten}</option>
						</c:forEach>
					</select>
				</div>
			</c:if>
			<div class="col-auto">
				<button type="submit" class="btn btn-secondary">Lọc</button>
				<a href="bode.htm" class="btn btn-outline-secondary">Xóa bộ lọc</a>
			</div>
		</form>

		<a href="bode-them.htm" class="btn btn-primary mb-3">+ Thêm câu
			hỏi</a> <a href="bode-import.htm" class="btn btn-success mb-3">📁
			Nhập từ file</a>

		<table class="table table-bordered table-hover">
			<thead class="table-dark">
				<tr>
					<th>Số câu</th>
					<th>Môn học</th>
					<th>Trình độ</th>
					<th>Nội dung</th>
					<th>Đáp án</th>
					<c:if test="${sessionScope.role == 'PGV'}">
						<th>Mã GV</th>
					</c:if>
					<th>Thao tác</th>
				</tr>
			</thead>
			<tbody>
				<c:forEach var="bd" items="${list}">
					<tr>
						<td>${bd.cauHoi}</td>
						<td>${bd.maMH}</td>
						<td>${bd.trinhDo}</td>
						<td>${bd.noiDung}</td>
						<td><strong>${bd.dapAn}</strong></td>
						<c:if test="${sessionScope.role == 'PGV'}">
							<td>${bd.maGV}</td>
						</c:if>
						<td><a href="bode-sua.htm?cauHoi=${bd.cauHoi}"
							class="btn btn-sm btn-warning">Sửa</a> <a
							href="bode-xoa.htm?cauHoi=${bd.cauHoi}"
							class="btn btn-sm btn-danger"
							onclick="return confirm('Xóa câu hỏi này?')">Xóa</a></td>
					</tr>
				</c:forEach>
			</tbody>
		</table>

		<!-- Phân trang -->
		<nav>
			<ul class="pagination">
				<c:if test="${page > 1}">
					<li class="page-item"><a class="page-link"
						href="bode.htm?page=${page-1}&maMH=${maMH != null ? maMH : ''}&trinhDo=${trinhDo != null ? trinhDo : ''}&noiDung=${noiDung != null ? noiDung : ''}&maGVLoc=${maGVLoc != null ? maGVLoc : ''}">
							&laquo; Trước </a></li>
				</c:if>

				<c:forEach begin="1" end="${totalPages}" var="i">
					<li class="page-item ${i == page ? 'active' : ''}"><a
						class="page-link"
						href="bode.htm?page=${i}&maMH=${maMH != null ? maMH : ''}&trinhDo=${trinhDo != null ? trinhDo : ''}&noiDung=${noiDung != null ? noiDung : ''}&maGVLoc=${maGVLoc != null ? maGVLoc : ''}">
							${i} </a></li>
				</c:forEach>

				<c:if test="${page < totalPages}">
					<li class="page-item"><a class="page-link"
						href="bode.htm?page=${page+1}&maMH=${maMH != null ? maMH : ''}&trinhDo=${trinhDo != null ? trinhDo : ''}&noiDung=${noiDung != null ? noiDung : ''}&maGVLoc=${maGVLoc != null ? maGVLoc : ''}">
							Sau &raquo; </a></li>
				</c:if>
			</ul>
		</nav>
		<a href="${pageContext.request.contextPath}/logout.htm"
			class="btn btn-outline-danger">Đăng xuất</a>
	</div>
	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>