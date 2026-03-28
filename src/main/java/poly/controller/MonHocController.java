package poly.controller;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import poly.dao.MonHocDAO;
import poly.model.MonHoc;

@Controller
@RequestMapping("/pgv")
public class MonHocController {

    @Autowired
    MonHocDAO monHocDAO;

    // Hiển thị danh sách
    @RequestMapping("/monhoc.htm")
    public String index(
            @RequestParam(required = false) String timkiem,
            Model model) {
        List<MonHoc> list;
        if (timkiem != null && !timkiem.isEmpty()) {
            list = monHocDAO.findByTen(timkiem);
        } else {
            list = monHocDAO.findAll();
        }
        model.addAttribute("list", list);
        model.addAttribute("timkiem", timkiem);
        return "pgv/monhoc";
    }

    // Hiển thị form thêm
    @RequestMapping(value = "/monhoc-them.htm", method = RequestMethod.GET)
    public String showThem(Model model) {
        model.addAttribute("monhoc", new MonHoc());
        model.addAttribute("action", "them");
        return "pgv/monhoc-form";
    }

    // Xử lý thêm
    @RequestMapping(value = "/monhoc-them.htm", method = RequestMethod.POST)
    public String doThem(@ModelAttribute MonHoc monhoc, Model model) {
        try {
            monHocDAO.insert(monhoc);
            return "redirect:/pgv/monhoc.htm";
        } catch (Exception e) {
            model.addAttribute("error", "Mã môn học đã tồn tại!");
            model.addAttribute("monhoc", monhoc);
            model.addAttribute("action", "them");
            return "pgv/monhoc-form";
        }
    }

    // Hiển thị form sửa
    @RequestMapping(value = "/monhoc-sua.htm", method = RequestMethod.GET)
    public String showSua(@RequestParam String ma, Model model) {
        MonHoc mh = monHocDAO.findByMa(ma);
        model.addAttribute("monhoc", mh);
        model.addAttribute("action", "sua");
        return "pgv/monhoc-form";
    }

    // Xử lý sửa
    @RequestMapping(value = "/monhoc-sua.htm", method = RequestMethod.POST)
    public String doSua(@ModelAttribute MonHoc monhoc) {
        monHocDAO.update(monhoc);
        return "redirect:/pgv/monhoc.htm";
    }	
   
    @RequestMapping("/monhoc-xoa.htm")
    public String doXoa(@RequestParam String ma, 
                        HttpSession session, Model model) {
        int soCau = monHocDAO.kiemTraConCauHoi(ma);
        if (soCau > 0) {
            session.setAttribute("errorMsg", 
                "Không thể xóa! Môn học này còn " + soCau + " câu hỏi trong bộ đề.");
            return "redirect:/pgv/monhoc.htm";
        }
        monHocDAO.delete(ma);
        session.setAttribute("successMsg", "Xóa môn học thành công!");
        return "redirect:/pgv/monhoc.htm";
    }
}