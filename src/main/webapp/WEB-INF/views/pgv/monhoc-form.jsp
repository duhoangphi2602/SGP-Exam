<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Form Môn học</title>
    <link rel="stylesheet" 
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="container mt-4">
    <h3>${action == 'them' ? 'Thêm' : 'Sửa'} Môn học</h3>

    <c:if test="${error != null}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <form action="${action == 'them' ? 'monhoc-them.htm' : 'monhoc-sua.htm'}" 
          method="post" class="col-md-4">
        <div class="mb-3">
            <label class="form-label">Mã môn học</label>
            <input type="text" name="maMH" value="${monhoc.maMH}"
                   class="form-control" 
                   ${action == 'sua' ? 'readonly' : 'required'}/>
        </div>
        <div class="mb-3">
            <label class="form-label">Tên môn học</label>
            <input type="text" name="tenMH" value="${monhoc.tenMH}"
                   class="form-control" required/>
        </div>
        <button type="submit" class="btn btn-primary">Lưu</button>
        <a href="monhoc.htm" class="btn btn-secondary">Hủy</a>
    </form>
</body>
</html>
