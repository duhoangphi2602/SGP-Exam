<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Sinh viên lớp ${lop.tenLop}</title>
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body>
	<%@ include file="../common/navbar.jsp"%>
	<div class="container mt-4">
		<div id="thongBao"></div>

		<h3>Lớp: ${lop.tenLop} (${lop.maLop})</h3>

		<form action="lop-sinhvien.htm" method="get" class="row g-2 mb-3">
			<input type="hidden" name="ma" value="${lop.maLop}">
			<div class="col-auto">
				<input type="text" name="timkiem" value="${timkiem}"
					class="form-control" placeholder="Tìm theo mã SV / họ tên" />
			</div>
			<div class="col-auto">
				<button type="submit" class="btn btn-secondary">Tìm</button>
				<a href="lop-sinhvien.htm?ma=${lop.maLop}"
					class="btn btn-outline-secondary">Xóa bộ lọc</a>
			</div>
		</form>

		<div class="mb-3">
			<button type="button" class="btn btn-primary"
				onclick="moModalThemSV()">+ Thêm sinh viên</button>
			<button type="button" class="btn btn-info" onclick="phucHoiSV()">↺
				Phục hồi</button>
			<a href="lop.htm" class="btn btn-secondary">← Quay lại</a>
		</div>

		<table class="table table-bordered table-hover" id="bangSV">
			<thead class="table-dark">
				<tr>
					<th>Mã SV</th>
					<th>Họ</th>
					<th>Tên</th>
					<th>Ngày sinh</th>
					<th>Địa chỉ</th>
					<th style="width: 200px;">Thao tác</th>
				</tr>
			</thead>
			<tbody>
				<c:forEach var="sv" items="${dssv}">
					<tr>
						<td>${sv.maSV}</td>
						<td>${sv.ho}</td>
						<td>${sv.ten}</td>
						<td>${sv.ngaySinh}</td>
						<td>${sv.diaChi}</td>
						<td>
							<button type="button" class="btn btn-sm btn-warning"
								onclick="moModalSuaSV('${sv.maSV}', '${sv.ho}', '${sv.ten}', '${sv.ngaySinh}', '${sv.diaChi}')">Hiệu
								chỉnh</button>
							<button type="button" class="btn btn-sm btn-danger"
								onclick="xoaSV('${sv.maSV}', '${lop.maLop}')">Xóa</button>
						</td>
					</tr>
				</c:forEach>
			</tbody>
		</table>
	</div>

	<!-- Modal Thêm/Sửa Sinh viên -->
	<div class="modal fade" id="modalSV" tabindex="-1">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="modalTitleSV">Thêm sinh viên</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal"></button>
				</div>
				<div class="modal-body">
					<div id="modalErrorSV" class="alert alert-danger"
						style="display: none;"></div>
					<form id="formSV">
						<input type="hidden" id="modeSV" value="them"> <input
							type="hidden" id="maLopSV" value="${lop.maLop}">
						<div class="mb-3">
							<label class="form-label">Mã sinh viên</label> <input type="text"
								id="maSV" class="form-control" required>
						</div>
						<div class="mb-3">
							<label class="form-label">Họ</label> <input type="text" id="ho"
								class="form-control" required>
						</div>
						<div class="mb-3">
							<label class="form-label">Tên</label> <input type="text" id="ten"
								class="form-control" required>
						</div>
						<div class="mb-3">
							<label class="form-label">Ngày sinh (dd/MM/yyyy)</label> <input
								type="text" id="ngaySinh" class="form-control"
								placeholder="dd/MM/yyyy">
						</div>
						<div class="mb-3">
							<label class="form-label">Địa chỉ</label> <input type="text"
								id="diaChi" class="form-control">
						</div>
					</form>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-secondary"
						data-bs-dismiss="modal">Hủy</button>
					<button type="button" class="btn btn-primary" onclick="ghiSV()">Ghi</button>
				</div>
			</div>
		</div>
	</div>

	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
	<script>
    var contextPath = '${pageContext.request.contextPath}';
    var maLopHienTai = '${lop.maLop}';
    var modalSVEl = new bootstrap.Modal(document.getElementById('modalSV'));

    function hienThongBao(loai, msg) {
        var div = document.getElementById('thongBao');
        div.innerHTML = '<div class="alert alert-' + loai + ' alert-dismissible fade show">' + msg +
            '<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>';
    }

    function moModalThemSV() {
        document.getElementById('modalTitleSV').innerText = 'Thêm sinh viên';
        document.getElementById('modeSV').value = 'them';
        document.getElementById('maSV').value = '';
        document.getElementById('maSV').readOnly = false;
        document.getElementById('ho').value = '';
        document.getElementById('ten').value = '';
        document.getElementById('ngaySinh').value = '';
        document.getElementById('diaChi').value = '';
        document.getElementById('modalErrorSV').style.display = 'none';
        modalSVEl.show();
    }

    function moModalSuaSV(maSV, ho, ten, ngaySinh, diaChi) {
        document.getElementById('modalTitleSV').innerText = 'Hiệu chỉnh sinh viên';
        document.getElementById('modeSV').value = 'sua';
        document.getElementById('maSV').value = maSV;
        document.getElementById('maSV').readOnly = true;
        document.getElementById('ho').value = ho;
        document.getElementById('ten').value = ten;
        document.getElementById('ngaySinh').value = ngaySinh;
        document.getElementById('diaChi').value = diaChi;
        document.getElementById('modalErrorSV').style.display = 'none';
        modalSVEl.show();
    }

    function ghiSV() {
        var maSV = document.getElementById('maSV').value.trim();
        var ho = document.getElementById('ho').value.trim();
        var ten = document.getElementById('ten').value.trim();
        var ngaySinh = document.getElementById('ngaySinh').value.trim();
        var diaChi = document.getElementById('diaChi').value.trim();
        var mode = document.getElementById('modeSV').value;
        var maLop = document.getElementById('maLopSV').value;
        var errDiv = document.getElementById('modalErrorSV');

        if (!maSV || !ho || !ten) {
            errDiv.innerText = 'Vui lòng nhập đầy đủ Mã SV, Họ, Tên!';
            errDiv.style.display = 'block';
            return;
        }

        var formData = new URLSearchParams();
        formData.append('maSV', maSV);
        formData.append('ho', ho);
        formData.append('ten', ten);
        formData.append('ngaySinh', ngaySinh);
        formData.append('diaChi', diaChi);
        formData.append('maLop', maLop);
        formData.append('mode', mode);

        fetch(contextPath + '/pgv/sv-ghi.htm', {
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
                document.querySelector('#bangSV tbody').innerHTML = content;
                modalSVEl.hide();
                hienThongBao('success', mode === 'them' ? 'Thêm sinh viên thành công!' : 'Sửa sinh viên thành công!');
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

    function xoaSV(maSV, maLop) {
        if (!confirm('Xóa sinh viên ' + maSV + '?')) return;

        var formData = new URLSearchParams();
        formData.append('ma', maSV);
        formData.append('maLop', maLop);

        fetch(contextPath + '/pgv/sv-xoa-ajax.htm', {
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
                document.querySelector('#bangSV tbody').innerHTML = content;
                hienThongBao('success', 'Xóa sinh viên thành công!');
            } else {
                hienThongBao('danger', content);
            }
        });
    }

    function phucHoiSV() {
        var formData = new URLSearchParams();
        formData.append('maLop', maLopHienTai);
        if (!confirm('Bạn có chắc muốn phục hồi?')) return;

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
                document.querySelector('#bangSV tbody').innerHTML = content;
                hienThongBao('info', 'Đã phục hồi thao tác gần nhất!');
            } else {
                hienThongBao(status === 'WARN' ? 'warning' : 'danger', content);
            }
        });
    }
    </script>
</body>
</html>