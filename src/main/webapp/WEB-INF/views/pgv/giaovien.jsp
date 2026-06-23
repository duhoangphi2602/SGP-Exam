<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản lý Giáo viên</title>
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
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

        <div class="mb-3">
            <button type="button" class="btn btn-primary" onclick="moModalThem()">+ Thêm giáo viên</button>
        </div>

        <table class="table table-bordered table-hover" id="bangGV">
            <thead class="table-dark">
                <tr>
                    <th>Mã GV</th>
                    <th>Họ</th>
                    <th>Tên</th>
                    <th>SĐT</th>
                    <th>Địa chỉ</th>
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
                            <label class="form-label">Mã giáo viên</label>
                            <input type="text" id="maGV" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Họ</label>
                            <input type="text" id="ho" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Tên</label>
                            <input type="text" id="ten" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Số điện thoại</label>
                            <input type="text" id="soDTLL" class="form-control">
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Địa chỉ</label>
                            <input type="text" id="diaChi" class="form-control">
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
            '<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>';
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
        modalEl.show();
    }

    function ghiGV() {
        var maGV = document.getElementById('maGV').value.trim();
        var ho = document.getElementById('ho').value.trim();
        var ten = document.getElementById('ten').value.trim();
        var soDTLL = document.getElementById('soDTLL').value.trim();
        var diaChi = document.getElementById('diaChi').value.trim();
        var mode = document.getElementById('mode').value;
        var errDiv = document.getElementById('modalError');

        if (!maGV || !ho || !ten) {
            errDiv.innerText = 'Vui lòng nhập đầy đủ Mã GV, Họ, Tên!';
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
        if (!confirm('Xóa giáo viên ' + maGV + '?')) return;

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
    }
    </script>
</body>
</html>