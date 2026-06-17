package poly.controller;

import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import poly.dao.ThiDAO;
import poly.dao.SinhVienDAO;
import poly.dao.LopDAO;
import poly.model.CauHoiThi;
import poly.model.GiaoVienDangKy;
import poly.model.SinhVien;
import poly.model.Lop;

@Controller
@RequestMapping("/sv")
public class ThiController {

	@Autowired
	ThiDAO thiDAO;
	@Autowired
	SinhVienDAO svDAO;
	@Autowired
	LopDAO lopDAO;

	// =====================================================
	// 1. Trang danh sách ca thi
	// =====================================================
	@RequestMapping("/thi.htm")
	public String index(HttpSession session, Model model) {
		String maSV = (String) session.getAttribute("masv");

		SinhVien sv = svDAO.findByMa(maSV);
		Lop lop = lopDAO.findByMa(sv.getMaLop());
		List<Map<String, Object>> dsCaThi = thiDAO.getDanhSachCaThi(maSV);

		model.addAttribute("sv", sv);
		model.addAttribute("lop", lop);
		model.addAttribute("dsCaThi", dsCaThi);
		return "sv/thi";
	}

	// =====================================================
	// 2. Bắt đầu thi — nhận từ form trong bảng
	// =====================================================
	@RequestMapping(value = "/thi-batdau.htm", method = RequestMethod.POST)
	public String batDauThi(@RequestParam String maMH, @RequestParam String ngayThi, @RequestParam int lan,
			HttpSession session) {

		String maSV = (String) session.getAttribute("masv");

		// Lấy thông tin ca thi
		GiaoVienDangKy dk = thiDAO.getThongTinCaThi(maSV, maMH, ngayThi, lan);
		if (dk == null) {
			session.setAttribute("errorMsg", "Không tìm thấy ca thi!");
			return "redirect:/sv/thi.htm";
		}

		// Random câu hỏi
		List<CauHoiThi> dsCauHoi = thiDAO.randomCauHoi(maMH, dk.getTrinhDo(), dk.getSoCauThi());

		// Lưu session
		session.setAttribute("dsCauHoi", dsCauHoi);
		session.setAttribute("maMH", maMH);
		session.setAttribute("lan", lan);
		session.setAttribute("thoiGian", dk.getThoiGian());
		session.setAttribute("soCauThi", dk.getSoCauThi());

		return "redirect:/sv/thi-lamBai.htm";
	}

	// =====================================================
	// 3. Trang làm bài
	// =====================================================
	@RequestMapping("/thi-lamBai.htm")
	public String lamBai(HttpSession session, Model model) {
		List<CauHoiThi> dsCauHoi = (List<CauHoiThi>) session.getAttribute("dsCauHoi");

		// Guard: nếu vào thẳng URL mà không qua batDauThi
		if (dsCauHoi == null || dsCauHoi.isEmpty()) {
			session.setAttribute("errorMsg", "Vui lòng chọn ca thi trước!");
			return "redirect:/sv/thi.htm";
		}

		int thoiGian = (int) session.getAttribute("thoiGian");

		model.addAttribute("dsCauHoi", dsCauHoi);
		model.addAttribute("thoiGian", thoiGian * 60); // đổi sang giây
		return "sv/thi-lamBai";
	}

	// =====================================================
	// 4. Nộp bài
	// =====================================================
	@RequestMapping(value = "/thi-nopBai.htm", method = RequestMethod.POST)
	public String nopBai(@RequestParam Map<String, String> dapAnSV, HttpSession session, Model model) {

		String maSV = (String) session.getAttribute("masv");
		String maMH = (String) session.getAttribute("maMH");
		int lan = (int) session.getAttribute("lan");
		int soCauThi = (int) session.getAttribute("soCauThi");
		List<CauHoiThi> dsCauHoi = (List<CauHoiThi>) session.getAttribute("dsCauHoi");

		if (dsCauHoi == null || maSV == null) {
			return "redirect:/sv/thi.htm";
		}

		// Tính điểm
		int soCauDung = 0;
		for (CauHoiThi cau : dsCauHoi) {
			String dapAnChon = dapAnSV.get("dapAn_" + cau.getCauHoi());
			String dapAnDung = getDapAnDung(cau.getCauHoi());
			if (dapAnChon != null && dapAnChon.trim().equals(dapAnDung.trim())) {
				soCauDung++;
			}
		}

		double diem = ((double) soCauDung / soCauThi) * 10;
		diem = Math.round(diem * 10.0) / 10.0;

		// 1. Ghi điểm vào BANGDIEM trước (Bắt buộc do có khóa ngoại)
		thiDAO.ghiDiem(maSV, maMH, lan, diem);

		// 2. MỚI: Lưu chi tiết từng câu vào CT_BAITHI
		int stt = 1;
		for (CauHoiThi cau : dsCauHoi) {
			String dapAnChon = dapAnSV.get("dapAn_" + cau.getCauHoi());
			// Nếu SV bỏ trống câu này, chuyển thành rỗng để an toàn khi lưu DB
			if(dapAnChon != null && dapAnChon.trim().isEmpty()) {
				dapAnChon = null; 
			}
			thiDAO.luuChiTietBaiThi(maSV, maMH, lan, stt, cau.getCauHoi(), dapAnChon);
			stt++;
		}

		session.setAttribute("ketQua_diem", diem);
		session.setAttribute("ketQua_soCauDung", soCauDung);
		session.setAttribute("ketQua_soCauThi", soCauThi);
		session.setAttribute("ketQua_dsCauHoi", dsCauHoi);
		session.setAttribute("ketQua_dapAnSV", dapAnSV);

		session.removeAttribute("dsCauHoi");
		session.removeAttribute("maMH");
		session.removeAttribute("lan");
		session.removeAttribute("thoiGian");
		session.removeAttribute("soCauThi");

		return "redirect:/sv/thi-ketQua.htm";
	}
	
