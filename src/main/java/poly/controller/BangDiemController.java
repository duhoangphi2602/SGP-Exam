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
    @Autowired LopDAO lopDAO;
    @Autowired MonHocDAO monHocDAO;
    @Autowired ThiDAO thiDAO;

    // Trang danh sách ca thi (Dạng A)
    @RequestMapping("/bangdiem.htm")
    public String showBangDiem(
            @RequestParam(required = false) String maLop,
            @RequestParam(required = false) String maMH,
            @RequestParam(required = false) Integer lan,
            HttpSession session, Model model) {

        String role = (String) session.getAttribute("role");
        if (role == null || role.equals("SINHVIEN")) {
            return "redirect:/login.htm";
        }

        // SỬA: dùng maGV đúng từ session
        String maGV = role.equals("PGV") ? null : (String) session.getAttribute("maGV");

        // Lấy danh sách ca thi kèm thống kê
        List<Map<String, Object>> dsCaThi = thiDAO.getDanhSachCaThi_BangDiem(maGV, maLop, maMH, lan);

        model.addAttribute("dsCaThi", dsCaThi);
        model.addAttribute("dsLop", lopDAO.findAll());
        model.addAttribute("dsMH", monHocDAO.findAll());
        model.addAttribute("maLopSelected", maLop);
        model.addAttribute("maMHSelected", maMH);
        model.addAttribute("lanSelected", lan);
        return "gv/bangdiem";
    }

    // Trang chi tiết bảng điểm 1 ca thi
    @RequestMapping("/bangdiem-chitiet.htm")
    public String showChiTiet(
            @RequestParam String maLop,
            @RequestParam String maMH,
            @RequestParam int lan,
            HttpSession session, Model model) {

        String role = (String) session.getAttribute("role");
        String maGV = role.equals("PGV") ? null : (String) session.getAttribute("maGV");

        List<Map<String, Object>> bangDiem = thiDAO.getBangDiemLop(maLop, maMH, lan, maGV);

        model.addAttribute("bangDiem", bangDiem);
        model.addAttribute("maLop", maLop);
        model.addAttribute("maMH", maMH);
        model.addAttribute("lan", lan);
        return "gv/bangdiem-chitiet";
    }
}