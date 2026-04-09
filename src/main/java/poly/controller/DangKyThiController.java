package poly.controller;

import java.time.LocalDate;
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

    // Danh sách đăng ký thi
    @RequestMapping("/dangkythi.htm")
    public String index(HttpSession session, Model model) {
        String role = (String) session.getAttribute("role");
        String maGV = (String) session.getAttribute("maGV");

        // PGV xem tất cả, GV chỉ xem của mình
        String maGVFilter = role.equals("PGV") ? null : maGV;
        model.addAttribute("list", dangKyDAO.findByMaGV(maGVFilter));
        return "gv/dangkythi";
    }

    // Form đăng ký - GET
    @RequestMapping(value = "/dangkythi-them.htm", method = RequestMethod.GET)
    public String showThem(Model model) {
        model.addAttribute("dk", new GiaoVienDangKy());
        model.addAttribute("dsMonHoc", monHocDAO.findAll());
        model.addAttribute("dsLop", lopDAO.findAll());
        return "gv/dangkythi-form";
    }

    // Form đăng ký - POST
    @RequestMapping(value = "/dangkythi-them.htm", method = RequestMethod.POST)
    public String doThem(
            @ModelAttribute GiaoVienDangKy dk,
            HttpSession session, Model model) {

        dk.setMaGV((String) session.getAttribute("maGV"));

        // Validate số câu
        if (dk.getSoCauThi() < 10 || dk.getSoCauThi() > 100) {
            model.addAttribute("error", "Số câu thi phải từ 10 đến 100!");
            model.addAttribute("dk", dk);
            model.addAttribute("dsMonHoc", monHocDAO.findAll());
            model.addAttribute("dsLop", lopDAO.findAll());
            return "gv/dangkythi-form";
        }

        // Validate thời gian
        if (dk.getThoiGian() < 5 || dk.getThoiGian() > 60) {
            model.addAttribute("error", "Thời gian thi phải từ 5 đến 60 phút!");
            model.addAttribute("dk", dk);
            model.addAttribute("dsMonHoc", monHocDAO.findAll());
            model.addAttribute("dsLop", lopDAO.findAll());
            return "gv/dangkythi-form";
        }

        // Validate ngày thi
        LocalDate ngayThi = LocalDate.parse(dk.getNgayThi());
        if (ngayThi.isBefore(LocalDate.now())) {
            model.addAttribute("error", "Ngày thi không được trước ngày hôm nay!");
            model.addAttribute("dk", dk);
            model.addAttribute("dsMonHoc", monHocDAO.findAll());
            model.addAttribute("dsLop", lopDAO.findAll());
            return "gv/dangkythi-form";
        }

        // Kiểm tra số câu chi tiết theo rule 70/30
        Map<String, Integer> soCauChiTiet = dangKyDAO.demSoCauChiTiet(dk.getMaMH());
        int cauChinh = soCauChiTiet.get(dk.getTrinhDo());
        int cauPhu = 0;

        // Xác định trình độ phụ (thấp hơn 1 bậc)
        String trinhDoPhu = null;
        if (dk.getTrinhDo().equals("A")) trinhDoPhu = "B";
        else if (dk.getTrinhDo().equals("B")) trinhDoPhu = "C";

        if (trinhDoPhu != null) {
            cauPhu = soCauChiTiet.get(trinhDoPhu);
        }

        // Tính số câu tối thiểu trình độ chính (70%)
        int cauChinhToiThieu = (int) Math.ceil(dk.getSoCauThi() * 0.7);
        // Tính số câu tối đa trình độ phụ (30%)
        int cauPhuToiDa = dk.getSoCauThi() - cauChinhToiThieu;
        // Tổng câu có thể lấy
        int tongCauCoThe = cauChinh + Math.min(cauPhu, cauPhuToiDa);

        if (cauChinh < cauChinhToiThieu) {
            String thongBao = String.format(
                "Không đủ câu hỏi trình độ %s!\n" +
                "Đang có: %d câu\n" +
                "Cần thêm: %d câu",
                dk.getTrinhDo(),
                cauChinh,
                cauChinhToiThieu - cauChinh
            );
            model.addAttribute("error", thongBao);
            model.addAttribute("dk", dk);
            model.addAttribute("dsMonHoc", monHocDAO.findAll());
            model.addAttribute("dsLop", lopDAO.findAll());
            return "gv/dangkythi-form";
        }

        if (tongCauCoThe < dk.getSoCauThi()) {
            String thongBao = String.format(
                "Không đủ câu hỏi trình độ %s!\n" +
                "Đang có: %d câu\n" +
                "Cần thêm: %d câu",
                dk.getTrinhDo(),
                tongCauCoThe,
                dk.getSoCauThi() - tongCauCoThe
            );
            model.addAttribute("error", thongBao);
            model.addAttribute("dk", dk);
            model.addAttribute("dsMonHoc", monHocDAO.findAll());
            model.addAttribute("dsLop", lopDAO.findAll());
            return "gv/dangkythi-form";
        }

        if (tongCauCoThe < dk.getSoCauThi()) {
            String thongBao = String.format(
                "Không đủ câu hỏi!%n" +
                "- Trình độ %s: có %d câu%n" +
                "%s" +
                "- Tổng có thể lấy: %d câu / Yêu cầu: %d câu",
                dk.getTrinhDo(), cauChinh,
                trinhDoPhu != null ? String.format(
                    "- Trình độ %s: có %d câu (tối đa %d câu)%n",
                    trinhDoPhu, cauPhu, cauPhuToiDa) : "",
                tongCauCoThe, dk.getSoCauThi()
            );
            model.addAttribute("error", thongBao);
            model.addAttribute("dk", dk);
            model.addAttribute("dsMonHoc", monHocDAO.findAll());
            model.addAttribute("dsLop", lopDAO.findAll());
            return "gv/dangkythi-form";
        }

        // Kiểm tra trùng khóa chính
        GiaoVienDangKy existing = dangKyDAO.findByKey(
            dk.getMaLop(), dk.getMaMH(), dk.getLan());
        if (existing != null) {
            model.addAttribute("error",
                "Lớp này đã được đăng ký thi môn " +
                dk.getMaMH() + " lần " + dk.getLan() + " rồi!");
            model.addAttribute("dk", dk);
            model.addAttribute("dsMonHoc", monHocDAO.findAll());
            model.addAttribute("dsLop", lopDAO.findAll());
            return "gv/dangkythi-form";
        }

        try {
            dangKyDAO.insert(dk);
            session.setAttribute("successMsg", "Đăng ký thi thành công!");
            return "redirect:/gv/dangkythi.htm";
        } catch (Exception e) {
            model.addAttribute("error", "Lỗi: " + e.getMessage());
            model.addAttribute("dk", dk);
            model.addAttribute("dsMonHoc", monHocDAO.findAll());
            model.addAttribute("dsLop", lopDAO.findAll());
            return "gv/dangkythi-form";
        }
    }

    // Xóa đăng ký
    @RequestMapping("/dangkythi-xoa.htm")
    public String doXoa(
            @RequestParam String maLop,
            @RequestParam String maMH,
            @RequestParam int lan,
            HttpSession session) {
        dangKyDAO.delete(maLop, maMH, lan);
        session.setAttribute("successMsg", "Xóa đăng ký thi thành công!");
        return "redirect:/gv/dangkythi.htm";
    }
}