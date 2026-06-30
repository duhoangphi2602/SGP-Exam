package poly.controller;

import java.io.InputStream;
import javax.servlet.http.HttpServletResponse;
import java.util.LinkedHashMap;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.support.TransactionCallback;
import org.springframework.transaction.support.TransactionTemplate;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import poly.dao.BoDeDAO;
import poly.dao.GiaoVienDAO;
import poly.dao.MonHocDAO;
import poly.model.BoDe;

@Controller
public class BoDeController {

	@Autowired
	BoDeDAO boDeDAO;
	@Autowired
	MonHocDAO monHocDAO;
	@Autowired
	GiaoVienDAO giaoVienDAO;
	@Autowired
	PlatformTransactionManager transactionManager;

	// =====================================================
	// Helper: kiểm tra đáp án trùng
	// =====================================================
	private boolean kiemTraDapAnTrung(BoDe bd) {
		Set<String> dapAnSet = new HashSet<>(
				Arrays.asList(bd.getA().trim(), bd.getB().trim(), bd.getC().trim(), bd.getD().trim()));
		return dapAnSet.size() < 4;
	}

	// =====================================================
	// Helper: add data cho form
	// =====================================================
	private void addFormData(Model model, BoDe bd, String action) {
		model.addAttribute("bd", bd);
		model.addAttribute("dsMonHoc", monHocDAO.findAll());
		model.addAttribute("action", action);
	}

	// =====================================================
	// Danh sách bộ đề
	// =====================================================
	@RequestMapping("/gv/bode.htm")
	public String index(@RequestParam(required = false) String maMH, @RequestParam(required = false) String trinhDo,
			@RequestParam(required = false) String noiDung, @RequestParam(required = false) String maGVLoc,
			@RequestParam(required = false) String trangThai, // thêm
			@RequestParam(defaultValue = "1") int page, HttpSession session, Model model) {

		String role = (String) session.getAttribute("role");
		String maGV = (String) session.getAttribute("maGV");

		int pageSize = 10;
		String maGVFilter = role.equals("PGV") ? null : maGV;

		List<BoDe> list = boDeDAO.findByFilterPaged(maMH, trinhDo, maGVFilter, noiDung, maGVLoc, page, pageSize,
				trangThai);
		int total = boDeDAO.countByFilter(maMH, trinhDo, maGVFilter, noiDung, maGVLoc, trangThai);
		int totalPages = (int) Math.ceil((double) total / pageSize);

		// PGV: load danh sách GV để hiện dropdown lọc
		if (role.equals("PGV")) {
			model.addAttribute("dsGiaoVien", giaoVienDAO.findAll());
			model.addAttribute("maGVLoc", maGVLoc);
		}
		// Lấy danh sách cauHoi đã sử dụng để JSP hiện đúng trạng thái
		Set<Integer> daSuDungSet = new java.util.HashSet<>();
		for (BoDe bd : list) {
			if (boDeDAO.daSuDung(bd.getCauHoi())) {
				daSuDungSet.add(bd.getCauHoi());
			}
		}
		model.addAttribute("daSuDungSet", daSuDungSet);
		model.addAttribute("trangThai", trangThai);
		model.addAttribute("list", list);
		model.addAttribute("dsMonHoc", monHocDAO.findAll());
		model.addAttribute("maMH", maMH);
		model.addAttribute("trinhDo", trinhDo);
		model.addAttribute("noiDung", noiDung);
		model.addAttribute("page", page);
		model.addAttribute("totalPages", totalPages);
		model.addAttribute("tongSoCau", total);

		return "gv/bode";
	}

	// =====================================================
	// Xử lý nhập từ file Excel
	// =====================================================

	@RequestMapping(value = "/gv/bode-import-page.htm", method = RequestMethod.GET)
	public String showImportPage() {
		return "gv/bode-import";
	}

