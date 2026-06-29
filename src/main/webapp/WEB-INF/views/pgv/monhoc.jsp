<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Quản lý Môn học</title>
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body>
	<%@ include file="../common/navbar.jsp"%>
	<div class="container mt-4">
		<h3>Quản lý Môn học</h3>

		<div id="thongBao"></div>

		<!-- Tìm kiếm -->
		<form action="monhoc.htm" method="get" class="row g-2 mb-3">
			<div class="col-auto">
				<input type="text" name="timkiem" value="${timkiem}"
					class="form-control" placeholder="Tìm theo tên môn học" />
			</div>
			<div class="col-auto">
				<button type="submit" class="btn btn-secondary">Tìm</button>
				<a href="monhoc.htm" class="btn btn-outline-secondary">Xóa bộ
					lọc</a>
			</div>
		</form>

		<div class="mb-3">
			<button type="button" class="btn btn-primary" onclick="moModalThem()">+
				Thêm môn học</button>
			<button type="button" class="btn btn-info" onclick="phucHoi()">↺
				Phục hồi</button>
		</div>

		<table class="table table-bordered table-hover" id="bangMonHoc">
			<thead class="table-dark">
				<tr>
					<th>Mã MH</th>
					<th>Tên môn học</th>
					<th style="width: 180px;">Thao tác</th>
				</tr>
			</thead>
			<tbody>
				<c:forEach var="mh" items="${list}">
					<tr>
						<td>${mh.maMH}</td>
						<td>${mh.tenMH}</td>
						<td>
							<button type="button" class="btn btn-sm btn-warning"
								onclick="moModalSua('${mh.maMH}', '${mh.tenMH}')">Hiệu
								chỉnh</button>
							<button type="button" class="btn btn-sm btn-danger"
								onclick="xoaMonHoc('${mh.maMH}')">Xóa</button>
						</td>
					</tr>
				</c:forEach>
			</tbody>
		</table>
	</div>

	<!-- Modal Thêm/Sửa -->
	<div class="modal fade" id="modalMonHoc" tabindex="-1">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="modalTitle">Thêm môn học</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal"></button>
				</div>
				<div class="modal-body">
					<div id="modalError" class="alert alert-danger"
						style="display: none;"></div>
					<form id="formMonHoc">
						<input type="hidden" id="mode" value="them">
						<div class="mb-3">
							<label class="form-label">Mã môn học</label> <input type="text"
								id="maMH" name="maMH" class="form-control" required>
						</div>
						<div class="mb-3">
							<label class="form-label">Tên môn học</label> <input type="text"
								id="tenMH" name="tenMH" class="form-control" required>
						</div>
					</form>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-secondary"
						data-bs-dismiss="modal">Hủy</button>
					<button type="button" class="btn btn-primary" onclick="ghiMonHoc()">Ghi</button>
				</div>
			</div>
		</div>
	</div>

	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
	<script>
    var contextPath = '${pageContext.request.contextPath}';
    var modalEl = new bootstrap.Modal(document.getElementById('modalMonHoc'));

    function hienThongBao(loai, msg) {
        var div = document.getElementById('thongBao');
        div.innerHTML = '<div class="alert alert-' + loai + ' alert-dismissible fade show">' + msg +
            '<button type="button" class="btn-close" onclick="this.parentElement.remove()"></button></div>';
    }

    function moModalThem() {
        document.getElementById('modalTitle').innerText = 'Thêm môn học';
        document.getElementById('mode').value = 'them';
        document.getElementById('maMH').value = '';
        document.getElementById('maMH').readOnly = false;
        document.getElementById('tenMH').value = '';
        document.getElementById('modalError').style.display = 'none';
        modalEl.show();
    }

    function moModalSua(maMH, tenMH) {
        document.getElementById('modalTitle').innerText = 'Hiệu chỉnh môn học';
        document.getElementById('mode').value = 'sua';
        document.getElementById('maMH').value = maMH;
        document.getElementById('maMH').readOnly = true;
        document.getElementById('tenMH').value = tenMH;
        document.getElementById('modalError').style.display = 'none';
        modalEl.show();
    }

    // Xử lý response dạng "OK|<rows html>" hoặc "ERROR|<message>" hoặc "WARN|<message>"
    function xuLyResponse(text, onSuccess) {
        var idx = text.indexOf('|');
        var status = text.substring(0, idx);
        var content = text.substring(idx + 1);

        if (status === 'OK') {
            document.querySelector('#bangMonHoc tbody').innerHTML = content;
            onSuccess();
        } else if (status === 'WARN') {
            hienThongBao('warning', content);
        } else {
            return content; // trả lỗi để caller xử lý riêng (vd hiện trong modal)
        }
    }

    function ghiMonHoc() {
        var maMH = document.getElementById('maMH').value.trim();
        var tenMH = document.getElementById('tenMH').value.trim();
        var mode = document.getElementById('mode').value;
        var errDiv = document.getElementById('modalError');

        if (!maMH || !tenMH) {
            errDiv.innerText = 'Vui lòng nhập đầy đủ thông tin!';
            errDiv.style.display = 'block';
            return;
        }

        var formData = new URLSearchParams();
        formData.append('maMH', maMH);
        formData.append('tenMH', tenMH);
        formData.append('mode', mode);

        fetch(contextPath + '/pgv/monhoc-ghi.htm', {
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
                document.querySelector('#bangMonHoc tbody').innerHTML = content;
                modalEl.hide();
                hienThongBao('success', mode === 'them' ? 'Thêm môn học thành công!' : 'Sửa môn học thành công!');
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

    function xoaMonHoc(maMH) {
        showConfirmModal('Xóa môn học ' + maMH + '?', function() {
            var formData = new URLSearchParams();
            formData.append('ma', maMH);

            fetch(contextPath + '/pgv/monhoc-xoa-ajax.htm', {
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
                    document.querySelector('#bangMonHoc tbody').innerHTML = content;
                    hienThongBao('success', 'Xóa môn học thành công!');
                } else {
                    hienThongBao('danger', content);
                }
            });
        });
    }

    function phucHoi() {
        showConfirmModal('Bạn có chắc muốn phục hồi?', function() {
            fetch(contextPath + '/pgv/monhoc-phuchoi.htm', {
                method: 'POST'
            })
            .then(res => res.text())
            .then(text => {
                var idx = text.indexOf('|');
                var status = text.substring(0, idx);
                var content = text.substring(idx + 1);

                if (status === 'OK') {
                    document.querySelector('#bangMonHoc tbody').innerHTML = content;
                    hienThongBao('info', 'Đã phục hồi thao tác gần nhất!');
                } else {
                    hienThongBao(status === 'WARN' ? 'warning' : 'danger', content);
                }
            });
        });
    }
    </script>
</body>
</html>