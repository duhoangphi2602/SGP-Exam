<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="container mt-4">
    <h3 class="text-center">Chi Tiết Bài Thi: ${tenMon} (Lần ${lan})</h3>
    <hr>
    <c:forEach var="c" items="${dsCauHoi}">
        <div class="card mb-3 ${c.DACHON == c.DAP_AN ? 'border-success' : 'border-danger'}">
            <div class="card-header">
                <strong>Câu ${c.STT}:</strong> ${c.NOIDUNG}
            </div>
            <div class="card-body">
                <p>A. ${c.A}</p>
                <p>B. ${c.B}</p>
                <p>C. ${c.C}</p>
                <p>D. ${c.D}</p>
                <hr>
                <p class="${c.DACHON == c.DAP_AN ? 'text-success' : 'text-danger'}">
                    <strong>Đáp án bạn chọn:</strong> ${c.DACHON}
                </p>
                <p class="text-primary"><strong>Đáp án đúng:</strong> ${c.DAP_AN}</p>
            </div>
        </div>
    </c:forEach>
    <a href="xem-ket-qua.htm" class="btn btn-secondary">Quay lại danh sách</a>
</div>