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

		<table class="table table-bordered table-hover" id="bangLop">
			<thead class="table-dark">
				<tr>
					<th>Mã lớp</th>
					<th>Tên lớp</th>
					<th style="width: 280px;">Thao tác</th>
				</tr>
			</thead>
			<tbody>
				<c:forEach var="lop" items="${list}">
					<tr>
						<td>${lop.maLop}</td>
						<td>${lop.tenLop}</td>
						<td><a href="lop-sinhvien.htm?ma=${lop.maLop}"
							class="btn btn-sm btn-info">Sinh viên</a>
							<button type="button" class="btn btn-sm btn-warning"
								onclick="moModalSua('${lop.maLop}', '${lop.tenLop}')">Hiệu
								chỉnh</button>
							<button type="button" class="btn btn-sm btn-danger"
								onclick="xoaLop('${lop.maLop}')">Xóa</button></td>
					</tr>
				</c:forEach>
			</tbody>
		</table>
	</div>

	<!-- Modal Thêm/Sửa -->
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
								id="maLop" name="maLop" class="form-control" required>
						</div>
						<div class="mb-3">
							<label class="form-label">Tên lớp</label> <input type="text"
								id="tenLop" name="tenLop" class="form-control" required>
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
    </script>
</body>
</html>