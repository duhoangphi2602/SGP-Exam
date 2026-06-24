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
		return db.query("EXEC SP_SV_GETBYLOP ?", new BeanPropertyRowMapper<>(SinhVien.class), maLop);
	}

	public SinhVien findByMa(String maSV) {
		List<SinhVien> list = db.query("EXEC SP_SV_GETBYMA ?", new BeanPropertyRowMapper<>(SinhVien.class), maSV);
		return list.isEmpty() ? null : list.get(0);
	}

	public void insert(SinhVien sv) {
		db.update("EXEC SP_SV_INSERT ?, ?, ?, ?, ?, ?", sv.getMaSV(), sv.getHo(), sv.getTen(), sv.getNgaySinh(),
				sv.getDiaChi(), sv.getMaLop());
	}

	public void update(SinhVien sv) {
		db.update("EXEC SP_SV_UPDATE ?, ?, ?, ?, ?", sv.getMaSV(), sv.getHo(), sv.getTen(), sv.getNgaySinh(),
				sv.getDiaChi());
	}

	public void delete(String maSV) {
		db.update("EXEC SP_SV_DELETE ?", maSV);
	}

	public int kiemTraConDiem(String maSV) {
		return db.queryForObject("EXEC SP_SV_KIEMTRA ?", Integer.class, maSV);
	}

	public SinhVien dangNhap(String maSV, String password) {
		List<SinhVien> list = db.query("EXEC SP_SV_DANGNHAP ?, ?", new BeanPropertyRowMapper<>(SinhVien.class), maSV,
				password);
		return list.isEmpty() ? null : list.get(0);
	}

	public void dangKy(String maSV, String passwordMoi) {
		db.update("EXEC SP_SV_DANGKY ?, ?", maSV, passwordMoi);
	}

	public boolean doiPassword(String maSV, String oldPass, String newPass) {
		try {
			db.update("EXEC SP_SV_DOIPASSWORD ?, ?, ?", maSV, oldPass, newPass);
			return true;
		} catch (Exception e) {
			return false;
		}
	}

	public List<SinhVien> findByLopTimKiem(String maLop, String tuKhoa) {
		return db.query("EXEC SP_SV_GETBYLOP_TIMKIEM ?, ?", new BeanPropertyRowMapper<>(SinhVien.class), maLop, tuKhoa);
	}

	public void phucHoi(String loai, String maSV, String ho, String ten, String ngaySinh, String diaChi, String maLop) {
		db.update("EXEC SP_SV_PHUCHOI ?, ?, ?, ?, ?, ?, ?", loai, maSV, ho, ten, ngaySinh, diaChi, maLop);
	}
}