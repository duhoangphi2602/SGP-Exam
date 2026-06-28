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
	background: #0d6efd;
	color: white;
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
	color: white;
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
	background: #0d6efd;
	color: white;
	border-color: #0d6efd;
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

#overlayLoi {
	display: none;
	position: fixed;
	top: 0;
	left: 0;
	width: 100%;
	height: 100%;
	background: rgba(0, 0, 0, 0.75);
	z-index: 9999;
	color: white;
	text-align: center;
}

#overlayLoi .noiDung {
	margin-top: 20vh;
}
</style>
</head>
<body>

	<!-- Overlay khi mất kết nối server -->
	<div id="overlayLoi">
		<div class="noiDung">
			<h2>⚠️ Hệ thống đang gặp sự cố</h2>
			<p>Bài thi của bạn đã được lưu lại.</p>
			<p>Vui lòng chờ hệ thống khôi phục...</p>
			<button class="btn btn-light mt-3" onclick="location.reload()">Thử
				kết nối lại</button>
		</div>
	</div>

	<div class="container mt-4">
		<c:if test="${daKhoiPhuc == true}">
			<div class="alert alert-success">Hệ thống đã khôi phục bài thi
				của bạn sau sự cố. Bạn có thể tiếp tục làm bài.</div>
		</c:if>

		<h4 class="mb-3">Làm bài thi</h4>

		<form id="formThi" action="thi-nopBai.htm" method="post">
			<c:forEach var="cau" items="${dsCauHoi}" varStatus="st">
				<c:set var="dapAnDa" value="${dapAnDaChon[cau.cauHoi]}" />
				<div class="cau-hoi" id="cau_${st.index + 1}">
					<p>
						<strong>Câu ${st.index + 1}:</strong> ${cau.noiDung}
					</p>
					<div class="form-check">
						<input class="form-check-input" type="radio"
							name="dapAn_${cau.cauHoi}" value="A" id="A_${cau.cauHoi}"
							<c:if test="${dapAnDa == 'A'}">checked</c:if>
							onchange="danhDau(${st.index + 1}, ${cau.cauHoi})" /> <label
							class="form-check-label" for="A_${cau.cauHoi}">A.
							${cau.a}</label>
					</div>
					<div class="form-check">
						<input class="form-check-input" type="radio"
							name="dapAn_${cau.cauHoi}" value="B" id="B_${cau.cauHoi}"
							<c:if test="${dapAnDa == 'B'}">checked</c:if>
							onchange="danhDau(${st.index + 1}, ${cau.cauHoi})" /> <label
							class="form-check-label" for="B_${cau.cauHoi}">B.
							${cau.b}</label>
					</div>
					<div class="form-check">
						<input class="form-check-input" type="radio"
							name="dapAn_${cau.cauHoi}" value="C" id="C_${cau.cauHoi}"
							<c:if test="${dapAnDa == 'C'}">checked</c:if>
							onchange="danhDau(${st.index + 1}, ${cau.cauHoi})" /> <label
							class="form-check-label" for="C_${cau.cauHoi}">C.
							${cau.c}</label>
					</div>
					<div class="form-check">
						<input class="form-check-input" type="radio"
							name="dapAn_${cau.cauHoi}" value="D" id="D_${cau.cauHoi}"
							<c:if test="${dapAnDa == 'D'}">checked</c:if>
							onchange="danhDau(${st.index + 1}, ${cau.cauHoi})" /> <label
							class="form-check-label" for="D_${cau.cauHoi}">D.
							${cau.d}</label>
					</div>
				</div>
			</c:forEach>

			<div class="text-center mt-3 mb-5">
				<button type="button" class="btn btn-primary btn-lg"
					onclick="xacNhanNopBai()">Nộp bài</button>
			</div>
		</form>
	</div>

	<!-- Floating Panel -->
	<div id="floatPanel">
		<div class="panel-header" onclick="togglePanel()">
			<span>Thời gian: <span id="dongHo">--:--</span></span> <span
				id="toggleIcon">▼</span>
		</div>
		<div class="panel-body" id="panelBody">
			<div id="danhSachCau" class="d-flex flex-wrap p-1"></div>
			<div class="legend">
				<div class="legend-item">
					<div class="legend-box" style="background: white"></div>
					<span>Chưa làm</span>
				</div>
				<div class="legend-item">
					<div class="legend-box" style="background: #0d6efd"></div>
					<span>Đã làm</span>
				</div>
			</div>
		</div>
		<div style="padding: 8px 10px; border-top: 1px solid #dee2e6;">
			<button type="button" onclick="xacNhanNopBai()"
				class="btn btn-danger btn-sm w-100">Nộp bài</button>
		</div>
	</div>

	<!-- Modal xác nhận nộp bài -->
	<div class="modal fade" id="modalNopBai" tabindex="-1"
		data-bs-backdrop="static">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content">
				<div class="modal-header bg-warning">
					<h5 class="modal-title">Xác nhận nộp bài</h5>
				</div>
				<div class="modal-body">Bạn chắc chắn muốn nộp bài? Sau khi
					nộp sẽ không thể làm lại.</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-secondary"
						data-bs-dismiss="modal">Tiếp tục làm bài</button>
					<button type="button" class="btn btn-danger"
						onclick="thucSuNopBai()">Nộp bài</button>
				</div>
			</div>
		</div>
	</div>

	<!-- Bootstrap JS TRƯỚC script của mình -->
	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
	<script>
    var contextPath = '${pageContext.request.contextPath}';
    var thoiGian = ${thoiGian};
    var soCau = ${dsCauHoi.size()};
    var panelOpen = true;

    // Khởi tạo modal SAU khi Bootstrap đã load
    var modalNopBai = new bootstrap.Modal(document.getElementById('modalNopBai'));

    // Danh sách câu đã có đáp án từ trước (khi khôi phục)
    var dapAnDaChonMap = {};
    <c:forEach var="cau" items="${dsCauHoi}" varStatus="st">
    <c:if test="${dapAnDaChon[cau.cauHoi] != null}">
    dapAnDaChonMap[${st.index + 1}] = true;
    </c:if>
    </c:forEach>

    function taoNutCauHoi() {
        var container = document.getElementById('danhSachCau');
        for (var i = 1; i <= soCau; i++) {
            var btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'btn-cau';
            btn.id = 'btnCau_' + i;
            btn.innerText = i;
            if (dapAnDaChonMap[i]) {
                btn.classList.add('da-lam');
            }
            btn.onclick = (function(index) {
                return function() {
                    document.getElementById('cau_' + index)
                        .scrollIntoView({ behavior: 'smooth' });
                };
            })(i);
            container.appendChild(btn);
        }
    }

    function xacNhanNopBai() {
        modalNopBai.show();
    }

    function thucSuNopBai() {
        modalNopBai.hide();
        document.getElementById('formThi').submit();
    }

    function danhDau(soThuTu, cauHoi) {
        var btn = document.getElementById('btnCau_' + soThuTu);
        if (btn) btn.classList.add('da-lam');

        var radioChecked = document.querySelector('input[name="dapAn_' + cauHoi + '"]:checked');
        if (!radioChecked) return;
        var dapAnChon = radioChecked.value;

        fetch(contextPath + '/sv/thi-luutam.htm', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: new URLSearchParams({
                cauHoi: cauHoi,
                stt: soThuTu,
                dapAnChon: dapAnChon,
                thoiGianConLai: thoiGian
            })
        }).catch(function() {});
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

    function capNhatDongHo() {
        var phut = Math.floor(thoiGian / 60);
        var giay = thoiGian % 60;
        document.getElementById('dongHo').innerText =
            (phut < 10 ? '0' : '') + phut + ':' +
            (giay < 10 ? '0' : '') + giay;

        if (thoiGian <= 60) {
            document.getElementById('dongHo').style.color = 'red';
        }
        if (thoiGian > 0) {
            thoiGian--;
        }
        setTimeout(capNhatDongHo, 1000);	
    }

    // Heartbeat
    var matKetNoi = false;
function heartbeat() {
    fetch(contextPath + '/sv/thi-laythoigian.htm')
    .then(function(res) {
        if (!res.ok) throw new Error('Server loi');
        return res.json();
    })
    .then(function(data) {
        if (data.error) throw new Error('Khong lay duoc thoi gian');
        thoiGian = data.thoiGianConLai;
        if (matKetNoi) location.reload();
        matKetNoi = false;
        if (thoiGian <= 0) {
            thucSuNopBai();
        }
    })
    .catch(function() {
        matKetNoi = true;
        document.getElementById('overlayLoi').style.display = 'block';
    });
}
setInterval(heartbeat, 5000);

    taoNutCauHoi();
    capNhatDongHo();
    </script>
</body>
</html>