<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ include file="../common/navbar.jsp"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Form Câu hỏi</title>
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="container mt-4">
	<h3>${action == 'them' ? 'Thêm' : 'Sửa'}câu hỏi</h3>

	<c:if test="${error != null}">
		<div class="alert alert-danger">${error}</div>
	</c:if>

	<form action="${action == 'them' ? 'bode-them.htm' : 'bode-sua.htm'}"
		method="post" class="col-md-7">

		<c:if test="${action == 'sua'}">
			<input type="hidden" name="cauHoi" value="${bd.cauHoi}" />
		</c:if>

		<div class="mb-3">
			<label class="form-label">Môn học</label> <select name="maMH"
				class="form-select" ${action == 'sua' ? 'disabled' : 'required'}>
				<option value="">-- Chọn môn --</option>
				<c:forEach var="mh" items="${dsMonHoc}">
					<option value="${mh.maMH}" ${mh.maMH == bd.maMH ? 'selected' : ''}>
						${mh.tenMH}</option>
				</c:forEach>
			</select>
			<c:if test="${action == 'sua'}">
				<input type="hidden" name="maMH" value="${bd.maMH}" />
			</c:if>
		</div>

		<div class="mb-3">
			<label class="form-label">Trình độ</label> <select name="trinhDo"
				class="form-select" ${action == 'sua' ? 'disabled' : 'required'}>
				<option value="">-- Chọn trình độ --</option>
				<option value="A" ${bd.trinhDo == 'A' ? 'selected' : ''}>A
					- ĐH Chuyên ngành</option>
				<option value="B" ${bd.trinhDo == 'B' ? 'selected' : ''}>B
					- ĐH Không chuyên</option>
				<option value="C" ${bd.trinhDo == 'C' ? 'selected' : ''}>C
					- Cao đẳng</option>
			</select>
			<c:if test="${action == 'sua'}">
				<input type="hidden" name="trinhDo" value="${bd.trinhDo}" />
			</c:if>
		</div>

		<div class="mb-3">
			<label class="form-label">Nội dung câu hỏi</label>
			<textarea name="noiDung" class="form-control" rows="3" required>${bd.noiDung}</textarea>
		</div>

		<div class="mb-3">
			<label class="form-label">Đáp án A</label> <input type="text"
				name="a" id="dapAnA" value="${bd.a}" class="form-control" required />
		</div>
		<div class="mb-3">
			<label class="form-label">Đáp án B</label> <input type="text"
				name="b" id="dapAnB" value="${bd.b}" class="form-control" required />
		</div>
		<div class="mb-3">
			<label class="form-label">Đáp án C</label> <input type="text"
				name="c" id="dapAnC" value="${bd.c}" class="form-control" required />
		</div>
		<div class="mb-3">
			<label class="form-label">Đáp án D</label> <input type="text"
				name="d" id="dapAnD" value="${bd.d}" class="form-control" required />
		</div>

		<div class="mb-3">
			<label class="form-label">Đáp án đúng</label> <select name="dapAn"
				class="form-select" required>
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
	<script>
    const dapAnFields = [
        { id: 'dapAnA', label: 'A' },
        { id: 'dapAnB', label: 'B' },
        { id: 'dapAnC', label: 'C' },
        { id: 'dapAnD', label: 'D' }
    ];

    function validateDapAn() {
        // Reset tất cả
        dapAnFields.forEach(f => {
            const el = document.getElementById(f.id);
            el.classList.remove('is-invalid');
            const fb = el.nextElementSibling;
            if (fb && fb.classList.contains('invalid-feedback')) fb.remove();
        });

        let hasError = false;

        for (let i = 0; i < dapAnFields.length; i++) {
            for (let j = i + 1; j < dapAnFields.length; j++) {
                const elI = document.getElementById(dapAnFields[i].id);
                const elJ = document.getElementById(dapAnFields[j].id);
                const valI = elI.value.trim();
                const valJ = elJ.value.trim();

                if (valI !== '' && valJ !== '' && valI === valJ) {
                    // Đánh dấu đỏ cả 2 field
                    [elI, elJ].forEach(el => {
                        if (!el.classList.contains('is-invalid')) {
                            el.classList.add('is-invalid');
                            const msg = document.createElement('div');
                            msg.className = 'invalid-feedback';
                            msg.textContent = 'Đáp án bị trùng với đáp án khác!';
                            el.insertAdjacentElement('afterend', msg);
                        }
                    });
                    hasError = true;
                }
            }
        }
        return !hasError;
    }

    // Validate khi rời khỏi field (blur)
    dapAnFields.forEach(f => {
        document.getElementById(f.id).addEventListener('blur', validateDapAn);
    });

    // Chặn submit nếu còn lỗi
    document.querySelector('form').addEventListener('submit', function(e) {
        if (!validateDapAn()) {
            e.preventDefault();
            // Scroll lên field lỗi đầu tiên
            const firstError = document.querySelector('.is-invalid');
            if (firstError) firstError.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
    });
</script>
</body>
</html>
