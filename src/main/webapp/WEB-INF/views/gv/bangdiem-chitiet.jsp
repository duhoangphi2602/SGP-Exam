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
                                <th class="text-center" width="15%">Mã SV</th>
                                <th width="30%">Họ</th>
                                <th width="20%">Tên</th>
                                <th class="text-center" width="15%">Điểm</th>
                                <th class="text-center" width="15%">Điểm chữ</th>
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

        var table = document.querySelector('.printable-table');
        var wb = XLSX.utils.table_to_book(table, { sheet: 'BangDiem' });
        XLSX.writeFile(wb, fileName);
    }
    </script>
</body>
</html>
