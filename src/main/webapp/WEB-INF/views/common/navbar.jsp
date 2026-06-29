<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<nav class="navbar navbar-expand-lg navbar-dark bg-primary">
	<div class="container-fluid">
		<c:choose>
			<c:when test="${sessionScope.role == 'PGV'}">
				<a class="navbar-brand fw-bold"
					href="${pageContext.request.contextPath}/pgv/home.htm">Thi Trắc
					Nghiệm</a>
			</c:when>
			<c:when test="${sessionScope.role == 'GIAOVIEN'}">
				<a class="navbar-brand fw-bold"
					href="${pageContext.request.contextPath}/gv/home.htm">Thi Trắc
					Nghiệm</a>
			</c:when>
			<c:when test="${sessionScope.role == 'SINHVIEN'}">
				<a class="navbar-brand fw-bold"
					href="${pageContext.request.contextPath}/sv/home.htm">Thi Trắc
					Nghiệm</a>
			</c:when>
			<c:otherwise>
				<a class="navbar-brand fw-bold"
					href="${pageContext.request.contextPath}/login.htm">Thi Trắc
					Nghiệm</a>
			</c:otherwise>
		</c:choose>
		<button class="navbar-toggler" type="button" data-bs-toggle="collapse"
			data-bs-target="#navbarNav">
			<span class="navbar-toggler-icon"></span>
		</button>
		<div class="collapse navbar-collapse" id="navbarNav">
			<ul class="navbar-nav me-auto">

				<!-- Menu PGV -->
				<c:if test="${sessionScope.role == 'PGV'}">
					<li class="nav-item dropdown"><a
						class="nav-link dropdown-toggle" href="#"
						data-bs-toggle="dropdown">Quản lý</a>
						<ul class="dropdown-menu">
							<li><a class="dropdown-item"
								href="${pageContext.request.contextPath}/pgv/monhoc.htm">Môn
									học</a></li>
							<li><a class="dropdown-item"
								href="${pageContext.request.contextPath}/pgv/lop.htm">Lớp &
									Sinh viên</a></li>
							<li><a class="dropdown-item"
								href="${pageContext.request.contextPath}/pgv/giaovien.htm">Giáo
									viên</a></li>
						</ul></li>
					<li class="nav-item dropdown"><a
						class="nav-link dropdown-toggle" href="#"
						data-bs-toggle="dropdown">Thi</a>
						<ul class="dropdown-menu">
							<li><a class="dropdown-item"
								href="${pageContext.request.contextPath}/gv/bode.htm">Bộ đề</a></li>
							<li><a class="dropdown-item"
								href="${pageContext.request.contextPath}/gv/dangkythi.htm">Đăng
									ký thi</a></li>
							<li><a class="dropdown-item"
								href="${pageContext.request.contextPath}/gv/bangdiem.htm">Bảng
									điểm</a></li>
						</ul></li>
					<li class="nav-item"><a class="nav-link"
						href="${pageContext.request.contextPath}/pgv/taikhoan.htm">Tài
							khoản</a></li>
				</c:if>

				<!-- Menu GIAOVIEN -->
				<c:if test="${sessionScope.role == 'GIAOVIEN'}">
					<li class="nav-item"><a class="nav-link"
						href="${pageContext.request.contextPath}/gv/bode.htm">Bộ đề</a></li>
					<li class="nav-item"><a class="nav-link"
						href="${pageContext.request.contextPath}/gv/dangkythi.htm">Đăng
							ký thi</a></li>
					<li class="nav-item"><a class="nav-link"
						href="${pageContext.request.contextPath}/gv/thi-thu.htm">Thi
							thử</a></li>
					<li class="nav-item"><a class="nav-link"
						href="${pageContext.request.contextPath}/gv/bangdiem.htm">Bảng
							điểm</a></li>
				</c:if>

				<!-- Menu SINHVIEN -->
				<c:if test="${sessionScope.role == 'SINHVIEN'}">
					<li class="nav-item"><a class="nav-link"
						href="${pageContext.request.contextPath}/sv/thi.htm">Thi</a></li>
					<li class="nav-item"><a class="nav-link"
						href="${pageContext.request.contextPath}/sv/ketqua.htm">Xem
							kết quả</a></li>
					<li class="nav-item"><a class="nav-link"
						href="${pageContext.request.contextPath}/sv/doiMatKhau.htm">Đổi
							mật khẩu</a></li>
				</c:if>

			</ul>

			<!-- Thông tin user bên phải -->
			<ul class="navbar-nav">
				<li class="nav-item"><span class="nav-link text-white">
						${sessionScope.hoTen} - ${sessionScope.role} </span></li>
				<li class="nav-item"><a class="nav-link"
					href="${pageContext.request.contextPath}/logout.htm"> Đăng xuất
				</a></li>
			</ul>
		</div>
	</div>
</nav>

<!-- Global Confirm Modal -->
<div class="modal fade" id="globalConfirmModal" tabindex="-1" aria-labelledby="globalConfirmModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="globalConfirmModalLabel">Xác nhận</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <p id="globalConfirmMessage">Bạn có chắc chắn muốn thực hiện thao tác này?</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
        <button type="button" class="btn btn-primary" id="globalConfirmBtn">Đồng ý</button>
      </div>
    </div>
  </div>
</div>

<script>
    var confirmCallback = null;
    
    function showConfirmModal(message, callback) {
        document.getElementById('globalConfirmMessage').innerText = message;
        confirmCallback = callback;
        
        var modalEl = document.getElementById('globalConfirmModal');
        // Tránh lỗi chưa load bootstrap ở một số trang
        if (typeof bootstrap !== 'undefined') {
            var modal = bootstrap.Modal.getOrCreateInstance(modalEl);
            modal.show();
        }
    }
    
    document.addEventListener("DOMContentLoaded", function() {
        var btnConfirm = document.getElementById('globalConfirmBtn');
        if (btnConfirm) {
            btnConfirm.addEventListener('click', function() {
                if (typeof bootstrap !== 'undefined') {
                    var modal = bootstrap.Modal.getInstance(document.getElementById('globalConfirmModal'));
                    if (modal) modal.hide();
                }
                if (confirmCallback) {
                    confirmCallback();
                    confirmCallback = null;
                }
            });
        }
    });
</script>

<!-- Global Alert Modal -->
<div class="modal fade" id="globalAlertModal" tabindex="-1" aria-labelledby="globalAlertModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="globalAlertModalLabel">Thông báo</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <p id="globalAlertMessage"></p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-primary" data-bs-dismiss="modal">Đóng</button>
      </div>
    </div>
  </div>
</div>

<script>
    function showAlertModal(message) {
        document.getElementById('globalAlertMessage').innerText = message;
        
        var modalEl = document.getElementById('globalAlertModal');
        if (typeof bootstrap !== 'undefined') {
            var modal = bootstrap.Modal.getOrCreateInstance(modalEl);
            modal.show();
        } else {
            alert(message); // Fallback nếu chưa load bootstrap
        }
    }
</script>