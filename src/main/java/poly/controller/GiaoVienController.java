package poly.controller;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import poly.dao.GiaoVienDAO;
import poly.model.GiaoVien;
import org.springframework.jdbc.core.JdbcTemplate;
import java.util.Map;

@Controller
@RequestMapping("/pgv")
public class GiaoVienController {

    @Autowired
    GiaoVienDAO giaoVienDAO;
    @Autowired
    JdbcTemplate db;

    @RequestMapping("/giaovien.htm")
    public String index(
            @RequestParam(required = false) String timkiem,
            Model model) {
        List<GiaoVien> list;
        if (timkiem != null && !timkiem.isEmpty()) {
            list = giaoVienDAO.findByTen(timkiem);
        } else {
            list = giaoVienDAO.findAll();
        }
        model.addAttribute("list", list);
        model.addAttribute("timkiem", timkiem);
        return "pgv/giaovien";
    }

    @RequestMapping(value = "/giaovien-them.htm", method = RequestMethod.GET)
    public String showThem(Model model) {
        model.addAttribute("gv", new GiaoVien());
        model.addAttribute("action", "them");
        return "pgv/giaovien-form";
    }

    @RequestMapping(value = "/giaovien-them.htm", method = RequestMethod.POST)
    public String doThem(@ModelAttribute GiaoVien gv, Model model) {
        try {
            giaoVienDAO.insert(gv);
            return "redirect:/pgv/giaovien.htm";
        } catch (Exception e) {
            model.addAttribute("error", "Mã giáo viên đã tồn tại!");
            model.addAttribute("gv", gv);
            model.addAttribute("action", "them");
            return "pgv/giaovien-form";
        }
    }

    @RequestMapping(value = "/giaovien-sua.htm", method = RequestMethod.GET)
    public String showSua(@RequestParam String ma, Model model) {
        model.addAttribute("gv", giaoVienDAO.findByMa(ma));
        model.addAttribute("action", "sua");
        return "pgv/giaovien-form";
    }

    @RequestMapping(value = "/giaovien-sua.htm", method = RequestMethod.POST)
    public String doSua(@ModelAttribute GiaoVien gv) {
        giaoVienDAO.update(gv);
        return "redirect:/pgv/giaovien.htm";
    }

    @RequestMapping("/giaovien-xoa.htm")
    public String doXoa(@RequestParam String ma) {
        giaoVienDAO.delete(ma);
        return "redirect:/pgv/giaovien.htm";
    }
    
    @RequestMapping("/bang-diem-lop.htm")
    public String xemBangDiemLop(
            @RequestParam(required = false) String maLop,
            @RequestParam(required = false) String maMH,
            @RequestParam(required = false) Integer lan,
            Model model) {
        
        // Đổ dữ liệu vào các ô chọn (Dropdown)
        model.addAttribute("dsLop", db.queryForList("SELECT MALOP, TENLOP FROM LOP"));
        model.addAttribute("dsMon", db.queryForList("SELECT MAMH, TENMH FROM MONHOC"));

        // Nếu bấm từ trang Danh sách lớp sang, maLop sẽ có giá trị sẵn
        model.addAttribute("selectedLop", maLop);

        if (maLop != null && maMH != null && lan != null) {
            List<Map<String, Object>> list = db.queryForList(
                "EXEC SP_IN_BANGDIEM_LOP ?, ?, ?", maLop, maMH, lan);
            
            model.addAttribute("bangdiem", list);
            model.addAttribute("selectedMon", maMH);
            model.addAttribute("selectedLan", lan);
        }
        return "pgv/bangdiemlop";
    }
}