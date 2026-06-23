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

    public List<MonHoc> findAll() {
        return db.query("EXEC SP_MONHOC_GETALL",
            new BeanPropertyRowMapper<>(MonHoc.class));
    }

    public MonHoc findByMa(String maMH) {
        List<MonHoc> list = db.query("EXEC SP_MONHOC_GETBYMA ?",
            new BeanPropertyRowMapper<>(MonHoc.class), maMH);
        return list.isEmpty() ? null : list.get(0);
    }

    public List<MonHoc> findByTen(String tenMH) {
        return db.query("EXEC SP_MONHOC_GETBYTEN ?",
            new BeanPropertyRowMapper<>(MonHoc.class), tenMH);
    }

    public void insert(MonHoc mh) {
        db.update("EXEC SP_MONHOC_INSERT ?, ?",
            mh.getMaMH().toUpperCase(), mh.getTenMH());
    }

    public void update(MonHoc mh) {
        db.update("EXEC SP_MONHOC_UPDATE ?, ?",
            mh.getMaMH().toUpperCase(), mh.getTenMH());
    }

    public void delete(String maMH) {
        db.update("EXEC SP_MONHOC_DELETE ?", maMH);
    }
    
    public int kiemTraConCauHoi(String maMH) {
        return db.queryForObject(
            "EXEC SP_MONHOC_KIEMTRA ?",
            Integer.class, maMH);
    }
    
    public void phucHoi(String loai, String maMH, String tenMH) {
        db.update("EXEC SP_MONHOC_PHUCHOI ?, ?, ?", loai, maMH, tenMH);
    }
}
