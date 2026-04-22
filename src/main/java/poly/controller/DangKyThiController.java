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
        Map<String, Integer> soCauChiTiet = dangKyDAO.demSoCauChiTiet(maMH);
        int cauChinh = soCauChiTiet.get(trinhDo);
        int cauPhu = 0;

        String trinhDoPhu = null;
        if (trinhDo.equals("A")) trinhDoPhu = "B";
        else if (trinhDo.equals("B")) trinhDoPhu = "C";

        if (trinhDoPhu != null) {
            cauPhu = soCauChiTiet.get(trinhDoPhu);
        }

        int cauChinhToiThieu = (int) Math.ceil(soCauThi * 0.7);
        int cauPhuToiDa = soCauThi - cauChinhToiThieu;
        int tongCauCoThe = cauChinh + Math.min(cauPhu, cauPhuToiDa);

        if (cauChinh < cauChinhToiThieu) {
            return String.format(
                "Không đủ câu hỏi trình độ %s! Hiện có: %d câu, cần thêm: %d câu",
                trinhDo, cauChinh, cauChinhToiThieu - cauChinh);
        }
        if (tongCauCoThe < soCauThi) {
            return String.format(
                "Không đủ câu hỏi! Tổng có thể lấy: %d câu, cần thêm: %d câu",
                tongCauCoThe, soCauThi - tongCauCoThe);
        }
        return null; // hợp lệ
    }

    // =====================================================
    // Helper: trả về form kèm error + data
    // =====================================================
    private void addFormData(Model model, GiaoVienDangKy dk, boolean isEdit) {
        model.addAttribute("dk", dk);
        model.addAttribute("isEdit", isEdit);
        if (!isEdit) {
            model.addAttribute("dsMonHoc", monHocDAO.findAll());
            model.addAttribute("dsLop", lopDAO.findAll());
        }
    }

    // =====================================================
    // Danh sách đăng ký thi
    // =====================================================
    @RequestMapping("/dangkythi.htm")
    public String index(HttpSession session, Model model) {
        String role = (String) session.getAttribute("role");
        String maGV = (String) session.getAttribute("maGV");

        List<GiaoVienDangKy> list;
        if (role.equals("PGV")) {
            list = dangKyDAO.findAll();
        } else {
            list = dangKyDAO.findByMaGV(maGV);
        }

        model.addAttribute("list", list);
        return "gv/dangkythi";
    }

    // =====================================================
    // Thêm đăng ký - GET
    // =====================================================
    @RequestMapping(value = "/dangkythi-them.htm", method = RequestMethod.GET)
    public String showThem(Model model) {
        model.addAttribute("dk", new GiaoVienDangKy());
        model.addAttribute("dsMonHoc", monHocDAO.findAll());
        model.addAttribute("dsLop", lopDAO.findAll());
        model.addAttribute("isEdit", false);
        return "gv/dangkythi-form";
    }

    // =====================================================
    // Thêm đăng ký - POST
    // =====================================================
    @RequestMapping(value = "/dangkythi-them.htm", method = RequestMethod.POST)
    public String doThem(@ModelAttribute GiaoVienDangKy dk, HttpSession session, Model model) {

        dk.setMaGV((String) session.getAttribute("maGV"));

        // Kiểm tra maGV hợp lệ
        if (dk.getMaGV() == null) {
            model.addAttribute("error", "Tài khoản này không có quyền đăng ký thi!");
            addFormData(model, dk, false);
            return "gv/dangkythi-form";
        }

     // 1. Kiểm tra trùng khóa chính
        GiaoVienDangKy existing = dangKyDAO.findByKey(dk.getMaLop(), dk.getMaMH(), dk.getLan());
        if (existing != null) {
            model.addAttribute("error", 
                "Lớp này đã có đăng ký thi lần " + dk.getLan() + " cho môn học này!");
            addFormData(model, dk, false);
            return "gv/dangkythi-form";
        }

        // 2. Kiểm tra lần 2 phải có lần 1 trước
        if (dk.getLan() == 2) {
            GiaoVienDangKy lan1 = dangKyDAO.findByKey(dk.getMaLop(), dk.getMaMH(), 1);
            if (lan1 == null) {
                model.addAttribute("error", "Chưa có đăng ký thi lần 1!");
                addFormData(model, dk, false);
                return "gv/dangkythi-form";
            }
            // ✅ Thêm: ngày thi lần 2 phải >= ngày thi lần 1
            LocalDate ngayThiLan1 = LocalDate.parse(lan1.getNgayThi(), 
                java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));
            LocalDate ngayThiLan2 = LocalDate.parse(dk.getNgayThi());
            if (ngayThiLan2.isBefore(ngayThiLan1)) {
                model.addAttribute("error", 
                    "Ngày thi lần 2 không hợp lệ!");
                addFormData(model, dk, false);
                return "gv/dangkythi-form";
            }
        }

        // 3. Validate số câu thi
        if (dk.getSoCauThi() < 10 || dk.getSoCauThi() > 100) {
            model.addAttribute("error", "Số câu thi phải từ 10 đến 100!");
            addFormData(model, dk, false);
            return "gv/dangkythi-form";
        }

        // 4. Validate ngày thi
        LocalDate ngayThi = LocalDate.parse(dk.getNgayThi());
        if (ngayThi.isBefore(LocalDate.now())) {
            model.addAttribute("error", "Ngày thi không hợp lệ!");
            addFormData(model, dk, false);
            return "gv/dangkythi-form";
        }

        // 5. Validate thời gian thi
        if (dk.getThoiGian() < 5 || dk.getThoiGian() > 60) {
            model.addAttribute("error", "Thời gian thi phải từ 5 đến 60 phút!");
            addFormData(model, dk, false);
            return "gv/dangkythi-form";
        }

        // 6. Kiểm tra đủ số câu theo rule 70/30
        String loi70_30 = kiemTraSoCau(dk.getMaMH(), dk.getTrinhDo(), dk.getSoCauThi());
        if (loi70_30 != null) {
            model.addAttribute("error", loi70_30);
            addFormData(model, dk, false);
            return "gv/dangkythi-form";
        }

        // 7. Insert
        try {
            dangKyDAO.insert(dk);
            session.setAttribute("successMsg", "Đăng ký thi thành công!");
            model.addAttribute("successMsg", "Đăng ký thi thành công!");
            addFormData(model, dk, false);
            return "gv/dangkythi-form";
        } catch (Exception e) {
            model.addAttribute("error", "Lỗi: " + e.getMessage());
            addFormData(model, dk, false);
            return "gv/dangkythi-form";
        }
    }

    // =====================================================
    // Sửa đăng ký - GET
    // =====================================================
    @RequestMapping(value = "/dangkythi-sua.htm", method = RequestMethod.GET)
    public String showSua(@RequestParam String maLop, @RequestParam String maMH,
            @RequestParam int lan, HttpSession session, Model model) {

        // Kiểm tra đã có SV thi chưa
        if (dangKyDAO.kiemTraSV(maLop, maMH, lan)) {
            session.setAttribute("errorMsg", "Không thể sửa: đã có sinh viên thi ca này!");
            return "redirect:/gv/dangkythi.htm";
        }

        // Kiểm tra còn trong tương lai không
        GiaoVienDangKy dk = dangKyDAO.findByKey(maLop, maMH, lan);
        LocalDate ngayThi = LocalDate.parse(dk.getNgayThi());
        if (!ngayThi.isAfter(LocalDate.now())) {
            session.setAttribute("errorMsg", "Không thể sửa: ca thi đã diễn ra!");
            return "redirect:/gv/dangkythi.htm";
        }

        model.addAttribute("dk", dk);
        model.addAttribute("isEdit", true);
        return "gv/dangkythi-form";
    }

    // =====================================================
    // Sửa đăng ký - POST
    // =====================================================
    @RequestMapping(value = "/dangkythi-sua.htm", method = RequestMethod.POST)
    public String doSua(@ModelAttribute GiaoVienDangKy dk, HttpSession session, Model model) {

        // 1. Validate ngày thi
        LocalDate ngayThi = LocalDate.parse(dk.getNgayThi());
        if (ngayThi.isBefore(LocalDate.now())) {
            model.addAttribute("error", "Ngày thi không hợp lệ!");
            addFormData(model, dk, true);
            return "gv/dangkythi-form";
        }

        // 2. Validate số câu
        if (dk.getSoCauThi() < 10 || dk.getSoCauThi() > 100) {
            model.addAttribute("error", "Số câu thi phải từ 10 đến 100!");
            addFormData(model, dk, true);
            return "gv/dangkythi-form";
        }

        // 3. Validate thời gian
        if (dk.getThoiGian() < 5 || dk.getThoiGian() > 60) {
            model.addAttribute("error", "Thời gian thi phải từ 5 đến 60 phút!");
            addFormData(model, dk, true);
            return "gv/dangkythi-form";
        }

        // 4. Kiểm tra đủ số câu theo rule 70/30
        String loi70_30 = kiemTraSoCau(dk.getMaMH(), dk.getTrinhDo(), dk.getSoCauThi());
        if (loi70_30 != null) {
            model.addAttribute("error", loi70_30);
            addFormData(model, dk, true);
            return "gv/dangkythi-form";
        }

        // 5. Update
        try {
            dangKyDAO.update(dk);
            session.setAttribute("successMsg", "Cập nhật đăng ký thi thành công!");
            return "redirect:/gv/dangkythi.htm";
        } catch (Exception e) {
            model.addAttribute("error", "Lỗi: " + e.getMessage());
            addFormData(model, dk, true);
            return "gv/dangkythi-form";
        }
    }

    // =====================================================
    // Xóa đăng ký
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
}