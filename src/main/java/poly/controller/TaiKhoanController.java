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
        return result.get(0).get("Rolename").toString();
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
                    taiKhoan.trim(), matMa.trim(), taiKhoan.trim(), nhomQuyen.trim());

            if (nhomQuyen.equals("PGV")) {
            	db.update("EXEC sp_addsrvrolemember '" + taiKhoan.trim() + "', 'securityadmin'");
            }

            session.setAttribute("successMsg", 
                "Tạo tài khoản thành công cho: " + maGV);
            return "redirect:/pgv/taikhoan.htm";
        } catch (Exception e) {
            model.addAttribute("error", e.getMessage());
            model.addAttribute("dsGV", giaoVienDAO.findAll());
            return "pgv/taikhoan";
        }
    }
}