<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Làm bài thi</title>
    <link rel="stylesheet" 
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <style>
        .cau-hoi { background: #f8f9fa; border-radius: 8px; padding: 15px; margin-bottom: 15px; }
        #dongHo { font-size: 24px; font-weight: bold; color: red; }
    </style>
</head>
<body>
    <div class="container mt-4">

        <!-- Đồng hồ đếm ngược -->
        <div class="text-center mb-3">
            <span>Thời gian còn lại: </span>
            <span id="dongHo"></span>
        </div>

        <form id="formThi" action="thi-nopBai.htm" method="post">
            <c:forEach var="cau" items="${dsCauHoi}" varStatus="st">
                <div class="cau-hoi">
                    <p><strong>Câu ${st.index + 1}:</strong> ${cau.noiDung}</p>
                    <div class="form-check">
                        <input class="form-check-input" type="radio" 
                               name="dapAn_${cau.cauHoi}" value="A" id="A_${cau.cauHoi}"/>
                        <label class="form-check-label" for="A_${cau.cauHoi}">
                            A. ${cau.a}
                        </label>
                    </div>
                    <div class="form-check">
                        <input class="form-check-input" type="radio" 
                               name="dapAn_${cau.cauHoi}" value="B" id="B_${cau.cauHoi}"/>
                        <label class="form-check-label" for="B_${cau.cauHoi}">
                            B. ${cau.b}
                        </label>
                    </div>
                    <div class="form-check">
                        <input class="form-check-input" type="radio" 
                               name="dapAn_${cau.cauHoi}" value="C" id="C_${cau.cauHoi}"/>
                        <label class="form-check-label" for="C_${cau.cauHoi}">
                            C. ${cau.c}
                        </label>
                    </div>
                    <div class="form-check">
                        <input class="form-check-input" type="radio" 
                               name="dapAn_${cau.cauHoi}" value="D" id="D_${cau.cauHoi}"/>
                        <label class="form-check-label" for="D_${cau.cauHoi}">
                            D. ${cau.d}
                        </label>
                    </div>
                </div>
            </c:forEach>

            <div class="text-center mt-3 mb-5">
                <button type="submit" class="btn btn-primary btn-lg"
                        onclick="return confirm('Bạn chắc chắn muốn nộp bài?')">
                    📤 Nộp bài
                </button>
            </div>
        </form>
    </div>

<script>
// Đồng hồ đếm ngược
var thoiGian = ${thoiGian}; // giây

function capNhatDongHo() {
    var phut = Math.floor(thoiGian / 60);
    var giay = thoiGian % 60;
    document.getElementById('dongHo').innerText = 
        (phut < 10 ? '0' : '') + phut + ':' + 
        (giay < 10 ? '0' : '') + giay;

    if (thoiGian <= 0) {
        alert('Hết giờ! Bài thi sẽ được nộp tự động.');
        document.getElementById('formThi').submit();
        return;
    }

    if (thoiGian <= 60) {
        document.getElementById('dongHo').style.color = 'red';
    }

    thoiGian--;
    setTimeout(capNhatDongHo, 1000);
}

capNhatDongHo();
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>