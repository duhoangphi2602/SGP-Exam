<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Bảng Điểm Môn Học</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .form-container { margin-bottom: 20px; padding: 15px; border: 1px solid #ccc; background-color: #f4f4f4; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: center; }
        th { background-color: #007bff; color: white; }
        .text-left { text-align: left; }
    </style>
</head>
<body>
    <%-- <jsp:include page="../common/navbar.jsp" /> --%>

    <h2>BẢNG ĐIỂM TỔNG KẾT MÔN HỌC</h2>

    <div class="form-container">
        <form action="${pageContext.request.contextPath}/gv/bang-diem.htm" method="GET">
            <label>Lớp: </label>
            <select name="maLop">
                <c:forEach var="lop" items="${danhSachLop}">
                    <option value="${lop}" ${lop == selectedLop ? 'selected' : ''}>${lop}</option>
                </c:forEach>
            </select>
            
            <label style="margin-left: 20px;">Môn thi: </label>
            <select name="maMon">
                <c:forEach var="mon" items="${danhSachMon}">
                    <option value="${mon}" ${mon == selectedMon ? 'selected' : ''}>${mon}</option>
                </c:forEach>
            </select>

            <label style="margin-left: 20px;">Lần thi: </label>
            <select name="lanThi">
                <option value="1" ${selectedLanThi == 1 ? 'selected' : ''}>1</option>
                <option value="2" ${selectedLanThi == 2 ? 'selected' : ''}>2</option>
            </select>

            <button type="submit" style="margin-left: 20px; padding: 5px 15px;">Xem điểm</button>
        </form>
    </div>

    <c:if test="${not empty bangDiem}">
        <table>
            <thead>
                <tr>
                    <th>STT</th>
                    <th>MÃ SINH VIÊN</th>
                    <th class="text-left">HỌ VÀ TÊN</th>
                    <th>ĐIỂM</th>
                    <th>ĐIỂM CHỮ</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="sv" items="${bangDiem}">
                    <tr>
                        <td>${sv.stt}</td>
                        <td>${sv.maSV}</td>
                        <td class="text-left">${sv.hoTen}</td>
                        <td>${sv.diem}</td>
                        <td>${sv.diemChu}</td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
        <br>
        <button onclick="window.print()">In bảng điểm</button>
    </c:if>

</body>
</html>