	@RequestMapping(value = "/gv/bode-import.htm", method = RequestMethod.POST)
	@ResponseBody
	public String doImport(@RequestParam("file") MultipartFile file, HttpSession session,
			HttpServletResponse response) {
		response.setContentType("text/plain;charset=UTF-8");
		String maGV = (String) session.getAttribute("maGV");

		// Chặn admin chính (PGV không có mã GV) sử dụng chức năng này
		if (maGV == null || maGV.trim().isEmpty()) {
			return "ERROR|Tài khoản của bạn không có mã giáo viên liên kết, không thể nhập câu hỏi từ file. Vui lòng dùng tài khoản giáo viên (hoặc PGV được nâng quyền từ GV) để thực hiện chức năng này.";
		}

		if (file.isEmpty()) {
			return "ERROR|Vui lòng chọn file!";
		}

		List<BoDe> dsCauHoi = new ArrayList<>();
		List<String> loiList = new ArrayList<>();

		// ===== Bước 1: Đọc file Excel =====
		try (InputStream is = file.getInputStream()) {
			Workbook workbook = new XSSFWorkbook(is);
			Sheet sheet = workbook.getSheetAt(0);

			int rowCount = sheet.getLastRowNum();
			for (int i = 1; i <= rowCount; i++) { // bỏ dòng header (i=0)
				Row row = sheet.getRow(i);
				if (row == null)
					continue;

				String maMH = getCellString(row, 0);
				String trinhDo = getCellString(row, 1);
				String noiDung = getCellString(row, 2);
				String a = getCellString(row, 3);
				String b = getCellString(row, 4);
				String c = getCellString(row, 5);
				String d = getCellString(row, 6);
				String dapAn = getCellString(row, 7);

				// Bỏ qua dòng hoàn toàn trống
				if (maMH.isEmpty() && trinhDo.isEmpty() && noiDung.isEmpty())
					continue;

				int soDong = i + 1; // số dòng thực tế trong Excel (tính cả header)

				// ===== Validate cấu trúc =====
				if (maMH.isEmpty() || trinhDo.isEmpty() || noiDung.isEmpty() || a.isEmpty() || b.isEmpty()
						|| c.isEmpty() || d.isEmpty() || dapAn.isEmpty()) {
					loiList.add("Dòng " + soDong + ": Thiếu thông tin (không được để trống các cột)!");
					continue;
				}

				// ===== Validate trình độ =====
				if (!trinhDo.equals("A") && !trinhDo.equals("B") && !trinhDo.equals("C")) {
					loiList.add("Dòng " + soDong + ": Trình độ phải là A, B hoặc C!");
					continue;
				}

				// ===== Validate môn học tồn tại =====
				if (monHocDAO.findByMa(maMH) == null) {
					loiList.add("Dòng " + soDong + ": Mã môn học '" + maMH + "' không tồn tại!");
					continue;
				}

				// ===== Validate đáp án đúng phải thuộc A/B/C/D =====
				if (!dapAn.equals("A") && !dapAn.equals("B") && !dapAn.equals("C") && !dapAn.equals("D")) {
					loiList.add("Dòng " + soDong + ": Đáp án đúng phải là A, B, C hoặc D!");
					continue;
				}

				BoDe bd = new BoDe();
				bd.setMaMH(maMH);
				bd.setTrinhDo(trinhDo);
				bd.setNoiDung(noiDung);
				bd.setA(a);
				bd.setB(b);
				bd.setC(c);
				bd.setD(d);
				bd.setDapAn(dapAn);
				bd.setMaGV(maGV);

				// ===== Validate đáp án trùng nhau - dùng lại hàm có sẵn =====
				if (kiemTraDapAnTrung(bd)) {
					loiList.add("Dòng " + soDong + ": Các đáp án A, B, C, D không được trùng nhau!");
					continue;
				}

				dsCauHoi.add(bd);
			}

			workbook.close();
		} catch (Exception e) {
			return "ERROR|Lỗi đọc file: " + e.getMessage();
		}

		// ===== Bước 2: Nếu có lỗi, dừng lại, không insert gì =====
		if (!loiList.isEmpty()) {
			StringBuilder sb = new StringBuilder();
			for (String loi : loiList) {
				sb.append(loi).append("<br>");
			}
			return "ERROR|" + sb.toString();
		}

		if (dsCauHoi.isEmpty()) {
			return "ERROR|File không có dữ liệu hợp lệ!";
		}

		// ===== Bước 3: Transaction - insert toàn bộ =====
		TransactionTemplate txTemplate = new TransactionTemplate(transactionManager);
		try {
			txTemplate.execute(new TransactionCallback<Void>() {
				@Override
				public Void doInTransaction(TransactionStatus status) {
					for (BoDe bd : dsCauHoi) {
						boDeDAO.insert(bd);
					}
					return null;
				}
			});
			return "OK|Nhập thành công " + dsCauHoi.size() + " câu hỏi!";
		} catch (Exception e) {
			return "ERROR|Lỗi khi lưu vào CSDL, đã hủy toàn bộ: " + e.getMessage();
		}
	}

