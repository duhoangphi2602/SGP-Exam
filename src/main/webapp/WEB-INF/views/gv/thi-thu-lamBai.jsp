<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Thi thử</title>
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
<style>
.cau-hoi {
	background: #f8f9fa;
	border-radius: 8px;
	padding: 15px;
	margin-bottom: 15px;
	scroll-margin-top: 80px;
}

#floatPanel {
	position: fixed;
	bottom: 20px;
	right: 20px;
	width: 280px;
	background: white;
	border-radius: 10px;
	box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
	z-index: 1000;
	overflow: hidden;
}

#floatPanel .panel-header {
	background: #ffc107;
	color: black;
	padding: 10px 15px;
	cursor: pointer;
	display: flex;
	justify-content: space-between;
	align-items: center;
}

#floatPanel .panel-body {
	padding: 10px;
	max-height: 300px;
	overflow-y: auto;
}

#dongHo {
	font-size: 20px;
	font-weight: bold;
	color: black;
}

.btn-cau {
	width: 36px;
	height: 36px;
	margin: 3px;
	padding: 0;
	font-size: 12px;
	border-radius: 5px;
	cursor: pointer;
	border: 1px solid #dee2e6;
	background: white;
}

.btn-cau.da-lam {
	background: #ffc107;
	color: black;
	border-color: #ffc107;
}

.legend {
	display: flex;
	gap: 10px;
	padding: 5px 10px;
	font-size: 12px;
	border-top: 1px solid #dee2e6;
}

.legend-item {
	display: flex;
	align-items: center;
	gap: 4px;
}

.legend-box {
	width: 16px;
	height: 16px;
	border-radius: 3px;
	border: 1px solid #dee2e6;
}

.container {
	margin-right: 320px;
}
</style>
</head>
<body>
	<div class="container mt-4">
		<h4 class="mb-3">Làm bài thi thử</h4>

		<form id="formThi"
			action="${pageContext.request.contextPath}/gv/thi-thu-ketqua.htm"
			method="post">
			<c:forEach var="cau" items="${dsCauHoi}" varStatus="st">
				<div class="cau-hoi" id="cau_${st.index + 1}">
					<p>
						<strong>Câu ${st.index + 1}:</strong> ${cau.noiDung}
					</p>
					<div class="form-check">
						<input class="form-check-input" type="radio"
							name="dapAn_${cau.cauHoi}" value="A" id="A_${cau.cauHoi}"
							onchange="danhDau(${st.index + 1})" />
						<label class="form-check-label" for="A_${cau.cauHoi}">A. ${cau.a}</label>
					</div>
					<div class="form-check">
						<input class="form-check-input" type="radio"
							name="dapAn_${cau.cauHoi}" value="B" id="B_${cau.cauHoi}"
							onchange="danhDau(${st.index + 1})" />
						<label class="form-check-label" for="B_${cau.cauHoi}">B. ${cau.b}</label>
					</div>
					<div class="form-check">
						<input class="form-check-input" type="radio"
							name="dapAn_${cau.cauHoi}" value="C" id="C_${cau.cauHoi}"
							onchange="danhDau(${st.index + 1})" />
						<label class="form-check-label" for="C_${cau.cauHoi}">C. ${cau.c}</label>
					</div>
					<div class="form-check">
						<input class="form-check-input" type="radio"
							name="dapAn_${cau.cauHoi}" value="D" id="D_${cau.cauHoi}"
							onchange="danhDau(${st.index + 1})" />
						<label class="form-check-label" for="D_${cau.cauHoi}">D. ${cau.d}</label>
					</div>
				</div>
			</c:forEach>

			<div class="text-center mt-3 mb-5">
				<button type="submit" class="btn btn-warning btn-lg"
					onclick="return confirm('Kết thúc thi thử? Kết quả sẽ không được ghi vào bảng điểm.')">
					Kết thúc thi thử
				</button>
			</div>
		</form>
	</div>

	<!-- Floating Panel -->
	<div id="floatPanel">
		<div class="panel-header" onclick="togglePanel()">
			<span>Thời gian: <span id="dongHo">--:--</span></span>
			<span id="toggleIcon">▼</span>
		</div>
		<div class="panel-body" id="panelBody">
			<div id="danhSachCau" class="d-flex flex-wrap p-1"></div>
			<div class="legend">
				<div class="legend-item">
					<div class="legend-box" style="background: white"></div>
					<span>Chưa làm</span>
				</div>
				<div class="legend-item">
					<div class="legend-box" style="background: #ffc107"></div>
					<span>Đã làm</span>
				</div>
			</div>
		</div>
		<div style="padding: 8px 10px; border-top: 1px solid #dee2e6;">
			<button onclick="xacNhanNopBai()" class="btn btn-warning btn-sm w-100">
				Kết thúc thi thử
			</button>
		</div>
	</div>

	<script>
var thoiGian = ${thoiGian};
var soCau = ${dsCauHoi.size()};
var panelOpen = true;

function taoNutCauHoi() {
    var container = document.getElementById('danhSachCau');
    for (var i = 1; i <= soCau; i++) {
        var btn = document.createElement('button');
        btn.type = 'button';
        btn.className = 'btn-cau';
        btn.id = 'btnCau_' + i;
        btn.innerText = i;
        btn.onclick = (function(index) {
            return function() {
                document.getElementById('cau_' + index)
                    .scrollIntoView({ behavior: 'smooth' });
            };
        })(i);
        container.appendChild(btn);
    }
}

function danhDau(soThuTu) {
    var btn = document.getElementById('btnCau_' + soThuTu);
    btn.classList.add('da-lam');
}

function togglePanel() {
    var body = document.getElementById('panelBody');
    var icon = document.getElementById('toggleIcon');
    if (panelOpen) {
        body.style.display = 'none';
        icon.innerText = '▲';
        panelOpen = false;
    } else {
        body.style.display = 'block';
        icon.innerText = '▼';
        panelOpen = true;
    }
}

function xacNhanNopBai() {
    if (confirm('Kết thúc thi thử.')) {
        document.getElementById('formThi').submit();
    }
}

function capNhatDongHo() {
    var phut = Math.floor(thoiGian / 60);
    var giay = thoiGian % 60;
    document.getElementById('dongHo').innerText =
        (phut < 10 ? '0' : '') + phut + ':' +
        (giay < 10 ? '0' : '') + giay;

    if (thoiGian <= 0) {
        alert('Hết giờ! Bài thi thử sẽ được nộp tự động.');
        document.getElementById('formThi').submit();
        return;
    }

    if (thoiGian <= 60) {
        document.getElementById('dongHo').style.color = 'red';
    }

    thoiGian--;
    setTimeout(capNhatDongHo, 1000);
}

taoNutCauHoi();
capNhatDongHo();
	</script>

	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>