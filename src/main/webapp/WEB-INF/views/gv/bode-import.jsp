<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Nhập câu hỏi từ file</title>
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/favicon.svg" />
    <script src="https://cdn.jsdelivr.net/npm/xlsx@0.18.5/dist/xlsx.full.min.js"></script>
</head>
<body>
    <%@ include file="../common/navbar.jsp" %>
    <div class="container mt-4">
        <h3>Nhập câu hỏi từ file Excel</h3>

        <div class="alert alert-info">
            File Excel cần có 8 cột theo đúng thứ tự, dòng đầu tiên là tiêu đề:<br>
            <strong>Mã MH | Trình độ | Nội dung | A | B | C | D | Đáp án</strong>
        </div>

        <div id="thongBao"></div>

        <form id="formImport" class="col-md-6">
            <div class="mb-3">
                <label class="form-label">Chọn file (.xlsx)</label>
                <input type="file" id="fileInput" class="form-control" accept=".xlsx" required>
            </div>
            <button type="button" class="btn btn-primary" onclick="upload()">Nhập câu hỏi</button>
            <a href="bode.htm" class="btn btn-secondary">Quay lại</a>
        </form>

        <!-- Preview bảng dữ liệu -->
        <div id="previewSection" style="display:none;" class="mt-4">
            <div class="d-flex align-items-center gap-3 mb-2">
                <h5 class="mb-0">Xem trước dữ liệu</h5>
                <span class="badge bg-primary" id="tongDong"></span>
            </div>
            <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
                <table class="table table-bordered table-sm table-hover" id="previewTable">
                    <thead class="table-dark sticky-top">
                        <tr>
                            <th>#</th>
                            <th>Mã MH</th>
                            <th>Trình độ</th>
                            <th>Nội dung</th>
                            <th>A</th>
                            <th>B</th>
                            <th>C</th>
                            <th>D</th>
                            <th>Đáp án</th>
                        </tr>
                    </thead>
                    <tbody id="previewBody"></tbody>
                </table>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
    var contextPath = '${pageContext.request.contextPath}';

    function hienThongBao(loai, msg) {
        var div = document.getElementById('thongBao');
        div.innerHTML = '<div class="alert alert-' + loai + '">' + msg + '</div>';
    }

    function upload() {
        var fileInput = document.getElementById('fileInput');
        if (!fileInput.files.length) {
            hienThongBao('danger', 'Vui lòng chọn file!');
            return;
        }

        var formData = new FormData();
        formData.append('file', fileInput.files[0]);

        hienThongBao('secondary', 'Đang xử lý...');

        fetch(contextPath + '/gv/bode-import.htm', {
            method: 'POST',
            body: formData
        })
        .then(res => res.text())
        .then(text => {
            var idx = text.indexOf('|');
            var status = text.substring(0, idx);
            var content = text.substring(idx + 1);

            if (status === 'OK') {
                hienThongBao('success', content);
                fileInput.value = '';
            } else {
                hienThongBao('danger', content);
            }
        })
        .catch(err => {
            hienThongBao('danger', 'Lỗi: ' + err);
        });
    }

    // ===== RESET KHI CHỌN FILE MỚI (cho phép chọn lại cùng 1 file) =====
    document.getElementById('fileInput').addEventListener('click', function() {
        this.value = '';
        document.getElementById('previewSection').style.display = 'none';
        document.getElementById('previewBody').innerHTML = '';
        document.getElementById('thongBao').innerHTML = '';
    });

    // ===== PREVIEW FILE EXCEL (chỉ hiển thị dữ liệu, không validate) =====
    document.getElementById('fileInput').addEventListener('change', function(e) {
        document.getElementById('thongBao').innerHTML = '';
        var file = e.target.files[0];
        if (!file) return;

        var reader = new FileReader();
        reader.onload = function(ev) {
            var data = new Uint8Array(ev.target.result);
            var workbook = XLSX.read(data, { type: 'array' });
            var sheet = workbook.Sheets[workbook.SheetNames[0]];
            var rows = XLSX.utils.sheet_to_json(sheet, { header: 1, defval: '' });

            var tbody = document.getElementById('previewBody');
            tbody.innerHTML = '';
            var soDong = 0;

            for (var i = 1; i < rows.length; i++) {
                var row = rows[i];
                var maMH    = String(row[0] || '').trim();
                var trinhDo = String(row[1] || '').trim();
                var noiDung = String(row[2] || '').trim();
                var a       = String(row[3] || '').trim();
                var b       = String(row[4] || '').trim();
                var c       = String(row[5] || '').trim();
                var d       = String(row[6] || '').trim();
                var dapAn   = String(row[7] || '').trim();

                if (!maMH && !trinhDo && !noiDung) continue;
                soDong++;

                var tr = document.createElement('tr');
                tr.innerHTML =
                    '<td>' + i + '</td>' +
                    '<td>' + escapeHtml(maMH) + '</td>' +
                    '<td>' + escapeHtml(trinhDo) + '</td>' +
                    '<td>' + escapeHtml(noiDung) + '</td>' +
                    '<td>' + escapeHtml(a) + '</td>' +
                    '<td>' + escapeHtml(b) + '</td>' +
                    '<td>' + escapeHtml(c) + '</td>' +
                    '<td>' + escapeHtml(d) + '</td>' +
                    '<td><strong>' + escapeHtml(dapAn) + '</strong></td>';
                tbody.appendChild(tr);
            }

            document.getElementById('tongDong').innerText = soDong + ' dòng';
            document.getElementById('previewSection').style.display = '';
        };
        reader.readAsArrayBuffer(file);
    });

    function escapeHtml(str) {
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;');
    }
    </script>
</body>
</html>
