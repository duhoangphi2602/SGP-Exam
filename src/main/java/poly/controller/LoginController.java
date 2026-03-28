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

@Controller
public class LoginController {

    @Autowired
    JdbcTemplate db;

    @RequestMapping(value = "/login.htm", method = RequestMethod.GET)
    public String showLogin() {
        return "login";
    }

    @RequestMapping(value = "/login.htm", method = RequestMethod.POST)
    public String doLogin(
            @RequestParam String username,
            @RequestParam String password,
            @RequestParam String loai,
            HttpSession session,
            Model model) {
        try {
            String url = "jdbc:sqlserver://localhost:1433;databaseName=THITRACNGHIEM;encrypt=false";

            if (loai.equals("SINHVIEN")) {
                // Sinh viên dùng tài khoản chung
                Connection conn = DriverManager.getConnection(url, "sinhvien", "123456");
                conn.close();

                // Kiểm tra MASV có tồn tại không
                List<Map<String, Object>> svList = db.queryForList(
                    "EXEC SP_SV_GETBYMA ?", username.trim());

                if (svList.isEmpty()) {
                    model.addAttribute("error", "Mã SV không tồn tại!");
                    return "login";
                }

                // Lưu session
                session.setAttribute("username", username.trim());
                session.setAttribute("role", "SINHVIEN");
                session.setAttribute("masv", username.trim());
                return "redirect:/sv/home.htm";

            } else {
                // Giảng viên / PGV dùng tài khoản riêng
                Connection conn = DriverManager.getConnection(url, username, password);
                conn.close();

                // Lấy role + MAGV
                List<Map<String, Object>> result = db.queryForList(
                    "EXEC sp_ThongTinDangNhap ?", username);

                if (result.isEmpty()) {
                    model.addAttribute("error", "Tài khoản không có quyền truy cập!");
                    return "login";
                }

                String role = result.get(0).get("Rolename").toString();
                String dbUsername = result.get(0).get("DBUsername").toString().trim();

                // Lưu session
                session.setAttribute("username", username);  // login name
                session.setAttribute("role", role);
                session.setAttribute("maGV", dbUsername);    // MAGV thật

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

    @RequestMapping("/logout.htm")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/login.htm";
    }
}