	// =====================================================
	// Đổi mật khẩu
	// =====================================================
	@RequestMapping(value = "/doiMatKhau.htm", method = RequestMethod.GET)
	public String doiMatKhauForm() {
	    return "sv/doiMatKhau";
	}

	@RequestMapping(value = "/doiMatKhau.htm", method = RequestMethod.POST)
	public String doiMatKhau(
	        @RequestParam String oldPass,
	        @RequestParam String newPass,
	        @RequestParam String confirmPass,
	        HttpSession session,
	        Model model) {

	    String maSV = (String) session.getAttribute("masv");

	    if (!newPass.equals(confirmPass)) {
	        model.addAttribute("error", "Xác nhận mật khẩu không khớp!");
	        return "sv/doiMatKhau";
	    }
	    if (newPass.equals(oldPass)) {
	        model.addAttribute("error", "Mật khẩu mới không được trùng mật khẩu cũ!");
	        return "sv/doiMatKhau";
	    }

	    boolean ok = svDAO.doiPassword(maSV, oldPass, newPass);
	    if (!ok) {
	        model.addAttribute("error", "Mật khẩu hiện tại không đúng!");
	        return "sv/doiMatKhau";
	    }

	    model.addAttribute("success", "Đổi mật khẩu thành công!");
	    return "sv/doiMatKhau";
	}

	// =====================================================
	// 5. Trang kết quả
	// =====================================================
	@RequestMapping("/thi-ketQua.htm")
	public String ketQua(HttpSession session, Model model) {
		Double diem = (Double) session.getAttribute("ketQua_diem");

		// Guard
		if (diem == null) {
			return "redirect:/sv/thi.htm";
		}

		model.addAttribute("diem", diem);
		model.addAttribute("soCauDung", session.getAttribute("ketQua_soCauDung"));
		model.addAttribute("soCauThi", session.getAttribute("ketQua_soCauThi"));
		model.addAttribute("dsCauHoi", session.getAttribute("ketQua_dsCauHoi"));
		model.addAttribute("dapAnSV", session.getAttribute("ketQua_dapAnSV"));

		return "sv/thi-ketQua";
	}
	
	// =====================================================
	// 6. Xem lịch sử thi (Danh sách tổng quan)
	// =====================================================
	@RequestMapping("/ketqua.htm")
	public String ketQuaTongQuan(HttpSession session, Model model) {
		String maSV = (String) session.getAttribute("masv");
		if(maSV == null) return "redirect:/login.htm";
		
		List<Map<String, Object>> dsKetQua = thiDAO.getKetQuaThi(maSV);
		model.addAttribute("dsKetQua", dsKetQua);
		return "sv/ketqua";
	}

	// =====================================================
	// 7. Xem chi tiết kết quả bài thi
	// =====================================================
	@RequestMapping("/ketqua-chitiet.htm")
	public String ketQuaChiTiet(@RequestParam("maMH") String maMH, @RequestParam("lan") int lan, HttpSession session, Model model) {
		String maSV = (String) session.getAttribute("masv");
		if(maSV == null) return "redirect:/login.htm";
		
		List<Map<String, Object>> chiTiet = thiDAO.getChiTietBaiThi(maSV, maMH, lan);
		model.addAttribute("chiTiet", chiTiet);
		model.addAttribute("maMH", maMH);
		model.addAttribute("lan", lan);
		
		return "sv/ketqua-chitiet";
	}

	// =====================================================
	// Helper
	// =====================================================
	private String getDapAnDung(int cauHoi) {
		List<Map<String, Object>> result = thiDAO.getDapAnDung(cauHoi);
		if (result == null || result.isEmpty())
			return "";
		return result.get(0).get("DAP_AN").toString().trim();
	}
	
	
}