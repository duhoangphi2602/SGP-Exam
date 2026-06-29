<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Thi Trắc Nghiệm</title>
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/favicon.svg" />
</head>
<body>
	<%@ include file="../common/navbar.jsp"%>
	<div class="container mt-4">

		<!-- Thông báo lỗi -->
		<%
		String errorMsg = (String) session.getAttribute("errorMsg");
		if (errorMsg != null) {
			session.removeAttribute("errorMsg");
		%>
		<div class="alert alert-danger alert-dismissible fade show">
			<%=errorMsg%>
			<button type="button" class="btn-close" onclick="this.parentElement.remove()"></button>
		</div>
		<%
		}
		%>

		<!-- Thông tin SV -->
		<div class="card mb-4">
			<div class="card-body">
				<h5>
					Lớp: <strong>${lop.maLop}</strong> — ${lop.tenLop}
				</h5>
				<h5>
					Sinh viên: <strong>${sv.ho} ${sv.ten}</strong> — ${sv.maSV}
				</h5>
			</div>
		</div>

		<!-- Bộ lọc -->
		<div class="mb-3">
			<button class="btn btn-outline-primary btn-sm me-1"
				onclick="locCaThi('ALL')">Tất cả</button>
			<button class="btn btn-outline-primary btn-sm me-1"
				onclick="locCaThi('HOM_NAY')">Hôm nay</button>
			<button class="btn btn-outline-primary btn-sm me-1"
				onclick="locCaThi('CHUA_DEN')">Sắp diễn ra</button>
			<button class="btn btn-outline-primary btn-sm me-1"
				onclick="locCaThi('DA_THI')">Đã thi</button>
			<button class="btn btn-outline-primary btn-sm me-1"
				onclick="locCaThi('BO_LO')">Đã bỏ lỡ</button>
		</div>

		<!-- Danh sách ca thi-->
		<div class="card">
			<div class="card-header bg-primary text-white">
				<h5 class="mb-0">Ca thi</h5>
			</div>
			<div class="card-body">
				<c:choose>
					<c:when test="${empty dsCaThi}">
						<div class="alert alert-info">Hôm nay không có ca thi nào!</div>
					</c:when>
					<c:otherwise>
						<table class="table table-bordered table-hover">
							<thead class="table-dark">
								<tr>
									<th>STT</th>
									<th>Môn học</th>
									<th>Ngày thi</th>
									<th>Lần</th>
									<th>Số câu</th>
									<th>Thời gian</th>
									<th>Trình độ</th>
									<th>Thông tin</th>
								</tr>
							</thead>
							<tbody>
								<c:forEach var="ca" items="${dsCaThi}" varStatus="st">
									<tr data-trangthai="${ca.TRANGTHAI}">
										<td>${st.index + 1}</td>
										<td>${ca.TENMH}</td>
										<td>${ca.NGAYTHI}</td>
										<td>${ca.LAN}</td>
										<td>${ca.SOCAUTHI}</td>
										<td>${ca.THOIGIAN}phút</td>
										<td><c:choose>
												<c:when test="${ca.TRINHDO == 'A'}">
                                                    A - ĐH Chuyên ngành
                                                </c:when>
												<c:when test="${ca.TRINHDO == 'B'}">
                                                    B - ĐH Không chuyên
                                                </c:when>
												<c:otherwise>
                                                    C - Cao đẳng
                                                </c:otherwise>
											</c:choose></td>
										<td><c:choose>
												<c:when test="${ca.TRANGTHAI == 'DA_THI'}">
													<span class="badge bg-success">Điểm: ${ca.DIEM}/10</span>
												</c:when>
												<c:when test="${ca.TRANGTHAI == 'HOM_NAY'}">
													<form action="thi-batdau.htm" method="post">
														<input type="hidden" name="maMH" value="${ca.MAMH}" /> <input
															type="hidden" name="ngayThi" value="${ca.NGAYTHI}" /> <input
															type="hidden" name="lan" value="${ca.LAN}" />
														<button type="submit" class="btn btn-success btn-sm">Vào
															thi</button>
													</form>
												</c:when>
												<c:when test="${ca.TRANGTHAI == 'CHUA_DEN'}">
													<span class="badge bg-secondary">Sắp diễn ra</span>
												</c:when>
												<c:when test="${ca.TRANGTHAI == 'BO_LO'}">
													<span class="badge bg-danger">Đã bỏ lỡ</span>
												</c:when>
											</c:choose></td>
									</tr>
								</c:forEach>
							</tbody>
						</table>
					</c:otherwise>
				</c:choose>
			</div>
		</div>
	</div>
	<script>
function locCaThi(trangthai) {
    const rows = document.querySelectorAll('tbody tr');
    rows.forEach(row => {
        if (trangthai === 'ALL' || row.dataset.trangthai === trangthai) {
            row.style.display = '';
        } else {
            row.style.display = 'none';
        }
    });
}
</script>
	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>