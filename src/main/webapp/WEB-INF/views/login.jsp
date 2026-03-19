<%@ page contentType="text/html;charset=UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Đăng nhập</title>
    <link rel="stylesheet" 
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="bg-light">
<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-4">
            <div class="card shadow">
                <div class="card-header text-center bg-primary text-white">
                    <h4>Hệ thống Thi Trắc Nghiệm</h4>
                </div>
                <div class="card-body">

                    <% if(request.getAttribute("error") != null) { %>
                        <div class="alert alert-danger">${error}</div>
                    <% } %>

                    <form action="login.htm" method="post">

                        <!-- Radio chọn loại người dùng -->
                        <div class="mb-3 d-flex gap-4">
                            <div class="form-check">
                                <input class="form-check-input" type="radio" 
                                       name="loai" id="rdSV" value="SINHVIEN" checked
                                       onclick="doiLabel()"/>
                                <label class="form-check-label" for="rdSV">Sinh Viên</label>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input" type="radio" 
                                       name="loai" id="rdGV" value="GIAOVIEN"
                                       onclick="doiLabel()"/>
                                <label class="form-check-label" for="rdGV">Giảng Viên</label>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label id="lblLogin" class="form-label">Mã SV</label>
                            <input type="text" name="username" 
                                   class="form-control" required/>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Mật khẩu</label>
                            <input type="password" name="password" 
                                   class="form-control" required/>
                        </div>
                        <button type="submit" 
                                class="btn btn-primary w-100">Đăng nhập</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
function doiLabel() {
    var loai = document.querySelector('input[name="loai"]:checked').value;
    var lblLogin = document.getElementById('lblLogin');
    if (loai === 'SINHVIEN') {
        lblLogin.innerText = 'Mã SV';
    } else {
        lblLogin.innerText = 'Login';
    }
}
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>