	// Helper: đọc giá trị cell dạng String an toàn
	private String getCellString(Row row, int colIndex) {
		Cell cell = row.getCell(colIndex);
		if (cell == null)
			return "";
		if (cell.getCellType() == org.apache.poi.ss.usermodel.CellType.NUMERIC) {
			return String.valueOf((long) cell.getNumericCellValue()).trim();
		}
		return cell.getStringCellValue().trim();
	}

	// =====================================================
	// Helper: build rows HTML cho bảng bộ đề
	// =====================================================
	private String buildRowsBoDe(List<BoDe> list, String role) {
		StringBuilder sb = new StringBuilder();
		for (BoDe bd : list) {
			boolean daSuDung = boDeDAO.daSuDung(bd.getCauHoi()); // cache 1 lần
			sb.append("<tr>");
			sb.append("<td class=\"align-middle\">").append(bd.getCauHoi()).append("</td>");
			sb.append("<td class=\"align-middle\">").append(escape(bd.getMaMH())).append("</td>");
			sb.append("<td class=\"align-middle\">").append(escape(bd.getTrinhDo())).append("</td>");
			sb.append("<td class=\"align-middle\">").append(escape(bd.getNoiDung())).append("</td>");
			if ("PGV".equals(role)) {
				sb.append("<td class=\"align-middle\">").append(escape(bd.getMaGV())).append("</td>");
			}
			sb.append("<td class=\"align-middle text-center\" style=\"white-space: nowrap;\">");
			sb.append("<div class=\"d-flex gap-1 justify-content-center\">");
			sb.append("<button type=\"button\" class=\"btn btn-secondary\" ").append("onclick=\"xemChiTiet(")
					.append(bd.getCauHoi()).append(",").append(daSuDung ? "true" : "false").append(")\">Xem</button>");
			if (!daSuDung) {
				sb.append("<button type=\"button\" class=\"btn btn-sm btn-warning\" ").append("onclick=\"moModalSua(")
						.append(bd.getCauHoi()).append(")\">Sửa</button>");
				sb.append("<button type=\"button\" class=\"btn btn-sm btn-danger\" ").append("onclick=\"xoaBoDe(")
						.append(bd.getCauHoi()).append(")\">Xóa</button>");
			}
			sb.append("</div>");
			sb.append("</td>");
			sb.append("</tr>");
		}
		return sb.toString();
	}

