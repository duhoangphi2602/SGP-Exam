<%@ page contentType="text/html;charset=UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="google" content="notranslate">
<title>Đăng nhập</title>
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/favicon.svg" />
</head>
<body class="bg-light" spellcheck="false">
	<div class="container mt-5">
		<div class="row justify-content-center">
			<div class="col-md-4">
				<div class="card border-0 shadow-lg rounded-3">
					<div class="card-body p-4 p-md-5">
						<div class="text-center mb-4">
							<h4 class="fw-bold text-primary">Hệ thống Thi Trắc Nghiệm PTIT</h4>
							<p class="text-muted">Đăng nhập để tiếp tục</p>
						</div>

						<%
						if (request.getAttribute("error") != null) {
						%>
						<div class="alert alert-danger">${error}</div>
						<%
						}
						%>

						<form action="login.htm" method="post">

							<!-- Radio chọn loại người dùng -->
							<div class="mb-3 d-flex gap-4">
								<div class="form-check">
									<input class="form-check-input" type="radio" name="loai"
										id="rdSV" value="SINHVIEN" checked onclick="doiLabel()" /> <label
										class="form-check-label" for="rdSV">Sinh Viên</label>
								</div>
								<div class="form-check">
									<input class="form-check-input" type="radio" name="loai"
										id="rdGV" value="GIAOVIEN" onclick="doiLabel()" /> <label
										class="form-check-label" for="rdGV">Giảng Viên</label>
								</div>
							</div>

							<div class="mb-3">
								<label id="lblLogin" class="form-label fw-semibold">Mã SV</label> <input
									type="text" name="username" class="form-control py-2" required />
							</div>
							<div class="mb-4">
								<label class="form-label fw-semibold">Mật khẩu</label> <input
									type="password" name="password" class="form-control py-2" required />
							</div>
							<button type="submit" class="btn btn-primary w-100 py-2 fw-bold">ĐĂNG NHẬP</button>
							<!-- Chỉ hiện khi chọn Sinh Viên -->
							<div id="linkDangKy" class="text-center mt-2">
								<a href="dangky.htm">Đăng ký tài khoản</a>
							</div>
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
			var linkDangKy = document.getElementById('linkDangKy');

			if (loai === 'SINHVIEN') {
				lblLogin.innerText = 'Mã SV';
				linkDangKy.style.display = 'block';
			} else {
				lblLogin.innerText = 'Login';
				linkDangKy.style.display = 'none';
			}
		}

		// Chạy khi load trang
		doiLabel();
	</script>

	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>