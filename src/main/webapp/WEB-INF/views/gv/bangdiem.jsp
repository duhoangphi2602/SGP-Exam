<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Xem Bảng Điểm</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body>
    <%@ include file="../common/navbar.jsp" %>
    <div class="container mt-4">
        <h4 class="text-primary fw-bold">TRA CỨU BẢNG ĐIỂM LỚP</h4>
        <hr>

        <!-- Form chọn điều kiện lọc -->
        <div class="card shadow-sm mb-4">
            <div class="card-body bg-light">
                <form action="${pageContext.request.contextPath}/gv/bangdiem.htm" method="GET" class="row g-3 align-items-end">
                    
                    <div class="col-md-4">
                        <label class="form-label fw-bold">Chọn Lớp</label>
                        <select name="maLop" class="form-select" required>
                            <option value="">-- Chọn Lớp --</option>
                            <c:forEach var="lop" items="${dsLop}">
                                <option value="${lop.maLop}" ${maLopSelected == lop.maLop.trim() ? 'selected' : ''}>
                                    ${lop.maLop} - ${lop.tenLop}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="col-md-4">
                        <label class="form-label fw-bold">Chọn Môn Học</label>
                        <select name="maMH" class="form-select" required>
                            <option value="">-- Chọn Môn --</option>
                            <c:forEach var="mh" items="${dsMH}">
                                <option value="${mh.maMH}" ${maMHSelected == mh.maMH.trim() ? 'selected' : ''}>
                                    ${mh.maMH} - ${mh.tenMH}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="col-md-2">
                        <label class="form-label fw-bold">Lần thi</label>
                        <select name="lan" class="form-select" required>
                            <option value="1" ${lanSelected == 1 ? 'selected' : ''}>Lần 1</option>
                            <option value="2" ${lanSelected == 2 ? 'selected' : ''}>Lần 2</option>
                        </select>
                    </div>

                    <div class="col-md-2">
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="bi bi-search"></i> Xem điểm
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Bảng hiển thị điểm -->
        <c:if test="${bangDiem != null}">
            <div class="d-flex justify-content-between align-items-center mt-4 mb-3">
                <h5 class="mb-0">Kết quả bảng điểm môn học:</h5>
                <div class="d-flex gap-2 d-print-none">
                    <button type="button" class="btn btn-success" data-bs-toggle="modal" data-bs-target="#excelModal">
                        <i class="bi bi-file-earmark-excel"></i> Xuất Excel
                    </button>
                </div>
            </div>
            
            <div class="table-responsive">
                <table class="table table-bordered table-hover shadow-sm printable-table">
                    <thead class="table-dark">
                        <tr>
                            <th width="5%" class="text-center">STT</th>
                            <th width="10%" class="text-center">MASV</th>
                            <th width="30%">HO</th>
                            <th width="15%">TEN</th>
                            <th width="12%" class="text-center">ĐIỂM</th>
                            <th width="13%" class="text-center">ĐIỂM CHỮ</th>
                            <th width="15%" class="text-center d-print-none">THAO TÁC</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="sv" items="${bangDiem}" varStatus="loop">
                            <tr>
                                <td class="text-center align-middle">${loop.index + 1}</td>
                                <td class="text-center align-middle fw-bold">${sv.MASV}</td>
                                <td class="align-middle">${sv.HO}</td>
                                <td class="align-middle">${sv.TEN}</td>
                                
                                <c:choose>
                                    <c:when test="${sv.DIEM != null}">
                                        <td class="text-center align-middle fs-5 fw-bold text-danger">${sv.DIEM}</td>
                                        <td class="text-center align-middle fw-bold text-primary">${sv.DIEM_CHU}</td>
                                    </c:when>
                                    <c:otherwise>
                                        <td class="text-center align-middle fst-italic text-muted">-</td>
                                        <td class="text-center align-middle text-secondary fst-italic">-</td>
                                    </c:otherwise>
                                </c:choose>
                                
                                <td class="text-center align-middle d-print-none">
                                    <a href="${pageContext.request.contextPath}/gv/ketqua-chitiet.htm?maSV=${sv.MASV.trim()}&maMH=${maMHSelected}&lan=${lanSelected}" class="btn btn-sm btn-info text-white" title="Xem chi tiết">
                                        <i class="bi bi-eye"></i> Chi tiết
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty bangDiem}">
                            <tr>
                                <td colspan="7" class="text-center py-4 text-danger fw-bold">
                                    Không tìm thấy sinh viên nào trong lớp này! (Hoặc ca thi chưa kết thúc / Bạn không có quyền truy cập)
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </c:if>
    </div>
    
    <style>
        .table-dark { color: #000 !important; background-color: #f8f9fa !important; }
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
                <input type="text" class="form-control" id="excelFileName" value="BangDiem_Lop_${maLopSelected}_Mon_${maMHSelected}_Lan_${lanSelected}">
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
            var fileName = fileNameInput.trim() === "" ? "BangDiem_Lop_${maLopSelected}" : fileNameInput.trim();
            if (!fileName.endsWith(".xlsx")) fileName += ".xlsx";

            // Đóng modal
            var excelModalElement = document.getElementById('excelModal');
            var modalInstance = bootstrap.Modal.getInstance(excelModalElement);
            if (modalInstance) {
                modalInstance.hide();
            }

            // Clone table to add headers without affecting UI
            var originalTable = document.querySelector(".printable-table");
            var clonedTable = originalTable.cloneNode(true);
            var thead = clonedTable.querySelector("thead");

            // Prevent '007' from becoming '7' by forcing MASV column to be string
            var rows = clonedTable.querySelectorAll("tbody tr");
            rows.forEach(function(row) {
                var masvCell = row.cells[1];
                if(masvCell) masvCell.setAttribute("t", "s"); // t="s" forces string type in SheetJS
            });

            // Insert title and info rows (in reverse order to keep them at top)
            var r3 = thead.insertRow(0); r3.insertCell(0).colSpan = 6; // Empty row
            var r2 = thead.insertRow(0); 
            var c2 = r2.insertCell(0); c2.colSpan = 6;
            c2.innerHTML = "Môn học: ${maMHSelected} - Lần thi: ${lanSelected}";
            var r1 = thead.insertRow(0);
            var c1 = r1.insertCell(0); c1.colSpan = 6;
            c1.innerHTML = "BẢNG ĐIỂM LỚP ${maLopSelected}";

            // Export to Excel
            var wb = XLSX.utils.table_to_book(clonedTable, {sheet: "BangDiem"});
            var ws = wb.Sheets["BangDiem"];
            
            // Format Tiêu đề chính
            if(ws["A1"]) {
                ws["A1"].s = {
                    font: { name: "Arial", sz: 16, bold: true, color: { rgb: "FF0070C0" } }, // Màu xanh dương
                    alignment: { horizontal: "center", vertical: "center" }
                };
            }
            
            // Format Tiêu đề phụ
            if(ws["A2"]) ws["A2"].s = { font: { bold: true, sz: 12 } };

            // Format tiêu đề bảng (Dòng 4)
            var range = XLSX.utils.decode_range(ws['!ref']);
            for(var C = range.s.c; C <= range.e.c; ++C) {
                var address = XLSX.utils.encode_col(C) + "4";
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

            // Set column widths
            ws['!cols'] = [
                {wch: 6},  // STT
                {wch: 15}, // MASV
                {wch: 25}, // HO
                {wch: 15}, // TEN
                {wch: 12}, // DIEM
                {wch: 15}  // DIEM CHU
            ];

            XLSX.writeFile(wb, fileName);
        }
    </script>
</body>
</html>