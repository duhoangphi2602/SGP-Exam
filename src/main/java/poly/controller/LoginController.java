package poly.controller;

import java.sql.Connection;
import java.sql.DriverManager;
import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import poly.dao.SinhVienDAO;
import poly.model.SinhVien;

@Controller
public class LoginController {

	@Autowired
	SinhVienDAO svDAO;

	@Autowired
	JdbcTemplate db;	

	@RequestMapping(value = "/login.htm", method = RequestMethod.GET)
	public String showLogin() {
		return "login";
	}

	@RequestMapping(value = "/login.htm", method = RequestMethod.POST)
	public String doLogin(@RequestParam String username, @RequestParam String password, @RequestParam String loai,
			HttpSession session, Model model) {
		try {
			String url = "jdbc:sqlserver://localhost:1433;databaseName=THITRACNGHIEM;encrypt=false;trustServerCertificate=true";

			if (loai.equals("SINHVIEN")) {
				// Sinh vien dung tai khoan chung
				Connection conn = DriverManager.getConnection(url, "sinhvien", "123456");
				conn.close();

				// Kiểm tra MASV + PASSWORD
				SinhVien sv = svDAO.dangNhap(username.trim(), password.trim());

				if (sv == null) {
					model.addAttribute("error", "Mã SV hoặc mật khẩu không đúng!");
					return "login";
				}

				session.setAttribute("username", username.trim());
				session.setAttribute("role", "SINHVIEN");
				session.setAttribute("masv", username.trim());
				return "redirect:/sv/home.htm";
			} else {
				// Giảng viên / PGV dùng tài khoản riêng
				Connection conn = DriverManager.getConnection(url, username, password);
				conn.close();

				// Lấy role + MAGV
				List<Map<String, Object>> result = db.queryForList("EXEC sp_ThongTinDangNhap ?", username);

				if (result.isEmpty()) {
					model.addAttribute("error", "Tài khoản không có quyền truy cập!");
					return "login";
				}

				String role = result.get(0).get("Rolename").toString();
				String dbUsername = result.get(0).get("DBUsername").toString().trim();

				// Lưu session
				session.setAttribute("username", username); // login name
				session.setAttribute("role", role);
				session.setAttribute("maGV", dbUsername); // MAGV thật

				if (role.equals("PGV")) {
					return "redirect:/pgv/home.htm";
				} else {
					return "redirect:/gv/home.htm";
				}
			}

		} catch (Exception e) {
			model.addAttribute("error", "Sai tên đăng nhập hoặc mật khẩu!");
			return "login";
		}
	}

	// dang xuat
	@RequestMapping("/logout.htm")
	public String logout(HttpSession session) {
		session.invalidate();
		return "redirect:/login.htm";
	}

	// Hiển thị form đăng ký
	@RequestMapping(value = "/dangky.htm", method = RequestMethod.GET)
	public String showDangKy() {
		return "dangky";
	}

	// Xử lý đăng ký
	@RequestMapping(value = "/dangky.htm", method = RequestMethod.POST)
	public String doDangKy(@RequestParam String masv, @RequestParam String passwordMoi, @RequestParam String xacNhan,
			Model model) {

		// Kiểm tra password khớp
		if (!passwordMoi.equals(xacNhan)) {
			model.addAttribute("error", "Mật khẩu xác nhận không khớp!");
			return "dangky";
		}

		// Kiểm tra MASV tồn tại
		SinhVien sv = svDAO.findByMa(masv.trim());
		if (sv == null) {
			model.addAttribute("error", "Mã SV không tồn tại!");
			return "dangky";
		}

		svDAO.dangKy(masv.trim(), passwordMoi.trim());
		model.addAttribute("success", "Đăng ký thành công! Vui lòng đăng nhập.");
		return "dangky";
	}
}