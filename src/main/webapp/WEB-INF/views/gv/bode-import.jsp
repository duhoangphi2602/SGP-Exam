<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Nhập câu hỏi từ file</title>
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
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
    </script>
</body>
</html>