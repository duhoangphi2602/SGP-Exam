<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<html>
<body>
    <h2>Danh sách lớp</h2>
    <table border="1">
        <tr><th>Mã lớp</th><th>Tên lớp</th></tr>
        <c:forEach var="lop" items="${dslop}">
            <tr>
                <td>${lop.MALOP}</td>
                <td>${lop.TENLOP}</td>
            </tr>
        </c:forEach>
    </table>
</body>
</html>
```

---