	// Helper: build phân trang HTML
	private String buildPagination(int page, int totalPages, String maMH, String trinhDo, String noiDung,
			String maGVLoc, String trangThai) {
		if (totalPages <= 1)
			return "";
		String base = "bode.htm?maMH=" + nvl(maMH) + "&trinhDo=" + nvl(trinhDo) + "&noiDung=" + nvl(noiDung)
				+ "&maGVLoc=" + nvl(maGVLoc) + "&trangThai=" + nvl(trangThai) + "&page=";
		StringBuilder sb = new StringBuilder("<ul class=\"pagination\">");
		if (page > 1) {
			sb.append("<li class=\"page-item\"><a class=\"page-link\" href=\"").append(base).append(page - 1)
					.append("\">&laquo; Trước</a></li>");
		}
		for (int i = 1; i <= totalPages; i++) {
			sb.append("<li class=\"page-item ").append(i == page ? "active" : "").append("\">")
					.append("<a class=\"page-link\" href=\"").append(base).append(i).append("\">").append(i)
					.append("</a></li>");
		}
		if (page < totalPages) {
			sb.append("<li class=\"page-item\"><a class=\"page-link\" href=\"").append(base).append(page + 1)
					.append("\">Sau &raquo;</a></li>");
		}
		sb.append("</ul>");
		return sb.toString();
	}

	private String nvl(String s) {
		return s == null ? "" : s;
	}

	private String escape(String s) {
		if (s == null)
			return "";
		return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
	}

	// =====================================================
	// AJAX: Load data câu hỏi (dùng sau Thêm/Sửa/Xóa)
	// =====================================================
	@RequestMapping(value = "/gv/bode-data.htm", method = RequestMethod.GET)
	@ResponseBody
	public String getData(@RequestParam(required = false) String maMH, @RequestParam(required = false) String trinhDo,
			@RequestParam(required = false) String noiDung, @RequestParam(required = false) String maGVLoc,
			@RequestParam(required = false) String trangThai, // thêm
			@RequestParam(defaultValue = "1") int page, HttpSession session, HttpServletResponse response) {
		response.setContentType("text/plain;charset=UTF-8");

		String role = (String) session.getAttribute("role");
		String maGV = (String) session.getAttribute("maGV");
		String maGVFilter = "PGV".equals(role) ? null : maGV;

		int pageSize = 10;
		List<BoDe> list = boDeDAO.findByFilterPaged(maMH, trinhDo, maGVFilter, noiDung, maGVLoc, page, pageSize,
				trangThai);
		int total = boDeDAO.countByFilter(maMH, trinhDo, maGVFilter, noiDung, maGVLoc, trangThai);
		int totalPages = (int) Math.ceil((double) total / pageSize);

		String rows = buildRowsBoDe(list, role);
		String pagination = buildPagination(page, totalPages, maMH, trinhDo, noiDung, maGVLoc, trangThai);

		// Format: "TOTAL|ROWS_HTML|PAGINATION_HTML"
		// Dùng dấu phân cách đặc biệt để tránh xung đột với nội dung HTML
		return total + "\u0001" + rows + "\u0001" + pagination;
	}

	// =====================================================
	// AJAX: Thêm câu hỏi
	// =====================================================
	@RequestMapping(value = "/gv/bode-them-ajax.htm", method = RequestMethod.POST)
	@ResponseBody
	public String doThemAjax(@RequestParam String maMH, @RequestParam String trinhDo, @RequestParam String noiDung,
			@RequestParam String a, @RequestParam String b, @RequestParam String c, @RequestParam String d,
			@RequestParam String dapAn, HttpSession session, HttpServletResponse response) {
		response.setContentType("text/plain;charset=UTF-8");

		String maGV = (String) session.getAttribute("maGV");
		if (maGV == null || maGV.trim().isEmpty()) {
			return "ERROR|Tài khoản không có mã giáo viên, không thể thêm câu hỏi!";
		}

		BoDe bd = new BoDe();
		bd.setMaMH(maMH);
		bd.setTrinhDo(trinhDo);
		bd.setNoiDung(noiDung);
		bd.setA(a);
		bd.setB(b);
		bd.setC(c);
		bd.setD(d);
		bd.setDapAn(dapAn);
		bd.setMaGV(maGV);

		if (kiemTraDapAnTrung(bd)) {
			return "ERROR|Các đáp án không được trùng nhau!";
		}

		try {
			boDeDAO.insert(bd);
			return "OK|Thêm câu hỏi thành công!";
		} catch (Exception e) {
			return "ERROR|Lỗi: " + e.getMessage();
		}
	}

