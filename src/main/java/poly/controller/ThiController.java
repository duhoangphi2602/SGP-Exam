package poly.controller;

import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import poly.dao.ThiDAO;
import poly.dao.SinhVienDAO;
import poly.dao.LopDAO;
import poly.model.CauHoiThi;
import poly.model.GiaoVienDangKy;
import poly.model.SinhVien;
import poly.model.Lop;

@Controller
@RequestMapping("/sv")
public class ThiController {

    @Autowired ThiDAO thiDAO;
    @Autowired SinhVienDAO svDAO;
    @Autowired LopDAO lopDAO;

    // Trang thi — hiện danh sách ca thi
    @RequestMapping("/thi.htm")
    public String index(HttpSession session, Model model) {
        String maSV = (String) session.getAttribute("masv");

        // Lấy thông tin SV + lớp
        SinhVien sv = svDAO.findByMa(maSV);
        Lop lop = lopDAO.findByMa(sv.getMaLop());

        // Lấy danh sách môn thi
        List<Map<String, Object>> dsMonHoc = thiDAO.getMonHoc(maSV);

        // Lấy danh sách ca thi + trạng thái
        List<Map<String, Object>> dsCaThi = thiDAO.getDanhSachCaThi(maSV);

        model.addAttribute("sv", sv);
        model.addAttribute("lop", lop);
        model.addAttribute("dsMonHoc", dsMonHoc);
        model.addAttribute("dsCaThi", dsCaThi);
        return "sv/thi";
    }

    // AJAX — lấy ngày thi theo môn
    @RequestMapping("/thi-getngay.htm")
    @ResponseBody
    public List<Map<String, Object>> getNgayThi(
            @RequestParam String maMH,
            HttpSession session) {
        String maSV = (String) session.getAttribute("masv");
        return thiDAO.getNgayThi(maSV, maMH);
    }

    // AJAX — lấy lần thi theo môn + ngày
    @RequestMapping("/thi-getlan.htm")
    @ResponseBody
    public List<Map<String, Object>> getLanThi(
            @RequestParam String maMH,
            @RequestParam String ngayThi,
            HttpSession session) {
        String maSV = (String) session.getAttribute("masv");
        return thiDAO.getLanThi(maSV, maMH, ngayThi);
    }

    // AJAX — lấy thông tin ca thi
    @RequestMapping("/thi-getthongtin.htm")
    @ResponseBody
    public Map<String, Object> getThongTin(
            @RequestParam String maMH,
            @RequestParam String ngayThi,
            @RequestParam int lan,
            HttpSession session) {
        String maSV = (String) session.getAttribute("masv");
        GiaoVienDangKy dk = thiDAO.getThongTinCaThi(maSV, maMH, ngayThi, lan);
        if (dk == null) return null;

        Map<String, Object> result = new java.util.HashMap<>();
        result.put("soCauThi", dk.getSoCauThi());
        result.put("thoiGian", dk.getThoiGian());
        result.put("trinhDo", dk.getTrinhDo());
        return result;
    }

    // Bắt đầu thi
    @RequestMapping(value = "/thi-batdau.htm", method = RequestMethod.POST)
    public String batDauThi(
            @RequestParam String maMH,
            @RequestParam String ngayThi,
            @RequestParam int lan,
            HttpSession session, Model model) {

        String maSV = (String) session.getAttribute("masv");

        // Lấy thông tin ca thi
        GiaoVienDangKy dk = thiDAO.getThongTinCaThi(maSV, maMH, ngayThi, lan);
        if (dk == null) {
            model.addAttribute("error", "Không tìm thấy ca thi!");
            return "redirect:/sv/thi.htm";
        }

        // Random câu hỏi
        List<CauHoiThi> dsCauHoi = thiDAO.randomCauHoi(
            maMH, dk.getTrinhDo(), dk.getSoCauThi());

        // Lưu vào session
        session.setAttribute("dsCauHoi", dsCauHoi);
        session.setAttribute("maMH", maMH);
        session.setAttribute("lan", lan);
        session.setAttribute("thoiGian", dk.getThoiGian());
        session.setAttribute("soCauThi", dk.getSoCauThi());

        return "redirect:/sv/thi-lamBai.htm";
    }

    // Trang làm bài
    @RequestMapping("/thi-lamBai.htm")
    public String lamBai(HttpSession session, Model model) {
        List<CauHoiThi> dsCauHoi = 
            (List<CauHoiThi>) session.getAttribute("dsCauHoi");
        int thoiGian = (int) session.getAttribute("thoiGian");

        model.addAttribute("dsCauHoi", dsCauHoi);
        model.addAttribute("thoiGian", thoiGian * 60); // đổi sang giây
        return "sv/thi-lamBai";
    }

    // Nộp bài
    @RequestMapping(value = "/thi-nopBai.htm", method = RequestMethod.POST)
    public String nopBai(
            @RequestParam Map<String, String> dapAnSV,
            HttpSession session, Model model) {

        String maSV = (String) session.getAttribute("masv");
        String maMH = (String) session.getAttribute("maMH");
        int lan = (int) session.getAttribute("lan");
        int soCauThi = (int) session.getAttribute("soCauThi");
        List<CauHoiThi> dsCauHoi = 
            (List<CauHoiThi>) session.getAttribute("dsCauHoi");

        // Tính điểm
        int soCauDung = 0;
        for (CauHoiThi cau : dsCauHoi) {
            String dapAnChon = dapAnSV.get("dapAn_" + cau.getCauHoi());
            // Lấy đáp án đúng từ DB
            String dapAnDung = getDapAnDung(cau.getCauHoi());
            if (dapAnChon != null && dapAnChon.equals(dapAnDung)) {
                soCauDung++;
            }
        }

        double diem = ((double) soCauDung / soCauThi) * 10;
        diem = Math.round(diem * 10.0) / 10.0; // làm tròn 1 chữ số

        // Ghi điểm vào DB
        thiDAO.ghiDiem(maSV, maMH, lan, diem);

        // Lưu kết quả vào session để hiện
        session.setAttribute("ketQua_diem", diem);
        session.setAttribute("ketQua_soCauDung", soCauDung);
        session.setAttribute("ketQua_soCauThi", soCauThi);
        session.setAttribute("ketQua_dsCauHoi", dsCauHoi);
        session.setAttribute("ketQua_dapAnSV", dapAnSV);

        return "redirect:/sv/thi-ketQua.htm";
    }

    // Lấy đáp án đúng từ DB
    private String getDapAnDung(int cauHoi) {
        List<Map<String, Object>> result = 
            thiDAO.getDapAnDung(cauHoi);
        if (result.isEmpty()) return "";
        return result.get(0).get("DAP_AN").toString().trim();
    }

}