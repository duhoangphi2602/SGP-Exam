package poly.dao;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import poly.model.MonHoc;

@Repository
public class MonHocDAO {

    @Autowired
    JdbcTemplate db;

    // Lấy tất cả môn học
    public List<MonHoc> findAll() {
        return db.query("SELECT MAMH, TENMH FROM MONHOC",
            new BeanPropertyRowMapper<>(MonHoc.class));
    }

    // Tìm theo mã
    public MonHoc findByMa(String maMH) {
        List<MonHoc> list = db.query(
            "SELECT MAMH, TENMH FROM MONHOC WHERE MAMH = ?",
            new BeanPropertyRowMapper<>(MonHoc.class), maMH);
        return list.isEmpty() ? null : list.get(0);
    }

    // Thêm mới
    public void insert(MonHoc mh) {
        db.update("INSERT INTO MONHOC(MAMH, TENMH) VALUES (?, ?)",
            mh.getMaMH().toUpperCase(), mh.getTenMH());
    }

    // Cập nhật
    public void update(MonHoc mh) {
        db.update("UPDATE MONHOC SET TENMH = ? WHERE MAMH = ?",
            mh.getTenMH(), mh.getMaMH().toUpperCase());
    }

    // Xóa
    public void delete(String maMH) {
        db.update("DELETE FROM MONHOC WHERE MAMH = ?", maMH);
    }

    // Tìm theo tên
    public List<MonHoc> findByTen(String tenMH) {
        return db.query(
            "SELECT MAMH, TENMH FROM MONHOC WHERE TENMH LIKE ?",
            new BeanPropertyRowMapper<>(MonHoc.class), "%" + tenMH + "%");
    }
}