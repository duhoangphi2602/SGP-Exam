package poly.controller;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

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

    // =====================================================
    // Helper: kiểm tra đủ số câu theo rule 70/30
    // =====================================================
    private String kiemTraSoCau(String maMH, String trinhDo, int soCauThi) {
        // Giữ nguyên như cũ
        Map<String, Integer> soCauChiTiet = dangKyDAO.demSoCauChiTiet(maMH);
        int cauChinh = soCauChiTiet.get(trinhDo);
        int cauPhu = 0;
        String trinhDoPhu = null;
        if (trinhDo.equals("A")) trinhDoPhu = "B";
        else if (trinhDo.equals("B")) trinhDoPhu = "C";
        if (trinhDoPhu != null) cauPhu = soCauChiTiet.get(trinhDoPhu);
        int cauChinhToiThieu = (int) Math.ceil(soCauThi * 0.7);
        int cauPhuToiDa = soCauThi - cauChinhToiThieu;
        int tongCauCoThe = cauChinh + Math.min(cauPhu, cauPhuToiDa);
        if (cauChinh < cauChinhToiThieu)
            return String.format("Không đủ câu hỏi trình độ %s! Hiện có: %d câu, cần thêm: %d câu",
                trinhDo, cauChinh, cauChinhToiThieu - cauChinh);
        if (tongCauCoThe < soCauThi)
            return String.format("Không đủ câu hỏi! Tổng có thể lấy: %d câu, cần thêm: %d câu",
                tongCauCoThe, soCauThi - tongCauCoThe);
        return null;
    }

    // =====================================================
    // Trang chính — hiện form + danh sách (THAY THẾ index cũ, XÓA showThem/showSua GET)
    // =====================================================
    @RequestMapping(value = "/dangkythi.htm", method = RequestMethod.GET)
    public String index(
            @RequestParam(required = false) String maLop,
            @RequestParam(required = false) String maMH,
            @RequestParam(required = false) Integer lan,
            HttpSession session, Model model) {

        String role = (String) session.getAttribute("role");
        String maGV = (String) session.getAttribute("maGV");

        // Load danh sách
        List<GiaoVienDangKy> list;
        if (role.equals("PGV")) {
            list = dangKyDAO.findAll();
        } else {
            list = dangKyDAO.findByMaGV(maGV);
        }
        model.addAttribute("list", list);
        model.addAttribute("dsMonHoc", monHocDAO.findAll());
        model.addAttribute("dsLop", lopDAO.findAll());

        // Nếu có params → đang sửa
        if (maLop != null && maMH != null && lan != null) {
            if (dangKyDAO.kiemTraSV(maLop, maMH, lan)) {
                model.addAttribute("error", "Không thể sửa: đã có sinh viên thi ca này!");
                model.addAttribute("dk", new GiaoVienDangKy());
                model.addAttribute("isEdit", false);
                return "gv/dangkythi";
            }

            GiaoVienDangKy dk = dangKyDAO.findByKey(maLop, maMH, lan);
            // Parse ngày từ dd/MM/yyyy → yyyy-MM-dd cho input type=date
            try {
                LocalDate ngay = LocalDate.parse(dk.getNgayThi(),
                    java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));
                dk.setNgayThi(ngay.toString());
            } catch (Exception ignored) {}

            model.addAttribute("dk", dk);
            model.addAttribute("isEdit", true);
        } else {
            model.addAttribute("dk", new GiaoVienDangKy());
            model.addAttribute("isEdit", false);
        }

        return "gv/dangkythi";
    }

    // =====================================================
    // Thêm đăng ký - POST (GIỮ NGUYÊN)
    // =====================================================
    @RequestMapping(value = "/dangkythi-them.htm", method = RequestMethod.POST)
    public String doThem(@ModelAttribute GiaoVienDangKy dk, HttpSession session, Model model) {
        dk.setMaGV((String) session.getAttribute("maGV"));

        if (dk.getMaGV() == null) {
            model.addAttribute("error", "Tài khoản này không có quyền đăng ký thi!");
            return loadTrangChinh(model, session, dk, false);
        }

        GiaoVienDangKy existing = dangKyDAO.findByKey(dk.getMaLop(), dk.getMaMH(), dk.getLan());
        if (existing != null) {
            model.addAttribute("error", "Lớp này đã có đăng ký thi lần " + dk.getLan() + " cho môn học này!");
            return loadTrangChinh(model, session, dk, false);
        }

        if (dk.getLan() == 2) {
            GiaoVienDangKy lan1 = dangKyDAO.findByKey(dk.getMaLop(), dk.getMaMH(), 1);
            if (lan1 == null) {
                model.addAttribute("error", "Chưa có đăng ký thi lần 1!");
                return loadTrangChinh(model, session, dk, false);
            }
            LocalDate ngayThiLan1 = LocalDate.parse(lan1.getNgayThi(),
                java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));
            LocalDate ngayThiLan2 = LocalDate.parse(dk.getNgayThi());
            if (ngayThiLan2.isBefore(ngayThiLan1)) {
                model.addAttribute("error", "Ngày thi lần 2 không hợp lệ!");
                return loadTrangChinh(model, session, dk, false);
            }
        }

        if (dk.getSoCauThi() < 10 || dk.getSoCauThi() > 100) {
            model.addAttribute("error", "Số câu thi phải từ 10 đến 100!");
            return loadTrangChinh(model, session, dk, false);
        }

        LocalDate ngayThi = LocalDate.parse(dk.getNgayThi());
        if (ngayThi.isBefore(LocalDate.now())) {
            model.addAttribute("error", "Ngày thi không hợp lệ!");
            return loadTrangChinh(model, session, dk, false);
        }

        if (dk.getThoiGian() < 5 || dk.getThoiGian() > 60) {
            model.addAttribute("error", "Thời gian thi phải từ 5 đến 60 phút!");
            return loadTrangChinh(model, session, dk, false);
        }

        String loi = kiemTraSoCau(dk.getMaMH(), dk.getTrinhDo(), dk.getSoCauThi());
        if (loi != null) {
            model.addAttribute("error", loi);
            return loadTrangChinh(model, session, dk, false);
        }

        try {
            dangKyDAO.insert(dk);
            model.addAttribute("successMsg", "Đăng ký thi thành công!");
        } catch (Exception e) {
            model.addAttribute("error", "Lỗi: " + e.getMessage());
        }
        return loadTrangChinh(model, session, new GiaoVienDangKy(), false);
    }

    // =====================================================
    // Sửa đăng ký - POST (GIỮ NGUYÊN)
    // =====================================================
    @RequestMapping(value = "/dangkythi-sua.htm", method = RequestMethod.POST)
    public String doSua(@ModelAttribute GiaoVienDangKy dk, HttpSession session, Model model) {

        LocalDate ngayThi = LocalDate.parse(dk.getNgayThi());
        if (ngayThi.isBefore(LocalDate.now())) {
            model.addAttribute("error", "Ngày thi không hợp lệ!");
            return loadTrangChinh(model, session, dk, true);
        }

        if (dk.getSoCauThi() < 10 || dk.getSoCauThi() > 100) {
            model.addAttribute("error", "Số câu thi phải từ 10 đến 100!");
            return loadTrangChinh(model, session, dk, true);
        }

        if (dk.getThoiGian() < 5 || dk.getThoiGian() > 60) {
            model.addAttribute("error", "Thời gian thi phải từ 5 đến 60 phút!");
            return loadTrangChinh(model, session, dk, true);
        }

        String loi = kiemTraSoCau(dk.getMaMH(), dk.getTrinhDo(), dk.getSoCauThi());
        if (loi != null) {
            model.addAttribute("error", loi);
            return loadTrangChinh(model, session, dk, true);
        }

        try {
            dangKyDAO.update(dk);
            model.addAttribute("successMsg", "Cập nhật đăng ký thi thành công!");
            return loadTrangChinh(model, session, new GiaoVienDangKy(), false);
        } catch (Exception e) {
            model.addAttribute("error", "Lỗi: " + e.getMessage());
            return loadTrangChinh(model, session, dk, true);
        }
    }

    // =====================================================
    // Xóa đăng ký (GIỮ NGUYÊN)
    // =====================================================
    @RequestMapping("/dangkythi-xoa.htm")
    public String doXoa(@RequestParam String maLop, @RequestParam String maMH,
            @RequestParam int lan, HttpSession session) {

        if (dangKyDAO.kiemTraSV(maLop, maMH, lan)) {
            session.setAttribute("errorMsg", "Không thể xóa: đã có sinh viên thi ca này!");
            return "redirect:/gv/dangkythi.htm";
        }
        dangKyDAO.delete(maLop, maMH, lan);
        session.setAttribute("successMsg", "Xóa đăng ký thi thành công!");
        return "redirect:/gv/dangkythi.htm";
    }
    
    // =====================================================
    // API 1: Trả về danh sách môn đã đăng ký của Lớp
    // =====================================================
    @RequestMapping(value = "/api/class-registrations.htm", method = RequestMethod.GET)
    @ResponseBody
    public String getClassRegistrations(@RequestParam("maLop") String maLop) {
        // Bên trong giữ nguyên y xì cũ
        List<Map<String, Object>> list = dangKyDAO.getDangKyByLop(maLop);
        StringBuilder json = new StringBuilder("[");
        for(int i=0; i<list.size(); i++) {
            Map<String, Object> map = list.get(i);
            json.append(String.format("{\"maMH\":\"%s\", \"lan\":%s, \"ngayThi\":\"%s\"}", 
                map.get("maMH"), map.get("lan"), map.get("ngayThi")));
            if(i < list.size() - 1) json.append(",");
        }
        json.append("]");
        return json.toString();
    }

    // =====================================================
    // API 2: Trả về số câu hỏi Tối Đa có thể ra đề
    // =====================================================
    @RequestMapping(value = "/api/max-questions.htm", method = RequestMethod.GET)
    @ResponseBody
    public String getMaxQuestions(@RequestParam("maMH") String maMH, @RequestParam("trinhDo") String trinhDo) {
        // Bên trong giữ nguyên y xì cũ
        if(maMH == null || maMH.trim().isEmpty() || trinhDo == null || trinhDo.trim().isEmpty()) return "{\"max\": 0}";
        
        Map<String, Integer> soCauChiTiet = dangKyDAO.demSoCauChiTiet(maMH);
        int cauChinh = soCauChiTiet.get(trinhDo);
        int cauPhu = 0;
        String trinhDoPhu = null;
        if (trinhDo.equals("A")) trinhDoPhu = "B";
        else if (trinhDo.equals("B")) trinhDoPhu = "C";
        if (trinhDoPhu != null) cauPhu = soCauChiTiet.get(trinhDoPhu);
        
        int maxByRatio = (int) (cauChinh / 0.7);
        int maxTotal = cauChinh + cauPhu;
        int absoluteMax = Math.min(maxByRatio, maxTotal);
        if (absoluteMax > 100) absoluteMax = 100; 
        
        return "{\"max\": " + absoluteMax + "}";
    }

    // =====================================================
    // Helper: load lại trang chính kèm data
    // =====================================================
    private String loadTrangChinh(Model model, HttpSession session, GiaoVienDangKy dk, boolean isEdit) {
        String role = (String) session.getAttribute("role");
        String maGV = (String) session.getAttribute("maGV");

        List<GiaoVienDangKy> list;
        if (role.equals("PGV")) {
            list = dangKyDAO.findAll();
        } else {
            list = dangKyDAO.findByMaGV(maGV);
        }

        model.addAttribute("list", list);
        model.addAttribute("dsMonHoc", monHocDAO.findAll());
        model.addAttribute("dsLop", lopDAO.findAll());
        model.addAttribute("dk", dk);
        model.addAttribute("isEdit", isEdit);
        return "gv/dangkythi";
    }
}