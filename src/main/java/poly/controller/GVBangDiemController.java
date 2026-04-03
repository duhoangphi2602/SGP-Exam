package poly.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import poly.dto.DiemSinhVienDTO;

import java.util.ArrayList;
import java.util.List;

@Controller
@RequestMapping("/gv")
public class GVBangDiemController {

    // Hiển thị form chọn lớp/môn và bảng điểm (nếu có submit)
    @RequestMapping(value = "/bang-diem.htm", method = {RequestMethod.GET, RequestMethod.POST})
    public String xemBangDiem(
            @RequestParam(required = false) String maLop,
            @RequestParam(required = false) String maMon,
            @RequestParam(required = false) Integer lanThi,
            ModelMap model) {

        // 1. Fake danh sách Lớp và Môn để đưa vào thẻ <select> (Dropdown)
        List<String> danhSachLop = new ArrayList<>();
        danhSachLop.add("D20CQCN01");
        danhSachLop.add("D20CQCN02");
        model.addAttribute("danhSachLop", danhSachLop);

        List<String> danhSachMon = new ArrayList<>();
        danhSachMon.add("Lập trình Java");
        danhSachMon.add("Cơ sở dữ liệu");
        model.addAttribute("danhSachMon", danhSachMon);

        // 2. Nếu người dùng đã chọn form và ấn submit (có tham số truyền lên)
        if (maLop != null && maMon != null && lanThi != null) {
            // Fake dữ liệu bảng điểm theo lớp/môn đã chọn
            List<DiemSinhVienDTO> bangDiem = new ArrayList<>();
            bangDiem.add(new DiemSinhVienDTO(1, "SV001", "Nguyễn Văn A", 8.5, "Giỏi"));
            bangDiem.add(new DiemSinhVienDTO(2, "SV002", "Trần Thị B", 6.0, "Trung bình khá"));
            bangDiem.add(new DiemSinhVienDTO(3, "SV003", "Lê Văn C", 9.0, "Xuất sắc"));
            
            model.addAttribute("bangDiem", bangDiem);
            // Giữ lại lựa chọn cũ trên giao diện
            model.addAttribute("selectedLop", maLop);
            model.addAttribute("selectedMon", maMon);
            model.addAttribute("selectedLanThi", lanThi);
        }

        // Trả về view: src/main/webapp/WEB-INF/views/gv/bangdiem.jsp
        return "gv/bangdiem";
    }
}