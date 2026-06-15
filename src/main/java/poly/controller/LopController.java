package poly.controller;

import java.util.ArrayDeque;
import java.util.Deque;
import java.util.List;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import poly.dao.LopDAO;
import poly.dao.SinhVienDAO;
import poly.model.Lop;
import poly.model.SinhVien;
import poly.model.UndoAction;

@Controller
@RequestMapping("/pgv")
public class LopController {

    @Autowired LopDAO lopDAO;
    @Autowired SinhVienDAO svDAO;

    // =====================================================
    // 1. Danh sách lớp
    // =====================================================
    @RequestMapping("/lop.htm")
    public String index(Model model) {
        model.addAttribute("list", lopDAO.findAll());
        return "pgv/lop";
    }

    // =====================================================
    // 2. AJAX: Ghi (Thêm hoặc Sửa) Lớp
    // =====================================================
    @RequestMapping(value = "/lop-ghi.htm", method = RequestMethod.POST, produces = "text/plain;charset=UTF-8")
    @ResponseBody
    public String doGhi(@RequestParam String maLop,
                         @RequestParam String tenLop,
                         @RequestParam String mode, // "them" hoặc "sua"
                         HttpSession session) {
        try {
            Lop lop = new Lop();
            lop.setMaLop(maLop);
            lop.setTenLop(tenLop);

            Deque<UndoAction> stack = getStack(session);

            if ("them".equals(mode)) {
                lopDAO.insert(lop);
                stack.push(new UndoAction("INSERT", "LOP", null, lop));
            } else {
                Lop oldLop = lopDAO.findByMa(maLop);
                lopDAO.update(lop);
                stack.push(new UndoAction("UPDATE", "LOP", oldLop, lop));
            }

            return "OK|" + buildRows(lopDAO.findAll());
        } catch (Exception e) {
            return "ERROR|" + parseError(e.getMessage(), maLop);
        }
    }

    // =====================================================
    // 3. AJAX: Xóa Lớp
    // =====================================================
    @RequestMapping(value = "/lop-xoa-ajax.htm", method = RequestMethod.POST, produces = "text/plain;charset=UTF-8")
    @ResponseBody
    public String doXoaAjax(@RequestParam String ma, HttpSession session) {
        try {
            int soSV = lopDAO.kiemTraConSV(ma);
            if (soSV > 0) {
                return "ERROR|Không thể xóa! Lớp này còn " + soSV + " sinh viên.";
            }

            Lop oldLop = lopDAO.findByMa(ma);
            lopDAO.delete(ma);

            Deque<UndoAction> stack = getStack(session);
            stack.push(new UndoAction("DELETE", "LOP", oldLop, null));

            return "OK|" + buildRows(lopDAO.findAll());
        } catch (Exception e) {
            return "ERROR|Lỗi: " + e.getMessage();
        }
    }

    // =====================================================
    // 4. AJAX: Phục hồi Lớp
    // =====================================================
    @RequestMapping(value = "/lop-phuchoi.htm", method = RequestMethod.POST, produces = "text/plain;charset=UTF-8")
    @ResponseBody
    public String doPhucHoi(HttpSession session) {
        Deque<UndoAction> stack = getStack(session);

        if (stack.isEmpty()) {
            return "WARN|Không còn gì để phục hồi!";
        }

        UndoAction action = stack.pop();
        try {
            switch (action.getLoai()) {
                case "INSERT":
                    Lop inserted = (Lop) action.getNewData();
                    lopDAO.delete(inserted.getMaLop());
                    break;
                case "UPDATE":
                    Lop old = (Lop) action.getOldData();
                    lopDAO.update(old);
                    break;
                case "DELETE":
                    Lop deleted = (Lop) action.getOldData();
                    lopDAO.insert(deleted);
                    break;
            }
            return "OK|" + buildRows(lopDAO.findAll());
        } catch (Exception e) {
            stack.push(action);
            return "ERROR|Lỗi khi phục hồi: " + e.getMessage();
        }
    }

    // =====================================================
    // Helpers - Lớp
    // =====================================================
    @SuppressWarnings("unchecked")
    private Deque<UndoAction> getStack(HttpSession session) {
        Deque<UndoAction> stack = (Deque<UndoAction>) session.getAttribute("undoStack_LOP");
        if (stack == null) {
            stack = new ArrayDeque<>();
            session.setAttribute("undoStack_LOP", stack);
        }
        return stack;
    }

    private String parseError(String err, String maLop) {
        if (err.contains("PRIMARY KEY") || err.contains("duplicate key")) {
            return "Mã lớp '" + maLop.trim() + "' đã tồn tại!";
        } else if (err.contains("UNIQUE")) {
            return "Tên lớp đã tồn tại!";
        }
        return "Lỗi: " + err;
    }

