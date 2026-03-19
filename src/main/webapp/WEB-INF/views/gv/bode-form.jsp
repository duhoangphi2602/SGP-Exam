<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ include file="../common/navbar.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Form Câu hỏi</title>
    <link rel="stylesheet" 
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="container mt-4">
    <h3>${action == 'them' ? 'Thêm' : 'Sửa'} câu hỏi</h3>

    <c:if test="${error != null}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <form action="${action == 'them' ? 'bode-them.htm' : 'bode-sua.htm'}" 
          method="post" class="col-md-7">

        <c:if test="${action == 'sua'}">
            <input type="hidden" name="cauHoi" value="${bd.cauHoi}"/>
        </c:if>

        <div class="mb-3">
            <label class="form-label">Môn học</label>
            <select name="maMH" class="form-select" 
                    ${action == 'sua' ? 'disabled' : 'required'}>
                <option value="">-- Chọn môn --</option>
                <c:forEach var="mh" items="${dsMonHoc}">
                    <option value="${mh.maMH}"
                        ${mh.maMH == bd.maMH ? 'selected' : ''}>
                        ${mh.tenMH}
                    </option>
                </c:forEach>
            </select>
            <c:if test="${action == 'sua'}">
                <input type="hidden" name="maMH" value="${bd.maMH}"/>
            </c:if>
        </div>

        <div class="mb-3">
            <label class="form-label">Trình độ</label>
            <select name="trinhDo" class="form-select"
                    ${action == 'sua' ? 'disabled' : 'required'}>
                <option value="">-- Chọn trình độ --</option>
                <option value="A" ${bd.trinhDo == 'A' ? 'selected' : ''}>A - ĐH Chuyên ngành</option>
                <option value="B" ${bd.trinhDo == 'B' ? 'selected' : ''}>B - ĐH Không chuyên</option>
                <option value="C" ${bd.trinhDo == 'C' ? 'selected' : ''}>C - Cao đẳng</option>
            </select>
            <c:if test="${action == 'sua'}">
                <input type="hidden" name="trinhDo" value="${bd.trinhDo}"/>
            </c:if>
        </div>

        <div class="mb-3">
            <label class="form-label">Nội dung câu hỏi</label>
            <textarea name="noiDung" class="form-control" 
                      rows="3" required>${bd.noiDung}</textarea>
        </div>

        <div class="mb-3">
            <label class="form-label">Đáp án A</label>
            <input type="text" name="a" value="${bd.a}" 
                   class="form-control" required/>
        </div>
        <div class="mb-3">
            <label class="form-label">Đáp án B</label>
            <input type="text" name="b" value="${bd.b}" 
                   class="form-control" required/>
        </div>
        <div class="mb-3">
            <label class="form-label">Đáp án C</label>
            <input type="text" name="c" value="${bd.c}" 
                   class="form-control" required/>
        </div>
        <div class="mb-3">
            <label class="form-label">Đáp án D</label>
            <input type="text" name="d" value="${bd.d}" 
                   class="form-control" required/>
        </div>

        <div class="mb-3">
            <label class="form-label">Đáp án đúng</label>
            <select name="dapAn" class="form-select" required>
                <option value="">-- Chọn đáp án đúng --</option>
                <option value="A" ${bd.dapAn == 'A' ? 'selected' : ''}>A</option>
                <option value="B" ${bd.dapAn == 'B' ? 'selected' : ''}>B</option>
                <option value="C" ${bd.dapAn == 'C' ? 'selected' : ''}>C</option>
                <option value="D" ${bd.dapAn == 'D' ? 'selected' : ''}>D</option>
            </select>
        </div>

        <button type="submit" class="btn btn-primary">Lưu</button>
        <a href="bode.htm" class="btn btn-secondary">Hủy</a>
    </form>
</body>
</html>
