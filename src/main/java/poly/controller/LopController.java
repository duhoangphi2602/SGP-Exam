package poly.controller;

import java.util.ArrayDeque;
import java.util.Deque;
import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import poly.dao.LopDAO;
import poly.dao.SinhVienDAO;
import poly.model.Lop;
import poly.model.SinhVien;
import poly.model.UndoAction;
import javax.servlet.http.HttpServletResponse;

@Controller
@RequestMapping("/pgv")
public class LopController {

	@Autowired
	LopDAO lopDAO;
	@Autowired
	SinhVienDAO svDAO;

	// =====================================================
	// 1. Danh sách lớp
	// =====================================================
	@RequestMapping("/lop.htm")
	public String index(@RequestParam(required = false) String timkiem, Model model) {
		List<Lop> list;
		if (timkiem != null && !timkiem.isEmpty()) {
			list = lopDAO.findByTen(timkiem);
		} else {
			list = lopDAO.findAll();
		}
		model.addAttribute("list", list);
		model.addAttribute("timkiem", timkiem);
		return "pgv/lop";
	}

	// =====================================================
	// 2. AJAX: Ghi (Thêm hoặc Sửa) Lớp
	// =====================================================
	@RequestMapping(value = "/lop-ghi.htm", method = RequestMethod.POST)
	@ResponseBody
	public String doGhi(@RequestParam String maLop, @RequestParam String tenLop, @RequestParam String mode,
			HttpSession session, HttpServletResponse response) {
		response.setContentType("text/plain;charset=UTF-8");
		try {
			Lop lop = new Lop();
			lop.setMaLop(maLop);
			lop.setTenLop(tenLop.trim().toUpperCase());

			Deque<UndoAction> stack = getStack(session);

			if ("them".equals(mode)) {
				lopDAO.insert(lop);
				stack.push(new UndoAction("INSERT", "LOP", null, lop));
			} else {
				Lop oldLop = lopDAO.findByMa(maLop);
				lopDAO.update(lop);
				stack.push(new UndoAction("UPDATE", "LOP", oldLop, lop));
			}

			return "OK|" + buildRows(lopDAO.findAll());
		} catch (Exception e) {
			return "ERROR|" + parseError(e.getMessage(), maLop);
		}
	}

	// =====================================================
	// 3. AJAX: Xóa Lớp
	// =====================================================
	@RequestMapping(value = "/lop-xoa-ajax.htm", method = RequestMethod.POST)
	@ResponseBody
	public String doXoaAjax(@RequestParam String ma, HttpSession session, HttpServletResponse response) {
		response.setContentType("text/plain;charset=UTF-8");
		try {
			int count = lopDAO.kiemTraConSV(ma);
			if (count > 0) {
				return "ERROR|Không thể xóa! Lớp này đang có Sinh viên hoặc Lịch thi.";
			}

			Lop oldLop = lopDAO.findByMa(ma);
			lopDAO.delete(ma);

			Deque<UndoAction> stack = getStack(session);
			stack.push(new UndoAction("DELETE", "LOP", oldLop, null));

			return "OK|" + buildRows(lopDAO.findAll());
		} catch (Exception e) {
			return "ERROR|Lỗi: " + e.getMessage();
		}
	}

	// =====================================================
	// 4. AJAX: Phục hồi Lớp
	// =====================================================
	@RequestMapping(value = "/lop-phuchoi.htm", method = RequestMethod.POST)
	@ResponseBody
	public String doPhucHoi(HttpSession session, HttpServletResponse response) {
	    response.setContentType("text/plain;charset=UTF-8");
	    Deque<UndoAction> stack = getStack(session);

	    if (stack.isEmpty()) {
	        return "WARN|Không còn gì để phục hồi!";
	    }

	    UndoAction action = stack.pop();
	    try {
	        Lop data = null;
	        switch (action.getLoai()) {
	            case "INSERT":
	                data = (Lop) action.getNewData();
	                break;
	            case "UPDATE":
	            case "DELETE":
	                data = (Lop) action.getOldData();
	                break;
	        }
	        lopDAO.phucHoi(action.getLoai(), data.getMaLop(), data.getTenLop());
	        return "OK|" + buildRows(lopDAO.findAll());
	    } catch (Exception e) {
	        stack.push(action);
	        return "ERROR|Lỗi khi phục hồi: " + e.getMessage();
	    }
	}

