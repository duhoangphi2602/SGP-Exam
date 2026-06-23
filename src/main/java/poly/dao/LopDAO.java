package poly.dao;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import poly.model.Lop;

@Repository
public class LopDAO {

    @Autowired
    JdbcTemplate db;

    public List<Lop> findAll() {
        return db.query("EXEC SP_LOP_GETALL",
            new BeanPropertyRowMapper<>(Lop.class));
    }

    public Lop findByMa(String maLop) {
        List<Lop> list = db.query("EXEC SP_LOP_GETBYMA ?",
            new BeanPropertyRowMapper<>(Lop.class), maLop);
        return list.isEmpty() ? null : list.get(0);
    }

    public void insert(Lop lop) {
        db.update("EXEC SP_LOP_INSERT ?, ?",
            lop.getMaLop().toUpperCase(), lop.getTenLop());
    }

    public void update(Lop lop) {
        db.update("EXEC SP_LOP_UPDATE ?, ?",
            lop.getMaLop().toUpperCase(), lop.getTenLop());
    }

    public void delete(String maLop) {
        db.update("EXEC SP_LOP_DELETE ?", maLop);
    }
    
    public int kiemTraConSV(String maLop) {
        return db.queryForObject(
            "EXEC SP_LOP_KIEMTRA ?", Integer.class, maLop);
    }
    
    public List<Lop> findByTen(String tenLop) {
        return db.query("EXEC SP_LOP_GETBYTEN ?",
            new BeanPropertyRowMapper<>(Lop.class), tenLop);
    }
    
    public void phucHoi(String loai, String maLop, String tenLop) {
        db.update("EXEC SP_LOP_PHUCHOI ?, ?, ?", loai, maLop, tenLop);
    }
}