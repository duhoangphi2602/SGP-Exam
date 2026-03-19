package poly.controller;

import java.util.List;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import poly.dao.BoDeDAO;
import poly.dao.GiaoVienDAO;
import poly.dao.MonHocDAO;
import poly.model.BoDe;

@Controller
public class BoDeController {

    @Autowired BoDeDAO boDeDAO;
    @Autowired MonHocDAO monHocDAO;
    @Autowired GiaoVienDAO giaoVienDAO;

    @RequestMapping("/gv/bode.htm")
    public String index(
            @RequestParam(required = false) String maMH,
            @RequestParam(required = false) String trinhDo,
            @RequestParam(defaultValue = "1") int page,
            HttpSession session, Model model) {

        String role = (String) session.getAttribute("role");
        String username = (String) session.getAttribute("username");
        int pageSize = 10;
        String maGVFilter = role.equals("PGV") ? null : username;

        List<BoDe> list = boDeDAO.findByFilterPaged(maMH, trinhDo, maGVFilter, page, pageSize);
        int total = boDeDAO.countByFilter(maMH, trinhDo, maGVFilter);
        int totalPages = (int) Math.ceil((double) total / pageSize);

        model.addAttribute("list", list);
        model.addAttribute("dsMonHoc", monHocDAO.findAll());
        model.addAttribute("maMH", maMH);
        model.addAttribute("trinhDo", trinhDo);
        model.addAttribute("page", page);
        model.addAttribute("totalPages", totalPages);
        return "gv/bode";
    }

    @RequestMapping(value = "/gv/bode-them.htm", method = RequestMethod.GET)
    public String showThem(HttpSession session, Model model) {
        model.addAttribute("bd", new BoDe());
        model.addAttribute("dsMonHoc", monHocDAO.findAll());
        model.addAttribute("action", "them");
        return "gv/bode-form";
    }

    @RequestMapping(value = "/gv/bode-them.htm", method = RequestMethod.POST)
    public String doThem(
            @ModelAttribute BoDe bd,
            HttpSession session, Model model) {
        bd.setMaGV((String) session.getAttribute("username"));
        try {
            boDeDAO.insert(bd);
            session.setAttribute("successMsg", "Thêm câu hỏi thành công!");
            return "redirect:/gv/bode.htm";
        } catch (Exception e) {
            model.addAttribute("error", "Lỗi khi thêm câu hỏi: " + e.getMessage());
            model.addAttribute("bd", bd);
            model.addAttribute("dsMonHoc", monHocDAO.findAll());
            model.addAttribute("action", "them");
            return "gv/bode-form";
        }
    }

    @RequestMapping(value = "/gv/bode-sua.htm", method = RequestMethod.GET)
    public String showSua(@RequestParam int cauHoi, Model model) {
        model.addAttribute("bd", boDeDAO.findByCauHoi(cauHoi));
        model.addAttribute("dsMonHoc", monHocDAO.findAll());
        model.addAttribute("action", "sua");
        return "gv/bode-form";
    }

    @RequestMapping(value = "/gv/bode-sua.htm", method = RequestMethod.POST)
    public String doSua(@ModelAttribute BoDe bd, HttpSession session) {
        boDeDAO.update(bd);
        session.setAttribute("successMsg", "Cập nhật câu hỏi thành công!");
        return "redirect:/gv/bode.htm";
    }

    @RequestMapping("/gv/bode-xoa.htm")
    public String doXoa(@RequestParam int cauHoi, HttpSession session) {
        boDeDAO.delete(cauHoi);
        session.setAttribute("successMsg", "Xóa câu hỏi thành công!");
        return "redirect:/gv/bode.htm";
    }
}