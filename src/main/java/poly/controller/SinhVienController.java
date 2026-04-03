package poly.controller;

import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequestMapping("/sv")
public class SinhVienController {

    @Autowired
    JdbcTemplate db;

    @RequestMapping("/xem-ket-qua.htm")
    public String xemKetQua(HttpSession session, ModelMap model) {
        // 1. Lấy thông tin từ Session (đã lưu lúc Login)
        String masv = (String) session.getAttribute("masv");
        String hoTen = (String) session.getAttribute("hoTen");
        
        if (masv == null) return "redirect:/login.htm";

        // 2. Lấy thông tin lớp của sinh viên từ DB để hiển thị Header
        Map<String, Object> svInfo = db.queryForMap(
            "SELECT sv.MALOP FROM SINHVIEN sv WHERE sv.MASV = ?", masv);
        
        model.addAttribute("hoTen", hoTen);
        model.addAttribute("maSV", masv);
        model.addAttribute("lop", svInfo.get("MALOP"));

        // 3. Lấy danh sách các môn đã thi (Dữ liệu thật cho Module 4.8)
        // Gọi SP_SV_XEMKETQUA đã tạo ở bước trước
        List<Map<String, Object>> dsKetQua = db.queryForList("EXEC SP_SV_XEMKETQUA ?", masv);
        
        model.addAttribute("dsKetQua", dsKetQua);

        // Trả về view: src/main/webapp/WEB-INF/views/sv/ketQuaThi.jsp
        return "sv/ketQuaThi";
    }
    
    @RequestMapping("/chi-tiet.htm")
    public String xemChiTiet(HttpSession session, 
                            @RequestParam String mamh, 
                            @RequestParam int lan, 
                            ModelMap model) {
        String masv = (String) session.getAttribute("masv");
        if (masv == null) return "redirect:/login.htm";

        // Truy vấn thông tin môn học
        String sqlTenMon = "SELECT TENMH FROM MONHOC WHERE MAMH = ?";
        String tenMon = db.queryForObject(sqlTenMon, String.class, mamh);

        // Gọi SP lấy chi tiết bài làm
        List<Map<String, Object>> dsCauHoi = db.queryForList("EXEC SP_SV_XEMCHITIETBAITHI ?, ?, ?", masv, mamh, lan);
        
        model.addAttribute("tenMon", tenMon);
        model.addAttribute("lan", lan);
        model.addAttribute("dsCauHoi", dsCauHoi);

        return "sv/ketQuaChiTiet";
    }
}