	// =====================================================
	// Helpers - Lớp
	// =====================================================
	@SuppressWarnings("unchecked")
	private Deque<UndoAction> getStack(HttpSession session) {
		Deque<UndoAction> stack = (Deque<UndoAction>) session.getAttribute("undoStack_LOP");
		if (stack == null) {
			stack = new ArrayDeque<>();
			session.setAttribute("undoStack_LOP", stack);
		}
		return stack;
	}

	private String parseError(String err, String maLop) {
		if (err.contains("PRIMARY KEY") || err.contains("duplicate key")) {
			return "Mã lớp '" + maLop.trim() + "' đã tồn tại!";
		} else if (err.contains("UNIQUE")) {
			return "Tên lớp đã tồn tại!";
		}
		return "Lỗi: " + err;
	}

	private String buildRows(List<Lop> list) {
		StringBuilder sb = new StringBuilder();
		for (Lop lop : list) {
			sb.append("<tr style=\"cursor: pointer;\" onclick=\"xemSinhVien('")
					.append(escapeJs(lop.getMaLop())).append("', '").append(escapeJs(lop.getTenLop())).append("', this)\">");
			sb.append("<td class=\"align-middle\">").append(escape(lop.getMaLop())).append("</td>");
			sb.append("<td class=\"align-middle\">").append(escape(lop.getTenLop())).append("</td>");
			sb.append("<td class=\"align-middle text-center\" style=\"white-space: nowrap;\" onclick=\"event.stopPropagation()\">");
			sb.append("<button type=\"button\" class=\"btn btn-sm btn-outline-warning p-1 me-1 border-0\" onclick=\"moModalSua('")
					.append(escapeJs(lop.getMaLop())).append("', '").append(escapeJs(lop.getTenLop())).append("')\" title=\"Sửa\">✏️</button>");
			sb.append("<button type=\"button\" class=\"btn btn-sm btn-outline-danger p-1 border-0\" onclick=\"xoaLop('")
					.append(escapeJs(lop.getMaLop())).append("')\" title=\"Xóa\">🗑️</button>");
			sb.append("</td>");
			sb.append("</tr>");
		}
		return sb.toString();
	}

	private String escape(String s) {
		if (s == null)
			return "";
		return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
	}

	private String escapeJs(String s) {
		if (s == null)
			return "";
		return s.replace("\\", "\\\\").replace("'", "\\'");
	}

	// =====================================================================
	// Phần Sinh viên (subform)
	// =====================================================================

	@RequestMapping("/lop-sinhvien.htm")
	public String dsSinhVien(@RequestParam String ma, @RequestParam(required = false) String timkiem, Model model) {
		model.addAttribute("lop", lopDAO.findByMa(ma));
		if (timkiem != null && !timkiem.isEmpty()) {
			model.addAttribute("dssv", svDAO.findByLopTimKiem(ma, timkiem));
		} else {
			model.addAttribute("dssv", svDAO.findByLop(ma));
		}
		model.addAttribute("timkiem", timkiem);
		return "pgv/lop-sinhvien";
	}

	// AJAX: Lấy danh sách Sinh viên của 1 Lớp (Subform)
	@RequestMapping(value = "/sv-danhsach-ajax.htm", method = RequestMethod.GET)
	@ResponseBody
	public String getDSSinhVienAjax(@RequestParam String maLop, HttpServletResponse response) {
		response.setContentType("text/plain;charset=UTF-8");
		try {
			return "OK|" + buildRowsSV(svDAO.findByLop(maLop), maLop);
		} catch (Exception e) {
			return "ERROR|Lỗi: " + e.getMessage();
		}
	}

