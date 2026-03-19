<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<nav class="navbar navbar-expand-lg navbar-dark bg-primary">
    <div class="container-fluid">
        <a class="navbar-brand" href="#">Thi Trắc Nghiệm</a>
        <button class="navbar-toggler" type="button" 
                data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav me-auto">

                <!-- Menu PGV -->
                <c:if test="${sessionScope.role == 'PGV'}">
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" 
                           data-bs-toggle="dropdown">Quản lý</a>
                        <ul class="dropdown-menu">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/pgv/monhoc.htm">Môn học</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/pgv/lop.htm">Lớp & Sinh viên</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/pgv/giaovien.htm">Giáo viên</a></li>
                        </ul>
                    </li>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" 
                           data-bs-toggle="dropdown">Thi</a>
                        <ul class="dropdown-menu">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/gv/bode.htm">Bộ đề</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/gv/dangkythi.htm">Đăng ký thi</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/gv/bangdiem.htm">Bảng điểm</a></li>
                        </ul>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/pgv/taikhoan.htm">Tài khoản</a>
                    </li>
                </c:if>

                <!-- Menu GIAOVIEN -->
                <c:if test="${sessionScope.role == 'GIAOVIEN'}">
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/gv/bode.htm">Bộ đề</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/gv/dangkythi.htm">Đăng ký thi</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/gv/bangdiem.htm">Bảng điểm</a>
                    </li>
                </c:if>

                <!-- Menu SINHVIEN -->
                <c:if test="${sessionScope.role == 'SINHVIEN'}">
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/sv/thi.htm">Thi</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/sv/ketqua.htm">Xem kết quả</a>
                    </li>
                </c:if>

            </ul>

            <!-- Thông tin user bên phải -->
            <ul class="navbar-nav">
                <li class="nav-item">
                    <span class="nav-link text-white">
                        Xin chào: <strong>${sessionScope.username}</strong>
                        (${sessionScope.role})
                    </span>
                </li>
                <li class="nav-item">
                    <a class="nav-link" 
                       href="${pageContext.request.contextPath}/logout.htm">
                       Đăng xuất
                    </a>
                </li>
            </ul>
        </div>
    </div>
</nav>