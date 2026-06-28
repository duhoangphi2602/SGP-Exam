package poly.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import poly.dao.ThiDAO;

@Component
public class ThiTamScheduler {

    @Autowired
    ThiDAO thiDAO;

    public void tick() {
        try {
            thiDAO.giamThoiGianTatCa();
        } catch (Exception e) {
            // Không để job chết hẳn nếu 1 lần update lỗi (ví dụ mất kết nối DB tạm thời)
            System.err.println("Lỗi khi trừ thời gian thi: " + e.getMessage());
        }
    }
}