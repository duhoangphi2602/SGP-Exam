package poly.controller;

import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

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

    // =====================================================
    // Helper: kiểm tra đáp án trùng
    // =====================================================
    private boolean kiemTraDapAnTrung(BoDe bd) {
        Set<String> dapAnSet = new HashSet<>(Arrays.asList(
            bd.getA().trim(),
            bd.getB().trim(),
            bd.getC().trim(),
            bd.getD().trim()
        ));
        return dapAnSet.size() < 4;
    }

    // =====================================================
    // Helper: add data cho form
    // =====================================================
    private void addFormData(Model model, BoDe bd, String action) {
        model.addAttribute("bd", bd);
        model.addAttribute("dsMonHoc", monHocDAO.findAll());
        model.addAttribute("action", action);
    }

    // =====================================================
    // Danh sách bộ đề
    // =====================================================
    @RequestMapping("/gv/bode.htm")
    public String index(
            @RequestParam(required = false) String maMH,
            @RequestParam(required = false) String trinhDo,
            @RequestParam(required = false) String noiDung,
            @RequestParam(required = false) String maGVLoc,
            @RequestParam(defaultValue = "1") int page,
            HttpSession session, Model model) {

        String role = (String) session.getAttribute("role");
        String maGV = (String) session.getAttribute("maGV");

        int pageSize = 10;
        String maGVFilter = role.equals("PGV") ? null : maGV;

        List<BoDe> list = boDeDAO.findByFilterPaged(
            maMH, trinhDo, maGVFilter, noiDung, maGVLoc, page, pageSize);
        int total = boDeDAO.countByFilter(
            maMH, trinhDo, maGVFilter, noiDung, maGVLoc);
        int totalPages = (int) Math.ceil((double) total / pageSize);

        // PGV: load danh sách GV để hiện dropdown lọc
        if (role.equals("PGV")) {
            model.addAttribute("dsGiaoVien", giaoVienDAO.findAll());
            model.addAttribute("maGVLoc", maGVLoc);
        }

        model.addAttribute("list", list);
        model.addAttribute("dsMonHoc", monHocDAO.findAll());
        model.addAttribute("maMH", maMH);
        model.addAttribute("trinhDo", trinhDo);
        model.addAttribute("noiDung", noiDung);
        model.addAttribute("page", page);
        model.addAttribute("totalPages", totalPages);
        return "gv/bode";
    }

    // =====================================================
    // Thêm câu hỏi - GET
    // =====================================================
    @RequestMapping(value = "/gv/bode-them.htm", method = RequestMethod.GET)
    public String showThem(Model model) {
        addFormData(model, new BoDe(), "them");
        return "gv/bode-form";
    }

    // =====================================================
    // Thêm câu hỏi - POST
    // =====================================================
    @RequestMapping(value = "/gv/bode-them.htm", method = RequestMethod.POST)
    public String doThem(@ModelAttribute BoDe bd, HttpSession session, Model model) {
        bd.setMaGV((String) session.getAttribute("maGV"));

        if (kiemTraDapAnTrung(bd)) {
            model.addAttribute("error", "Các đáp án không được trùng nhau!");
            addFormData(model, bd, "them");
            return "gv/bode-form";
        }

        try {
            boDeDAO.insert(bd);
            model.addAttribute("successMsg", "Thêm câu hỏi thành công!");
            addFormData(model, bd, "them");
            return "gv/bode-form";
        } catch (Exception e) {
        	model.addAttribute("error", "Lỗi khi cập nhật câu hỏi: " + e.getMessage());
            addFormData(model, bd, "them");
            return "gv/bode-form";
        }
    }

    // =====================================================
    // Sửa câu hỏi - GET
    // =====================================================
    @RequestMapping(value = "/gv/bode-sua.htm", method = RequestMethod.GET)
    public String showSua(@RequestParam int cauHoi, Model model) {
        addFormData(model, boDeDAO.findByCauHoi(cauHoi), "sua");
        return "gv/bode-form";
    }

    // =====================================================
    // Sửa câu hỏi - POST
    // =====================================================
    @RequestMapping(value = "/gv/bode-sua.htm", method = RequestMethod.POST)
    public String doSua(@ModelAttribute BoDe bd, HttpSession session, Model model) {
        if (kiemTraDapAnTrung(bd)) {
            model.addAttribute("error", "Các đáp án không được trùng nhau!");
            addFormData(model, bd, "sua");
            return "gv/bode-form";
        }

        try {
            boDeDAO.update(bd);
            model.addAttribute("successMsg", "Cập nhật câu hỏi thành công!");
            addFormData(model, bd, "sua");
            return "gv/bode-form";
        } catch (Exception e) {
            model.addAttribute("error", "Lỗi khi cập nhật câu hỏi: " + e.getMessage());
            addFormData(model, bd, "sua");
            return "gv/bode-form";
        }
    }

    // =====================================================
    // Xóa câu hỏi
    // =====================================================
    @RequestMapping("/gv/bode-xoa.htm")
    public String doXoa(@RequestParam int cauHoi, HttpSession session) {
        boDeDAO.delete(cauHoi);
        session.setAttribute("successMsg", "Xóa câu hỏi thành công!");
        return "redirect:/gv/bode.htm";
    }
}