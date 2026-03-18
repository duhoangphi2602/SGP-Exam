package poly.controller;

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
            model.addAttribute("error", "Mã lớp đã tồn tại!");
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
    public String doXoaLop(@RequestParam String ma) {
        lopDAO.delete(ma);
        return "redirect:/pgv/lop.htm";
    }

    // Danh sách SV theo lớp (subform)
    @RequestMapping("/lop-sinhvien.htm")
    public String dsSinhVien(@RequestParam String ma, Model model) {
        model.addAttribute("lop", lopDAO.findByMa(ma));
        model.addAttribute("dssv", svDAO.findByLop(ma));
        return "pgv/lop-sinhvien";
    }

    // Thêm SV - GET
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
            svDAO.insert(sv);
            return "redirect:/pgv/lop-sinhvien.htm?ma=" + sv.getMaLop();
        } catch (Exception e) {
            model.addAttribute("error", "Mã SV đã tồn tại!");
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
    public String doSuaSV(@ModelAttribute SinhVien sv) {
        svDAO.update(sv);
        return "redirect:/pgv/lop-sinhvien.htm?ma=" + sv.getMaLop();
    }

    // Xóa SV
    @RequestMapping("/sv-xoa.htm")
    public String doXoaSV(@RequestParam String ma, @RequestParam String maLop) {
        svDAO.delete(ma);
        return "redirect:/pgv/lop-sinhvien.htm?ma=" + maLop;
    }
}