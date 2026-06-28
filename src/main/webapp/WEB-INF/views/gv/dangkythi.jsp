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
				<button type="button" class="btn-close" onclick="this.parentElement.remove()"></button>
			</div>
			<c:remove var="successMsg" scope="session" />
		</c:if>

		<c:if test="${not empty successMsg}">
			<div class="alert alert-success alert-dismissible fade show">
				${successMsg}
				<button type="button" class="btn-close" onclick="this.parentElement.remove()"></button>
			</div>
		</c:if>

		<c:if test="${not empty error}">
			<div class="alert alert-danger alert-dismissible fade show">
				${error}
				<button type="button" class="btn-close" onclick="this.parentElement.remove()"></button>
			</div>
		</c:if>

		<c:if test="${not empty sessionScope.errorMsg}">
			<div class="alert alert-danger alert-dismissible fade show">
				${sessionScope.errorMsg}
				<button type="button" class="btn-close" onclick="this.parentElement.remove()"></button>
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
								<td><a
									href="dangkythi.htm?maLop=${dk.maLop}&maMH=${dk.maMH}&lan=${dk.lan}"
									class="btn btn-sm btn-warning">Sửa</a> <a
									href="javascript:void(0)"
									onclick="xoaDangKy('dangkythi-xoa.htm?maLop=${dk.maLop}&maMH=${dk.maMH}&lan=${dk.lan}')"
									class="btn btn-sm btn-danger">Xóa</a></td>
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
	<!-- SCRIPT XỬ LÝ ĐĂNG KÝ THI THÔNG MINH -->
	<script>
		function xoaDangKy(url) {
			showConfirmModal('Xóa đăng ký này?', function() {
				window.location.href = url;
			});
		}

		// Khai báo biến
		let currentRegistrations = [];
		const isEdit = ${isEdit}; // true/false từ JSP
		
		const maLopSelect = document.querySelector('select[name="maLop"]');
		const maMHSelect = document.querySelector('select[name="maMH"]');
		const lanSelect = document.querySelector('select[name="lan"]');
		const trinhDoSelect = document.querySelector('select[name="trinhDo"]');
		const soCauInput = document.querySelector('input[name="soCauThi"]');
		const ngayThiInput = document.querySelector('input[name="ngayThi"]');
		const submitBtn = document.querySelector('button[type="submit"]');


		// ==========================================
		// 1. LOGIC CHẶN NGÀY THI TRONG QUÁ KHỨ
		// ==========================================
		function updateDateConstraint() {
			const today = new Date();
			let minDateStr = today.toISOString().split('T')[0]; 
			
			if (!isEdit && currentRegistrations.length > 0 && maMHSelect) {
				const maMH = maMHSelect.value;
				const lan = parseInt(lanSelect ? lanSelect.value : 1);
				if (lan === 2 && maMH) {
					const lan1Reg = currentRegistrations.find(r => r.maMH === maMH && r.lan === 1);
					if (lan1Reg && lan1Reg.ngayThi) {
						let d = new Date(lan1Reg.ngayThi);
						d.setDate(d.getDate() + 1); 
						let nextDayStr = d.toISOString().split('T')[0];
						if(nextDayStr > minDateStr) {
							minDateStr = nextDayStr;
						}
					}
				}
			}
			ngayThiInput.setAttribute('min', minDateStr);
		}
		updateDateConstraint();
		// ==========================================
		// 3. LOGIC LÀM MỜ MÔN HỌC BỊ TRÙNG
		// ==========================================
		if (!isEdit && maLopSelect) {
			function fetchRegistrations() {
				const maLop = maLopSelect.value;
				if (!maLop) {
					currentRegistrations = [];
					updateSubjects();
					return;
				}
				// ĐÃ SỬA: Mã hóa encodeURIComponent cho maLop
				fetch('${pageContext.request.contextPath}/gv/api/class-registrations.htm?maLop=' + encodeURIComponent(maLop))
					.then(res => res.json())
					.then(data => {
						currentRegistrations = data;
						updateSubjects();
						updateDateConstraint();
					}).catch(err => console.log("Lỗi tải lịch sử lớp:", err));
			}

			function updateSubjects() {
				const selectedLan = parseInt(lanSelect.value);
				Array.from(maMHSelect.options).forEach(opt => {
					if (!opt.value) return; 
					const maMH = opt.value.trim();
					let status = "AVAILABLE"; let reason = "";
					
					const hasLan1 = currentRegistrations.some(r => r.maMH === maMH && r.lan === 1);
					const hasLan2 = currentRegistrations.some(r => r.maMH === maMH && r.lan === 2);
					
					if (selectedLan === 1 && hasLan1) {
						status = "UNAVAILABLE";
						reason = "Lớp này đã đăng ký thi lần 1 môn này rồi!";
					} else if (selectedLan === 2) {
						if (hasLan2) {
							status = "UNAVAILABLE"; reason = "Lớp này đã đăng ký thi cả 2 lần môn này rồi!";
						} else if (!hasLan1) {
							status = "UNAVAILABLE"; reason = "Phải đăng ký thi lần 1 trước khi đăng ký lần 2!";
						}
					}
					
					opt.setAttribute('data-status', status);
					opt.setAttribute('data-reason', reason);
					
					if (status === "UNAVAILABLE") {
						opt.style.color = "#adb5bd";
						opt.style.backgroundColor = "#f8f9fa";
					} else {
						opt.style.color = ""; opt.style.backgroundColor = "";
					}
				});
				validateSelection();
			}

			function validateSelection() {
				const selectedOpt = maMHSelect.options[maMHSelect.selectedIndex];
				if (selectedOpt && selectedOpt.getAttribute('data-status') === "UNAVAILABLE") {
					showAlertModal("⚠️ " + selectedOpt.getAttribute('data-reason'));
					maMHSelect.value = "";
					submitBtn.disabled = true;
				} else {
					submitBtn.disabled = false;
					updateDateConstraint();
				}
			}

			maLopSelect.addEventListener('change', fetchRegistrations);
			lanSelect.addEventListener('change', () => { updateSubjects(); updateDateConstraint(); });
			maMHSelect.addEventListener('change', validateSelection);

			if (maLopSelect.value) fetchRegistrations();
		}
	</script>
	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>