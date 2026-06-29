package poly.controller;

import java.util.ArrayDeque;
import java.util.Deque;
import java.util.List;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import poly.dao.GiaoVienDAO;
import poly.model.GiaoVien;
import poly.model.UndoAction;

@Controller
@RequestMapping("/pgv")
public class GiaoVienController {

    @Autowired
    GiaoVienDAO giaoVienDAO;

    // =====================================================
    // Helper: validate GV
    // =====================================================
    private String validateGV(GiaoVien gv, String maGVLoaiTru) {
        String maGV = gv.getMaGV();
        if (maGV == null || !maGV.matches("^[a-zA-Z0-9]+$")) {
            return "Mã Giáo viên không hợp lệ! (Chỉ được chứa chữ không dấu và số, không khoảng trắng, không ký tự đặc biệt).";
        }
        
        // Regex chữ tiếng việt + chữ cái, cho phép khoảng trắng ở giữa nhưng không được 2 khoảng trắng liền nhau
        String regexHoTen = "^[\\p{L}]+( [\\p{L}]+)*$";
        
        if (gv.getHo() == null || !gv.getHo().trim().matches(regexHoTen)) {
            return "Họ Giáo viên không hợp lệ! (Không chứa số, ký tự đặc biệt, không có 2 khoảng trắng liền nhau).";
        }
        if (gv.getTen() == null || !gv.getTen().trim().matches(regexHoTen)) {
            return "Tên Giáo viên không hợp lệ! (Không chứa số, ký tự đặc biệt, không có 2 khoảng trắng liền nhau).";
        }
        if (gv.getSoDTLL() != null && !gv.getSoDTLL().trim().isEmpty()) {
            if (!gv.getSoDTLL().trim().matches("^0\\d{9}$")) {
                return "Số điện thoại không hợp lệ! (Phải có đúng 10 số và bắt đầu bằng số 0).";
            }
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
            if (gv.isHasAccount()) {
                sb.append("<span class=\"badge bg-success\">Đã cấp (").append(escape(gv.getTenNhom())).append(")</span>");
            } else {
                sb.append("<span class=\"badge bg-secondary\">Chưa có</span>");
            }
            sb.append("</td>");
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
    public String doGhi(@RequestParam("maGV") String maGV,
                         @RequestParam("ho") String ho,
                         @RequestParam("ten") String ten,
                         @RequestParam(value="soDTLL", required=false, defaultValue="") String soDTLL,
                         @RequestParam(value="diaChi", required=false, defaultValue="") String diaChi,
                         @RequestParam("mode") String mode,
                         HttpSession session,
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

            Deque<UndoAction> stack = getStack(session);

            if ("them".equals(mode)) {
                giaoVienDAO.insert(gv);
                stack.push(new UndoAction("INSERT", "GIAOVIEN", null, gv));
            } else {
                GiaoVien oldGV = giaoVienDAO.findByMa(maGV.trim());
                giaoVienDAO.update(gv);
                stack.push(new UndoAction("UPDATE", "GIAOVIEN", oldGV, gv));
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
    public String doXoaAjax(@RequestParam("ma") String ma, HttpSession session, HttpServletResponse response) {
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

            GiaoVien oldGV = giaoVienDAO.findByMa(ma);
            giaoVienDAO.delete(ma);
            
            Deque<UndoAction> stack = getStack(session);
            stack.push(new UndoAction("DELETE", "GIAOVIEN", oldGV, null));
            
            return "OK|" + buildRows(giaoVienDAO.findAll());
        } catch (Exception e) {
            return "ERROR|Lỗi: " + e.getMessage();
        }
    }

    // =====================================================
    // AJAX: Phục hồi
    // =====================================================
    @RequestMapping(value = "/giaovien-phuchoi.htm", method = RequestMethod.POST)
    @ResponseBody
    public String doPhucHoi(HttpSession session, HttpServletResponse response) {
        response.setContentType("text/plain;charset=UTF-8");
        Deque<UndoAction> stack = getStack(session);

        if (stack.isEmpty()) {
            return "WARN|Không còn gì để phục hồi!";
        }

        UndoAction action = stack.pop();
        try {
            GiaoVien data = null;
            switch (action.getLoai()) {
                case "INSERT":
                    data = (GiaoVien) action.getNewData();
                    break;
                case "UPDATE":
                case "DELETE":
                    data = (GiaoVien) action.getOldData();
                    break;
            }
            giaoVienDAO.phucHoi(action.getLoai(), data.getMaGV(), data.getHo(), data.getTen(), data.getSoDTLL(), data.getDiaChi());
            return "OK|" + buildRows(giaoVienDAO.findAll());
        } catch (Exception e) {
            stack.push(action); // Push back if failed
            return "ERROR|Lỗi khi phục hồi: " + e.getMessage();
        }
    }

    @SuppressWarnings("unchecked")
    private Deque<UndoAction> getStack(HttpSession session) {
        Deque<UndoAction> stack = (Deque<UndoAction>) session.getAttribute("undoStack_GIAOVIEN");
        if (stack == null) {
            stack = new ArrayDeque<>();
            session.setAttribute("undoStack_GIAOVIEN", stack);
        }
        return stack;
    }
}