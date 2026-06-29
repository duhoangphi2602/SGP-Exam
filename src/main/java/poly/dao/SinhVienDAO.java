package poly.dao;

import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;
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

	@Transactional(rollbackFor = Exception.class)
	public void ghiNhanBatch(String maLop, List<Map<String, String>> changes) throws Exception {
		// 1. DELETE
		for (Map<String, String> row : changes) {
			if ("DELETE".equals(row.get("action"))) {
				String maSV = row.get("maSV");
				if (kiemTraConDiem(maSV) > 0) {
					throw new RuntimeException("Sinh viên " + maSV + " đã có điểm thi, không thể xóa!");
				}
				this.delete(maSV);
			}
		}

		// 2. UPDATE
		for (Map<String, String> row : changes) {
			if ("UPDATE".equals(row.get("action"))) {
				this.update(mapToEntity(row, maLop));
			}
		}

		// 3. INSERT
		for (Map<String, String> row : changes) {
			if ("INSERT".equals(row.get("action"))) {
				this.insert(mapToEntity(row, maLop));
			}
		}
	}

	private SinhVien mapToEntity(Map<String, String> row, String maLop) throws Exception {
		SinhVien sv = new SinhVien();
		
		String maSV = row.get("maSV").trim().toUpperCase();
		if (!maSV.matches("^[A-Z0-9]+$")) {
			throw new RuntimeException("Mã sinh viên '" + maSV + "' không hợp lệ! (Chỉ chữ/số, không ký tự đặc biệt).");
		}
		
		String ho = row.get("ho").trim().toUpperCase();
		String ten = row.get("ten").trim().toUpperCase();
		String regexHoTen = "^[\\p{L}]+( [\\p{L}]+)*$";
		if (!ho.matches(regexHoTen)) {
			throw new RuntimeException("Họ sinh viên '" + ho + "' không hợp lệ!");
		}
		if (!ten.matches(regexHoTen)) {
			throw new RuntimeException("Tên sinh viên '" + ten + "' không hợp lệ!");
		}

		sv.setMaSV(maSV);
		sv.setHo(ho);
		sv.setTen(ten);
		sv.setNgaySinh(row.get("ngaySinh").trim());
		sv.setDiaChi(row.get("diaChi"));
		sv.setMaLop(maLop);
		
		java.time.LocalDate ns;
		try {
			ns = java.time.LocalDate.parse(sv.getNgaySinh(), java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));
		} catch (java.time.format.DateTimeParseException e) {
			throw new RuntimeException("Ngày sinh " + sv.getNgaySinh() + " không đúng định dạng dd/MM/yyyy!");
		}
		int tuoi = java.time.Period.between(ns, java.time.LocalDate.now()).getYears();
		if (tuoi < 16) throw new RuntimeException("Sinh viên " + sv.getMaSV() + " phải đủ ít nhất 16 tuổi!");
		if (tuoi > 60) throw new RuntimeException("Tuổi của Sinh viên " + sv.getMaSV() + " vượt quá 60!");
		
		return sv;
	}
}