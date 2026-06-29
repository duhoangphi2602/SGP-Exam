<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản lý Giáo viên</title>
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/favicon.svg" />
</head>
<body>
    <%@ include file="../common/navbar.jsp"%>
    <div class="container mt-4">
        <h3>Quản lý Giáo viên</h3>

        <div id="thongBao"></div>

        <!-- Tìm kiếm -->
        <form action="giaovien.htm" method="get" class="row g-2 mb-3">
            <div class="col-auto">
                <input type="text" name="timkiem" value="${timkiem}"
                       class="form-control" placeholder="Tìm theo tên"/>
            </div>
            <div class="col-auto">
                <button type="submit" class="btn btn-secondary">Tìm</button>
                <a href="giaovien.htm" class="btn btn-outline-secondary">Xóa bộ lọc</a>
            </div>
        </form>

        <div class="mb-3 d-flex align-items-center">
            <button type="button" class="btn btn-primary" onclick="moModalThem()">+ Thêm giáo viên</button>
            <button type="button" class="btn btn-secondary ms-2" onclick="phucHoiGV()">Phục hồi (Undo)</button>
        </div>

        <table class="table table-bordered table-hover" id="bangGV">
            <thead class="table-dark">
                <tr>
                    <th>Mã GV</th>
                    <th>Họ</th>
                    <th>Tên</th>
                    <th>SĐT</th>
                    <th>Địa chỉ</th>
                    <th>Tài khoản</th>
                    <th style="width: 200px;">Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="gv" items="${list}">
                    <tr>
                        <td>${gv.maGV}</td>
                        <td>${gv.ho}</td>
                        <td>${gv.ten}</td>
                        <td>${gv.soDTLL}</td>
                        <td>${gv.diaChi}</td>
                        <td>
                            <c:choose>
                                <c:when test="${gv.hasAccount}">
                                    <span class="badge bg-success">Đã cấp (${gv.tenNhom})</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-secondary">Chưa có</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <button type="button" class="btn btn-sm btn-warning"
                                    onclick="moModalSua('${gv.maGV}','${gv.ho}','${gv.ten}','${gv.soDTLL}','${gv.diaChi}')">Hiệu chỉnh</button>
                            <button type="button" class="btn btn-sm btn-danger"
                                    onclick="xoaGV('${gv.maGV}')">Xóa</button>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <!-- Modal Thêm/Sửa -->
    <div class="modal fade" id="modalGV" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="modalTitle">Thêm giáo viên</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div id="modalError" class="alert alert-danger" style="display:none;"></div>
                    <form id="formGV">
                        <input type="hidden" id="mode" value="them">
                        <div class="mb-3">
                            <label class="form-label">Mã giáo viên <span class="text-danger">*</span></label>
                            <input type="text" id="maGV" class="form-control" required oninput="validateMa(this)" maxlength="8">
                            <div class="form-text text-muted" style="font-size: 0.85em;" id="errMaGV">Chỉ chữ cái và số, không khoảng trắng hay ký tự đặc biệt.</div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Họ <span class="text-danger">*</span></label>
                            <input type="text" id="ho" class="form-control" required oninput="validateTen(this, 'errHo')" maxlength="40">
                            <div class="form-text text-muted" style="font-size: 0.85em;" id="errHo">Chỉ được chứa chữ cái.</div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Tên <span class="text-danger">*</span></label>
                            <input type="text" id="ten" class="form-control" required oninput="validateTen(this, 'errTen')" maxlength="10">
                            <div class="form-text text-muted" style="font-size: 0.85em;" id="errTen">Chỉ được chứa chữ cái.</div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Số điện thoại</label>
                            <input type="text" id="soDTLL" class="form-control" oninput="validateSDT(this, 'errSDT')" maxlength="10">
                            <div class="form-text text-muted" style="font-size: 0.85em;" id="errSDT">Bắt buộc 10 chữ số, bắt đầu bằng số 0.</div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Địa chỉ</label>
                            <input type="text" id="diaChi" class="form-control" maxlength="50">
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="button" class="btn btn-primary" onclick="ghiGV()">Ghi</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
    var contextPath = '${pageContext.request.contextPath}';
    var modalEl = new bootstrap.Modal(document.getElementById('modalGV'));

    function hienThongBao(loai, msg) {
        var div = document.getElementById('thongBao');
        div.innerHTML = '<div class="alert alert-' + loai + ' alert-dismissible fade show">' + msg +
            '<button type="button" class="btn-close" onclick="this.parentElement.remove()"></button></div>';
    }

    function moModalThem() {
        document.getElementById('modalTitle').innerText = 'Thêm giáo viên';
        document.getElementById('mode').value = 'them';
        document.getElementById('maGV').value = '';
        document.getElementById('maGV').readOnly = false;
        document.getElementById('ho').value = '';
        document.getElementById('ten').value = '';
        document.getElementById('soDTLL').value = '';
        document.getElementById('diaChi').value = '';
        document.getElementById('modalError').style.display = 'none';
        document.getElementById('errMaGV').style.display = 'none';
        document.getElementById('errHo').style.display = 'none';
        document.getElementById('errTen').style.display = 'none';
        document.getElementById('errSDT').style.display = 'none';
        modalEl.show();
    }

    function moModalSua(maGV, ho, ten, soDTLL, diaChi) {
        document.getElementById('modalTitle').innerText = 'Hiệu chỉnh giáo viên';
        document.getElementById('mode').value = 'sua';
        document.getElementById('maGV').value = maGV;
        document.getElementById('maGV').readOnly = true;
        document.getElementById('ho').value = ho;
        document.getElementById('ten').value = ten;
        document.getElementById('soDTLL').value = soDTLL;
        document.getElementById('diaChi').value = diaChi;
        document.getElementById('modalError').style.display = 'none';
        document.getElementById('errMaGV').style.display = 'none';
        document.getElementById('errHo').style.display = 'none';
        document.getElementById('errTen').style.display = 'none';
        document.getElementById('errSDT').style.display = 'none';
        modalEl.show();
    }
    
    // =====================================
    // REAL-TIME VALIDATION
    // =====================================
    function validateMa(input) {
        let originalVal = input.value;
        let val = originalVal.replace(/[^a-zA-Z0-9]/g, '');
        if (originalVal !== val) {
            let err = document.getElementById('errMaGV');
            err.className = 'form-text text-danger fw-bold';
            err.innerText = 'Ký tự lạ đã tự động bị xóa!';
            clearTimeout(input.errTimer);
            input.errTimer = setTimeout(() => { 
                err.className = 'form-text text-muted'; 
                err.innerText = 'Chỉ chữ cái và số, không khoảng trắng hay ký tự đặc biệt.';
            }, 2000);
        }
        input.value = val.toUpperCase();
    }
    
    function validateTen(input, errId) {
        let originalVal = input.value;
        let val = originalVal.replace(/[^a-zA-ZÀ-ỹ\s]/g, '').replace(/\s{2,}/g, ' ');
        if (originalVal !== val) {
            let err = document.getElementById(errId);
            err.className = 'form-text text-danger fw-bold';
            err.innerText = 'Ký tự lạ đã tự động bị xóa!';
            clearTimeout(input.errTimer);
            input.errTimer = setTimeout(() => { 
                err.className = 'form-text text-muted'; 
                err.innerText = 'Chỉ được chứa chữ cái.';
            }, 2000);
        }
        input.value = val.toUpperCase();
    }
    
    function validateSDT(input, errId) {
        let originalVal = input.value;
        let val = originalVal.replace(/[^0-9]/g, '');
        if (originalVal !== val) {
            let err = document.getElementById(errId);
            err.className = 'form-text text-danger fw-bold';
            err.innerText = 'Chỉ được nhập số!';
            clearTimeout(input.errTimer);
            input.errTimer = setTimeout(() => { 
                err.className = 'form-text text-muted'; 
                err.innerText = 'Bắt buộc 10 chữ số, bắt đầu bằng số 0.';
            }, 2000);
        }
        input.value = val;
    }

    function ghiGV() {
        var maGV = document.getElementById('maGV').value.trim();
        var ho = document.getElementById('ho').value.trim();
        var ten = document.getElementById('ten').value.trim();
        var soDTLL = document.getElementById('soDTLL').value.trim();
        var diaChi = document.getElementById('diaChi').value.trim();
        var mode = document.getElementById('mode').value;
        var errDiv = document.getElementById('modalError');

        // Bổ sung chuẩn hóa khoảng trắng đầu cuối
        document.getElementById('ho').value = ho;
        document.getElementById('ten').value = ten;

        if (!maGV || !ho || !ten) {
            errDiv.innerText = 'Vui lòng nhập đầy đủ Mã GV, Họ, Tên!';
            errDiv.style.display = 'block';
            return;
        }
        
        if (soDTLL && !soDTLL.match(/^0\d{9}$/)) {
            errDiv.innerText = 'Số điện thoại không hợp lệ! (Phải đủ 10 số và bắt đầu bằng số 0)';
            errDiv.style.display = 'block';
            return;
        }

        var formData = new URLSearchParams();
        formData.append('maGV', maGV);
        formData.append('ho', ho);
        formData.append('ten', ten);
        formData.append('soDTLL', soDTLL);
        formData.append('diaChi', diaChi);
        formData.append('mode', mode);

        fetch(contextPath + '/pgv/giaovien-ghi.htm', {
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
                document.querySelector('#bangGV tbody').innerHTML = content;
                modalEl.hide();
                hienThongBao('success', mode === 'them' ? 'Thêm giáo viên thành công!' : 'Sửa giáo viên thành công!');
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

    function xoaGV(maGV) {
        showConfirmModal('Xóa giáo viên ' + maGV + '?', function() {
            var formData = new URLSearchParams();
            formData.append('ma', maGV);

            fetch(contextPath + '/pgv/giaovien-xoa-ajax.htm', {
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
                    document.querySelector('#bangGV tbody').innerHTML = content;
                    hienThongBao('success', 'Xóa giáo viên thành công!');
                } else {
                    hienThongBao('danger', content);
                }
            });
        });
    }

    function phucHoiGV() {
        fetch(contextPath + '/pgv/giaovien-phuchoi.htm', {
            method: 'POST'
        })
        .then(res => res.text())
        .then(text => {
            var idx = text.indexOf('|');
            var status = text.substring(0, idx);
            var content = text.substring(idx + 1);

            if (status === 'OK') {
                document.querySelector('#bangGV tbody').innerHTML = content;
                hienThongBao('success', 'Phục hồi thành công!');
            } else if (status === 'WARN') {
                hienThongBao('warning', content);
            } else {
                hienThongBao('danger', content);
            }
        })
        .catch(err => hienThongBao('danger', 'Lỗi: ' + err));
    }
    </script>
</body>
</html>