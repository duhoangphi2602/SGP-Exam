package poly.controller;

import java.util.ArrayDeque;
import java.util.Deque;
import java.util.List;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import poly.dao.MonHocDAO;
import poly.model.MonHoc;
import poly.model.UndoAction;

@Controller
@RequestMapping("/pgv")
public class MonHocController {

    @Autowired
    MonHocDAO monHocDAO;

    // =====================================================
    // 1. Hiển thị danh sách
    // =====================================================
    @RequestMapping("/monhoc.htm")
    public String index(
            @RequestParam(required = false) String timkiem,
            Model model) {
        List<MonHoc> list;
        if (timkiem != null && !timkiem.isEmpty()) {
            list = monHocDAO.findByTen(timkiem);
        } else {
            list = monHocDAO.findAll();
        }
        model.addAttribute("list", list);
        model.addAttribute("timkiem", timkiem);
        return "pgv/monhoc";
    }

    // =====================================================
    // 2. AJAX: Ghi (Thêm hoặc Sửa) - trả HTML fragment của tbody
    // =====================================================
    @RequestMapping(value = "/monhoc-ghi.htm", method = RequestMethod.POST)
    @ResponseBody
    public String doGhi(@RequestParam String maMH,
                         @RequestParam String tenMH,
                         @RequestParam String mode, // "them" hoặc "sua"
                         HttpSession session) {
        try {
            MonHoc mh = new MonHoc(maMH, tenMH);
            Deque<UndoAction> stack = getStack(session);

            if ("them".equals(mode)) {
                monHocDAO.insert(mh);
                stack.push(new UndoAction("INSERT", "MONHOC", null, mh));
            } else {
                MonHoc oldMh = monHocDAO.findByMa(maMH); // lấy data cũ TRƯỚC khi update
                monHocDAO.update(mh);
                stack.push(new UndoAction("UPDATE", "MONHOC", oldMh, mh));
            }

            return "OK|" + buildRows(monHocDAO.findAll());
        } catch (Exception e) {
            return "ERROR|" + parseError(e.getMessage(), maMH);
        }
    }

    // =====================================================
    // 3. AJAX: Xóa - trả HTML fragment của tbody
    // =====================================================
    @RequestMapping(value = "/monhoc-xoa-ajax.htm", method = RequestMethod.POST)
    @ResponseBody
    public String doXoaAjax(@RequestParam String ma, HttpSession session) {
        try {
            int soCau = monHocDAO.kiemTraConCauHoi(ma);
            if (soCau > 0) {
                return "ERROR|Không thể xóa! Môn học này còn " + soCau + " câu hỏi trong bộ đề.";
            }

            MonHoc oldMh = monHocDAO.findByMa(ma); // lưu lại trước khi xóa
            monHocDAO.delete(ma);

            Deque<UndoAction> stack = getStack(session);
            stack.push(new UndoAction("DELETE", "MONHOC", oldMh, null));

            return "OK|" + buildRows(monHocDAO.findAll());
        } catch (Exception e) {
            return "ERROR|Lỗi: " + e.getMessage();
        }
    }

    // =====================================================
    // 4. AJAX: Phục hồi - trả HTML fragment của tbody
    // =====================================================
    @RequestMapping(value = "/monhoc-phuchoi.htm", method = RequestMethod.POST)
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
                    MonHoc inserted = (MonHoc) action.getNewData();
                    monHocDAO.delete(inserted.getMaMH());
                    break;
                case "UPDATE":
                    MonHoc old = (MonHoc) action.getOldData();
                    monHocDAO.update(old);
                    break;
                case "DELETE":
                    MonHoc deleted = (MonHoc) action.getOldData();
                    monHocDAO.insert(deleted);
                    break;
            }
            return "OK|" + buildRows(monHocDAO.findAll());
        } catch (Exception e) {
            stack.push(action); // đẩy lại vì phục hồi thất bại
            return "ERROR|Lỗi khi phục hồi: " + e.getMessage();
        }
    }

    // =====================================================
    // Helpers
    // =====================================================
    @SuppressWarnings("unchecked")
    private Deque<UndoAction> getStack(HttpSession session) {
        Deque<UndoAction> stack = (Deque<UndoAction>) session.getAttribute("undoStack_MONHOC");
        if (stack == null) {
            stack = new ArrayDeque<>();
            session.setAttribute("undoStack_MONHOC", stack);
        }
        return stack;
    }

    private String parseError(String err, String maMH) {
        if (err.contains("PRIMARY KEY") || err.contains("duplicate key")) {
            return "Mã môn học '" + maMH.trim() + "' đã tồn tại!";
        } else if (err.contains("UNIQUE")) {
            return "Tên môn học đã tồn tại!";
        }
        return "Lỗi: " + err;
    }

    // Build HTML cho các dòng <tr> của bảng môn học
    private String buildRows(List<MonHoc> list) {
        StringBuilder sb = new StringBuilder();
        for (MonHoc mh : list) {
            sb.append("<tr>");
            sb.append("<td>").append(escape(mh.getMaMH())).append("</td>");
            sb.append("<td>").append(escape(mh.getTenMH())).append("</td>");
            sb.append("<td>");
            sb.append("<button type=\"button\" class=\"btn btn-sm btn-warning\" ")
              .append("onclick=\"moModalSua('").append(escapeJs(mh.getMaMH())).append("', '")
              .append(escapeJs(mh.getTenMH())).append("')\">Hiệu chỉnh</button> ");
            sb.append("<button type=\"button\" class=\"btn btn-sm btn-danger\" ")
              .append("onclick=\"xoaMonHoc('").append(escapeJs(mh.getMaMH())).append("')\">Xóa</button>");
            sb.append("</td>");
            sb.append("</tr>");
        }
        return sb.toString();
    }

    // Escape HTML cơ bản
    private String escape(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }

    // Escape cho chuỗi trong JS string literal (dấu nháy đơn)
    private String escapeJs(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("'", "\\'");
    }
}