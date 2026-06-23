package poly.controller;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import poly.dao.GiaoVienDAO;
import poly.model.GiaoVien;

@Controller
@RequestMapping("/pgv")
public class GiaoVienController {

	@Autowired
	GiaoVienDAO giaoVienDAO;

	// =====================================================
	// Helper: add data cho form
	// =====================================================
	private void addFormData(Model model, GiaoVien gv, String action) {
		model.addAttribute("gv", gv);
		model.addAttribute("action", action);
	}

	@RequestMapping("/giaovien.htm")
	public String index(@RequestParam(required = false) String timkiem, Model model) {
		List<GiaoVien> list;
		if (timkiem != null && !timkiem.isEmpty()) {
			list = giaoVienDAO.findByTen(timkiem);
		} else {
			list = giaoVienDAO.findAll();
		}
		model.addAttribute("list", list);
		model.addAttribute("timkiem", timkiem);
		return "pgv/giaovien";
	}

	// show them giao vien
	@RequestMapping(value = "/giaovien-them.htm", method = RequestMethod.GET)
	public String showThem(Model model) {
		addFormData(model, new GiaoVien(), "them");
		return "pgv/giaovien-form";
	}

	// them giao vien
	@RequestMapping(value = "/giaovien-them.htm", method = RequestMethod.POST)
	public String doThem(@ModelAttribute GiaoVien gv, Model model) {
		String loi = validateGV(gv, null);
		if (loi != null) {
			model.addAttribute("error", loi);
			addFormData(model, gv, "them");
			return "pgv/giaovien-form";
		}

		try {
			giaoVienDAO.insert(gv);
			model.addAttribute("successMsg", "Thêm giáo viên thành công!");
			addFormData(model, gv, "them");
			return "pgv/giaovien-form";
		} catch (Exception e) {
			String err = e.getMessage();
			if (err.contains("PRIMARY KEY") || err.contains("duplicate key")) {
				model.addAttribute("error", "Mã giáo viên '" + gv.getMaGV().trim() + "' đã tồn tại!");
			} else {
				model.addAttribute("error", "Lỗi: " + err);
			}
			addFormData(model, gv, "them");
			return "pgv/giaovien-form";
		}
	}

	// sua giao vien
	@RequestMapping(value = "/giaovien-sua.htm", method = RequestMethod.GET)
	public String showSua(@RequestParam String ma, Model model) {
		addFormData(model, giaoVienDAO.findByMa(ma), "sua");
		return "pgv/giaovien-form";
	}

	//Sua giao vien
	@RequestMapping(value = "/giaovien-sua.htm", method = RequestMethod.POST)
	public String doSua(@ModelAttribute GiaoVien gv, Model model) {
	    String loi = validateGV(gv, gv.getMaGV());
	    if (loi != null) {
	        model.addAttribute("error", loi);
	        addFormData(model, gv, "sua");
	        return "pgv/giaovien-form";
	    }

	    try {
	        giaoVienDAO.update(gv);
	        model.addAttribute("successMsg", "Cập nhật giáo viên thành công!");
	        addFormData(model, gv, "sua");
	        return "pgv/giaovien-form";
	    } catch (Exception e) {
	        model.addAttribute("error", "Lỗi: " + e.getMessage());
	        addFormData(model, gv, "sua");
	        return "pgv/giaovien-form";
	    }
	}

	// Xoa giao vien
	@RequestMapping("/giaovien-xoa.htm")
	public String doXoa(@RequestParam String ma, HttpSession session) {
	    int soCau = giaoVienDAO.kiemTraConCauHoi(ma);
	    if (soCau > 0) {
	        session.setAttribute("errorMsg", "Không thể xóa! Giáo viên này còn " + soCau + " câu hỏi trong bộ đề.");
	        return "redirect:/pgv/giaovien.htm";
	    }

	    int soDangKy = giaoVienDAO.kiemTraConDangKy(ma);
	    if (soDangKy > 0) {
	        session.setAttribute("errorMsg", "Không thể xóa! Giáo viên này còn " + soDangKy + " ca thi đã đăng ký.");
	        return "redirect:/pgv/giaovien.htm";
	    }

	    if (giaoVienDAO.coTaiKhoan(ma)) {
	        session.setAttribute("errorMsg", "Không thể xóa! Giáo viên này còn tài khoản đăng nhập!.");
	        return "redirect:/pgv/giaovien.htm";
	    }

	    giaoVienDAO.delete(ma);
	    session.setAttribute("successMsg", "Xóa giáo viên thành công!");
	    return "redirect:/pgv/giaovien.htm";
	}

	// Helper validate
	private String validateGV(GiaoVien gv, String maGVLoaiTru) {
		if (gv.getHo() == null || gv.getHo().trim().isEmpty() || gv.getTen() == null || gv.getTen().trim().isEmpty()) {
			return "Họ và Tên không được để trống!";
		}
		if (gv.getSoDTLL() == null || !gv.getSoDTLL().trim().matches("0\\d{9}")) {
			return "Số điện thoại không hợp lệ! (phải có 10 số, bắt đầu bằng 0)";
		}
		return null;
	}
}