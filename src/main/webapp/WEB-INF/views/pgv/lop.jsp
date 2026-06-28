<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Quản lý Lớp</title>
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
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
					<div class="card-body p-0" style="max-height: 600px; overflow-y: auto;">
						<table class="table table-bordered table-hover mb-0" id="bangLop">
							<thead class="table-dark sticky-top">
								<tr>
									<th>Mã lớp</th>
									<th>Tên lớp</th>
									<th class="text-center" style="width: 1%; white-space: nowrap;">Thao tác</th>
								</tr>
							</thead>
							<tbody>
								<c:forEach var="lop" items="${list}">
									<tr style="cursor: pointer;" onclick="xemSinhVien('${lop.maLop}', '${lop.tenLop}', this)">
										<td class="align-middle">${lop.maLop}</td>
										<td class="align-middle">${lop.tenLop}</td>
										<td class="align-middle text-center" style="white-space: nowrap;" onclick="event.stopPropagation()">
											<button type="button" class="btn btn-sm btn-outline-warning p-1 me-1 border-0" onclick="moModalSua('${lop.maLop}', '${lop.tenLop}')" title="Sửa">✏️</button>
											<button type="button" class="btn btn-sm btn-outline-danger p-1 border-0" onclick="xoaLop('${lop.maLop}')" title="Xóa">🗑️</button>
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
				<div id="subformPlaceholder" class="card shadow-sm bg-light text-center p-5 border-0 h-100 d-flex justify-content-center align-items-center">
					<h5 class="text-muted">👈 Vui lòng chọn một lớp ở danh sách bên trái để quản lý sinh viên.</h5>
				</div>

				<div class="card shadow-sm border-0" id="subformContainer" style="display: none; border-top: 4px solid #0d6efd !important;">
					<div class="card-header bg-white">
						<h5 class="mb-3 text-primary fw-bold" id="subformTitle">Sinh viên lớp: </h5>
						<div class="d-flex flex-wrap gap-2">
							<button type="button" class="btn btn-primary btn-sm" onclick="themSVInline()">+ Thêm</button>
							<button type="button" class="btn btn-warning btn-sm" onclick="suaSVInline()">✏️ Sửa</button>
							<button type="button" class="btn btn-danger btn-sm" onclick="xoaSVInline()">🗑️ Xóa</button>
							<button type="button" class="btn btn-secondary btn-sm" onclick="phucHoiSV()">↺ Phục hồi</button>
							<button type="button" class="btn btn-success btn-sm fw-bold shadow-sm" onclick="ghiSV()">💾 Lưu</button>
						</div>
					</div>
					<div class="card-body p-0" style="max-height: 600px; overflow-y: auto;">
						<div id="thongBaoSV" class="m-2"></div>
						<table class="table table-bordered table-hover mb-0" id="bangSV">
							<thead class="table-light sticky-top">
								<tr>
									<th style="width: 40px;" class="text-center"><input type="checkbox" id="checkAllSV" onclick="toggleCheckAll(this)"></th>
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
					<div id="modalError" class="alert alert-danger" style="display: none;"></div>
					<form id="formLop">
						<input type="hidden" id="mode" value="them">
						<div class="mb-3">
							<label class="form-label">Mã lớp</label> <input type="text" id="maLop" name="maLop" class="form-control" required>
						</div>
						<div class="mb-3">
							<label class="form-label">Tên lớp</label> <input type="text" id="tenLop" name="tenLop" class="form-control" required>
						</div>
					</form>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
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
            '<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>';
    }

    function moModalThem() {
        document.getElementById('modalTitle').innerText = 'Thêm lớp';
        document.getElementById('mode').value = 'them';
        document.getElementById('maLop').value = '';
        document.getElementById('maLop').readOnly = false;
        document.getElementById('tenLop').value = '';
        document.getElementById('modalError').style.display = 'none';
        modalEl.show();
    }

    function moModalSua(maLop, tenLop) {
        document.getElementById('modalTitle').innerText = 'Hiệu chỉnh lớp';
        document.getElementById('mode').value = 'sua';
        document.getElementById('maLop').value = maLop;
        document.getElementById('maLop').readOnly = true;
        document.getElementById('tenLop').value = tenLop;
        document.getElementById('modalError').style.display = 'none';
        modalEl.show();
    }

    function ghiLop() {
        var maLop = document.getElementById('maLop').value.trim();
        var tenLop = document.getElementById('tenLop').value.trim();
        var mode = document.getElementById('mode').value;
        var errDiv = document.getElementById('modalError');

        if (!maLop || !tenLop) {
            errDiv.innerText = 'Vui lòng nhập đầy đủ thông tin!';
            errDiv.style.display = 'block';
            return;
        }

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
        if (!confirm('Xóa lớp ' + maLop + '?')) return;

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
    }

    function phucHoi() {
    	if (!confirm('Bạn có chắc muốn phục hồi?')) return;
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
    }

	// --- JAVASCRIPT CHO SINH VIÊN (SUBFORM INLINE EDITING) ---
    var maLopHienTai = '';
    var isDirtySV = false;

    function hienThongBaoSV(loai, msg) {
        var div = document.getElementById('thongBaoSV');
        div.innerHTML = '<div class="alert alert-' + loai + ' alert-dismissible fade show">' + msg +
            '<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>';
    }

    function checkDirty() {
        if (isDirtySV) {
            return confirm("Bạn có thay đổi chưa lưu! Bạn có chắc chắn muốn bỏ qua các thay đổi này?");
        }
        return true;
    }

    function xemSinhVien(maLop, tenLop, rowElement) {
        if (!checkDirty()) return;

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
			alert('Vui lòng chọn một lớp trước!'); return;
		}
        var tbody = document.querySelector('#bangSV tbody');
        var tr = document.createElement('tr');
        tr.setAttribute('data-status', 'new');
        tr.innerHTML = `
            <td class="text-center align-middle"><input type="checkbox" class="checkSV" checked></td>
            <td><input type="text" class="form-control form-control-sm input-masv" placeholder="Mã SV"></td>
            <td><input type="text" class="form-control form-control-sm input-ho" placeholder="Họ"></td>
            <td><input type="text" class="form-control form-control-sm input-ten" placeholder="Tên"></td>
            <td><input type="text" class="form-control form-control-sm input-ngaysinh" placeholder="dd/MM/yyyy"></td>
            <td><input type="text" class="form-control form-control-sm input-diachi" placeholder="Địa chỉ"></td>
        `;
        tbody.appendChild(tr);
        isDirtySV = true;
        
        // Cuộn xuống dòng cuối
        tr.scrollIntoView({ behavior: 'smooth', block: 'end' });
    }

    function suaSVInline() {
        var checkboxes = document.querySelectorAll('.checkSV:checked');
        if (checkboxes.length === 0) {
            alert('Vui lòng chọn ít nhất một sinh viên để hiệu chỉnh!');
            return;
        }
        checkboxes.forEach(cb => {
            var tr = cb.closest('tr');
            var status = tr.getAttribute('data-status');
            if (status !== 'new' && status !== 'deleted') {
                tr.setAttribute('data-status', 'modified');
                var maSV = tr.children[1].innerText.trim();
                var ho = tr.children[2].innerText.trim();
                var ten = tr.children[3].innerText.trim();
                var ngaySinh = tr.children[4].innerText.trim();
                var diaChi = tr.children[5].innerText.trim();

                tr.children[1].innerHTML = '<input type="text" class="form-control form-control-sm input-masv" value="'+maSV+'" readonly>';
                tr.children[2].innerHTML = '<input type="text" class="form-control form-control-sm input-ho" value="'+ho+'">';
                tr.children[3].innerHTML = '<input type="text" class="form-control form-control-sm input-ten" value="'+ten+'">';
                tr.children[4].innerHTML = '<input type="text" class="form-control form-control-sm input-ngaysinh" value="'+ngaySinh+'">';
                tr.children[5].innerHTML = '<input type="text" class="form-control form-control-sm input-diachi" value="'+diaChi+'">';
                isDirtySV = true;
            }
        });
    }

    function xoaSVInline() {
        var checkboxes = document.querySelectorAll('.checkSV:checked');
        if (checkboxes.length === 0) {
            alert('Vui lòng chọn ít nhất một sinh viên để xóa!');
            return;
        }
        if (!confirm('Bạn có chắc muốn xóa các sinh viên đã chọn? Hành động này sẽ được ghi nhận khi bạn bấm Lưu.')) return;
        
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
                    var maSV = tr.querySelector('.input-masv').value.trim();
                    var ho = tr.querySelector('.input-ho').value.trim();
                    var ten = tr.querySelector('.input-ten').value.trim();
                    var ngaySinh = tr.querySelector('.input-ngaysinh').value.trim();
                    
                    if (!maSV || !ho || !ten || !ngaySinh) {
                        isValid = false;
                        errorMsg = "Vui lòng nhập đầy đủ Mã SV, Họ, Tên, Ngày Sinh!";
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
                        diaChi: tr.querySelector('.input-diachi').value.trim()
                    });
                }
            }
        });

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
            if (confirm("Bạn đang có các thay đổi chưa được ghi. Bạn có chắc muốn hủy bỏ các thay đổi này và tải lại danh sách không?")) {
                isDirtySV = false;
                xemSinhVien(maLopHienTai, document.getElementById('subformTitle').innerText.replace('Sinh viên lớp: ', '').split(' (')[0]);
            }
            return;
        }

        if (!confirm('Bạn có chắc muốn phục hồi thao tác Ghi dữ liệu gần nhất của sinh viên?')) return;

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
    }
    </script>
</body>
</html>