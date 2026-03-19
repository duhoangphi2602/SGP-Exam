package poly.dao;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import poly.model.SinhVien;

@Repository
public class SinhVienDAO {

    @Autowired
    JdbcTemplate db;

    public List<SinhVien> findByLop(String maLop) {
        return db.query("EXEC SP_SV_GETBYLOP ?",
            new BeanPropertyRowMapper<>(SinhVien.class), maLop);
    }

    public SinhVien findByMa(String maSV) {
        List<SinhVien> list = db.query("EXEC SP_SV_GETBYMA ?",
            new BeanPropertyRowMapper<>(SinhVien.class), maSV);
        return list.isEmpty() ? null : list.get(0);
    }

    public void insert(SinhVien sv) {
        db.update("EXEC SP_SV_INSERT ?, ?, ?, ?, ?, ?",
            sv.getMaSV(), sv.getHo(), sv.getTen(),
            sv.getNgaySinh(), sv.getDiaChi(), sv.getMaLop());
    }

    public void update(SinhVien sv) {
        db.update("EXEC SP_SV_UPDATE ?, ?, ?, ?, ?",
            sv.getMaSV(), sv.getHo(), sv.getTen(),
            sv.getNgaySinh(), sv.getDiaChi());
    }

    public void delete(String maSV) {
        db.update("EXEC SP_SV_DELETE ?", maSV);
    }
}