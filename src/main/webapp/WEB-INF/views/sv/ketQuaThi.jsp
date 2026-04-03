<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kết Quả Thi - Hệ Thống Thi Trắc Nghiệm</title>
    
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    
    <style>
        body { background-color: #f8f9fa; }
        .main-card { border: none; border-radius: 15px; }
        .card-header { 
            background: linear-gradient(to right, #007bff, #0056b3); 
            border-radius: 15px 15px 0 0 !important; 
        }
        .info-box { background-color: #ffffff; padding: 15px; border-radius: 10px; border-left: 5px solid #007bff; }
        .table thead { background-color: #e9ecef; }
        .score-text { color: #d9534f; font-weight: bold; font-size: 1.1rem; }
    </style>
</head>
<body>

    <div class="container py-5">
        <div class="card main-card shadow">
            <div class="card-header text-white py-3">
                <h3 class="text-center mb-0 text-uppercase">Phiếu Kết Quả Thi</h3>
            </div>
            
            <div class="card-body p-4">
                <div class="info-box mb-4 shadow-sm">
                    <div class="row">
                        <div class="col-md-6">
                            <p class="mb-1"><strong>Họ và tên:</strong> <span class="text-primary">${hoTen}</span></p>
                            <p class="mb-0"><strong>Mã sinh viên:</strong> <span>${maSV}</span></p>
                        </div>
                        <div class="col-md-6 text-md-right mt-2 mt-md-0">
                            <p class="mb-0"><strong>Lớp:</strong> <span class="badge badge-secondary p-2">${lop}</span></p>
                        </div>
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="table table-hover table-bordered text-center align-middle">
                        <thead>
                            <tr>
                                <th width="5%">STT</th>
                                <th width="15%">Mã Môn</th>
                                <th>Tên Môn Học</th>
                                <th width="15%">Ngày Thi</th>
                                <th width="10%">Lần Thi</th>
                                <th width="10%">Điểm</th>
                                <th width="15%">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty dsKetQua}">
                                    <tr>
                                        <td colspan="7" class="py-5 text-muted">
                                            <i class="fas fa-folder-open fa-3x mb-3 d-block"></i>
                                            Bạn chưa tham gia bất kỳ kỳ thi nào.
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="kq" items="${dsKetQua}" varStatus="status">
                                        <tr>
                                            <td>${status.index + 1}</td>
                                            <td><span class="font-weight-bold">${kq.MAMH}</span></td>
                                            <td class="text-left">${kq.TENMH}</td>
                                            <td>
                                                <fmt:formatDate value="${kq.NGAYTHI}" pattern="dd/MM/yyyy" />
                                            </td>
                                            <td>
                                                <span class="badge badge-info px-3">Lần ${kq.LAN}</span>
                                            </td>
                                            <td>
                                                <span class="score-text">${kq.DIEM}</span>
                                            </td>
                                            <td>
                                                <a href="chi-tiet-bai-thi.htm?mamh=${kq.MAMH}&lan=${kq.LAN}" 
                                                   class="btn btn-sm btn-outline-primary shadow-sm">
                                                   <i class="fas fa-search-plus"></i> Chi tiết
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <div class="text-center mt-4">
                    <a href="home.htm" class="btn btn-secondary px-4 shadow-sm">
                        <i class="fas fa-arrow-left mr-2"></i> Quay lại trang chủ
                    </a>
                </div>
            </div>
            
            <div class="card-footer text-center text-muted small py-3 bg-white">
                Hệ thống thi trắc nghiệm &copy; 2026 - Skin AI System
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/jquery@3.5.1/dist/jquery.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>