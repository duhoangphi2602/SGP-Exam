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
import poly.dao.MonHocDAO;
import poly.model.MonHoc;

@Controller
@RequestMapping("/sv")
public class ThiController {

	@Autowired
	ThiDAO thiDAO;
	@Autowired
	SinhVienDAO svDAO;
	@Autowired
	LopDAO lopDAO;
	@Autowired
	MonHocDAO mhDAO;

	// =====================================================
	// 1. Trang danh sách ca thi
	// =====================================================
	@RequestMapping("/thi.htm")
	public String index(HttpSession session, Model model) {
		String maSV = (String) session.getAttribute("masv");

		// Tự động chốt điểm các ca thi đã hết giờ nhưng SV bỏ dở (không quay lại)
		List<Map<String, Object>> dsCaDangDo = thiDAO.layDanhSachCaDangThiTam(maSV);
		for (Map<String, Object> ca : dsCaDangDo) {
			String maMHTam = ca.get("MAMH").toString().trim();
			int lanTam = ((Number) ca.get("LAN")).intValue();
			tuDongNopNeuHetGio(maSV, maMHTam, lanTam);
		}

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

		// Đã có điểm rồi — không cho thi lại, dọn rác nếu còn sót BAITHI_TAM
		if (thiDAO.daThi(maSV, maMH, lan)) {
			thiDAO.xoaBaiThiTam(maSV, maMH, lan);
			session.setAttribute("errorMsg", "Bạn đã hoàn thành ca thi này rồi!");
			return "redirect:/sv/thi.htm";
		}

		// Nếu đã có bài đang làm dở cho ca thi này → vào thẳng trang làm bài, không random lại
		if (thiDAO.coBaiThiTam(maSV, maMH, lan)) {
			session.setAttribute("maMH", maMH);
			session.setAttribute("lan", lan);
			return "redirect:/sv/thi-lamBai.htm";
		}

		// Lấy thông tin ca thi
		GiaoVienDangKy dk = thiDAO.getThongTinCaThi(maSV, maMH, ngayThi, lan);
		if (dk == null) {
			session.setAttribute("errorMsg", "Không tìm thấy ca thi!");
			return "redirect:/sv/thi.htm";
		}

		// Random câu hỏi
		List<CauHoiThi> dsCauHoi = thiDAO.randomCauHoi(maMH, dk.getTrinhDo(), dk.getSoCauThi());

		// Lưu toàn bộ đề mới vào BAITHI_TAM (DAPAN_CHON = null cho từng câu)
		for (int i = 0; i < dsCauHoi.size(); i++) {
			CauHoiThi cau = dsCauHoi.get(i);
			thiDAO.luuTam(maSV, maMH, lan, cau.getCauHoi(), i + 1, null, dk.getThoiGian() * 60);
		}

		// Lưu session
		session.setAttribute("dsCauHoi", dsCauHoi);
		session.setAttribute("maMH", maMH);
		session.setAttribute("lan", lan);
		session.setAttribute("thoiGian", dk.getThoiGian() * 60);
		session.setAttribute("soCauThi", dk.getSoCauThi());

		return "redirect:/sv/thi-lamBai.htm";
	}

	// =====================================================
	// 3. Trang làm bài
	// Luôn lấy dữ liệu (đề + đáp án + thời gian) trực tiếp từ
	// BAITHI_TAM để đảm bảo thời gian được tính chính xác
	// theo thời gian thực, không phụ thuộc giá trị tĩnh lưu
	// trong session (tránh hiện tượng "đứng yên" qua các lần F5)
	// =====================================================
	@RequestMapping("/thi-lamBai.htm")
	public String lamBai(HttpSession session, Model model) {
		String maSV = (String) session.getAttribute("masv");
		String maMH = (String) session.getAttribute("maMH");
		Integer lan = (Integer) session.getAttribute("lan");

		if (maMH == null || lan == null) {
			session.setAttribute("errorMsg", "Vui lòng chọn ca thi trước!");
			return "redirect:/sv/thi.htm";
		}

		if (!thiDAO.coBaiThiTam(maSV, maMH, lan)) {
			session.setAttribute("errorMsg", "Vui lòng chọn ca thi trước!");
			return "redirect:/sv/thi.htm";
		}

		// Lấy lại đề + đáp án đã chọn + thời gian còn lại (tính real-time)
		List<Map<String, Object>> dsTam = thiDAO.khoiPhucBaiThi(maSV, maMH, lan);

		List<CauHoiThi> dsCauHoi = new java.util.ArrayList<>();
		Map<Integer, String> dapAnDaChon = new java.util.HashMap<>();
		int thoiGianConLai = 0;

		for (Map<String, Object> row : dsTam) {
			CauHoiThi cau = new CauHoiThi();
			cau.setCauHoi(((Number) row.get("CAUHOI")).intValue());
			cau.setNoiDung((String) row.get("NOIDUNG"));
			cau.setA((String) row.get("A"));
			cau.setB((String) row.get("B"));
			cau.setC((String) row.get("C"));
			cau.setD((String) row.get("D"));
			dsCauHoi.add(cau);

			Object dapAn = row.get("DAPAN_CHON");
			if (dapAn != null && !dapAn.toString().trim().isEmpty()) {
				dapAnDaChon.put(cau.getCauHoi(), dapAn.toString().trim());
			}
			thoiGianConLai = ((Number) row.get("THOIGIAN_CONLAI")).intValue();
		}

		// Hết giờ thật sự — tự động nộp bài theo đáp án hiện có, không cho vào làm tiếp
		if (thoiGianConLai <= 0) {
			tuDongNopNeuHetGio(maSV, maMH, lan);
			session.removeAttribute("dsCauHoi");
			session.removeAttribute("maMH");
			session.removeAttribute("lan");
			session.removeAttribute("thoiGian");
			session.removeAttribute("soCauThi");
			session.setAttribute("errorMsg", "Đã hết giờ làm bài! Hệ thống đã tự động nộp bài cho bạn.");
			return "redirect:/sv/thi.htm";
		}

		session.setAttribute("dsCauHoi", dsCauHoi);
		session.setAttribute("thoiGian", thoiGianConLai);
		session.setAttribute("soCauThi", dsCauHoi.size());

		model.addAttribute("dsCauHoi", dsCauHoi);
		model.addAttribute("thoiGian", thoiGianConLai);
		model.addAttribute("dapAnDaChon", dapAnDaChon);
		return "sv/thi-lamBai";
	}

