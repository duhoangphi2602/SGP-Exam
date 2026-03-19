<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Tạo tài khoản</title>
    <link rel="stylesheet" 
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body>
    <%@ include file="../common/navbar.jsp" %>
    <div class="container mt-4">
        <h3>TẠO TÀI KHOẢN ĐĂNG NHẬP CHƯƠNG TRÌNH</h3>
        <hr>

        <% String msg = (String) session.getAttribute("successMsg");
           if (msg != null) { session.removeAttribute("successMsg"); %>
            <div class="alert alert-success alert-dismissible fade show">
                <%= msg %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <c:if test="${error != null}">
            <div class="alert alert-danger">${error}</div>
        </c:if>

        <form action="taikhoan-them.htm" method="post" class="col-md-6">

            <!-- Họ tên + Mã GV -->
            <div class="mb-3 row align-items-center">
                <label class="col-sm-3 col-form-label">Họ tên</label>
                <div class="col-sm-6">
                    <select id="dsGV" name="maGV" class="form-select" 
                            onchange="chonGV(this)" required>
                        <option value="">-- Chọn giáo viên --</option>
                        <c:forEach var="gv" items="${dsGV}">
                            <option value="${gv.maGV}" 
                                    data-ten="${gv.ho} ${gv.ten}">
                                ${gv.ho} ${gv.ten}
                            </option>
                        </c:forEach>
                    </select>
                </div>
                <label class="col-sm-1 col-form-label">Mã NV</label>
                <div class="col-sm-2">
                    <input type="text" id="maGVHienThi" 
                           class="form-control" readonly/>
                </div>
            </div>

            <!-- Thông báo đã có tài khoản -->
            <div id="thongBaoTK" class="mb-3" style="display:none">
                <div class="alert alert-warning">
                    ⚠️ Nhân viên này đã có tài khoản với nhóm quyền: 
                    <strong id="roleHienTai"></strong>
                </div>
            </div>

            <!-- Form nhập tài khoản -->
            <div id="formTaiKhoan">
                <div class="mb-3 row">
                    <label class="col-sm-3 col-form-label">Tài khoản</label>
                    <div class="col-sm-6">
                        <input type="text" name="taiKhoan" id="taiKhoan"
                               class="form-control"/>
                    </div>
                </div>
                <div class="mb-3 row">
                    <label class="col-sm-3 col-form-label">Mật mã</label>
                    <div class="col-sm-6">
                        <input type="password" name="matMa" id="matMa"
                               class="form-control"/>
                    </div>
                </div>
                <div class="mb-3 row">
                    <label class="col-sm-3 col-form-label">Nhóm quyền</label>
                    <div class="col-sm-6">
                        <select name="nhomQuyen" id="nhomQuyen" class="form-select">
                            <option value="">-- Chọn nhóm --</option>
                            <option value="PGV">PGV</option>
                            <option value="GIAOVIEN">GIAOVIEN</option>
                        </select>
                    </div>
                </div>
            </div>

            <div class="mt-3">
                <button type="submit" id="btnTao"
                        class="btn btn-warning me-2">Tạo tài khoản</button>
                <a href="home.htm" class="btn btn-secondary">Thoát</a>
            </div>
        </form>
    </div>

<script>
function chonGV(select) {
    var maGV = select.value;
    var maGVHienThi = document.getElementById('maGVHienThi');
    var thongBaoTK = document.getElementById('thongBaoTK');
    var formTaiKhoan = document.getElementById('formTaiKhoan');
    var btnTao = document.getElementById('btnTao');

    if (!maGV) {
        maGVHienThi.value = '';
        thongBaoTK.style.display = 'none';
        formTaiKhoan.style.display = 'block';
        return;
    }

    // Hiện mã GV
    maGVHienThi.value = maGV.trim();

    // Kiểm tra đã có tài khoản chưa
    fetch('taikhoan-check.htm?maGV=' + maGV)
        .then(response => response.text())
        .then(data => {
            if (data === 'CHUA_CO') {
                // Chưa có tài khoản → hiện form
                thongBaoTK.style.display = 'none';
                formTaiKhoan.style.display = 'block';
                btnTao.disabled = false;

                // Gợi ý tài khoản = maGV
                document.getElementById('taiKhoan').value = maGV.trim();
                document.getElementById('nhomQuyen').value = 'GIAOVIEN';
            } else {
                // Đã có tài khoản → ẩn form, hiện cảnh báo
                thongBaoTK.style.display = 'block';
                document.getElementById('roleHienTai').innerText = data;
                formTaiKhoan.style.display = 'none';
                btnTao.disabled = true;
            }
        });
}
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
