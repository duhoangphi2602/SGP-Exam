package poly.controller;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import poly.dao.LopDAO;
import poly.dao.SinhVienDAO;
import poly.model.Lop;
import poly.model.SinhVien;

@Controller
@RequestMapping("/pgv")
public class LopController {

    @Autowired LopDAO lopDAO;
    @Autowired SinhVienDAO svDAO;

    // Danh sách lớp
    @RequestMapping("/lop.htm")
    public String index(Model model) {
        model.addAttribute("list", lopDAO.findAll());
        return "pgv/lop";
    }

    // Thêm lớp - GET
    @RequestMapping(value = "/lop-them.htm", method = RequestMethod.GET)
    public String showThemLop(Model model) {
        model.addAttribute("lop", new Lop());
        return "pgv/lop-form";
    }

    // Thêm lớp - POST
    @RequestMapping(value = "/lop-them.htm", method = RequestMethod.POST)
    public String doThemLop(@ModelAttribute Lop lop, Model model) {
        try {
            lopDAO.insert(lop);
            return "redirect:/pgv/lop.htm";
        } catch (Exception e) {
            String err = e.getMessage();
            if (err.contains("PRIMARY KEY") || err.contains("duplicate key")) {
                model.addAttribute("error", "Mã lớp '" + lop.getMaLop().trim() + "' đã tồn tại!");
            } else if (err.contains("UNIQUE")) {
                model.addAttribute("error", "Tên lớp đã tồn tại!");
            } else {
                model.addAttribute("error", "Lỗi: " + err);
            }
            model.addAttribute("lop", lop);
            return "pgv/lop-form";
        }
    }

    // Sửa lớp - GET
    @RequestMapping(value = "/lop-sua.htm", method = RequestMethod.GET)
    public String showSuaLop(@RequestParam String ma, Model model) {
        model.addAttribute("lop", lopDAO.findByMa(ma));
        return "pgv/lop-form";
    }

    // Sửa lớp - POST
    @RequestMapping(value = "/lop-sua.htm", method = RequestMethod.POST)
    public String doSuaLop(@ModelAttribute Lop lop) {
        lopDAO.update(lop);
        return "redirect:/pgv/lop.htm";
    }

    // Xóa lớp
    @RequestMapping("/lop-xoa.htm")
    public String doXoaLop(@RequestParam String ma, HttpSession session) {
        int soSV = lopDAO.kiemTraConSV(ma);
        if (soSV > 0) {
            session.setAttribute("errorMsg",
                "Không thể xóa! Lớp này còn " + soSV + " sinh viên.");
            return "redirect:/pgv/lop.htm";
        }
        lopDAO.delete(ma);
        session.setAttribute("successMsg", "Xóa lớp thành công!");
        return "redirect:/pgv/lop.htm";
    }

    // Danh sách SV theo lớp (subform)
    @RequestMapping("/lop-sinhvien.htm")
    public String dsSinhVien(@RequestParam String ma, Model model) {
        model.addAttribute("lop", lopDAO.findByMa(ma));
        model.addAttribute("dssv", svDAO.findByLop(ma));
        return "pgv/lop-sinhvien";
    }

    // Show SV - GET
    @RequestMapping(value = "/sv-them.htm", method = RequestMethod.GET)
    public String showThemSV(@RequestParam String maLop, Model model) {
        SinhVien sv = new SinhVien();
        sv.setMaLop(maLop);
        model.addAttribute("sv", sv);
        model.addAttribute("action", "them");
        return "pgv/sv-form";
    }

    // Thêm SV - POST
    @RequestMapping(value = "/sv-them.htm", method = RequestMethod.POST)
    public String doThemSV(@ModelAttribute SinhVien sv, Model model) {
        try {
            // Kiểm tra ngày sinh
            java.time.LocalDate ngaySinh = java.time.LocalDate.parse(
                sv.getNgaySinh(), 
                java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));
            
            if (ngaySinh.isAfter(java.time.LocalDate.now())) {
                model.addAttribute("error", "Ngày sinh không được là ngày trong tương lai!");
                model.addAttribute("sv", sv);
                model.addAttribute("action", "them");
                return "pgv/sv-form";
            }

            svDAO.insert(sv);
            return "redirect:/pgv/lop-sinhvien.htm?ma=" + sv.getMaLop();
        } catch (java.time.format.DateTimeParseException e) {
            model.addAttribute("error", "Ngày sinh không đúng định dạng dd/MM/yyyy!");
            model.addAttribute("sv", sv);
            model.addAttribute("action", "them");
            return "pgv/sv-form";
        } catch (Exception e) {
            String err = e.getMessage();
            if (err.contains("PRIMARY KEY") || err.contains("duplicate key")) {
                model.addAttribute("error", "Mã sinh viên '" + sv.getMaSV().trim() + "' đã tồn tại!");
            } else if (err.contains("FOREIGN KEY")) {
                model.addAttribute("error", "Mã lớp không tồn tại!");
            } else {
                model.addAttribute("error", "Lỗi: " + err);
            }
            model.addAttribute("sv", sv);
            model.addAttribute("action", "them");
            return "pgv/sv-form";
        }
    }

    // Sửa SV - GET
    @RequestMapping(value = "/sv-sua.htm", method = RequestMethod.GET)
    public String showSuaSV(@RequestParam String ma, Model model) {
        model.addAttribute("sv", svDAO.findByMa(ma));
        model.addAttribute("action", "sua");
        return "pgv/sv-form";
    }

    // Sửa SV - POST
    @RequestMapping(value = "/sv-sua.htm", method = RequestMethod.POST)
    public String doSuaSV(@ModelAttribute SinhVien sv, Model model) {
        try {
            // Kiểm tra ngày sinh
            java.time.LocalDate ngaySinh = java.time.LocalDate.parse(
                sv.getNgaySinh(),
                java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));

            if (ngaySinh.isAfter(java.time.LocalDate.now())) {
                model.addAttribute("error", "Ngày sinh không không hợp lệ!");
                model.addAttribute("sv", sv);
                model.addAttribute("action", "sua");
                return "pgv/sv-form";
            }

            svDAO.update(sv);
            return "redirect:/pgv/lop-sinhvien.htm?ma=" + sv.getMaLop();
        } catch (java.time.format.DateTimeParseException e) {
            model.addAttribute("error", "Ngày sinh không đúng định dạng dd/MM/yyyy!");
            model.addAttribute("sv", sv);
            model.addAttribute("action", "sua");
            return "pgv/sv-form";
        } catch (Exception e) {
            model.addAttribute("error", "Lỗi: " + e.getMessage());
            model.addAttribute("sv", sv);
            model.addAttribute("action", "sua");
            return "pgv/sv-form";
        }
    }

    // Xóa SV
    @RequestMapping("/sv-xoa.htm")
    public String doXoaSV(@RequestParam String ma,
                          @RequestParam String maLop,
                          HttpSession session) {
        int soDiem = svDAO.kiemTraConDiem(ma);
        if (soDiem > 0) {
            session.setAttribute("errorMsg",
                "Không thể xóa! Sinh viên này đã có điểm thi.");
            return "redirect:/pgv/lop-sinhvien.htm?ma=" + maLop;
        }
        svDAO.delete(ma);
        session.setAttribute("successMsg", "Xóa sinh viên thành công!");
        return "redirect:/pgv/lop-sinhvien.htm?ma=" + maLop;
    }
}