	// =====================================================
	// AJAX: Lấy data 1 câu hỏi để load vào modal Sửa
	// =====================================================
	@RequestMapping(value = "/gv/bode-get.htm", method = RequestMethod.GET)
	@ResponseBody
	public String getCauHoi(@RequestParam int cauHoi, HttpServletResponse response) {
		response.setContentType("text/plain;charset=UTF-8");
		BoDe bd = boDeDAO.findByCauHoi(cauHoi);
		if (bd == null)
			return "ERROR|Không tìm thấy câu hỏi!";

		// Trả về dạng: "cauHoi|maMH|trinhDo|noiDung|a|b|c|d|dapAn"
		return "OK" + "\u0001" + bd.getCauHoi() + "\u0001" + nvl(bd.getMaMH()) + "\u0001" + nvl(bd.getTrinhDo())
				+ "\u0001" + nvl(bd.getNoiDung()) + "\u0001" + nvl(bd.getA()) + "\u0001" + nvl(bd.getB()) + "\u0001"
				+ nvl(bd.getC()) + "\u0001" + nvl(bd.getD()) + "\u0001" + nvl(bd.getDapAn());
	}

	// =====================================================
	// AJAX: Sửa câu hỏi
	// =====================================================
	@RequestMapping(value = "/gv/bode-sua-ajax.htm", method = RequestMethod.POST)
	@ResponseBody
	public String doSuaAjax(@RequestParam int cauHoi, @RequestParam String trinhDo, @RequestParam String noiDung,
			@RequestParam String a, @RequestParam String b, @RequestParam String c, @RequestParam String d,
			@RequestParam String dapAn, @RequestParam String maMH, HttpServletResponse response) {
		response.setContentType("text/plain;charset=UTF-8");

		BoDe bd = new BoDe();
		bd.setCauHoi(cauHoi);
		bd.setMaMH(maMH);
		bd.setTrinhDo(trinhDo);
		bd.setNoiDung(noiDung);
		bd.setA(a);
		bd.setB(b);
		bd.setC(c);
		bd.setD(d);
		bd.setDapAn(dapAn);

		if (kiemTraDapAnTrung(bd)) {
			return "ERROR|Các đáp án không được trùng nhau!";
		}

		try {
			boDeDAO.update(bd);
			return "OK|Cập nhật câu hỏi thành công!";
		} catch (Exception e) {
			return "ERROR|Lỗi: " + e.getMessage();
		}
	}

	// =====================================================
	// AJAX: Xóa câu hỏi
	// =====================================================
	@RequestMapping(value = "/gv/bode-xoa-ajax.htm", method = RequestMethod.POST)
	@ResponseBody
	public String doXoaAjax(@RequestParam int cauHoi, HttpSession session, HttpServletResponse response) {
		response.setContentType("text/plain;charset=UTF-8");
		try {
			boDeDAO.delete(cauHoi);
			return "OK|Xóa câu hỏi thành công!";
		} catch (Exception e) {
			return "ERROR|Lỗi: " + e.getMessage();
		}
	}

