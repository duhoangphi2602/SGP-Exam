package poly.dao;

import java.util.List;
import java.util.Map;

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
        db.update("EXEC SP_DANGKY_DELETE ?, ?, ?", maLop, maMH, lan);
    }

    public int demSoCau(String maMH, String trinhDo) {
        return db.queryForObject(
            "EXEC SP_BODE_DEMSOCAU ?, ?",
            Integer.class, maMH, trinhDo);
    }
    
 // Đếm số câu theo từng trình độ
    public Map<String, Integer> demSoCauChiTiet(String maMH) {
        List<Map<String, Object>> list = db.queryForList(
            "EXEC SP_BODE_DEMSOCAU_CHITIET ?", maMH);
        
        Map<String, Integer> result = new java.util.HashMap<>();
        result.put("A", 0);
        result.put("B", 0);
        result.put("C", 0);
        
        for (Map<String, Object> row : list) {
            String trinhDo = row.get("TRINHDO").toString().trim();
            int soCau = ((Number) row.get("SOCAU")).intValue();
            result.put(trinhDo, soCau);
        }
        return result;
    }
    
    //Loc dang ky thi theo ma GV
    public List<GiaoVienDangKy> findByMaGV(String maGV) {
        return db.query("EXEC SP_DANGKY_GETBYGV ?",
            new BeanPropertyRowMapper<>(GiaoVienDangKy.class), maGV);
    }

    //Kiem tra da co sinh vien thi chua?
    public boolean kiemTraSV(String maLop, String maMH, int lan) {
        Integer result = db.queryForObject(
            "EXEC SP_DANGKY_KIEMTRA_DADATHI ?, ?, ?",
            Integer.class, maLop, maMH, lan);
        return result != null && result == 1;
    }
    
    //Sua dang ky thi
    public void update(GiaoVienDangKy dk) {
        db.update("EXEC SP_DANGKY_UPDATE ?, ?, ?, ?, ?, ?, ?",
            dk.getMaLop(), dk.getMaMH(), dk.getLan(),
            dk.getTrinhDo(), dk.getNgayThi(),
            dk.getSoCauThi(), dk.getThoiGian());
    }
    
    // =====================================================
    // Lấy lịch sử đăng ký của một lớp để kiểm tra trùng (AJAX)
    // =====================================================
    public List<Map<String, Object>> getDangKyByLop(String maLop) {
        return db.queryForList("SELECT RTRIM(MAMH) as maMH, LAN as lan, CONVERT(varchar, NGAYTHI, 23) as ngayThi FROM GIAOVIEN_DANGKY WHERE MALOP = ?", maLop);
    }
}