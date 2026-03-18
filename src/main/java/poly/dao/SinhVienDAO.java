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
        return db.query(
            "SELECT MASV, HO, TEN, CONVERT(varchar,NGAYSINH,103) as NGAYSINH, DIACHI, MALOP FROM SINHVIEN WHERE MALOP = ?",
            new BeanPropertyRowMapper<>(SinhVien.class), maLop);
    }

    public SinhVien findByMa(String maSV) {
        List<SinhVien> list = db.query(
            "SELECT MASV, HO, TEN, CONVERT(varchar,NGAYSINH,103) as NGAYSINH, DIACHI, MALOP FROM SINHVIEN WHERE MASV = ?",
            new BeanPropertyRowMapper<>(SinhVien.class), maSV);
        return list.isEmpty() ? null : list.get(0);
    }

    public void insert(SinhVien sv) {
        db.update(
            "INSERT INTO SINHVIEN(MASV, HO, TEN, NGAYSINH, DIACHI, MALOP) VALUES(?,?,?,?,?,?)",
            sv.getMaSV(), sv.getHo(), sv.getTen(),
            sv.getNgaySinh(), sv.getDiaChi(), sv.getMaLop());
    }

    public void update(SinhVien sv) {
        db.update(
            "UPDATE SINHVIEN SET HO=?, TEN=?, NGAYSINH=?, DIACHI=? WHERE MASV=?",
            sv.getHo(), sv.getTen(),
            sv.getNgaySinh(), sv.getDiaChi(), sv.getMaSV());
    }

    public void delete(String maSV) {
        db.update("DELETE FROM SINHVIEN WHERE MASV = ?", maSV);
    }
}