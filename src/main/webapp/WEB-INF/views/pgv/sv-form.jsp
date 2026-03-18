<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Form Sinh viên</title>
    <link rel="stylesheet" 
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="container mt-4">
    <h3>${action == 'them' ? 'Thêm' : 'Sửa'} Sinh viên</h3>

    <c:if test="${error != null}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <form action="${action == 'them' ? 'sv-them.htm' : 'sv-sua.htm'}" 
          method="post" class="col-md-5">
        <input type="hidden" name="maLop" value="${sv.maLop}"/>

        <div class="mb-3">
            <label class="form-label">Mã sinh viên</label>
            <input type="text" name="maSV" value="${sv.maSV}"
                   class="form-control"
                   ${action == 'sua' ? 'readonly' : 'required'}/>
        </div>
        <div class="mb-3">
            <label class="form-label">Họ</label>
            <input type="text" name="ho" value="${sv.ho}"
                   class="form-control" required/>
        </div>
        <div class="mb-3">
            <label class="form-label">Tên</label>
            <input type="text" name="ten" value="${sv.ten}"
                   class="form-control" required/>
        </div>
        <div class="mb-3">
            <label class="form-label">Ngày sinh (dd/MM/yyyy)</label>
            <input type="text" name="ngaySinh" value="${sv.ngaySinh}"
                   class="form-control" placeholder="dd/MM/yyyy"/>
        </div>
        <div class="mb-3">
            <label class="form-label">Địa chỉ</label>
            <input type="text" name="diaChi" value="${sv.diaChi}"
                   class="form-control"/>
        </div>
        <button type="submit" class="btn btn-primary">Lưu</button>
        <a href="lop-sinhvien.htm?ma=${sv.maLop}" class="btn btn-secondary">Hủy</a>
    </form>
</body>
</html>

