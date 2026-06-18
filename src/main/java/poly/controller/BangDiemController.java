package poly.controller;

import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import poly.dao.LopDAO;
import poly.dao.MonHocDAO;
import poly.dao.ThiDAO;

@Controller
@RequestMapping("/gv")
public class BangDiemController {

    @Autowired
    LopDAO lopDAO;

    @Autowired
    MonHocDAO monHocDAO;

    @Autowired
    ThiDAO thiDAO;

    @RequestMapping("/bangdiem.htm")
    public String showBangDiem(
            @RequestParam(required = false) String maLop,
            @RequestParam(required = false) String maMH,
            @RequestParam(required = false) Integer lan,
            HttpSession session,
            Model model) {
        
        // Chặn nếu chưa đăng nhập hoặc là sinh viên
        String role = (String) session.getAttribute("role");
        if (role == null || role.equals("SINHVIEN")) {
            return "redirect:/login.htm";
        }

        // Đổ dữ liệu ra 2 dropdown Lớp và Môn Học
        model.addAttribute("dsLop", lopDAO.findAll());
        model.addAttribute("dsMH", monHocDAO.findAll());

        // Nếu người dùng đã chọn form và bấm Xem
        if (maLop != null && !maLop.trim().isEmpty() && 
            maMH != null && !maMH.trim().isEmpty() && 
            lan != null) {
            
            List<Map<String, Object>> bangDiem = thiDAO.getBangDiemLop(maLop.trim(), maMH.trim(), lan);
            
            model.addAttribute("bangDiem", bangDiem);
            model.addAttribute("maLopSelected", maLop.trim());
            model.addAttribute("maMHSelected", maMH.trim());
            model.addAttribute("lanSelected", lan);
        }

        return "gv/bangdiem";
    }
}