	@RequestMapping(value = "/gv/bode-get-readonly.htm", method = RequestMethod.GET)
	@ResponseBody
	public String getCauHoiReadonly(@RequestParam int cauHoi, HttpServletResponse response) {
		response.setContentType("text/plain;charset=UTF-8");
		BoDe bd = boDeDAO.findByCauHoi(cauHoi);
		if (bd == null)
			return "ERROR|Không tìm thấy câu hỏi!";
		return "OK" + "\u0001" + bd.getCauHoi() + "\u0001" + nvl(bd.getMaMH()) + "\u0001" + nvl(bd.getTrinhDo())
				+ "\u0001" + nvl(bd.getNoiDung()) + "\u0001" + nvl(bd.getA()) + "\u0001" + nvl(bd.getB()) + "\u0001"
				+ nvl(bd.getC()) + "\u0001" + nvl(bd.getD()) + "\u0001" + nvl(bd.getDapAn());
	}

	// =====================================================
	// AJAX: Tính facet — biết lựa chọn nào trong dropdown sẽ ra 0 kết quả
	// =====================================================
	@RequestMapping(value = "/gv/bode-facets.htm", method = RequestMethod.GET)
	@ResponseBody
	public String getFacets(@RequestParam(required = false) String maMH, @RequestParam(required = false) String trinhDo,
			@RequestParam(required = false) String noiDung, @RequestParam(required = false) String maGVLoc,
			@RequestParam(required = false) String trangThai, HttpSession session, HttpServletResponse response) {
		response.setContentType("application/json;charset=UTF-8");

		String role = (String) session.getAttribute("role");
		String maGV = (String) session.getAttribute("maGV");
		String maGVFilter = "PGV".equals(role) ? null : maGV;

		StringBuilder json = new StringBuilder("{");

		// ----- Môn học -----
		json.append("\"maMH\":{");
		List<poly.model.MonHoc> dsMonHoc = monHocDAO.findAll();
		for (int i = 0; i < dsMonHoc.size(); i++) {
			String ma = dsMonHoc.get(i).getMaMH();
			int c = boDeDAO.countByFilter(ma, trinhDo, maGVFilter, noiDung, maGVLoc, trangThai);
			json.append("\"").append(ma).append("\":").append(c > 0 ? 1 : 0);
			if (i < dsMonHoc.size() - 1)
				json.append(",");
		}
		json.append("},");

		// ----- Trình độ -----
		json.append("\"trinhDo\":{");
		String[] dsTrinhDo = { "A", "B", "C" };
		for (int i = 0; i < dsTrinhDo.length; i++) {
			int c = boDeDAO.countByFilter(maMH, dsTrinhDo[i], maGVFilter, noiDung, maGVLoc, trangThai);
			json.append("\"").append(dsTrinhDo[i]).append("\":").append(c > 0 ? 1 : 0);
			if (i < dsTrinhDo.length - 1)
				json.append(",");
		}
		json.append("},");

		// ----- Trạng thái -----
		json.append("\"trangThai\":{");
		String[] dsTrangThai = { "DA_DUNG", "CHUA_DUNG" };
		for (int i = 0; i < dsTrangThai.length; i++) {
			int c = boDeDAO.countByFilter(maMH, trinhDo, maGVFilter, noiDung, maGVLoc, dsTrangThai[i]);
			json.append("\"").append(dsTrangThai[i]).append("\":").append(c > 0 ? 1 : 0);
			if (i < dsTrangThai.length - 1)
				json.append(",");
		}
		json.append("}");

		// ----- Mã GV (chỉ PGV mới có dropdown này) -----
		if ("PGV".equals(role)) {
			json.append(",\"maGVLoc\":{");
			List<poly.model.GiaoVien> dsGiaoVien = giaoVienDAO.findAll();
			for (int i = 0; i < dsGiaoVien.size(); i++) {
				String ma = dsGiaoVien.get(i).getMaGV();
				int c = boDeDAO.countByFilter(maMH, trinhDo, maGVFilter, noiDung, ma, trangThai);
				json.append("\"").append(ma).append("\":").append(c > 0 ? 1 : 0);
				if (i < dsGiaoVien.size() - 1)
					json.append(",");
			}
			json.append("}");
		}

		json.append("}");
		return json.toString();
	}

}