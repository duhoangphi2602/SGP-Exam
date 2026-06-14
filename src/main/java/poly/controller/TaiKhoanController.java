package poly.controller;

import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import poly.dao.GiaoVienDAO;
import poly.model.GiaoVien;

@Controller
@RequestMapping("/pgv")
public class TaiKhoanController {

    @Autowired JdbcTemplate db;
    @Autowired GiaoVienDAO giaoVienDAO;

    @RequestMapping("/taikhoan.htm")
    public String index(Model model) {
        model.addAttribute("dsGV", giaoVienDAO.findAll());
        return "pgv/taikhoan";
    }

    // Kiểm tra GV đã có tài khoản chưa (AJAX)
    @RequestMapping("/taikhoan-check.htm")
    @ResponseBody
    public String checkTaiKhoan(@RequestParam String maGV) {
        List<Map<String, Object>> result = db.queryForList(
            "EXEC sp_ThongTinDangNhap ?", maGV);
        if (result.isEmpty()) {
            return "CHUA_CO";
        }
        String role = result.get(0).get("Rolename").toString();
        String loginName = result.get(0).get("Username").toString().trim();
        return role + "|" + loginName; // trả về "GIAOVIEN|phanhai"
    }

    // Tạo tài khoản
    @RequestMapping(value = "/taikhoan-them.htm", method = RequestMethod.POST)
    public String doThem(
            @RequestParam String maGV,
            @RequestParam String taiKhoan,
            @RequestParam String matMa,
            @RequestParam String nhomQuyen,
            HttpSession session, Model model) {
        try {
            db.update("EXEC SP_TAOTAIKHOAN ?, ?, ?, ?",
                taiKhoan.trim(), matMa.trim(), maGV.trim(), nhomQuyen.trim());
            if (nhomQuyen.equals("PGV")) {
                db.update("EXEC sp_addsrvrolemember '" + taiKhoan.trim() + "', 'securityadmin'");
            }
            session.setAttribute("successMsg", "Tạo tài khoản thành công cho: " + maGV);
            return "redirect:/pgv/taikhoan.htm";
        } catch (Exception e) {
            String err = e.getMessage();
            if (err.contains("already exists") || err.contains("15025")
                    || err.contains("Login đã tồn tại")) {
                model.addAttribute("error", 
                    "Tên đăng nhập '" + taiKhoan.trim() + "' đã tồn tại!");
            } else {
                model.addAttribute("error", "Lỗi: " + err);
            }
            model.addAttribute("dsGV", giaoVienDAO.findAll());
            return "pgv/taikhoan";
        }
    }
    
    @RequestMapping("/taikhoan-xoa.htm")
    @ResponseBody
    public String doXoa(@RequestParam String lgname) {
        try {
            db.update("EXEC SP_XOATAIKHOAN ?", lgname.trim());
            return "OK";
        } catch (Exception e) {
            return "ERROR: " + e.getMessage();
        }
    }
    
    @RequestMapping("/taikhoan-nangquyen.htm")
    @ResponseBody
    public String doNangQuyen(@RequestParam String lgname) {
        try {
            db.update("EXEC SP_NANGQUYEN_PGV ?", lgname.trim());
            return "OK";
        } catch (Exception e) {
            return "ERROR: " + e.getMessage();
        }
    }
}