	// AJAX: Ghi Batch (Thêm/Sửa/Xóa hàng loạt)
	@RequestMapping(value = "/sv-ghi-batch.htm", method = RequestMethod.POST, consumes = "application/json")
	@ResponseBody
	public String doGhiBatch(@RequestBody Map<String, Object> payload) {
		try {
			String maLop = (String) payload.get("maLop");
			@SuppressWarnings("unchecked")
			List<Map<String, String>> changes = (List<Map<String, String>>) payload.get("changes");

			if (changes == null || changes.isEmpty()) {
				return "OK|" + buildRowsSV(svDAO.findByLop(maLop), maLop);
			}

			// DAO tự quản lý Transaction (Rollback nếu lỗi)
			svDAO.ghiNhanBatch(maLop, changes);

			return "OK|" + buildRowsSV(svDAO.findByLop(maLop), maLop);
		} catch (Exception e) {
			String err = e.getMessage();
			if (err.contains("PRIMARY KEY") || err.contains("duplicate key")) {
				return "ERROR|Trùng lặp Mã Sinh Viên trong hệ thống!";
			} else if (err.contains("FOREIGN KEY")) {
				return "ERROR|Lỗi dữ liệu: Khóa ngoại không hợp lệ!";
			}
			return "ERROR|" + err;
		}
	}