    private String buildRows(List<Lop> list) {
        StringBuilder sb = new StringBuilder();
        for (Lop lop : list) {
            sb.append("<tr>");
            sb.append("<td>").append(escape(lop.getMaLop())).append("</td>");
            sb.append("<td>").append(escape(lop.getTenLop())).append("</td>");
            sb.append("<td>");
            sb.append("<a href=\"lop-sinhvien.htm?ma=").append(escape(lop.getMaLop()))
              .append("\" class=\"btn btn-sm btn-info\">Sinh viên</a> ");
            sb.append("<button type=\"button\" class=\"btn btn-sm btn-warning\" ")
              .append("onclick=\"moModalSua('").append(escapeJs(lop.getMaLop())).append("', '")
              .append(escapeJs(lop.getTenLop())).append("')\">Hiệu chỉnh</button> ");
            sb.append("<button type=\"button\" class=\"btn btn-sm btn-danger\" ")
              .append("onclick=\"xoaLop('").append(escapeJs(lop.getMaLop())).append("')\">Xóa</button>");
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

    // =====================================================================
    // Phần Sinh viên (subform) - giữ nguyên tạm thời, sẽ sửa ở task tiếp theo
    // =====================================================================

    @RequestMapping("/lop-sinhvien.htm")
    public String dsSinhVien(@RequestParam String ma, Model model) {
        model.addAttribute("lop", lopDAO.findByMa(ma));
        model.addAttribute("dssv", svDAO.findByLop(ma));
        return "pgv/lop-sinhvien";
    }

    @RequestMapping(value = "/sv-them.htm", method = RequestMethod.GET)
    public String showThemSV(@RequestParam String maLop, Model model) {
        SinhVien sv = new SinhVien();
        sv.setMaLop(maLop);
        model.addAttribute("sv", sv);
        model.addAttribute("action", "them");
        return "pgv/sv-form";
    }

    @RequestMapping(value = "/sv-them.htm", method = RequestMethod.POST)
    public String doThemSV(@ModelAttribute SinhVien sv, Model model) {
        try {
            java.time.LocalDate ngaySinh = java.time.LocalDate.parse(
                sv.getNgaySinh(),
                java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));

            if (ngaySinh.isAfter(java.time.LocalDate.now())) {
                model.addAttribute("error", "Ngày sinh không được là ngày trong tương lai!");
                model.addAttribute("sv", sv);
                model.addAttribute("action", "them");
                return "pgv/sv-form";
            }

            svDAO.insert(sv);
            return "redirect:/pgv/lop-sinhvien.htm?ma=" + sv.getMaLop();
        } catch (java.time.format.DateTimeParseException e) {
            model.addAttribute("error", "Ngày sinh không đúng định dạng dd/MM/yyyy!");
            model.addAttribute("sv", sv);
            model.addAttribute("action", "them");
            return "pgv/sv-form";
        } catch (Exception e) {
            String err = e.getMessage();
            if (err.contains("PRIMARY KEY") || err.contains("duplicate key")) {
                model.addAttribute("error", "Mã sinh viên '" + sv.getMaSV().trim() + "' đã tồn tại!");
            } else if (err.contains("FOREIGN KEY")) {
                model.addAttribute("error", "Mã lớp không tồn tại!");
            } else {
                model.addAttribute("error", "Lỗi: " + err);
            }
            model.addAttribute("sv", sv);
            model.addAttribute("action", "them");
            return "pgv/sv-form";
        }
    }

    @RequestMapping(value = "/sv-sua.htm", method = RequestMethod.GET)
    public String showSuaSV(@RequestParam String ma, Model model) {
        model.addAttribute("sv", svDAO.findByMa(ma));
        model.addAttribute("action", "sua");
        return "pgv/sv-form";
    }

    @RequestMapping(value = "/sv-sua.htm", method = RequestMethod.POST)
    public String doSuaSV(@ModelAttribute SinhVien sv, Model model) {
        try {
            java.time.LocalDate ngaySinh = java.time.LocalDate.parse(
                sv.getNgaySinh(),
                java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));

            if (ngaySinh.isAfter(java.time.LocalDate.now())) {
                model.addAttribute("error", "Ngày sinh không không hợp lệ!");
                model.addAttribute("sv", sv);
                model.addAttribute("action", "sua");
                return "pgv/sv-form";
            }

            svDAO.update(sv);
            return "redirect:/pgv/lop-sinhvien.htm?ma=" + sv.getMaLop();
        } catch (java.time.format.DateTimeParseException e) {
            model.addAttribute("error", "Ngày sinh không đúng định dạng dd/MM/yyyy!");
            model.addAttribute("sv", sv);
            model.addAttribute("action", "sua");
            return "pgv/sv-form";
        } catch (Exception e) {
            model.addAttribute("error", "Lỗi: " + e.getMessage());
            model.addAttribute("sv", sv);
            model.addAttribute("action", "sua");
            return "pgv/sv-form";
        }
    }

    @RequestMapping("/sv-xoa.htm")
    public String doXoaSV(@RequestParam String ma,
                          @RequestParam String maLop,
                          HttpSession session) {
        int soDiem = svDAO.kiemTraConDiem(ma);
        if (soDiem > 0) {
            session.setAttribute("errorMsg",
                "Không thể xóa! Sinh viên này đã có điểm thi.");
            return "redirect:/pgv/lop-sinhvien.htm?ma=" + maLop;
        }
        svDAO.delete(ma);
        session.setAttribute("successMsg", "Xóa sinh viên thành công!");
        return "redirect:/pgv/lop-sinhvien.htm?ma=" + maLop;
    }
}