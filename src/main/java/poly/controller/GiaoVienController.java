package poly.controller;

import java.util.List;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import poly.dao.GiaoVienDAO;
import poly.model.GiaoVien;

@Controller
@RequestMapping("/pgv")
public class GiaoVienController {

    @Autowired
    GiaoVienDAO giaoVienDAO;

    // =====================================================
    // Helper: validate GV
    // =====================================================
    private String validateGV(GiaoVien gv, String maGVLoaiTru) {
        if (gv.getHo() == null || gv.getHo().trim().isEmpty()
                || gv.getTen() == null || gv.getTen().trim().isEmpty()) {
            return "Họ và Tên không được để trống!";
        }
        if (gv.getSoDTLL() == null || !gv.getSoDTLL().trim().matches("0\\d{9}")) {
            return "Số điện thoại không hợp lệ! (phải có 10 số, bắt đầu bằng 0)";
        }
        return null;
    }

    // =====================================================
    // Helper: build rows HTML
    // =====================================================
    private String buildRows(List<GiaoVien> list) {
        StringBuilder sb = new StringBuilder();
        for (GiaoVien gv : list) {
            sb.append("<tr>");
            sb.append("<td>").append(escape(gv.getMaGV())).append("</td>");
            sb.append("<td>").append(escape(gv.getHo())).append("</td>");
            sb.append("<td>").append(escape(gv.getTen())).append("</td>");
            sb.append("<td>").append(escape(gv.getSoDTLL())).append("</td>");
            sb.append("<td>").append(escape(gv.getDiaChi())).append("</td>");
            sb.append("<td>");
            sb.append("<button type=\"button\" class=\"btn btn-sm btn-warning\" ")
              .append("onclick=\"moModalSua('")
              .append(escapeJs(gv.getMaGV())).append("','")
              .append(escapeJs(gv.getHo())).append("','")
              .append(escapeJs(gv.getTen())).append("','")
              .append(escapeJs(gv.getSoDTLL())).append("','")
              .append(escapeJs(gv.getDiaChi())).append("')\">Hiệu chỉnh</button> ");
            sb.append("<button type=\"button\" class=\"btn btn-sm btn-danger\" ")
              .append("onclick=\"xoaGV('").append(escapeJs(gv.getMaGV())).append("')\">Xóa</button>");
            sb.append("</td>");
            sb.append("</tr>");
        }
        return sb.toString();
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }

    private String escapeJs(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("'", "\\'");
    }

    // =====================================================
    // Danh sách
    // =====================================================
    @RequestMapping("/giaovien.htm")
    public String index(@RequestParam(required = false) String timkiem, Model model) {
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

    // =====================================================
    // AJAX: Ghi (Thêm hoặc Sửa)
    // =====================================================
    @RequestMapping(value = "/giaovien-ghi.htm", method = RequestMethod.POST)
    @ResponseBody
    public String doGhi(@RequestParam String maGV,
                         @RequestParam String ho,
                         @RequestParam String ten,
                         @RequestParam String soDTLL,
                         @RequestParam String diaChi,
                         @RequestParam String mode,
                         HttpServletResponse response) {
        response.setContentType("text/plain;charset=UTF-8");
        try {
            GiaoVien gv = new GiaoVien();
            gv.setMaGV(maGV.trim());
            gv.setHo(ho.trim());
            gv.setTen(ten.trim());
            gv.setSoDTLL(soDTLL.trim());
            gv.setDiaChi(diaChi.trim());

            String loi = validateGV(gv, "them".equals(mode) ? "" : maGV.trim());
            if (loi != null) return "ERROR|" + loi;

            if ("them".equals(mode)) {
                giaoVienDAO.insert(gv);
            } else {
                giaoVienDAO.update(gv);
            }

            return "OK|" + buildRows(giaoVienDAO.findAll());
        } catch (Exception e) {
            String err = e.getMessage();
            if (err.contains("PRIMARY KEY") || err.contains("duplicate key")) {
                return "ERROR|Mã giáo viên '" + maGV.trim() + "' đã tồn tại!";
            }
            return "ERROR|Lỗi: " + err;
        }
    }

    // =====================================================
    // AJAX: Xóa
    // =====================================================
    @RequestMapping(value = "/giaovien-xoa-ajax.htm", method = RequestMethod.POST)
    @ResponseBody
    public String doXoaAjax(@RequestParam String ma, HttpServletResponse response) {
        response.setContentType("text/plain;charset=UTF-8");
        try {
            int soCau = giaoVienDAO.kiemTraConCauHoi(ma);
            if (soCau > 0) {
                return "ERROR|Không thể xóa! Giáo viên này còn câu hỏi trong bộ đề.";
            }

            int soDangKy = giaoVienDAO.kiemTraConDangKy(ma);
            if (soDangKy > 0) {
                return "ERROR|Không thể xóa! Giáo viên này còn ca thi đã đăng ký.";
            }

            if (giaoVienDAO.coTaiKhoan(ma)) {
                return "ERROR|Không thể xóa! Giáo viên này còn tài khoản đăng nhập, vui lòng xóa tài khoản trước.";
            }

            giaoVienDAO.delete(ma);
            return "OK|" + buildRows(giaoVienDAO.findAll());
        } catch (Exception e) {
            return "ERROR|Lỗi: " + e.getMessage();
        }
    }
}