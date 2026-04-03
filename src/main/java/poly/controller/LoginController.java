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
        
        String url = "jdbc:sqlserver://localhost:1433;databaseName=THITRACNGHIEM;encrypt=false";

        try {
            if (loai.equals("SINHVIEN")) {
                // 1. Kết nối bằng tài khoản chung (để mở cổng)
                Connection conn = DriverManager.getConnection(url, "sinhvien", "123456");
                conn.close();

                // 2. Xác thực thông tin sinh viên cá nhân
                List<Map<String, Object>> svList = db.queryForList(
                    "EXEC SP_SV_DANGNHAP ?, ?", username.trim(), password);

                if (svList.isEmpty()) {
                    model.addAttribute("error", "Mã sinh viên hoặc mật khẩu không đúng!");
                    return "login";
                }

                // 3. Lưu Session an toàn
                Map<String, Object> sv = svList.get(0);
                session.setAttribute("username", username.trim());
                session.setAttribute("role", "SINHVIEN");
                session.setAttribute("masv", username.trim());
                
                String hoTen = (sv.get("HO") != null ? sv.get("HO").toString().trim() : "") + " " + 
                               (sv.get("TEN") != null ? sv.get("TEN").toString().trim() : "");
                session.setAttribute("hoTen", hoTen);
                
                return "redirect:/sv/home.htm";

            } else {
                // 1. Kết nối bằng tài khoản SQL cá nhân (pgv01/gv01)
                // Lỗi "Login failed" xảy ra chính xác tại dòng này
                Connection conn = DriverManager.getConnection(url, username, password);
                conn.close();

                // 2. Lấy thông tin Role và DBUsername từ SP
                List<Map<String, Object>> result = db.queryForList("EXEC sp_ThongTinDangNhap ?", username);

                // KIỂM TRA AN TOÀN: Tránh lỗi NullPointerException
                if (result.isEmpty()) {
                    model.addAttribute("error", "Tài khoản không có quyền truy cập!");
                    return "login";
                }

                Map<String, Object> row = result.get(0);
                
                // Kiểm tra xem cột Rolename có bị NULL trong DB không
                if (row.get("Rolename") == null) {
                    model.addAttribute("error", "Tài khoản chưa được phân quyền trên hệ thống!");
                    return "login";
                }

                String role = row.get("Rolename").toString().trim();
                String dbUsername = (row.get("DBUsername") != null) ? row.get("DBUsername").toString().trim() : username;

                // 3. Lưu session
                session.setAttribute("username", username);  
                session.setAttribute("role", role);
                session.setAttribute("maGV", dbUsername);    

                if (role.equalsIgnoreCase("PGV")) {
                    return "redirect:/pgv/home.htm";
                } else {
                    return "redirect:/gv/home.htm";
                }
            }

        } catch (Exception e) {
            // In lỗi ra Console để bạn nhìn thấy nguyên nhân thật sự (Login failed hay lỗi khác)
            e.printStackTrace();
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