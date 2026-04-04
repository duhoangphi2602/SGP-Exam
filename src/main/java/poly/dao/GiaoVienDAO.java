package poly.dao;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import poly.model.GiaoVien;

@Repository
public class GiaoVienDAO {

    @Autowired
    JdbcTemplate db;

    public List<GiaoVien> findAll() {
        return db.query("EXEC SP_GV_GETALL",
            new BeanPropertyRowMapper<>(GiaoVien.class));
    }

    public GiaoVien findByMa(String maGV) {
        List<GiaoVien> list = db.query("EXEC SP_GV_GETBYMA ?",
            new BeanPropertyRowMapper<>(GiaoVien.class), maGV);
        return list.isEmpty() ? null : list.get(0);
    }

    public List<GiaoVien> findByTen(String ten) {
        return db.query("EXEC SP_GV_GETBYTEN ?",
            new BeanPropertyRowMapper<>(GiaoVien.class), ten);
    }

    public void insert(GiaoVien gv) {
        db.update("EXEC SP_GV_INSERT ?, ?, ?, ?, ?",
            gv.getMaGV(), gv.getHo(), gv.getTen(),
            gv.getSoDTLL(), gv.getDiaChi());
    }

    public void update(GiaoVien gv) {
        db.update("EXEC SP_GV_UPDATE ?, ?, ?, ?, ?",
            gv.getMaGV(), gv.getHo(), gv.getTen(),
            gv.getSoDTLL(), gv.getDiaChi());
    }

    public void delete(String maGV) {
        db.update("EXEC SP_GV_DELETE ?", maGV);
    }
    
    public int kiemTraConCauHoi(String maGV) {
        return db.queryForObject(
            "EXEC SP_GV_KIEMTRA ?", Integer.class, maGV);
    }
}