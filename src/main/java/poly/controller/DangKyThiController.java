package poly.controller;

import java.time.LocalDate;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import poly.dao.*;
import poly.model.GiaoVienDangKy;

@Controller
@RequestMapping("/gv")
public class DangKyThiController {

    @Autowired GiaoVienDangKyDAO dangKyDAO;
    @Autowired MonHocDAO monHocDAO;
    @Autowired LopDAO lopDAO;

    // Danh sách đăng ký thi
    @RequestMapping("/dangkythi.htm")
    public String index(Model model) {
        model.addAttribute("list", dangKyDAO.findAll());
        return "gv/dangkythi";
    }

    // Form đăng ký - GET
    @RequestMapping(value = "/dangkythi-them.htm", method = RequestMethod.GET)
    public String showThem(Model model) {
        model.addAttribute("dk", new GiaoVienDangKy());
        model.addAttribute("dsMonHoc", monHocDAO.findAll());
        model.addAttribute("dsLop", lopDAO.findAll());
        return "gv/dangkythi-form";
    }

    // Form đăng ký - POST
    @RequestMapping(value = "/dangkythi-them.htm", method = RequestMethod.POST)
    public String doThem(
            @ModelAttribute GiaoVienDangKy dk,
            HttpSession session, Model model) {

        // Gán MAGV = username đang login
        dk.setMaGV((String) session.getAttribute("username"));

        // Kiểm tra đủ số câu hỏi
        LocalDate ngayThi = LocalDate.parse(dk.getNgayThi());
        if (ngayThi.isBefore(LocalDate.now())) {
            model.addAttribute("error", "Ngày thi không được trước ngày hôm nay!");
            model.addAttribute("dk", dk);
            model.addAttribute("dsMonHoc", monHocDAO.findAll());
            model.addAttribute("dsLop", lopDAO.findAll());
            return "gv/dangkythi-form";
        }
        int soCauTrongBoDe = dangKyDAO.demSoCau(dk.getMaMH(), dk.getTrinhDo());

        if (soCauTrongBoDe < dk.getSoCauThi()) {
            model.addAttribute("error",
                "Không đủ câu hỏi! Bộ đề chỉ có " + soCauTrongBoDe +
                " câu trình độ " + dk.getTrinhDo() +
                " cho môn này. Yêu cầu: " + dk.getSoCauThi() + " câu.");
            model.addAttribute("dk", dk);
            model.addAttribute("dsMonHoc", monHocDAO.findAll());
            model.addAttribute("dsLop", lopDAO.findAll());
            return "gv/dangkythi-form";
        }

        // Kiểm tra đã đăng ký chưa (trùng khóa chính)
        GiaoVienDangKy existing = dangKyDAO.findByKey(
            dk.getMaLop(), dk.getMaMH(), dk.getLan());
        if (existing != null) {
            model.addAttribute("error",
                "Lớp này đã được đăng ký thi môn " +
                dk.getMaMH() + " lần " + dk.getLan() + " rồi!");
            model.addAttribute("dk", dk);
            model.addAttribute("dsMonHoc", monHocDAO.findAll());
            model.addAttribute("dsLop", lopDAO.findAll());
            return "gv/dangkythi-form";
        }

        try {
            dangKyDAO.insert(dk);
            session.setAttribute("successMsg", "Đăng ký thi thành công!");
            return "redirect:/gv/dangkythi.htm";
        } catch (Exception e) {
            model.addAttribute("error", "Lỗi: " + e.getMessage());
            model.addAttribute("dk", dk);
            model.addAttribute("dsMonHoc", monHocDAO.findAll());
            model.addAttribute("dsLop", lopDAO.findAll());
            return "gv/dangkythi-form";
        }
    }

    // Xóa đăng ký
    @RequestMapping("/dangkythi-xoa.htm")
    public String doXoa(
            @RequestParam String maLop,
            @RequestParam String maMH,
            @RequestParam int lan,
            HttpSession session) {
        dangKyDAO.delete(maLop, maMH, lan);
        session.setAttribute("successMsg", "Xóa đăng ký thi thành công!");
        return "redirect:/gv/dangkythi.htm";
    }
}