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

	// Trang thi — hiện danh sách ca thi
	@RequestMapping("/thi.htm")
	public String index(HttpSession session, Model model) {
		String maSV = (String) session.getAttribute("masv");

		// Lấy thông tin SV + lớp
		SinhVien sv = svDAO.findByMa(maSV);
		Lop lop = lopDAO.findByMa(sv.getMaLop());

		// Lấy danh sách môn thi
		List<Map<String, Object>> dsMonHoc = thiDAO.getMonHoc(maSV);

		// Lấy danh sách ca thi + trạng thái
		List<Map<String, Object>> dsCaThi = thiDAO.getDanhSachCaThi(maSV);

		model.addAttribute("sv", sv);
		model.addAttribute("lop", lop);
		model.addAttribute("dsMonHoc", dsMonHoc);
		model.addAttribute("dsCaThi", dsCaThi);
		return "sv/thi";
	}

	// AJAX — lấy ngày thi theo môn
	@RequestMapping(value = "/thi-getngay.htm")
	@ResponseBody
	public String getNgayThi(@RequestParam String maMH, HttpSession session) {
		String maSV = (String) session.getAttribute("masv");
		List<Map<String, Object>> list = thiDAO.getNgayThi(maSV, maMH);

		StringBuilder json = new StringBuilder("[");
		for (int i = 0; i < list.size(); i++) {
			String ngay = list.get(i).get("NGAYTHI").toString();
			json.append("{\"NGAYTHI\":\"").append(ngay).append("\"}");
			if (i < list.size() - 1)
				json.append(",");
		}
		json.append("]");
		return json.toString();
	}

	// AJAX — lấy lần thi theo môn + ngày
	@RequestMapping(value = "/thi-getlan.htm")
	@ResponseBody
	public String getLanThi(@RequestParam String maMH, @RequestParam String ngayThi, HttpSession session) {
		String maSV = (String) session.getAttribute("masv");
		List<Map<String, Object>> list = thiDAO.getLanThi(maSV, maMH, ngayThi);

		StringBuilder json = new StringBuilder("[");
		for (int i = 0; i < list.size(); i++) {
			String lan = list.get(i).get("LAN").toString();
			json.append("{\"LAN\":\"").append(lan).append("\"}");
			if (i < list.size() - 1)
				json.append(",");
		}
		json.append("]");
		return json.toString();
	}

	// AJAX — lấy thông tin ca thi
	@RequestMapping(value = "/thi-getthongtin.htm")
	@ResponseBody
	public String getThongTin(@RequestParam String maMH, @RequestParam String ngayThi, @RequestParam int lan,
			HttpSession session) {
		String maSV = (String) session.getAttribute("masv");
		GiaoVienDangKy dk = thiDAO.getThongTinCaThi(maSV, maMH, ngayThi, lan);
		if (dk == null)
			return "{}";

		return "{\"soCauThi\":" + dk.getSoCauThi() + ",\"thoiGian\":" + dk.getThoiGian() + ",\"trinhDo\":\""
				+ dk.getTrinhDo().trim() + "\"}";
	}

	// Bắt đầu thi
	@RequestMapping(value = "/thi-batdau.htm", method = RequestMethod.POST)
	public String batDauThi(
	        @RequestParam String maMH,
	        @RequestParam String ngayThi,
	        @RequestParam int lan,
	        HttpSession session, Model model) {

	    String maSV = (String) session.getAttribute("masv");

	    // Kiểm tra ngày thi
	    java.time.LocalDate ngayThiDate = java.time.LocalDate.parse(
	        ngayThi, java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));
	    java.time.LocalDate homNay = java.time.LocalDate.now();

	    if (ngayThiDate.isAfter(homNay)) {
	        session.setAttribute("errorMsg", "Chưa đến ngày thi!");
	        return "redirect:/sv/thi.htm";
	    }
	    if (ngayThiDate.isBefore(homNay)) {
	        session.setAttribute("errorMsg", "Ca thi này đã quá hạn!");
	        return "redirect:/sv/thi.htm";
	    }

	    // Lấy thông tin ca thi
	    GiaoVienDangKy dk = thiDAO.getThongTinCaThi(maSV, maMH, ngayThi, lan);
	    if (dk == null) {
	        session.setAttribute("errorMsg", "Không tìm thấy ca thi!");
	        return "redirect:/sv/thi.htm";
	    }

	    // Random câu hỏi
	    List<CauHoiThi> dsCauHoi = thiDAO.randomCauHoi(
	        maMH, dk.getTrinhDo(), dk.getSoCauThi());

	    // Lưu vào session
	    session.setAttribute("dsCauHoi", dsCauHoi);
	    session.setAttribute("maMH", maMH);
	    session.setAttribute("lan", lan);
	    session.setAttribute("thoiGian", dk.getThoiGian());
	    session.setAttribute("soCauThi", dk.getSoCauThi());

	    return "redirect:/sv/thi-lamBai.htm";
	}

	// Trang làm bài
	@RequestMapping("/thi-lamBai.htm")
	public String lamBai(HttpSession session, Model model) {
		List<CauHoiThi> dsCauHoi = (List<CauHoiThi>) session.getAttribute("dsCauHoi");
		int thoiGian = (int) session.getAttribute("thoiGian");

		model.addAttribute("dsCauHoi", dsCauHoi);
		model.addAttribute("thoiGian", thoiGian * 60); // đổi sang giây
		return "sv/thi-lamBai";
	}

	// Nộp bài
	@RequestMapping(value = "/thi-nopBai.htm", method = RequestMethod.POST)
	public String nopBai(@RequestParam Map<String, String> dapAnSV, HttpSession session, Model model) {

		String maSV = (String) session.getAttribute("masv");
		String maMH = (String) session.getAttribute("maMH");
		int lan = (int) session.getAttribute("lan");
		int soCauThi = (int) session.getAttribute("soCauThi");
		List<CauHoiThi> dsCauHoi = (List<CauHoiThi>) session.getAttribute("dsCauHoi");

		// Tính điểm
		int soCauDung = 0;
		for (CauHoiThi cau : dsCauHoi) {
			String dapAnChon = dapAnSV.get("dapAn_" + cau.getCauHoi());
			// Lấy đáp án đúng từ DB
			String dapAnDung = getDapAnDung(cau.getCauHoi());
			if (dapAnChon != null && dapAnChon.equals(dapAnDung)) {
				soCauDung++;
			}
		}

		double diem = ((double) soCauDung / soCauThi) * 10;
		diem = Math.round(diem * 10.0) / 10.0; // làm tròn 1 chữ số

		// Ghi điểm vào DB
		thiDAO.ghiDiem(maSV, maMH, lan, diem);

		// Lưu kết quả vào session để hiện
		session.setAttribute("ketQua_diem", diem);
		session.setAttribute("ketQua_soCauDung", soCauDung);
		session.setAttribute("ketQua_soCauThi", soCauThi);
		session.setAttribute("ketQua_dsCauHoi", dsCauHoi);
		session.setAttribute("ketQua_dapAnSV", dapAnSV);

		return "redirect:/sv/thi-ketQua.htm";
	}

	// Lấy đáp án đúng từ DB
	private String getDapAnDung(int cauHoi) {
		List<Map<String, Object>> result = thiDAO.getDapAnDung(cauHoi);
		if (result.isEmpty())
			return "";
		return result.get(0).get("DAP_AN").toString().trim();
	}

}