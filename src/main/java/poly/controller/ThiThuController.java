package poly.controller;

import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import poly.dao.GiaoVienDangKyDAO;
import poly.dao.ThiDAO;
import poly.model.CauHoiThi;
import poly.model.GiaoVienDangKy;

@Controller
@RequestMapping("/gv")
public class ThiThuController {

    @Autowired ThiDAO thiDAO;
    @Autowired GiaoVienDangKyDAO dangKyDAO;

    // =====================================================
    // 1. Trang chọn ca thi để thi thử
    // =====================================================
    @RequestMapping(value = "/thi-thu.htm", method = RequestMethod.GET)
    public String index(HttpSession session, Model model) {
        String maGV = (String) session.getAttribute("maGV");
        String role = (String) session.getAttribute("role");

        List<GiaoVienDangKy> dsCaThi;
        if ("PGV".equals(role) && maGV == null) {
            // Admin chính không có mã GV → không có ca thi
            dsCaThi = java.util.Collections.emptyList();
            model.addAttribute("warningMsg", "Tài khoản của bạn không có mã giáo viên liên kết, không thể thi thử.");
        } else {
            dsCaThi = dangKyDAO.findByMaGV(maGV);
        }

        model.addAttribute("dsCaThi", dsCaThi);
        return "gv/thi-thu";
    }

    // =====================================================
    // 2. Bắt đầu thi thử
    // =====================================================
    @RequestMapping(value = "/thi-thu-batdau.htm", method = RequestMethod.POST)
    public String batDau(@RequestParam String maLop,
                          @RequestParam String maMH,
                          @RequestParam int lan,
                          HttpSession session) {
        String maGV = (String) session.getAttribute("maGV");

        // Lấy thông tin ca thi (dùng lại SP_THI_GETTHONGTIN)
        // Truyền maGV thay vì maSV vì đây là GV thi thử
        GiaoVienDangKy dk = dangKyDAO.findByKey(maLop, maMH, lan);
        if (dk == null) {
            session.setAttribute("errorMsg", "Không tìm thấy ca thi!");
            return "redirect:/gv/thi-thu.htm";
        }

        // Random câu hỏi (dùng lại SP_THI_RANDOM)
        List<CauHoiThi> dsCauHoi = thiDAO.randomCauHoi(maMH, dk.getTrinhDo(), dk.getSoCauThi());
        if (dsCauHoi == null || dsCauHoi.isEmpty()) {
            session.setAttribute("errorMsg", "Không thể random câu hỏi, vui lòng kiểm tra bộ đề!");
            return "redirect:/gv/thi-thu.htm";
        }

        // Lưu session — dùng prefix "thiThu_" để không xung đột với session thi SV
        session.setAttribute("thiThu_dsCauHoi", dsCauHoi);
        session.setAttribute("thiThu_maMH", maMH);
        session.setAttribute("thiThu_lan", lan);
        session.setAttribute("thiThu_thoiGian", dk.getThoiGian());
        session.setAttribute("thiThu_soCauThi", dk.getSoCauThi());
        session.setAttribute("thiThu_maLop", maLop);

        return "redirect:/gv/thi-thu-lamBai.htm";
    }

    // =====================================================
    // 3. Trang làm bài thi thử
    // =====================================================
    @RequestMapping(value = "/thi-thu-lamBai.htm", method = RequestMethod.GET)
    public String lamBai(HttpSession session, Model model) {
        List<CauHoiThi> dsCauHoi = (List<CauHoiThi>) session.getAttribute("thiThu_dsCauHoi");

        if (dsCauHoi == null || dsCauHoi.isEmpty()) {
            session.setAttribute("errorMsg", "Vui lòng chọn ca thi trước!");
            return "redirect:/gv/thi-thu.htm";
        }

        int thoiGian = (int) session.getAttribute("thiThu_thoiGian");
        model.addAttribute("dsCauHoi", dsCauHoi);
        model.addAttribute("thoiGian", thoiGian * 60); // đổi sang giây
        return "gv/thi-thu-lamBai";
    }

    // =====================================================
    // 4. Xử lý kết quả thi thử (không ghi DB)
    // =====================================================
    @RequestMapping(value = "/thi-thu-ketqua.htm", method = RequestMethod.POST)
    public String ketQua(@RequestParam Map<String, String> dapAnGV,
                          HttpSession session, Model model) {

        List<CauHoiThi> dsCauHoi = (List<CauHoiThi>) session.getAttribute("thiThu_dsCauHoi");
        int soCauThi = (int) session.getAttribute("thiThu_soCauThi");

        // Guard
        if (dsCauHoi == null) {
            return "redirect:/gv/thi-thu.htm";
        }

        // Tính điểm + thu thập kết quả từng câu
        int soCauDung = 0;
        List<Map<String, Object>> ketQuaTungCau = new java.util.ArrayList<>();

        for (CauHoiThi cau : dsCauHoi) {
            String dapAnChon = dapAnGV.get("dapAn_" + cau.getCauHoi());
            // Lấy đáp án đúng từ bảng BODE (GV có quyền xem)
            List<Map<String, Object>> result = thiDAO.getDapAnDung(cau.getCauHoi());
            String dapAnDung = (result != null && !result.isEmpty())
                ? result.get(0).get("DAP_AN").toString().trim() : "";

            boolean dungKhong = dapAnChon != null && dapAnChon.trim().equals(dapAnDung);
            if (dungKhong) soCauDung++;

            Map<String, Object> row = new java.util.LinkedHashMap<>();
            row.put("cauHoi", cau.getCauHoi());
            row.put("noiDung", cau.getNoiDung());
            row.put("a", cau.getA());
            row.put("b", cau.getB());
            row.put("c", cau.getC());
            row.put("d", cau.getD());
            row.put("dapAnChon", dapAnChon != null ? dapAnChon : "(Bỏ qua)");
            row.put("dapAnDung", dapAnDung);
            row.put("dungKhong", dungKhong);
            ketQuaTungCau.add(row);
        }

        double diem = Math.round(((double) soCauDung / soCauThi) * 10 * 10.0) / 10.0;

        // Lưu kết quả vào model
        model.addAttribute("diem", diem);
        model.addAttribute("soCauDung", soCauDung);
        model.addAttribute("soCauThi", soCauThi);
        model.addAttribute("ketQuaTungCau", ketQuaTungCau);

        // Dọn session thi thử
        session.removeAttribute("thiThu_dsCauHoi");
        session.removeAttribute("thiThu_maMH");
        session.removeAttribute("thiThu_lan");
        session.removeAttribute("thiThu_thoiGian");
        session.removeAttribute("thiThu_soCauThi");
        session.removeAttribute("thiThu_maLop");

        return "gv/thi-thu-ketQua";
    }
}