	// =====================================================
	// 4. Nộp bài (SV chủ động bấm Nộp bài trên giao diện)
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

		// 1. Ghi điểm vào BANGDIEM trước (bắt buộc do CT_BAITHI có khóa ngoại)
		thiDAO.ghiDiem(maSV, maMH, lan, diem);

		// 2. Lưu chi tiết từng câu vào CT_BAITHI
		int stt = 1;
		for (CauHoiThi cau : dsCauHoi) {
			String dapAnChon = dapAnSV.get("dapAn_" + cau.getCauHoi());
			if (dapAnChon != null && dapAnChon.trim().isEmpty()) {
				dapAnChon = null;
			}
			thiDAO.luuChiTietBaiThi(maSV, maMH, lan, stt, cau.getCauHoi(), dapAnChon);
			stt++;
		}

		// 3. Dọn dữ liệu tạm — không cần thiết nữa
		thiDAO.xoaBaiThiTam(maSV, maMH, lan);

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
		if (maSV == null) return "redirect:/login.htm";

		List<Map<String, Object>> dsKetQua = thiDAO.getKetQuaThi(maSV);
		model.addAttribute("dsKetQua", dsKetQua);
		return "sv/ketqua";
	}

	// =====================================================
	// 7. Xem chi tiết kết quả bài thi
	// =====================================================
	@RequestMapping("/ketqua-chitiet.htm")
	public String ketQuaChiTiet(@RequestParam("maMH") String maMH, @RequestParam("lan") int lan,
			HttpSession session, Model model) {
		String maSV = (String) session.getAttribute("masv");
		if (maSV == null) return "redirect:/login.htm";

		SinhVien sv = svDAO.findByMa(maSV);
		Lop lop = lopDAO.findByMa(sv.getMaLop());
		MonHoc mh = mhDAO.findByMa(maMH);

		// Thêm thông tin sinh viên, lớp, môn học
		model.addAttribute("sv", sv);
		model.addAttribute("lop", lop);
		model.addAttribute("monHoc", mh);

		// Lấy Ngày thi từ điểm (nếu có lưu) hoặc lấy từ danh sách ca thi cũ
		List<Map<String, Object>> dsKetQua = thiDAO.getKetQuaThi(maSV);
		for (Map<String, Object> kq : dsKetQua) {
			if (kq.get("MAMH").toString().trim().equals(maMH.trim()) 
				&& ((Number)kq.get("LAN")).intValue() == lan) {
				model.addAttribute("ngayThi", kq.get("NGAYTHI"));
				model.addAttribute("diem", kq.get("DIEM"));
				break;
			}
		}

		List<Map<String, Object>> chiTiet = thiDAO.getChiTietBaiThi(maSV, maMH, lan);
		model.addAttribute("chiTiet", chiTiet);
		model.addAttribute("maMH", maMH);
		model.addAttribute("lan", lan);

		return "sv/ketqua-chitiet";
	}

	// =====================================================
	// 8. Lưu tạm từng câu hỏi khi SV chọn đáp án (chống mất dữ liệu khi sự cố)
	// =====================================================
	@RequestMapping(value = "/thi-luutam.htm", method = RequestMethod.POST)
	@ResponseBody
	public String luuTam(
			@RequestParam int cauHoi,
			@RequestParam int stt,
			@RequestParam(required = false) String dapAnChon,
			@RequestParam int thoiGianConLai,
			HttpSession session) {
		try {
			String maSV = (String) session.getAttribute("masv");
			String maMH = (String) session.getAttribute("maMH");
			int lan = (int) session.getAttribute("lan");
			thiDAO.luuTam(maSV, maMH, lan, cauHoi, stt, dapAnChon, thoiGianConLai);
			return "OK";
		} catch (Exception e) {
			return "ERROR";
		}
	}

	// =====================================================
	// 9. Heartbeat — JS phía client ping định kỳ để phát hiện sự cố server
	// =====================================================
	@RequestMapping(value = "/thi-ping.htm", method = RequestMethod.GET)
	@ResponseBody
	public String ping() {
		return "OK";
	}

	// =====================================================
	// Helper: lấy đáp án đúng của 1 câu hỏi
	// =====================================================
	private String getDapAnDung(int cauHoi) {
		List<Map<String, Object>> result = thiDAO.getDapAnDung(cauHoi);
		if (result == null || result.isEmpty())
			return "";
		return result.get(0).get("DAP_AN").toString().trim();
	}

	// =====================================================
	// Helper: tự động chấm điểm + nộp bài nếu phát hiện đã hết giờ
	// nhưng SV chưa nộp (do bỏ dở giữa chừng hoặc gặp sự cố).
	// Chỉ tính các câu đã chọn đáp án trong BAITHI_TAM, câu chưa
	// chọn coi như sai — giống hệt cơ chế tự nộp khi hết giờ bình thường.
	//
	// Trả về true nếu đã xử lý xong (đã có điểm từ trước, hoặc vừa
	// chấm điểm xong); false nếu chưa đến lúc cần xử lý (chưa hết giờ).
	// =====================================================
	private boolean tuDongNopNeuHetGio(String maSV, String maMH, int lan) {
		// Đã có điểm rồi — không cần làm gì thêm, chỉ dọn rác nếu còn sót
		if (thiDAO.daThi(maSV, maMH, lan)) {
			thiDAO.xoaBaiThiTam(maSV, maMH, lan);
			return true;
		}

		List<Map<String, Object>> dsTam = thiDAO.khoiPhucBaiThi(maSV, maMH, lan);
		if (dsTam.isEmpty()) {
			return false; // không có bài đang dở cho ca thi này
		}

		int thoiGianConLai = ((Number) dsTam.get(0).get("THOIGIAN_CONLAI")).intValue();
		if (thoiGianConLai > 0) {
			return false; // chưa hết giờ, chưa cần xử lý
		}

		// Hết giờ thật sự — tự động chấm điểm theo đáp án đã có
		int soCauDung = 0;
		int soCauThi = dsTam.size();

		for (Map<String, Object> row : dsTam) {
			Object dapAnObj = row.get("DAPAN_CHON");
			if (dapAnObj == null) continue;
			String dapAnChon = dapAnObj.toString().trim();
			if (dapAnChon.isEmpty()) continue;

			int cauHoi = ((Number) row.get("CAUHOI")).intValue();
			String dapAnDung = getDapAnDung(cauHoi);
			if (dapAnChon.equals(dapAnDung.trim())) {
				soCauDung++;
			}
		}

		double diem = ((double) soCauDung / soCauThi) * 10;
		diem = Math.round(diem * 10.0) / 10.0;

		thiDAO.ghiDiem(maSV, maMH, lan, diem);

		int stt = 1;
		for (Map<String, Object> row : dsTam) {
			int cauHoi = ((Number) row.get("CAUHOI")).intValue();
			Object dapAnObj = row.get("DAPAN_CHON");
			String dapAnChon = (dapAnObj == null || dapAnObj.toString().trim().isEmpty())
					? null : dapAnObj.toString().trim();
			thiDAO.luuChiTietBaiThi(maSV, maMH, lan, stt, cauHoi, dapAnChon);
			stt++;
		}

		thiDAO.xoaBaiThiTam(maSV, maMH, lan);
		return true;
	}
	
	
	//Cap nhat thoi gian thi
	@RequestMapping(value = "/thi-capnhatthoigian.htm", method = RequestMethod.POST)
	@ResponseBody
	public String capNhatThoiGian(@RequestParam int thoiGianConLai, HttpSession session) {
	    try {
	        String maSV = (String) session.getAttribute("masv");
	        String maMH = (String) session.getAttribute("maMH");
	        Integer lan = (Integer) session.getAttribute("lan");
	        if (maMH == null || lan == null) return "ERROR";
	        thiDAO.capNhatThoiGian(maSV, maMH, lan, thoiGianConLai);
	        return "OK";
	    } catch (Exception e) {
	        return "ERROR";
	    }
	}
	
	// API đọc giờ còn lại — dùng cho heartbeat (chỉ đọc, không ghi)
	@RequestMapping(value = "/thi-laythoigian.htm", method = RequestMethod.GET)
	@ResponseBody
	public String layThoiGian(HttpSession session) {
	    try {
	        String maSV = (String) session.getAttribute("masv");
	        String maMH = (String) session.getAttribute("maMH");
	        Integer lan = (Integer) session.getAttribute("lan");
	        if (maMH == null || lan == null) return "{\"error\":true}";
	        Integer giay = thiDAO.layThoiGianConLai(maSV, maMH, lan);
	        if (giay == null) return "{\"error\":true}";
	        return "{\"thoiGianConLai\":" + giay + "}";
	    } catch (Exception e) {
	        return "{\"error\":true}";
	    }
	}
	
	
}