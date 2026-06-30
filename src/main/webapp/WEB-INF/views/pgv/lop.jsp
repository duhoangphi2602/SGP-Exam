<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Quản lý Lớp</title>
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
<link rel="icon" type="image/svg+xml"
	href="${pageContext.request.contextPath}/favicon.svg" />
</head>
<body>
	<%@ include file="../common/navbar.jsp"%>
	<div class="container mt-4">
		<h3>Quản lý Lớp</h3>

		<div id="thongBao"></div>

		<form action="lop.htm" method="get" class="row g-2 mb-3">
			<div class="col-auto">
				<input type="text" name="timkiem" value="${timkiem}"
					class="form-control" placeholder="Tìm theo tên lớp" />
			</div>
			<div class="col-auto">
				<button type="submit" class="btn btn-secondary">Tìm</button>
				<a href="lop.htm" class="btn btn-outline-secondary">Xóa bộ lọc</a>
			</div>
		</form>

		<div class="mb-3">
			<button type="button" class="btn btn-primary" onclick="moModalThem()">+
				Thêm lớp</button>
			<button type="button" class="btn btn-info" onclick="phucHoi()">↺
				Phục hồi</button>
		</div>

		<div class="row">
			<!-- CỘT TRÁI: DANH SÁCH LỚP -->
			<div class="col-lg-4 col-md-5 mb-4">
				<div class="card shadow-sm border-0">
					<div class="card-header bg-white">
						<h5 class="mb-0 text-primary fw-bold">Danh sách Lớp</h5>
					</div>
					<div class="card-body p-0"
						style="max-height: 600px; overflow-y: auto;">
						<table class="table table-bordered table-hover mb-0" id="bangLop">
							<thead class="table-dark sticky-top">
								<tr>
									<th>Mã lớp</th>
									<th>Tên lớp</th>
									<th class="text-center" style="width: 1%; white-space: nowrap;">Thao
										tác</th>
								</tr>
							</thead>
							<tbody>
								<c:forEach var="lop" items="${list}">
									<tr style="cursor: pointer;"
										onclick="xemSinhVien('${lop.maLop}', '${lop.tenLop}', this)">
										<td class="align-middle">${lop.maLop}</td>
										<td class="align-middle">${lop.tenLop}</td>
										<td class="align-middle text-center"
											style="white-space: nowrap;"
											onclick="event.stopPropagation()">
											<button type="button"
												class="btn btn-sm btn-outline-warning p-1 me-1 border-0"
												onclick="moModalSua('${lop.maLop}', '${lop.tenLop}')"
												title="Sửa">✏️</button>
											<button type="button"
												class="btn btn-sm btn-outline-danger p-1 border-0"
												onclick="xoaLop('${lop.maLop}')" title="Xóa">🗑️</button>
										</td>
									</tr>
								</c:forEach>
							</tbody>
						</table>
					</div>
				</div>
			</div>

			<!-- CỘT PHẢI: SUBFORM SINH VIÊN -->
			<div class="col-lg-8 col-md-7">
				<!-- Placeholder khi chưa chọn lớp -->
				<div id="subformPlaceholder"
					class="card shadow-sm bg-light text-center p-5 border-0 h-100 d-flex justify-content-center align-items-center">
					<h5 class="text-muted">👈 Vui lòng chọn một lớp ở danh sách
						bên trái để quản lý sinh viên.</h5>
				</div>

				<div class="card shadow-sm border-0" id="subformContainer"
					style="display: none; border-top: 4px solid #0d6efd !important;">
					<div class="card-header bg-white">
						<h5 class="mb-3 text-primary fw-bold" id="subformTitle">Sinh
							viên lớp:</h5>
						<div class="d-flex flex-wrap gap-2">
							<button type="button" class="btn btn-primary btn-sm"
								onclick="themSVInline()">+ Thêm</button>
							<button type="button" class="btn btn-warning btn-sm"
								onclick="suaSVInline()">✏️ Sửa</button>
							<button type="button" class="btn btn-info btn-sm text-white"
								id="btnXacNhanSV" style="display: none;"
								onclick="xacNhanSVInline()">✔️ Xác nhận</button>
							<button type="button" class="btn btn-danger btn-sm"
								onclick="xoaSVInline()">🗑️ Xóa</button>
							<button type="button" class="btn btn-secondary btn-sm"
								onclick="phucHoiSV()">↺ Phục hồi</button>
							<button type="button"
								class="btn btn-success btn-sm fw-bold shadow-sm"
								onclick="ghiSV()">💾 Lưu</button>
						</div>
					</div>
					<div class="card-body p-0"
						style="max-height: 600px; overflow-y: auto;">
						<div id="thongBaoSV" class="m-2"></div>
						<table class="table table-bordered table-hover mb-0" id="bangSV">
							<thead class="table-light sticky-top">
								<tr>
									<th style="width: 40px;" class="text-center"><input
										type="checkbox" id="checkAllSV" onclick="toggleCheckAll(this)"></th>
									<th>Mã SV</th>
									<th>Họ</th>
									<th>Tên</th>
									<th>Ngày sinh</th>
									<th>Địa chỉ</th>
								</tr>
							</thead>
							<tbody>
								<!-- AJAX đổ dữ liệu vào đây -->
							</tbody>
						</table>
					</div>
				</div>
			</div>
		</div>

	</div>

	<!-- Modal Thêm/Sửa Lớp -->
	<div class="modal fade" id="modalLop" tabindex="-1">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="modalTitle">Thêm lớp</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal"></button>
				</div>
				<div class="modal-body">
					<div id="modalError" class="alert alert-danger"
						style="display: none;"></div>
					<form id="formLop">
						<input type="hidden" id="mode" value="them">
						<div class="mb-3">
							<label class="form-label">Mã lớp</label> <input type="text"
								id="maLop" name="maLop" class="form-control" required
								oninput="validateMaLop(this)">
							<div class="invalid-feedback" id="errMaLop"></div>
						</div>
						<div class="mb-3">
							<label class="form-label">Tên lớp</label> <input type="text"
								id="tenLop" name="tenLop" class="form-control" required
								oninput="validateTenLop(this)">
							<div class="invalid-feedback" id="errTenLop"></div>
						</div>
					</form>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-secondary"
						data-bs-dismiss="modal">Hủy</button>
					<button type="button" class="btn btn-primary" onclick="ghiLop()">Ghi</button>
				</div>
			</div>
		</div>
	</div>

	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
	<script>
    var contextPath = '${pageContext.request.contextPath}';
    var modalEl = new bootstrap.Modal(document.getElementById('modalLop'));

    function hienThongBao(loai, msg) {
        var div = document.getElementById('thongBao');
        div.innerHTML = '<div class="alert alert-' + loai + ' alert-dismissible fade show">' + msg +
            '<button type="button" class="btn-close" onclick="this.parentElement.remove()"></button></div>';
    }

    function moModalThem() {
        document.getElementById('modalTitle').innerText = 'Thêm lớp';
        document.getElementById('mode').value = 'them';
        document.getElementById('maLop').value = '';
        document.getElementById('maLop').readOnly = false;
        document.getElementById('tenLop').value = '';
        document.getElementById('modalError').style.display = 'none';
        resetFieldStateLop();
        modalEl.show();
    }

    function moModalSua(maLop, tenLop) {
        document.getElementById('modalTitle').innerText = 'Hiệu chỉnh lớp';
        document.getElementById('mode').value = 'sua';
        document.getElementById('maLop').value = maLop.trim();
        document.getElementById('maLop').readOnly = true;
        document.getElementById('tenLop').value = tenLop.trim();
        document.getElementById('modalError').style.display = 'none';
        resetFieldStateLop();
        modalEl.show();
    }

    function ghiLop() {
        var maLopEl = document.getElementById('maLop');
        var tenLopEl = document.getElementById('tenLop');
        var errDiv = document.getElementById('modalError');

        var okMa = validateMaLop(maLopEl);
        var okTen = validateTenLop(tenLopEl);
        if (!okMa || !okTen) {
            errDiv.innerText = 'Vui lòng kiểm tra lại thông tin nhập.';
            errDiv.style.display = 'block';
            return;
        }
        errDiv.style.display = 'none';

        var maLop = maLopEl.value.trim();
        var tenLop = tenLopEl.value.trim();
        var mode = document.getElementById('mode').value;

        var formData = new URLSearchParams();
        formData.append('maLop', maLop);
        formData.append('tenLop', tenLop);
        formData.append('mode', mode);

        fetch(contextPath + '/pgv/lop-ghi.htm', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: formData
        })
        .then(res => res.text())
        .then(text => {
            var idx = text.indexOf('|');
            var status = text.substring(0, idx);
            var content = text.substring(idx + 1);

            if (status === 'OK') {
                document.querySelector('#bangLop tbody').innerHTML = content;
                modalEl.hide();
                hienThongBao('success', mode === 'them' ? 'Thêm lớp thành công!' : 'Sửa lớp thành công!');
            } else {
                errDiv.innerText = content;
                errDiv.style.display = 'block';
            }
        })
        .catch(err => {
            errDiv.innerText = 'Lỗi: ' + err;
            errDiv.style.display = 'block';
        });
    }

    function xoaLop(maLop) {
        showConfirmModal('Xóa lớp ' + maLop + '?', function() {
            var formData = new URLSearchParams();
            formData.append('ma', maLop);

            fetch(contextPath + '/pgv/lop-xoa-ajax.htm', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: formData
            })
            .then(res => res.text())
            .then(text => {
                var idx = text.indexOf('|');
                var status = text.substring(0, idx);
                var content = text.substring(idx + 1);

                if (status === 'OK') {
                    document.querySelector('#bangLop tbody').innerHTML = content;
                    hienThongBao('success', 'Xóa lớp thành công!');
                } else {
                    hienThongBao('danger', content);
                }
            });
        });
    }

    function phucHoi() {
        showConfirmModal('Bạn có chắc muốn phục hồi?', function() {
            fetch(contextPath + '/pgv/lop-phuchoi.htm', {
                method: 'POST'
            })
            .then(res => res.text())
            .then(text => {
                var idx = text.indexOf('|');
                var status = text.substring(0, idx);
                var content = text.substring(idx + 1);

                if (status === 'OK') {
                    document.querySelector('#bangLop tbody').innerHTML = content;
                    hienThongBao('info', 'Đã phục hồi thao tác gần nhất!');
                } else {
                    hienThongBao(status === 'WARN' ? 'warning' : 'danger', content);
                }
            });
        });
    }

	// --- JAVASCRIPT CHO SINH VIÊN (SUBFORM INLINE EDITING) ---
    var maLopHienTai = '';
    var isDirtySV = false;

    function hienThongBaoSV(loai, msg) {
        var div = document.getElementById('thongBaoSV');
        div.innerHTML = '<div class="alert alert-' + loai + ' alert-dismissible fade show">' + msg +
            '<button type="button" class="btn-close" onclick="this.parentElement.remove()"></button></div>';
    }

    function runIfClean(callback) {
        if (isDirtySV) {
            showConfirmModal("Bạn có thay đổi chưa lưu! Bạn có chắc chắn muốn bỏ qua các thay đổi này?", function() {
                callback();
            });
        } else {
            callback();
        }
    }

    function xemSinhVien(maLop, tenLop, rowElement) {
        runIfClean(function() {
            maLopHienTai = maLop;
            isDirtySV = false;
        var placeholder = document.getElementById('subformPlaceholder');
        if(placeholder) {
            placeholder.classList.remove('d-flex');
            placeholder.style.display = 'none';
        }
        var subform = document.getElementById('subformContainer');
        subform.style.display = 'block';
        
        document.getElementById('subformTitle').innerText = 'Sinh viên lớp: ' + tenLop + ' (' + maLop + ')';
        document.getElementById('thongBaoSV').innerHTML = '';

		// Highlight row
		var rows = document.querySelectorAll('#bangLop tbody tr');
		rows.forEach(r => r.classList.remove('table-active'));
		if(rowElement) {
			rowElement.classList.add('table-active');
		}

        // Auto scroll for mobile devices
        if(window.innerWidth < 992) {
            subform.scrollIntoView({ behavior: 'smooth' });
        }

        // Fetch danh sách sinh viên
        fetch(contextPath + '/pgv/sv-danhsach-ajax.htm?maLop=' + maLop)
        .then(res => res.text())
        .then(text => {
            var idx = text.indexOf('|');
            var status = text.substring(0, idx);
            var content = text.substring(idx + 1);
            if (status === 'OK') {
                var tbody = document.querySelector('#bangSV tbody');
                // Chèn thêm checkbox vào cột đầu tiên
                var parser = new DOMParser();
                var doc = parser.parseFromString("<table><tbody>" + content + "</tbody></table>", "text/html");
                var trs = doc.querySelectorAll('tr');
                trs.forEach(tr => {
                    var maSV = tr.querySelector('td:nth-child(1)').innerText.trim();
                    tr.setAttribute('data-id', maSV);
                    var tdCheck = document.createElement('td');
                    tdCheck.className = 'text-center align-middle';
                    tdCheck.innerHTML = '<input type="checkbox" class="checkSV" value="'+maSV+'">';
                    tr.insertBefore(tdCheck, tr.firstChild);
                    // Xóa cột thao tác cũ nếu có
                    if (tr.children.length > 6) {
                        tr.removeChild(tr.lastChild);
                    }
                });
                tbody.innerHTML = doc.querySelector('tbody').innerHTML;
            } else {
                hienThongBaoSV('danger', content);
            }
        });
        });
    }

    function toggleCheckAll(source) {
        var checkboxes = document.querySelectorAll('.checkSV');
        checkboxes.forEach(cb => {
            var tr = cb.closest('tr');
            if (tr.getAttribute('data-status') !== 'deleted') {
                cb.checked = source.checked;
            }
        });
    }

    function themSVInline() {
		if(!maLopHienTai) {
			showAlertModal('Vui lòng chọn một lớp trước!'); return;
		}
        var tbody = document.querySelector('#bangSV tbody');
        var tr = document.createElement('tr');
        tr.setAttribute('data-status', 'new');
        tr.innerHTML = `
            <td class="text-center align-middle"><input type="checkbox" class="checkSV" checked></td>
            <td><input type="text" class="form-control form-control-sm input-masv" placeholder="Mã SV" oninput="validateInputSV(this, 'masv')"></td>
            <td><input type="text" class="form-control form-control-sm input-ho" placeholder="Họ" oninput="validateInputSV(this, 'hoten')"></td>
            <td><input type="text" class="form-control form-control-sm input-ten" placeholder="Tên" oninput="validateInputSV(this, 'hoten')"></td>
            <td><input type="text" class="form-control form-control-sm input-ngaysinh" placeholder="dd/MM/yyyy" oninput="validateInputSV(this, 'ngaysinh')"></td>
            <td><input type="text" class="form-control form-control-sm input-diachi" placeholder="Địa chỉ"></td>
        `;
        tbody.appendChild(tr);
        isDirtySV = true;
        
        // Cuộn xuống dòng cuối
        tr.scrollIntoView({ behavior: 'smooth', block: 'end' });
        document.getElementById('btnXacNhanSV').style.display = 'inline-block';
    }

    function suaSVInline() {
        var checkboxes = document.querySelectorAll('.checkSV:checked');
        if (checkboxes.length === 0) {
            showAlertModal('Vui lòng chọn ít nhất một sinh viên để hiệu chỉnh!');
            return;
        }
        checkboxes.forEach(cb => {
            var tr = cb.closest('tr');
            var status = tr.getAttribute('data-status');
            if (status !== 'new' && status !== 'deleted') {
                if (!tr.hasAttribute('data-old-masv')) {
                    tr.setAttribute('data-old-masv', tr.children[1].innerText.trim());
                    tr.setAttribute('data-old-ho', tr.children[2].innerText.trim());
                    tr.setAttribute('data-old-ten', tr.children[3].innerText.trim());
                    tr.setAttribute('data-old-ngaysinh', tr.children[4].innerText.trim());
                    tr.setAttribute('data-old-diachi', tr.children[5].innerText.trim());
                }
                tr.setAttribute('data-status', 'modified');
                var maSV = tr.children[1].innerText.trim();
                var ho = tr.children[2].innerText.trim();
                var ten = tr.children[3].innerText.trim();
                var ngaySinh = tr.children[4].innerText.trim();
                var diaChi = tr.children[5].innerText.trim();

                tr.children[1].innerHTML = '<input type="text" class="form-control form-control-sm input-masv" value="'+maSV+'" readonly>';
                tr.children[2].innerHTML = '<input type="text" class="form-control form-control-sm input-ho" value="'+ho+'" oninput="validateInputSV(this, \'hoten\')">';
                tr.children[3].innerHTML = '<input type="text" class="form-control form-control-sm input-ten" value="'+ten+'" oninput="validateInputSV(this, \'hoten\')">';
                tr.children[4].innerHTML = '<input type="text" class="form-control form-control-sm input-ngaysinh" value="'+ngaySinh+'" oninput="validateInputSV(this, \'ngaysinh\')">';
                tr.children[5].innerHTML = '<input type="text" class="form-control form-control-sm input-diachi" value="'+diaChi+'">';
                isDirtySV = true;
            }
        });
        document.getElementById('btnXacNhanSV').style.display = 'inline-block';
    }

    function xoaSVInline() {
        var checkboxes = document.querySelectorAll('.checkSV:checked');
        if (checkboxes.length === 0) {
            showAlertModal('Vui lòng chọn ít nhất một sinh viên để xóa!');
            return;
        }
        showConfirmModal('Bạn có chắc muốn xóa các sinh viên đã chọn? Hành động này sẽ được ghi nhận khi bạn bấm Lưu.', function() {
            checkboxes.forEach(cb => {
                var tr = cb.closest('tr');
                var status = tr.getAttribute('data-status');
                if (status === 'new') {
                    tr.remove(); // Chưa lưu thì xóa luôn
                } else {
                    tr.setAttribute('data-status', 'deleted');
                    tr.classList.add('table-danger');
                    tr.style.textDecoration = 'line-through';
                    cb.checked = false;
                    cb.disabled = true;
                    // Vô hiệu hóa input nếu đang sửa
                    var inputs = tr.querySelectorAll('input[type="text"]');
                    inputs.forEach(inp => inp.disabled = true);
                }
                isDirtySV = true;
            });
        });
    }

    function xacNhanSVInline() {
        var tbody = document.querySelector('#bangSV tbody');
        var rows = tbody.querySelectorAll('tr[data-status="new"], tr[data-status="modified"]');
        var isValid = true;
        var errorMsg = "";

        // Bước 1: kiểm tra trùng Mã SV trong toàn bảng TRƯỚC khi convert bất kỳ input nào
        var trungLap = kiemTraTrungMaSVTrongBang();
        if (trungLap.length > 0) {
            hienThongBaoSV('danger', "Mã SV bị trùng trong bảng: " + trungLap.join(', '));
            return; // dừng ngay, không convert input nào cả, giữ nguyên để người dùng sửa
        }

        rows.forEach(tr => {
            if (!isValid) return; // dừng convert các dòng sau nếu đã phát hiện lỗi
            if (tr.querySelector('input[type="text"]')) { // Nếu đang là input
                var maSV = tr.querySelector('.input-masv').value.trim().toUpperCase();
                var ho = tr.querySelector('.input-ho').value.trim().toUpperCase();
                var ten = tr.querySelector('.input-ten').value.trim().toUpperCase();
                var ngaySinh = tr.querySelector('.input-ngaysinh').value.trim();
                var diaChi = tr.querySelector('.input-diachi').value.trim();

                if (!maSV || !ho || !ten || !ngaySinh) {
                    isValid = false;
                    errorMsg = "Vui lòng nhập đầy đủ Mã SV, Họ, Tên, Ngày Sinh!";
                    tr.classList.add('table-warning');
                    return;
                }
                if (!isMaSVHopLe(maSV)) {
                    isValid = false;
                    errorMsg = "Mã SV '" + maSV + "' không hợp lệ (không khoảng trắng, không ký tự đặc biệt)!";
                    tr.classList.add('table-warning');
                    return;
                }
                if (!isHoTenHopLe(ho) || !isHoTenHopLe(ten)) {
                    isValid = false;
                    errorMsg = "Họ/Tên không được chứa số hoặc ký tự đặc biệt!";
                    tr.classList.add('table-warning');
                    return;
                }

                var ktNgaySinh = isNgaySinhHopLe(ngaySinh);
                if (!ktNgaySinh.hopLe) {
                    isValid = false;
                    errorMsg = ktNgaySinh.msg;
                    tr.classList.add('table-warning');
                    return;
                }

                // Kiểm tra xem có thực sự thay đổi không
                var status = tr.getAttribute('data-status');
                var isChanged = false;
                if (status === 'modified') {
                    if (maSV !== tr.getAttribute('data-old-masv') ||
                        ho !== tr.getAttribute('data-old-ho') ||
                        ten !== tr.getAttribute('data-old-ten') ||
                        ngaySinh !== tr.getAttribute('data-old-ngaysinh') ||
                        diaChi !== tr.getAttribute('data-old-diachi')) {
                        isChanged = true;
                    }
                } else if (status === 'new') {
                    isChanged = true;
                }

                // Chuyển input về text thuần — chỉ chạy khi dòng này hợp lệ
                tr.children[1].innerText = maSV;
                tr.children[2].innerText = ho;
                tr.children[3].innerText = ten;
                tr.children[4].innerText = ngaySinh;
                tr.children[5].innerText = diaChi;

                if (isChanged) {
                    tr.classList.add('table-warning'); // Highlight đã sửa
                } else {
                    tr.classList.remove('table-warning');
                    tr.removeAttribute('data-status'); // Gỡ bỏ trạng thái modified
                }
            }
        });

        // Tính toán lại isDirtySV
        var isDirty = false;
        document.querySelectorAll('#bangSV tbody tr').forEach(row => {
            if (row.getAttribute('data-status')) isDirty = true;
        });
        isDirtySV = isDirty;

        if (!isValid) {
            hienThongBaoSV('danger', errorMsg);
        } else {
            document.getElementById('btnXacNhanSV').style.display = 'none';
        }
    }

    function ghiSV() {
        if (!maLopHienTai) return;
        var changes = [];
        var tbody = document.querySelector('#bangSV tbody');
        var rows = tbody.querySelectorAll('tr');
        var isValid = true;
        var errorMsg = "";

        rows.forEach(tr => {
            var status = tr.getAttribute('data-status');
            if (status && isValid) {
                if (status === 'deleted') {
                    changes.push({ action: 'DELETE', maSV: tr.getAttribute('data-id') });
                } else {
                    var maSVInp = tr.querySelector('.input-masv');
                    var maSV = maSVInp ? maSVInp.value.trim() : tr.children[1].innerText.trim();
                    var ho = maSVInp ? tr.querySelector('.input-ho').value.trim() : tr.children[2].innerText.trim();
                    var ten = maSVInp ? tr.querySelector('.input-ten').value.trim() : tr.children[3].innerText.trim();
                    var ngaySinh = maSVInp ? tr.querySelector('.input-ngaysinh').value.trim() : tr.children[4].innerText.trim();
                    var diaChi = maSVInp ? tr.querySelector('.input-diachi').value.trim() : tr.children[5].innerText.trim();
                    
                    if (!maSV || !ho || !ten || !ngaySinh) {
                        isValid = false;
                        errorMsg = "Vui lòng nhập đầy đủ Mã SV, Họ, Tên, Ngày Sinh!";
                        tr.classList.add('table-warning');
                        return;
                    }
                    if (!isMaSVHopLe(maSV)) {
                        isValid = false;
                        errorMsg = "Mã SV '" + maSV + "' không hợp lệ (không khoảng trắng, không ký tự đặc biệt)!";
                        tr.classList.add('table-warning');
                        return;
                    }
                    if (!isHoTenHopLe(ho) || !isHoTenHopLe(ten)) {
                        isValid = false;
                        errorMsg = "Họ/Tên không được chứa số hoặc ký tự đặc biệt!";
                        tr.classList.add('table-warning');
                        return;
                    }
                    
                    var dateRegex = /^(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[012])\/(19|20)\d\d$/;
                    if (!dateRegex.test(ngaySinh)) {
                        isValid = false;
                        errorMsg = "Ngày sinh " + ngaySinh + " không đúng định dạng dd/MM/yyyy!";
                        tr.classList.add('table-warning');
                        return;
                    }

                    changes.push({
                        action: status === 'new' ? 'INSERT' : 'UPDATE',
                        maSV: maSV, ho: ho, ten: ten, ngaySinh: ngaySinh,
                        diaChi: diaChi
                    });
                }
            }
        });

        if (isValid) {
            var trungLap = kiemTraTrungMaSVTrongBang();
            if (trungLap.length > 0) {
                isValid = false;
                errorMsg = "Mã SV bị trùng trong bảng: " + trungLap.join(', ');
            }
        }

        if (!isValid) {
            hienThongBaoSV('danger', errorMsg);
            return;
        }

        if (changes.length === 0) {
            hienThongBaoSV('info', 'Không có thay đổi nào cần lưu!');
            return;
        }

        var payload = {
            maLop: maLopHienTai,
            changes: changes
        };

        fetch(contextPath + '/pgv/sv-ghi-batch.htm', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        })
        .then(res => res.text())
        .then(text => {
            var idx = text.indexOf('|');
            var statusText = text.substring(0, idx);
            var content = text.substring(idx + 1);

            if (statusText === 'OK') {
                isDirtySV = false;
                xemSinhVien(maLopHienTai, document.getElementById('subformTitle').innerText.replace('Sinh viên lớp: ', '').split(' (')[0]);
                hienThongBaoSV('success', 'Đã lưu toàn bộ thay đổi thành công!');
            } else {
                hienThongBaoSV('danger', content);
            }
        });
    }

    function phucHoiSV() {
		if(!maLopHienTai) return;
        
        if (isDirtySV) {
            showConfirmModal("Bạn đang có các thay đổi chưa được ghi. Bạn có chắc muốn hủy bỏ các thay đổi này và tải lại danh sách không?", function() {
                isDirtySV = false;
                xemSinhVien(maLopHienTai, document.getElementById('subformTitle').innerText.replace('Sinh viên lớp: ', '').split(' (')[0]);
            });
            return;
        }

        showConfirmModal('Bạn có chắc muốn phục hồi thao tác Ghi dữ liệu gần nhất của sinh viên?', function() {
            var formData = new URLSearchParams();
            formData.append('maLop', maLopHienTai);

            fetch(contextPath + '/pgv/sv-phuchoi.htm', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: formData
            })
            .then(res => res.text())
            .then(text => {
                var idx = text.indexOf('|');
                var status = text.substring(0, idx);
                var content = text.substring(idx + 1);

                if (status === 'OK') {
                    xemSinhVien(maLopHienTai, document.getElementById('subformTitle').innerText.replace('Sinh viên lớp: ', '').split(' (')[0]);
                    hienThongBaoSV('info', 'Đã phục hồi thao tác Ghi gần nhất thành công!');
                } else {
                    hienThongBaoSV(status === 'WARN' ? 'warning' : 'danger', content);
                }
            });
        });
    }
    
 // THÊM MỚI
    function setFieldError(inputEl, errId, msg) {
        if (msg) {
            inputEl.classList.add('is-invalid');
            inputEl.classList.remove('is-valid');
            document.getElementById(errId).innerText = msg;
        } else {
            inputEl.classList.remove('is-invalid');
            inputEl.classList.add('is-valid');
            document.getElementById(errId).innerText = '';
        }
    }

    function validateMaLop(el) {
        var val = el.value;
        if (!val) {
            setFieldError(el, 'errMaLop', 'Mã lớp không được để trống.');
            return false;
        }
        if (/\s/.test(val)) {
            setFieldError(el, 'errMaLop', 'Mã lớp không được chứa khoảng trắng.');
            return false;
        }
        if (/[^a-zA-Z0-9]/.test(val)) {
            setFieldError(el, 'errMaLop', 'Mã lớp không được chứa ký tự đặc biệt.');
            return false;
        }
        setFieldError(el, 'errMaLop', '');
        return true;
    }

    function validateTenLop(el) {
        var val = el.value.trim();
        if (!val) {
            setFieldError(el, 'errTenLop', 'Tên lớp không được để trống.');
            return false;
        }
        if (/[^\p{L}0-9\s]/u.test(val)) {
            setFieldError(el, 'errTenLop', 'Tên lớp không được chứa ký tự đặc biệt.');
            return false;
        }
        setFieldError(el, 'errTenLop', '');
        return true;
    }

    function resetFieldStateLop() {
        ['maLop', 'tenLop'].forEach(function(id) {
            var el = document.getElementById(id);
            el.classList.remove('is-invalid', 'is-valid');
        });
        document.getElementById('errMaLop').innerText = '';
        document.getElementById('errTenLop').innerText = '';
    }
    
    function isMaSVHopLe(val) {
        return val && /^[a-zA-Z0-9]+$/.test(val);
    }

    function isHoTenHopLe(val) {
        return val && /^[\p{L}\s]+$/u.test(val);
    }
    
    function isNgaySinhHopLe(val) {
        var dateRegex = /^(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[012])\/(19|20)\d\d$/;
        if (!dateRegex.test(val)) return { hopLe: false, msg: 'Ngày sinh ' + val + ' không đúng định dạng dd/MM/yyyy!' };

        var parts = val.split('/');
        var ngay = parseInt(parts[0], 10);
        var thang = parseInt(parts[1], 10);
        var nam = parseInt(parts[2], 10);
        var ngaySinhDate = new Date(nam, thang - 1, ngay);
        var today = new Date();

        var tuoi = today.getFullYear() - ngaySinhDate.getFullYear();
        var m = today.getMonth() - ngaySinhDate.getMonth();
        if (m < 0 || (m === 0 && today.getDate() < ngaySinhDate.getDate())) {
            tuoi--;
        }

        if (tuoi < 16) return { hopLe: false, msg: 'Sinh viên phải đủ ít nhất 16 tuổi!' };
        if (tuoi > 60) return { hopLe: false, msg: 'Ngày sinh không hợp lệ (tuổi vượt quá 60)!' };

        return { hopLe: true, msg: '' };
    }
    
 // THÊM MỚI
    function validateInputSV(el, loai) {
        var val = el.value.trim();
        var ok = true;
        if (loai === 'masv') {
            ok = isMaSVHopLe(val);
        } else if (loai === 'hoten') {
            ok = isHoTenHopLe(val);
        } else if (loai === 'ngaysinh') {
            ok = isNgaySinhHopLe(val).hopLe;
        }
        if (!val) ok = false;

        if (ok) {
            el.classList.remove('is-invalid');
            el.classList.add('is-valid');
        } else {
            el.classList.remove('is-valid');
            el.classList.add('is-invalid');
        }
    }
 
 // THÊM MỚI
    function kiemTraTrungMaSVTrongBang() {
        var tbody = document.querySelector('#bangSV tbody');
        var rows = tbody.querySelectorAll('tr');
        var maSVMap = {}; // maSV -> số lần xuất hiện (chỉ tính dòng còn hiệu lực, không tính 'deleted')
        var trungLap = [];

        rows.forEach(tr => {
            var status = tr.getAttribute('data-status');
            if (status === 'deleted') return;

            var maSVInp = tr.querySelector('.input-masv');
            var maSV = maSVInp ? maSVInp.value.trim().toUpperCase() : tr.children[1].innerText.trim().toUpperCase();
            if (!maSV) return;

            maSVMap[maSV] = (maSVMap[maSV] || 0) + 1;
        });

        for (var ma in maSVMap) {
            if (maSVMap[ma] > 1) trungLap.push(ma);
        }
        return trungLap; // mảng rỗng nếu không trùng
    }
    </script>
</body>
</html>