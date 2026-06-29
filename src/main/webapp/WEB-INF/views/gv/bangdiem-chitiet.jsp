<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Chi Tiết Bảng Điểm</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <style>
        @media print {
            @page { size: landscape; margin: 10mm; }
            body { font-size: 11pt; color: #000; }
            .d-print-none { display: none !important; }
            .navbar { display: none !important; }
            .container { max-width: 100%; margin: 0; padding: 0; }
            .printable-table { border-collapse: collapse !important; width: 100%; }
            .printable-table th, .printable-table td {
                border: 1px solid #000 !important;
                padding: 6px !important;
            }
            .table-dark {
                color: #000 !important;
                background-color: #f8f9fa !important;
                -webkit-print-color-adjust: exact;
            }
        }
    </style>
    <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/favicon.svg" />
</head>
<body>
    <%@ include file="../common/navbar.jsp" %>
    <div class="container mt-4">

        <!-- Nút quay lại + xuất -->
        <div class="d-flex justify-content-between align-items-center mb-3 d-print-none">
            <a href="${pageContext.request.contextPath}/gv/bangdiem.htm"
               class="btn btn-secondary">&larr; Quay lại danh sách</a>
            <div class="d-flex gap-2">
                <button type="button" class="btn btn-success"
                        data-bs-toggle="modal" data-bs-target="#excelModal">
                    Xuất Excel
                </button>
                <button type="button" class="btn btn-outline-secondary"
                        onclick="window.print()">In bảng điểm</button>
            </div>
        </div>

        <!-- Tiêu đề -->
        <h4 class="text-primary fw-bold text-center">BẢNG ĐIỂM</h4>
        <p class="text-center mb-1">
            <strong>Lớp:</strong> ${maLop} &nbsp;|&nbsp;
            <strong>Môn:</strong> ${maMH} &nbsp;|&nbsp;
            <strong>Lần thi:</strong> ${lan}
        </p>
        <hr>

        <!-- Bảng điểm -->
        <c:choose>
            <c:when test="${empty bangDiem}">
                <div class="alert alert-warning">
                    Không có dữ liệu. Ca thi này chưa diễn ra hoặc bạn không có quyền xem.
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-responsive">
                    <table class="table table-bordered table-hover shadow-sm printable-table">
                        <thead class="table-dark">
                            <tr>
                                <th class="text-center" width="5%">STT</th>
                                <th class="text-center" width="10%">Mã SV</th>
                                <th width="30%">Họ</th>
                                <th width="15%">Tên</th>
                                <th class="text-center" width="12%">Điểm</th>
                                <th class="text-center" width="13%">Điểm chữ</th>
                                <th class="text-center d-print-none" width="15%">THAO TÁC</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="sv" items="${bangDiem}" varStatus="loop">
                                <tr>
                                    <td class="text-center align-middle">${loop.index + 1}</td>
                                    <td class="text-center align-middle fw-bold" data-t="s">${sv.MASV}</td>
                                    <td class="align-middle">${sv.HO}</td>
                                    <td class="align-middle">${sv.TEN}</td>
                                    <c:choose>
                                        <c:when test="${sv.DIEM != null}">
                                            <td class="text-center align-middle fs-5 fw-bold text-danger">
                                                ${sv.DIEM}
                                            </td>
                                            <td class="text-center align-middle fw-bold text-primary">
                                                ${sv.DIEM_CHU}
                                            </td>
                                        </c:when>
                                        <c:otherwise>
                                            <td class="text-center align-middle fst-italic text-muted">-</td>
                                            <td class="text-center align-middle fst-italic text-muted">-</td>
                                        </c:otherwise>
                                    </c:choose>
                                    <td class="text-center align-middle d-print-none">
                                        <a href="${pageContext.request.contextPath}/gv/ketqua-chitiet.htm?maSV=${sv.MASV.trim()}&maMH=${maMH}&lan=${lan}" class="btn btn-sm btn-info text-white" title="Xem chi tiết">
                                            <i class="bi bi-eye"></i> Chi tiết
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Modal tên file Excel -->
    <div class="modal fade" id="excelModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title">Xuất Excel</h5>
                    <button type="button" class="btn-close btn-close-white"
                            data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <label class="form-label fw-bold">Tên file:</label>
                    <input type="text" class="form-control" id="excelFileName"
                           value="BangDiem_${maLop}_${maMH}_Lan${lan}">
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary"
                            data-bs-dismiss="modal">Hủy</button>
                    <button type="button" class="btn btn-success"
                            onclick="xuatExcel()">Xuất</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/xlsx-js-style@1.2.0/dist/xlsx.bundle.js"></script>
    <script>
    function xuatExcel() {
        var fileName = document.getElementById('excelFileName').value.trim();
        if (!fileName) fileName = 'BangDiem';
        if (!fileName.endsWith('.xlsx')) fileName += '.xlsx';

        var modal = bootstrap.Modal.getInstance(document.getElementById('excelModal'));
        if (modal) modal.hide();

        var originalTable = document.querySelector('.printable-table');
        var clonedTable = originalTable.cloneNode(true);
        var thead = clonedTable.querySelector("thead");
        
        var r3 = thead.insertRow(0); r3.insertCell(0).colSpan = 7;
        var r2 = thead.insertRow(0);
        var c2 = r2.insertCell(0); c2.colSpan = 7;
        c2.innerHTML = "Môn: ${maMH} - Lần thi: ${lan}";
        var r1 = thead.insertRow(0);
        var c1 = r1.insertCell(0); c1.colSpan = 7;
        c1.innerHTML = "Lớp: ${maLop}";
        var r0 = thead.insertRow(0);
        var c0 = r0.insertCell(0); c0.colSpan = 7;
        c0.innerHTML = "BẢNG ĐIỂM";

        var wb = XLSX.utils.table_to_book(clonedTable, { sheet: 'BangDiem' });
        var ws = wb.Sheets['BangDiem'];
        
        for (var i in ws) {
            if (typeof ws[i] != 'object') continue;
            var cell = XLSX.utils.decode_cell(i);
            ws[i].s = {
                font: { name: "Times New Roman", sz: 12 },
                alignment: { vertical: "center" },
                border: {
                    top: {style:'thin'}, bottom: {style:'thin'},
                    left: {style:'thin'}, right: {style:'thin'}
                }
            };
            if (cell.r < 4) { // Headers
                ws[i].s.font.bold = true;
                ws[i].s.alignment.horizontal = "center";
                ws[i].s.border = {}; // No border
            }
            if (cell.r == 0) ws[i].s.font.sz = 16;
            if (cell.r == 4) { // Table header
                ws[i].s.font.bold = true;
                ws[i].s.fill = { fgColor: { rgb: "000000" } };
                ws[i].s.font.color = { rgb: "FFFFFF" };
                ws[i].s.alignment.horizontal = "center";
            }
        }
        ws['!cols'] = [ {wch: 6}, {wch: 12}, {wch: 30}, {wch: 15}, {wch: 10}, {wch: 12} ];

        XLSX.writeFile(wb, fileName);
    }
    </script>
</body>
</html>
