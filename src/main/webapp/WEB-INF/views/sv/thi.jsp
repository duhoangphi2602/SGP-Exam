<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Thi Trắc Nghiệm</title>
    <link rel="stylesheet" 
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body>
    <%@ include file="../common/navbar.jsp" %>
    <div class="container mt-4">

        <!-- Thông tin SV -->
        <div class="card mb-4">
            <div class="card-body">
                <h5>Lớp: <strong>${lop.maLop}</strong> — ${lop.tenLop}</h5>
                <h5>Sinh viên: <strong>${sv.ho} ${sv.ten}</strong> — ${sv.maSV}</h5>
            </div>
        </div>

        <!-- Chọn ca thi -->
        <div class="card mb-4">
            <div class="card-header bg-primary text-white">
                <h5 class="mb-0">Chọn ca thi</h5>
            </div>
            <div class="card-body">
                <form action="thi-batdau.htm" method="post">
                    <div class="row g-3">

                        <!-- Chọn môn -->
                        <div class="col-md-4">
                            <label class="form-label">Môn học</label>
                            <select name="maMH" id="maMH" class="form-select" 
                                    onchange="loadNgayThi()" required>
                                <option value="">-- Chọn môn --</option>
                                <c:forEach var="mh" items="${dsMonHoc}">
                                    <option value="${mh.MAMH}">${mh.TENMH}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <!-- Chọn ngày thi -->
                        <div class="col-md-3">
                            <label class="form-label">Ngày thi</label>
                            <select name="ngayThi" id="ngayThi" class="form-select"
                                    onchange="loadLanThi()" required>
                                <option value="">-- Chọn ngày --</option>
                            </select>
                        </div>

                        <!-- Chọn lần thi -->
                        <div class="col-md-2">
                            <label class="form-label">Lần thi</label>
                            <select name="lan" id="lan" class="form-select"
                                    onchange="loadThongTin()" required>
                                <option value="">-- Lần --</option>
                            </select>
                        </div>

                        <!-- Thông tin ca thi -->
                        <div class="col-md-3">
                            <label class="form-label">Thông tin ca thi</label>
                            <div id="thongTinCaThi" class="border rounded p-2 bg-light" 
                                 style="min-height: 38px;">
                                <small class="text-muted">Chọn đủ thông tin...</small>
                            </div>
                        </div>

                    </div>

                    <div class="mt-3">
                        <button type="submit" id="btnBatDau" 
                                class="btn btn-success" disabled>
                            🎯 Bắt đầu thi
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Danh sách ca thi -->
        <div class="card">
            <div class="card-header bg-secondary text-white">
                <h5 class="mb-0">Danh sách ca thi</h5>
            </div>
            <div class="card-body">
                <table class="table table-bordered table-hover">
                    <thead class="table-dark">
                        <tr>
                            <th>STT</th>
                            <th>Môn học</th>
                            <th>Ngày thi</th>
                            <th>Lần</th>
                            <th>Số câu</th>
                            <th>Thời gian</th>
                            <th>Trạng thái</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="ca" items="${dsCaThi}" varStatus="st">
                            <tr>
                                <td>${st.index + 1}</td>
                                <td>${ca.TENMH}</td>
                                <td>${ca.NGAYTHI}</td>
                                <td>${ca.LAN}</td>
                                <td>${ca.SOCAUTHI}</td>
                                <td>${ca.THOIGIAN} phút</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${ca.TRANGTHAI == 'DA_THI'}">
                                            <span class="badge bg-success">
                                                Đã thi: ${ca.DIEM}
                                            </span>
                                        </c:when>
                                        <c:when test="${ca.TRANGTHAI == 'QUA_HAN'}">
                                            <span class="badge bg-danger">Quá hạn</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-warning text-dark">Chưa thi</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

<script>
function loadNgayThi() {
    var maMH = document.getElementById('maMH').value;
    var ngaySelect = document.getElementById('ngayThi');
    var lanSelect = document.getElementById('lan');

    // Reset
    ngaySelect.innerHTML = '<option value="">-- Chọn ngày --</option>';
    lanSelect.innerHTML = '<option value="">-- Lần --</option>';
    document.getElementById('thongTinCaThi').innerHTML = 
        '<small class="text-muted">Chọn đủ thông tin...</small>';
    document.getElementById('btnBatDau').disabled = true;

    if (!maMH) return;

    fetch('thi-getngay.htm?maMH=' + maMH)
        .then(r => r.json())
        .then(data => {
            data.forEach(item => {
                var opt = document.createElement('option');
                opt.value = item.NGAYTHI;
                opt.text = item.NGAYTHI;
                ngaySelect.appendChild(opt);
            });
        });
}

function loadLanThi() {
    var maMH = document.getElementById('maMH').value;
    var ngayThi = document.getElementById('ngayThi').value;
    var lanSelect = document.getElementById('lan');

    // Reset
    lanSelect.innerHTML = '<option value="">-- Lần --</option>';
    document.getElementById('btnBatDau').disabled = true;

    if (!maMH || !ngayThi) return;

    fetch('thi-getlan.htm?maMH=' + maMH + '&ngayThi=' + ngayThi)
        .then(r => r.json())
        .then(data => {
            data.forEach(item => {
                var opt = document.createElement('option');
                opt.value = item.LAN;
                opt.text = 'Lần ' + item.LAN;
                lanSelect.appendChild(opt);
            });
        });
}

function loadThongTin() {
    var maMH = document.getElementById('maMH').value;
    var ngayThi = document.getElementById('ngayThi').value;
    var lan = document.getElementById('lan').value;

    document.getElementById('btnBatDau').disabled = true;

    if (!maMH || !ngayThi || !lan) return;

    fetch('thi-getthongtin.htm?maMH=' + maMH + '&ngayThi=' + ngayThi + '&lan=' + lan)
        .then(r => r.json())
        .then(data => {
            if (data) {
                document.getElementById('thongTinCaThi').innerHTML = 
                    '<small>' +
                    '📝 Số câu: <b>' + data.soCauThi + '</b><br>' +
                    '⏱ Thời gian: <b>' + data.thoiGian + ' phút</b><br>' +
                    '📊 Trình độ: <b>' + data.trinhDo + '</b>' +
                    '</small>';
                document.getElementById('btnBatDau').disabled = false;
            }
        });
}
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>