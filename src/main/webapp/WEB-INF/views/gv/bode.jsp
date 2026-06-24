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

		<div id="thongBao"></div>

		<!-- Lọc -->
		<form id="formLoc" class="row g-2 mb-3">
			<div class="col-auto">
				<select name="maMH" id="locMaMH" class="form-select"
					onchange="locBoDe(1)">
					<option value="">-- Chọn môn --</option>
					<c:forEach var="mh" items="${dsMonHoc}">
						<option value="${mh.maMH}" ${mh.maMH == maMH ? 'selected' : ''}>
							${mh.tenMH}</option>
					</c:forEach>
				</select>
			</div>
			<c:if test="${sessionScope.role == 'PGV'}">
				<div class="col-auto">
					<select id="locMaGV" class="form-select" onchange="locBoDe(1)">
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
				<select name="trinhDo" id="locTrinhDo" class="form-select"
					onchange="locBoDe(1)">
					<option value="">-- Trình độ --</option>
					<option value="A" ${trinhDo == 'A' ? 'selected' : ''}>A -
						ĐH Chuyên ngành</option>
					<option value="B" ${trinhDo == 'B' ? 'selected' : ''}>B -
						ĐH Không chuyên</option>
					<option value="C" ${trinhDo == 'C' ? 'selected' : ''}>C -
						Cao đẳng</option>
				</select>
			</div>
			<div class="col-auto">
				<input type="text" id="locNoiDung" class="form-control"
					placeholder="Tìm theo nội dung..." value="${noiDung}" />
			</div>

			<div class="col-auto">
				<select id="locTrangThai" class="form-select" onchange="locBoDe(1)">
					<option value="">-- Trạng thái --</option>
					<option value="DA_DUNG" ${trangThai == 'DA_DUNG' ? 'selected' : ''}>Đã
						sử dụng</option>
					<option value="CHUA_DUNG"
						${trangThai == 'CHUA_DUNG' ? 'selected' : ''}>Chưa sử
						dụng</option>
				</select>
			</div>
			<div class="col-auto">
				<button type="button" class="btn btn-secondary" onclick="locBoDe(1)">Lọc</button>
				<button type="button" class="btn btn-outline-secondary"
					onclick="xoaLocBoDe()">Xóa bộ lọc</button>
			</div>
		</form>

		<!-- Tổng số câu + nút Thêm -->
		<div class="d-flex align-items-center gap-3 mb-3">
			<button type="button" class="btn btn-primary" onclick="moModalThem()">+
				Thêm câu hỏi</button>
			<a href="bode-import.htm" class="btn btn-success">📁 Nhập từ file</a>
			<div class="alert alert-info py-1 px-3 mb-0">
				Tổng số câu hỏi: <strong id="tongSoCau">${tongSoCau}</strong>
			</div>
		</div>

		<table class="table table-bordered table-hover" id="bangBoDe">
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
						<td><c:choose>
								<c:when test="${daSuDungSet.contains(bd.cauHoi)}">
									<span class="badge bg-secondary">Đã sử dụng</span>
								</c:when>
								<c:otherwise>
									<button type="button" class="btn btn-sm btn-warning"
										onclick="moModalSua(${bd.cauHoi})">Sửa</button>
									<button type="button" class="btn btn-sm btn-danger"
										onclick="xoaBoDe(${bd.cauHoi})">Xóa</button>
								</c:otherwise>
							</c:choose></td>
					</tr>
				</c:forEach>
			</tbody>
		</table>

		<!-- Phân trang -->
		<nav id="phanTrang">
			<ul class="pagination">
				<c:forEach begin="1" end="${totalPages}" var="i">
					<c:if test="${page > 1 && i == 1}">
						<li class="page-item"><a class="page-link"
							href="bode.htm?page=${page-1}&maMH=${maMH != null ? maMH : ''}&trinhDo=${trinhDo != null ? trinhDo : ''}&noiDung=${noiDung != null ? noiDung : ''}&maGVLoc=${maGVLoc != null ? maGVLoc : ''}&trangThai=${trangThai != null ? trangThai : ''}">&laquo;
								Trước</a></li>
					</c:if>
					<li class="page-item ${i == page ? 'active' : ''}"><a
						class="page-link"
						href="bode.htm?page=${i}&maMH=${maMH != null ? maMH : ''}&trinhDo=${trinhDo != null ? trinhDo : ''}&noiDung=${noiDung != null ? noiDung : ''}&maGVLoc=${maGVLoc != null ? maGVLoc : ''}&trangThai=${trangThai != null ? trangThai : ''}">${i}</a>
					</li>
					<c:if test="${page < totalPages && i == totalPages}">
						<li class="page-item"><a class="page-link"
							href="bode.htm?page=${page+1}&maMH=${maMH != null ? maMH : ''}&trinhDo=${trinhDo != null ? trinhDo : ''}&noiDung=${noiDung != null ? noiDung : ''}&maGVLoc=${maGVLoc != null ? maGVLoc : ''}&trangThai=${trangThai != null ? trangThai : ''}">Sau
								&raquo;</a></li>
					</c:if>
				</c:forEach>
			</ul>
		</nav>
	</div>

	<!-- Modal Thêm/Sửa -->
	<div class="modal fade" id="modalBoDe" tabindex="-1"
		data-bs-backdrop="static">
		<div class="modal-dialog modal-lg modal-dialog-scrollable">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="modalTitle">Thêm câu hỏi</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal"></button>
				</div>
				<div class="modal-body">
					<!-- Thông báo bên trong modal -->
					<div id="modalSuccess" class="alert alert-success"
						style="display: none;"></div>
					<div id="modalError" class="alert alert-danger"
						style="display: none;"></div>

					<form id="formBoDe">
						<input type="hidden" id="cauHoi" value="0"> <input
							type="hidden" id="modeBoDe" value="them">

						<div class="mb-3">
							<label class="form-label">Môn học</label> <select id="maMH"
								class="form-select" required>
								<option value="">-- Chọn môn --</option>
								<c:forEach var="mh" items="${dsMonHoc}">
									<option value="${mh.maMH}">${mh.tenMH}</option>
								</c:forEach>
							</select>
							<div id="maMHReadonly" class="form-control bg-light"
								style="display: none;"></div>
						</div>

						<div class="mb-3">
							<label class="form-label">Trình độ</label> <select id="trinhDo"
								class="form-select" required>
								<option value="">-- Chọn trình độ --</option>
								<option value="A">A - ĐH Chuyên ngành</option>
								<option value="B">B - ĐH Không chuyên</option>
								<option value="C">C - Cao đẳng</option>
							</select>
						</div>

						<div class="mb-3">
							<label class="form-label">Nội dung câu hỏi</label>
							<textarea id="noiDung" class="form-control" rows="3" required></textarea>
						</div>

						<div class="mb-3">
							<label class="form-label">Đáp án A</label> <input type="text"
								id="dapAnA" class="form-control" required>
						</div>
						<div class="mb-3">
							<label class="form-label">Đáp án B</label> <input type="text"
								id="dapAnB" class="form-control" required>
						</div>
						<div class="mb-3">
							<label class="form-label">Đáp án C</label> <input type="text"
								id="dapAnC" class="form-control" required>
						</div>
						<div class="mb-3">
							<label class="form-label">Đáp án D</label> <input type="text"
								id="dapAnD" class="form-control" required>
						</div>

						<div class="mb-3">
							<label class="form-label">Đáp án đúng</label> <select id="dapAn"
								class="form-select" required>
								<option value="">-- Chọn đáp án đúng --</option>
								<option value="A">A</option>
								<option value="B">B</option>
								<option value="C">C</option>
								<option value="D">D</option>
							</select>
						</div>
					</form>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-secondary"
						data-bs-dismiss="modal">Đóng</button>
					<button type="button" class="btn btn-primary" id="btnGhi"
						onclick="ghiBoDe()">Ghi</button>
				</div>
			</div>
		</div>
	</div>

	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
	<script>
    var contextPath = '${pageContext.request.contextPath}';
    var isPGV = '${sessionScope.role}' === 'PGV';
    var modalEl = new bootstrap.Modal(document.getElementById('modalBoDe'));
    var currentPage = ${page};
    var currentMaMH = '${maMH != null ? maMH : ""}';
    var currentTrinhDo = '${trinhDo != null ? trinhDo : ""}';
    var currentNoiDung = '${noiDung != null ? noiDung : ""}';
    var currentMaGVLoc = '${maGVLoc != null ? maGVLoc : ""}';
    var currentTrangThai = '${trangThai != null ? trangThai : ""}';

    // ===== HELPER =====
    function hienThongBao(loai, msg) {
        var div = document.getElementById('thongBao');
        div.innerHTML = '<div class="alert alert-' + loai + ' alert-dismissible fade show">' + msg +
            '<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>';
        div.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }

    function getLocParams() {
        return {
            maMH: document.getElementById('locMaMH') ? document.getElementById('locMaMH').value : currentMaMH,
            trinhDo: document.getElementById('locTrinhDo') ? document.getElementById('locTrinhDo').value : currentTrinhDo,
            noiDung: document.getElementById('locNoiDung') ? document.getElementById('locNoiDung').value : currentNoiDung,
            maGVLoc: document.getElementById('locMaGV') ? document.getElementById('locMaGV').value : currentMaGVLoc,
            trangThai: document.getElementById('locTrangThai') ? document.getElementById('locTrangThai').value : ''
        };
    }

    // ===== LỌC =====
    function locBoDe(page) {
        var p = getLocParams();
        currentPage = page || currentPage;
        currentMaMH = p.maMH;
        currentTrinhDo = p.trinhDo;
        currentNoiDung = p.noiDung;
        currentMaGVLoc = p.maGVLoc;
        currentTrangThai = p.trangThai;

        var url = contextPath + '/gv/bode-data.htm?page=' + currentPage
        + '&maMH=' + encodeURIComponent(p.maMH)
        + '&trinhDo=' + encodeURIComponent(p.trinhDo)
        + '&noiDung=' + encodeURIComponent(p.noiDung)
        + '&maGVLoc=' + encodeURIComponent(p.maGVLoc)
        + '&trangThai=' + encodeURIComponent(p.trangThai);

        fetch(url)
        .then(res => res.text())
        .then(text => {
            var parts = text.split('\u0001');
            document.getElementById('tongSoCau').innerText = parts[0];
            document.querySelector('#bangBoDe tbody').innerHTML = parts[1];
            document.querySelector('#phanTrang ul').outerHTML = parts[2] || '<ul class="pagination"></ul>';
        });
    }

    function xoaLocBoDe() {
        if (document.getElementById('locMaMH')) document.getElementById('locMaMH').value = '';
        if (document.getElementById('locTrinhDo')) document.getElementById('locTrinhDo').value = '';
        if (document.getElementById('locNoiDung')) document.getElementById('locNoiDung').value = '';
        if (document.getElementById('locMaGV')) document.getElementById('locMaGV').value = '';
        if (document.getElementById('locTrangThai')) document.getElementById('locTrangThai').value = '';
        locBoDe(1); 
    }

    // Tìm theo nội dung khi bấm Enter
    document.getElementById('locNoiDung').addEventListener('keydown', function(e) {
        if (e.key === 'Enter') locBoDe(1);
    });

    // ===== THÊM =====
    function moModalThem() {
        document.getElementById('modalTitle').innerText = 'Thêm câu hỏi';
        document.getElementById('modeBoDe').value = 'them';
        document.getElementById('cauHoi').value = '0';

        // Hiện select môn học, ẩn readonly
        document.getElementById('maMH').style.display = '';
        document.getElementById('maMHReadonly').style.display = 'none';
        document.getElementById('maMH').disabled = false;
        document.getElementById('maMH').value = '';

        document.getElementById('trinhDo').value = '';
        document.getElementById('noiDung').value = '';
        document.getElementById('dapAnA').value = '';
        document.getElementById('dapAnB').value = '';
        document.getElementById('dapAnC').value = '';
        document.getElementById('dapAnD').value = '';
        document.getElementById('dapAn').value = '';

        document.getElementById('modalError').style.display = 'none';
        document.getElementById('modalSuccess').style.display = 'none';
        document.getElementById('btnGhi').style.display = '';
        modalEl.show();
    }

    // ===== SỬA =====
    function moModalSua(cauHoi) {
        document.getElementById('modalError').style.display = 'none';
        document.getElementById('modalSuccess').style.display = 'none';

        fetch(contextPath + '/gv/bode-get.htm?cauHoi=' + cauHoi)
        .then(res => res.text())
        .then(text => {
            var parts = text.split('\u0001');
            if (parts[0] !== 'OK') {
                hienThongBao('danger', parts[1]);
                return;
            }

            document.getElementById('modalTitle').innerText = 'Sửa câu hỏi #' + parts[1];
            document.getElementById('modeBoDe').value = 'sua';
            document.getElementById('cauHoi').value = parts[1];

            // Ẩn select môn học, hiện readonly
            document.getElementById('maMH').style.display = 'none';
            document.getElementById('maMHReadonly').style.display = '';
            document.getElementById('maMHReadonly').innerText = 'Môn: ' + parts[2];

            document.getElementById('trinhDo').value = parts[3];
            document.getElementById('noiDung').value = parts[4];
            document.getElementById('dapAnA').value = parts[5];
            document.getElementById('dapAnB').value = parts[6];
            document.getElementById('dapAnC').value = parts[7];
            document.getElementById('dapAnD').value = parts[8];
            document.getElementById('dapAn').value = parts[9];

            document.getElementById('btnGhi').style.display = '';
            modalEl.show();
        });
    }

    // ===== GHI (Thêm hoặc Sửa) =====
    function ghiBoDe() {
        var mode = document.getElementById('modeBoDe').value;
        var maMH = mode === 'them' ? document.getElementById('maMH').value : document.getElementById('cauHoi').getAttribute('data-mamh');
        if (mode === 'them') maMH = document.getElementById('maMH').value;

        var cauHoi = document.getElementById('cauHoi').value;
        var trinhDo = document.getElementById('trinhDo').value;
        var noiDung = document.getElementById('noiDung').value.trim();
        var a = document.getElementById('dapAnA').value.trim();
        var b = document.getElementById('dapAnB').value.trim();
        var c = document.getElementById('dapAnC').value.trim();
        var d = document.getElementById('dapAnD').value.trim();
        var dapAn = document.getElementById('dapAn').value;
        var errDiv = document.getElementById('modalError');
        var successDiv = document.getElementById('modalSuccess');

        errDiv.style.display = 'none';
        successDiv.style.display = 'none';

        // Validate client
        if ((mode === 'them' && !maMH) || !trinhDo || !noiDung || !a || !b || !c || !d || !dapAn) {
            errDiv.innerText = 'Vui lòng nhập đầy đủ thông tin!';
            errDiv.style.display = 'block';
            return;
        }

        // Validate đáp án trùng
        var dapAnArr = [a, b, c, d];
        var dapAnSet = new Set(dapAnArr);
        if (dapAnSet.size < 4) {
            errDiv.innerText = 'Các đáp án A, B, C, D không được trùng nhau!';
            errDiv.style.display = 'block';
            return;
        }

        var url = mode === 'them'
            ? contextPath + '/gv/bode-them-ajax.htm'
            : contextPath + '/gv/bode-sua-ajax.htm';

        var formData = new URLSearchParams();
        if (mode === 'them') {
            formData.append('maMH', maMH);
        } else {
            formData.append('cauHoi', cauHoi);
            // lấy maMH từ hidden data
            formData.append('maMH', document.getElementById('maMHReadonly').getAttribute('data-mamh') || '');
        }
        formData.append('trinhDo', trinhDo);
        formData.append('noiDung', noiDung);
        formData.append('a', a);
        formData.append('b', b);
        formData.append('c', c);
        formData.append('d', d);
        formData.append('dapAn', dapAn);

        fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: formData
        })
        .then(res => res.text())
        .then(text => {
            var idx = text.indexOf('|');
            var status = text.substring(0, idx);
            var msg = text.substring(idx + 1);

            if (status === 'OK') {
                successDiv.innerText = msg;
                successDiv.style.display = 'block';
                errDiv.style.display = 'none';

                if (mode === 'them') {
                    // Clear form để nhập câu tiếp theo
                    document.getElementById('maMH').value = '';
                    document.getElementById('trinhDo').value = '';
                    document.getElementById('noiDung').value = '';
                    document.getElementById('dapAnA').value = '';
                    document.getElementById('dapAnB').value = '';
                    document.getElementById('dapAnC').value = '';
                    document.getElementById('dapAnD').value = '';
                    document.getElementById('dapAn').value = '';
                } else {
                    // Sửa xong → đóng modal
                    setTimeout(() => modalEl.hide(), 800);
                }

                // Refresh bảng (giữ filter + trang hiện tại)
                locBoDe(mode === 'them' ? 1 : currentPage);
            } else {
                errDiv.innerText = msg;
                errDiv.style.display = 'block';
                successDiv.style.display = 'none';
            }
        })
        .catch(err => {
            errDiv.innerText = 'Lỗi: ' + err;
            errDiv.style.display = 'block';
        });
    }

    // ===== XÓA =====
    function xoaBoDe(cauHoi) {
        if (!confirm('Xóa câu hỏi #' + cauHoi + '?')) return;

        var formData = new URLSearchParams();
        formData.append('cauHoi', cauHoi);

        fetch(contextPath + '/gv/bode-xoa-ajax.htm', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: formData
        })
        .then(res => res.text())
        .then(text => {
            var idx = text.indexOf('|');
            var status = text.substring(0, idx);
            var msg = text.substring(idx + 1);

            if (status === 'OK') {
                hienThongBao('success', msg);
                locBoDe(currentPage);
            } else {
                hienThongBao('danger', msg);
            }
        });
    }
    </script>
</body>
</html>