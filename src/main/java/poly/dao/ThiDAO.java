package poly.dao;

import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import poly.model.CauHoiThi;
import poly.model.GiaoVienDangKy;

@Repository
public class ThiDAO {

    @Autowired
    JdbcTemplate db;

    // Lấy danh sách môn SV được thi
    public List<Map<String, Object>> getMonHoc(String maSV) {
        return db.queryForList("EXEC SP_THI_GETMONHOC ?", maSV);
    }

    // Lấy danh sách ngày thi theo môn
    public List<Map<String, Object>> getNgayThi(String maSV, String maMH) {
        return db.queryForList("EXEC SP_THI_GETNGAYTHI ?, ?", maSV, maMH);
    }

    // Lấy danh sách lần thi
    public List<Map<String, Object>> getLanThi(String maSV, String maMH, String ngayThi) {
        return db.queryForList("EXEC SP_THI_GETLANTHI ?, ?, ?", maSV, maMH, ngayThi);
    }

    // Lấy thông tin ca thi
    public GiaoVienDangKy getThongTinCaThi(String maSV, String maMH, String ngayThi, int lan) {
        List<GiaoVienDangKy> list = db.query(
            "EXEC SP_THI_GETTHONGTIN ?, ?, ?, ?",
            new BeanPropertyRowMapper<>(GiaoVienDangKy.class),
            maSV, maMH, ngayThi, lan);
        return list.isEmpty() ? null : list.get(0);
    }

    // Lấy danh sách ca thi + trạng thái
    public List<Map<String, Object>> getDanhSachCaThi(String maSV) {
        return db.queryForList("EXEC SP_THI_GETDANHSACH ?", maSV);
    }

    // Random câu hỏi
    public List<CauHoiThi> randomCauHoi(String maMH, String trinhDo, int soCauThi) {
        return db.query(
            "EXEC SP_THI_RANDOM ?, ?, ?",
            new BeanPropertyRowMapper<>(CauHoiThi.class),
            maMH, trinhDo, soCauThi);
    }

    // Ghi điểm
    public void ghiDiem(String maSV, String maMH, int lan, double diem) {
        db.update("EXEC sp_GhiDiem ?, ?, ?, ?", maSV, maMH, lan, diem);
    }

    // Kiểm tra SV đã thi chưa
    public boolean daThi(String maSV, String maMH, int lan) {
        int count = db.queryForObject(
            "SELECT COUNT(*) FROM BANGDIEM WHERE MASV=? AND MAMH=? AND LAN=?",
            Integer.class, maSV, maMH, lan);
        return count > 0;
    }
    
    // Lấy đáp án đúng từ DB
    public List<Map<String, Object>> getDapAnDung(int cauHoi) {
        return db.queryForList(
            "SELECT DAP_AN FROM BODE WHERE CAUHOI = ?", cauHoi);
    }
}