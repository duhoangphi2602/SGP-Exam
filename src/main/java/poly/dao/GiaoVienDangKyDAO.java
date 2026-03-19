package poly.dao;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import poly.model.GiaoVienDangKy;

@Repository
public class GiaoVienDangKyDAO {

    @Autowired
    JdbcTemplate db;

    public List<GiaoVienDangKy> findAll() {
        return db.query("EXEC SP_DANGKY_GETALL",
            new BeanPropertyRowMapper<>(GiaoVienDangKy.class));
    }

    public GiaoVienDangKy findByKey(String maLop, String maMH, int lan) {
        List<GiaoVienDangKy> list = db.query(
            "EXEC SP_DANGKY_GETBYKEY ?, ?, ?",
            new BeanPropertyRowMapper<>(GiaoVienDangKy.class),
            maLop, maMH, lan);
        return list.isEmpty() ? null : list.get(0);
    }

    public void insert(GiaoVienDangKy dk) {
        db.update("EXEC SP_DANGKY_INSERT ?, ?, ?, ?, ?, ?, ?, ?",
            dk.getMaGV(), dk.getMaMH(), dk.getMaLop(),
            dk.getTrinhDo(), dk.getNgayThi(),
            dk.getLan(), dk.getSoCauThi(), dk.getThoiGian());
    }

    public void delete(String maLop, String maMH, int lan) {
        db.update("EXEC SP_DANGKY_DELETE ?, ?, ?",
            maLop, maMH, lan);
    }

    public int demSoCau(String maMH, String trinhDo) {
        return db.queryForObject(
            "EXEC SP_BODE_DEMSOCAU ?, ?",
            Integer.class, maMH, trinhDo);
    }
}