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
        return db.query("SELECT MALOP, TENLOP FROM LOP",
            new BeanPropertyRowMapper<>(Lop.class));
    }

    public Lop findByMa(String maLop) {
        List<Lop> list = db.query(
            "SELECT MALOP, TENLOP FROM LOP WHERE MALOP = ?",
            new BeanPropertyRowMapper<>(Lop.class), maLop);
        return list.isEmpty() ? null : list.get(0);
    }

    public void insert(Lop lop) {
        db.update("INSERT INTO LOP(MALOP, TENLOP) VALUES(?, ?)",
            lop.getMaLop().toUpperCase(), lop.getTenLop());
    }

    public void update(Lop lop) {
        db.update("UPDATE LOP SET TENLOP = ? WHERE MALOP = ?",
            lop.getTenLop(), lop.getMaLop());
    }

    public void delete(String maLop) {
        db.update("DELETE FROM LOP WHERE MALOP = ?", maLop);
    }
}