	// AJAX: Ghi (Thêm hoặc Sửa) Sinh viên
	@RequestMapping(value = "/sv-ghi.htm", method = RequestMethod.POST)
	@ResponseBody
	public String doGhiSV(@RequestParam String maSV, @RequestParam String ho, @RequestParam String ten,
			@RequestParam String ngaySinh, @RequestParam String diaChi, @RequestParam String maLop,
			@RequestParam String mode, HttpSession session, HttpServletResponse response) {
		response.setContentType("text/plain;charset=UTF-8");
		try {
			java.time.LocalDate ns;
			try {
				ns = java.time.LocalDate.parse(ngaySinh, java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));
			} catch (java.time.format.DateTimeParseException e) {
				return "ERROR|Ngày sinh không đúng định dạng dd/MM/yyyy!";
			}

			int tuoi = java.time.Period.between(ns, java.time.LocalDate.now()).getYears();

			if (tuoi < 16) {
				return "ERROR|Sinh viên phải đủ ít nhất 16 tuổi!";
			}
			if (tuoi > 60) {
				return "ERROR|Ngày sinh không hợp lệ (tuổi vượt quá 60)!";
			}

			SinhVien sv = new SinhVien();
			sv.setMaSV(maSV);
			sv.setHo(ho);
			sv.setTen(ten);
			sv.setNgaySinh(ngaySinh);
			sv.setDiaChi(diaChi);
			sv.setMaLop(maLop);

			Deque<UndoAction> stack = getStackSV(session);

			if ("them".equals(mode)) {
				svDAO.insert(sv);
				stack.push(new UndoAction("INSERT", "SINHVIEN", null, sv));
			} else {
				SinhVien oldSv = svDAO.findByMa(maSV);
				svDAO.update(sv);
				stack.push(new UndoAction("UPDATE", "SINHVIEN", oldSv, sv));
			}

			return "OK|" + buildRowsSV(svDAO.findByLop(maLop), maLop);
		} catch (Exception e) {
			String err = e.getMessage();
			if (err.contains("PRIMARY KEY") || err.contains("duplicate key")) {
				return "ERROR|Mã sinh viên '" + maSV.trim() + "' đã tồn tại!";
			} else if (err.contains("FOREIGN KEY")) {
				return "ERROR|Mã lớp không tồn tại!";
			}
			return "ERROR|Lỗi: " + err;
		}
	}

	// AJAX: Xóa Sinh viên
	@RequestMapping(value = "/sv-xoa-ajax.htm", method = RequestMethod.POST)
	@ResponseBody
	public String doXoaSVAjax(@RequestParam String ma, @RequestParam String maLop, HttpSession session,
			HttpServletResponse response) {
		response.setContentType("text/plain;charset=UTF-8");
		try {
			int soDiem = svDAO.kiemTraConDiem(ma);
			if (soDiem > 0) {
				return "ERROR|Không thể xóa! Sinh viên này đã có điểm thi.";
			}

			SinhVien oldSv = svDAO.findByMa(ma);
			svDAO.delete(ma);

			Deque<UndoAction> stack = getStackSV(session);
			stack.push(new UndoAction("DELETE", "SINHVIEN", oldSv, null));

			return "OK|" + buildRowsSV(svDAO.findByLop(maLop), maLop);
		} catch (Exception e) {
			return "ERROR|Lỗi: " + e.getMessage();
		}
	}

	// AJAX: Phục hồi Sinh viên
	@RequestMapping(value = "/sv-phuchoi.htm", method = RequestMethod.POST)
	@ResponseBody
	public String doPhucHoiSV(@RequestParam String maLop, HttpSession session,
	                           HttpServletResponse response) {
	    response.setContentType("text/plain;charset=UTF-8");
	    Deque<UndoAction> stack = getStackSV(session);

	    if (stack.isEmpty()) {
	        return "WARN|Không còn gì để phục hồi!";
	    }

	    UndoAction action = stack.pop();
	    try {
	        SinhVien data = null;
	        switch (action.getLoai()) {
	            case "INSERT":
	                data = (SinhVien) action.getNewData();
	                break;
	            case "UPDATE":
	            case "DELETE":
	                data = (SinhVien) action.getOldData();
	                break;
	        }
	        svDAO.phucHoi(
	            action.getLoai(),
	            data.getMaSV(),
	            data.getHo(),
	            data.getTen(),
	            data.getNgaySinh(),
	            data.getDiaChi(),
	            data.getMaLop()
	        );
	        return "OK|" + buildRowsSV(svDAO.findByLop(maLop), maLop);
	    } catch (Exception e) {
	        stack.push(action);
	        return "ERROR|Lỗi khi phục hồi: " + e.getMessage();
	    }
	}

	// =====================================================
	// Helpers - Sinh viên
	// =====================================================
	@SuppressWarnings("unchecked")
	private Deque<UndoAction> getStackSV(HttpSession session) {
		Deque<UndoAction> stack = (Deque<UndoAction>) session.getAttribute("undoStack_SINHVIEN");
		if (stack == null) {
			stack = new ArrayDeque<>();
			session.setAttribute("undoStack_SINHVIEN", stack);
		}
		return stack;
	}

	private String buildRowsSV(List<SinhVien> list, String maLop) {
		StringBuilder sb = new StringBuilder();
		for (SinhVien sv : list) {
			sb.append("<tr>");
			sb.append("<td>").append(escape(sv.getMaSV())).append("</td>");
			sb.append("<td>").append(escape(sv.getHo())).append("</td>");
			sb.append("<td>").append(escape(sv.getTen())).append("</td>");
			sb.append("<td>").append(escape(sv.getNgaySinh())).append("</td>");
			sb.append("<td>").append(escape(sv.getDiaChi())).append("</td>");
			sb.append("<td>");
			sb.append("<button type=\"button\" class=\"btn btn-sm btn-warning\" ").append("onclick=\"moModalSuaSV('")
					.append(escapeJs(sv.getMaSV())).append("', '").append(escapeJs(sv.getHo())).append("', '")
					.append(escapeJs(sv.getTen())).append("', '").append(escapeJs(sv.getNgaySinh())).append("', '")
					.append(escapeJs(sv.getDiaChi())).append("')\">Hiệu chỉnh</button> ");
			sb.append("<button type=\"button\" class=\"btn btn-sm btn-danger\" ").append("onclick=\"xoaSV('")
					.append(escapeJs(sv.getMaSV())).append("', '").append(escapeJs(maLop)).append("')\">Xóa</button>");
			sb.append("</td>");
			sb.append("</tr>");
		}
		return sb.toString();
	}
}