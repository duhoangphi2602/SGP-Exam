<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Chi tiết bài thi</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/favicon.svg" />
</head>
<body>
    <%@ include file="../common/navbar.jsp" %>
    <div class="container mt-4">
        <!-- Header: Nút Quay lại và Xuất Excel -->
        <div class="d-flex justify-content-between align-items-center mb-4 d-print-none">
            <a href="javascript:history.back()" class="btn btn-secondary">
                <i class="bi bi-arrow-left"></i> Quay lại
            </a>
            <div class="d-flex gap-2">
                <button type="button" class="btn btn-success" data-bs-toggle="modal" data-bs-target="#excelModal">
                    <i class="bi bi-file-earmark-excel"></i> Xuất Excel
                </button>
            </div>
        </div>

        <!-- Bố cục hiển thị -->
        <div class="print-header mb-4">
            <h4 class="text-center fw-bold text-uppercase mb-4">Kết Quả Thi Chi Tiết</h4>
            <div class="row">
                <div class="col-8">
                    <p class="mb-1">Lớp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: <strong>${lop.tenLop} (${lop.maLop})</strong></p>
                    <p class="mb-1">Họ tên&nbsp;&nbsp;: <strong>${sv.ho} ${sv.ten}</strong></p>
                    <p class="mb-1">Môn thi: <strong>${monHoc.tenMH} (${monHoc.maMH})</strong></p>
                    <p class="mb-1">Ngày thi: <strong>${ngayThi}</strong></p>
                </div>
                <div class="col-4">
                    <p class="mb-1"><br></p>
                    <p class="mb-1">Mã số SV: <strong>${sv.maSV}</strong></p>
                    <p class="mb-1"><br></p>
                    <p class="mb-1">Lần thi: <strong>${lan}</strong></p>
                </div>
            </div>
            <div class="mt-3 fs-5 text-danger fw-bold">
                Điểm bài thi: ${diem}
            </div>
        </div>

        <c:if test="${empty chiTiet}">
            <div class="alert alert-warning shadow-sm border-warning d-print-none" role="alert">
                <h5 class="alert-heading">⚠️ Không có dữ liệu chi tiết!</h5>
                <p>Bài thi này có thể đã được thực hiện từ trước khi hệ thống cập nhật tính năng lưu vết chi tiết, hoặc dữ liệu đã bị dọn dẹp.</p>
            </div>
            <div class="d-none d-print-block text-center text-danger fw-bold mt-5">
                (Không có dữ liệu chi tiết câu hỏi cho bài thi này)
            </div>
        </c:if>

        <c:if test="${not empty chiTiet}">
            <table class="table table-bordered printable-table mt-3">
                <thead>
                    <tr class="text-center bg-light">
                        <th width="5%">STT</th>
                        <th width="6%">Câu số<br>(trong bộ đề)</th>
                        <th width="31%">Nội dung câu hỏi</th>
                        <th width="10%">A</th>
                        <th width="10%">B</th>
                        <th width="10%">C</th>
                        <th width="10%">D</th>
                        <th width="8%">Trả lời<br>của SV</th>
                        <th width="10%">Đáp án</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="cau" items="${chiTiet}">
                        <tr>
                            <td class="text-center align-middle">${cau.STT}</td>
                            <td class="text-center align-middle fw-bold text-secondary">${cau.CAUHOI}</td>
                            <td class="align-middle">${cau.NOIDUNG}</td>
                            <td class="align-middle">${cau.A}</td>
                            <td class="align-middle">${cau.B}</td>
                            <td class="align-middle">${cau.C}</td>
                            <td class="align-middle">${cau.D}</td>
                            <td class="text-center align-middle fw-bold ${cau.DACHON != null && cau.DACHON.trim() == cau.DAP_AN.trim() ? 'text-success' : 'text-danger'}">
                                ${cau.DACHON != null ? cau.DACHON.trim() : '-'}
                            </td>
                            <td class="text-center align-middle fw-bold text-primary">${cau.DAP_AN.trim()}</td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:if>
    </div>

    <style>
        .print-header { border-bottom: 2px solid #000; padding-bottom: 15px; }
        .bg-light { background-color: #f8f9fa !important; }
        .text-danger { color: #dc3545 !important; }
        .text-success { color: #198754 !important; }
        .text-primary { color: #0d6efd !important; }
    </style>
    
    <!-- Modal Nhập tên file Excel -->
    <div class="modal fade" id="excelModal" tabindex="-1" aria-labelledby="excelModalLabel" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header bg-success text-white">
            <h5 class="modal-title" id="excelModalLabel"><i class="bi bi-file-earmark-excel"></i> Tùy chỉnh xuất Excel</h5>
            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <div class="mb-3">
                <label for="excelFileName" class="form-label fw-bold">Vui lòng nhập tên file muốn lưu:</label>
                <input type="text" class="form-control" id="excelFileName" value="ChiTietBaiThi_${sv.maSV}_Mon_${monHoc.maMH}_Lan_${lan}">
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
            <button type="button" class="btn btn-success" onclick="executeExportExcel()">Xác nhận xuất</button>
          </div>
        </div>
      </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/xlsx-js-style@1.2.0/dist/xlsx.bundle.js"></script>
    <script>
        function executeExportExcel() {
            var fileNameInput = document.getElementById("excelFileName").value;
            var fileName = fileNameInput.trim() === "" ? "ChiTietBaiThi_${sv.maSV}" : fileNameInput.trim();
            if (!fileName.endsWith(".xlsx")) fileName += ".xlsx";

            // Đóng modal
            var excelModalElement = document.getElementById('excelModal');
            var modalInstance = bootstrap.Modal.getInstance(excelModalElement);
            if (modalInstance) {
                modalInstance.hide();
            }

            var originalTable = document.querySelector(".printable-table");
            var clonedTable = originalTable.cloneNode(true);
            var thead = clonedTable.querySelector("thead");

            var r4 = thead.insertRow(0); r4.insertCell(0).colSpan = 9; // Empty
            var r3 = thead.insertRow(0);
            var c3 = r3.insertCell(0); c3.colSpan = 9;
            c3.innerHTML = "Ngày thi: ${ngayThi} - Điểm: ${diem}";
            var r2 = thead.insertRow(0);
            var c2 = r2.insertCell(0); c2.colSpan = 9;
            c2.innerHTML = "Môn: ${monHoc.tenMH} - Lần thi: ${lan}";
            var r1 = thead.insertRow(0);
            var c1 = r1.insertCell(0); c1.colSpan = 9;
            c1.innerHTML = "Họ tên: ${sv.ho} ${sv.ten} - Lớp: ${lop.tenLop} - MASV: ${sv.maSV}";
            var r0 = thead.insertRow(0);
            var c0 = r0.insertCell(0); c0.colSpan = 9;
            c0.innerHTML = "CHI TIẾT KẾT QUẢ BÀI THI";

            var wb = XLSX.utils.table_to_book(clonedTable, {sheet: "ChiTietKetQua"});
            var ws = wb.Sheets["ChiTietKetQua"];
            
            // Format Tiêu đề chính
            if(ws["A1"]) {
                ws["A1"].s = {
                    font: { name: "Arial", sz: 16, bold: true, color: { rgb: "FF0070C0" } }, // Màu xanh dương
                    alignment: { horizontal: "center", vertical: "center" }
                };
            }
            
            // Format các dòng thông tin phụ
            if(ws["A2"]) ws["A2"].s = { font: { bold: true, sz: 12 } };
            if(ws["A3"]) ws["A3"].s = { font: { bold: true, sz: 12 } };
            if(ws["A4"]) ws["A4"].s = { font: { bold: true, sz: 12, color: { rgb: "FFFF0000" } } }; // Điểm màu đỏ

            // Format tiêu đề bảng (Dòng 6)
            var range = XLSX.utils.decode_range(ws['!ref']);
            for(var C = range.s.c; C <= range.e.c; ++C) {
                var address = XLSX.utils.encode_col(C) + "6";
                if(!ws[address]) continue;
                ws[address].s = {
                    font: { bold: true, color: { rgb: "FFFFFFFF" } },
                    fill: { fgColor: { rgb: "FF343A40" } }, // Màu xám đen
                    alignment: { horizontal: "center", vertical: "center" },
                    border: {
                        top: { style: "thin", color: { rgb: "FF000000" } },
                        bottom: { style: "thin", color: { rgb: "FF000000" } },
                        left: { style: "thin", color: { rgb: "FF000000" } },
                        right: { style: "thin", color: { rgb: "FF000000" } }
                    }
                };
            }

            ws['!cols'] = [
                {wch: 6},  // STT
                {wch: 15}, // Câu số (trong bộ đề)
                {wch: 65}, // Nội dung
                {wch: 25}, // A
                {wch: 25}, // B
                {wch: 25}, // C
                {wch: 25}, // D
                {wch: 12}, // Trả lời
                {wch: 12}  // Đáp án
            ];

            XLSX.writeFile(wb, fileName);
        }
    </script>
</body>
</html>
