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
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class LoginController {

    @Autowired
    JdbcTemplate db;

    // Hiển thị trang login
    @RequestMapping(value = "/login.htm", method = RequestMethod.GET)
    public String showLogin() {
        return "login";
    }

    // Xử lý đăng nhập
    @RequestMapping(value = "/login.htm", method = RequestMethod.POST)
    public String doLogin(
            @RequestParam String username,
            @RequestParam String password,
            HttpSession session,
            Model model) {

        try {
            // Thử kết nối bằng credentials của user
            String url = "jdbc:sqlserver://localhost:1433;databaseName=THITRACNGHIEM;encrypt=false";
            Connection conn = DriverManager.getConnection(url, username, password);
            conn.close();

            // Lấy thông tin role
            List<Map<String, Object>> result = db.queryForList(
                "EXEC sp_ThongTinDangNhap ?", username);

            if (result.isEmpty()) {
                model.addAttribute("error", "Tài khoản không có quyền truy cập!");
                return "login";
            }

            String role = result.get(0).get("Rolename").toString();

            // Lưu session
            session.setAttribute("username", username);
            session.setAttribute("role", role);

            // Redirect theo role
            if (role.equals("PGV")) {
                return "redirect:/pgv/home.htm";
            } else if (role.equals("GIAOVIEN")) {
                return "redirect:/gv/home.htm";
            } else if (role.equals("SINHVIEN")) {
                return "redirect:/sv/home.htm";
            }

        } catch (Exception e) {
            model.addAttribute("error", "Sai tên đăng nhập hoặc mật khẩu!");
            return "login";
        }

        return "login";
    }

    // Đăng xuất
    @RequestMapping("/logout.htm")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/login.htm";
    }
}