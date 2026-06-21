package poly.controller;

import java.io.InputStream;
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
			@RequestParam(defaultValue = "1") int page, HttpSession session, Model model) {

		String role = (String) session.getAttribute("role");
		String maGV = (String) session.getAttribute("maGV");

		int pageSize = 10;
		String maGVFilter = role.equals("PGV") ? null : maGV;

		List<BoDe> list = boDeDAO.findByFilterPaged(maMH, trinhDo, maGVFilter, noiDung, maGVLoc, page, pageSize);
		int total = boDeDAO.countByFilter(maMH, trinhDo, maGVFilter, noiDung, maGVLoc);
		int totalPages = (int) Math.ceil((double) total / pageSize);

		// PGV: load danh sách GV để hiện dropdown lọc
		if (role.equals("PGV")) {
			model.addAttribute("dsGiaoVien", giaoVienDAO.findAll());
			model.addAttribute("maGVLoc", maGVLoc);
		}

		model.addAttribute("list", list);
		model.addAttribute("dsMonHoc", monHocDAO.findAll());
		model.addAttribute("maMH", maMH);
		model.addAttribute("trinhDo", trinhDo);
		model.addAttribute("noiDung", noiDung);
		model.addAttribute("page", page);
		model.addAttribute("totalPages", totalPages);
		return "gv/bode";
	}

	// =====================================================
	// Thêm câu hỏi - GET
	// =====================================================
	@RequestMapping(value = "/gv/bode-them.htm", method = RequestMethod.GET)
	public String showThem(Model model) {
		addFormData(model, new BoDe(), "them");
		return "gv/bode-form";
	}

	// =====================================================
	// Thêm câu hỏi - POST
	// =====================================================
	@RequestMapping(value = "/gv/bode-them.htm", method = RequestMethod.POST)
	public String doThem(@ModelAttribute BoDe bd, HttpSession session, Model model) {
		bd.setMaGV((String) session.getAttribute("maGV"));

		if (kiemTraDapAnTrung(bd)) {
			model.addAttribute("error", "Các đáp án không được trùng nhau!");
			addFormData(model, bd, "them");
			return "gv/bode-form";
		}

		try {
			boDeDAO.insert(bd);
			model.addAttribute("successMsg", "Thêm câu hỏi thành công!");
			addFormData(model, bd, "them");
			return "gv/bode-form";
		} catch (Exception e) {
			model.addAttribute("error", "Lỗi khi cập nhật câu hỏi: " + e.getMessage());
			addFormData(model, bd, "them");
			return "gv/bode-form";
		}
	}

	// =====================================================
	// Sửa câu hỏi - GET
	// =====================================================
	@RequestMapping(value = "/gv/bode-sua.htm", method = RequestMethod.GET)
	public String showSua(@RequestParam int cauHoi, Model model) {
		addFormData(model, boDeDAO.findByCauHoi(cauHoi), "sua");
		return "gv/bode-form";
	}

	// =====================================================
	// Sửa câu hỏi - POST
	// =====================================================
	@RequestMapping(value = "/gv/bode-sua.htm", method = RequestMethod.POST)
	public String doSua(@ModelAttribute BoDe bd, HttpSession session, Model model) {
		if (boDeDAO.daSuDung(bd.getCauHoi())) {
			model.addAttribute("error", "Không thể sửa câu hỏi này vì đã được sử dụng trong bài thi!");
			addFormData(model, bd, "sua");
			return "gv/bode-form";
		}

		if (kiemTraDapAnTrung(bd)) {
			model.addAttribute("error", "Các đáp án không được trùng nhau!");
			addFormData(model, bd, "sua");
			return "gv/bode-form";
		}

		try {
			boDeDAO.update(bd);
			model.addAttribute("successMsg", "Cập nhật câu hỏi thành công!");
			addFormData(model, bd, "sua");
			return "gv/bode-form";
		} catch (Exception e) {
			model.addAttribute("error", "Lỗi khi cập nhật câu hỏi: " + e.getMessage());
			addFormData(model, bd, "sua");
			return "gv/bode-form";
		}
	}

	// =====================================================
	// Xóa câu hỏi
	// =====================================================
	@RequestMapping("/gv/bode-xoa.htm")
	public String doXoa(@RequestParam int cauHoi, HttpSession session) {
		if (boDeDAO.daSuDung(cauHoi)) {
			session.setAttribute("errorMsg", "Không thể xóa câu hỏi này vì đã được sử dụng trong bài thi!");
			return "redirect:/gv/bode.htm";
		}
		boDeDAO.delete(cauHoi);
		session.setAttribute("successMsg", "Xóa câu hỏi thành công!");
		return "redirect:/gv/bode.htm";
	}

	// =====================================================
	// Hiển thị form nhập từ file
	// =====================================================
	@RequestMapping(value = "/gv/bode-import.htm", method = RequestMethod.GET)
	public String showImport(Model model) {
		return "gv/bode-import";
	}

	// =====================================================
	// Xử lý nhập từ file Excel
	// =====================================================
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

				// ===== Validate đáp án trùng nhau =====
				Set<String> dapAnSet = new HashSet<>();
				dapAnSet.add(a.trim());
				dapAnSet.add(b.trim());
				dapAnSet.add(c.trim());
				dapAnSet.add(d.trim());
				if (dapAnSet.size() < 4) {
					loiList.add("Dòng " + soDong + ": Các đáp án A, B, C, D không được trùng nhau!");
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
}