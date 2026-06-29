package poly.dao;

import java.util.List;
import java.util.Map;
import com.microsoft.sqlserver.jdbc.SQLServerDataTable;
import com.microsoft.sqlserver.jdbc.SQLServerException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import poly.model.CauHoiThi;
import poly.model.GiaoVienDangKy;

@Repository
public class ThiDAO {

    @Autowired
    JdbcTemplate db;

    // Lấy thông tin ca thi
    public GiaoVienDangKy getThongTinCaThi(String maSV, String maMH, String ngayThi, int lan) {
        List<GiaoVienDangKy> list = db.query(
            "EXEC SP_THI_GETTHONGTIN ?, ?, ?, ?",
            new BeanPropertyRowMapper<>(GiaoVienDangKy.class),
            maSV, maMH, ngayThi, lan);
        return list.isEmpty() ? null : list.get(0);
    }

    // Lấy danh sách ca thi + trạng thái
    public List<Map<String, Object>> getDanhSachCaThi(String maSV) {
        return db.queryForList("EXEC SP_THI_GETDANHSACH ?", maSV);
    }

    // Random câu hỏi
    public List<CauHoiThi> randomCauHoi(String maMH, String trinhDo, int soCauThi) {
        return db.query(
            "EXEC SP_THI_RANDOM ?, ?, ?",
            new BeanPropertyRowMapper<>(CauHoiThi.class),
            maMH, trinhDo, soCauThi);
    }

    // Ghi điểm
    public void ghiDiem(String maSV, String maMH, int lan, double diem) {
        db.update("EXEC sp_GhiDiem ?, ?, ?, ?", maSV, maMH, lan, diem);
    }
    
    // Nộp bài thi sử dụng Transaction và TVP (Table-Valued Parameter)
    public void nopBaiThi(String maSV, String maMH, int lan, double diem, List<Map<String, Object>> chiTiet) throws SQLServerException {
        SQLServerDataTable sourceDataTable = new SQLServerDataTable();
        sourceDataTable.addColumnMetadata("STT", java.sql.Types.INTEGER);
        sourceDataTable.addColumnMetadata("CAUHOI", java.sql.Types.INTEGER);
        sourceDataTable.addColumnMetadata("DACHON", java.sql.Types.CHAR);

        for (Map<String, Object> c : chiTiet) {
            sourceDataTable.addRow(c.get("STT"), c.get("CAUHOI"), c.get("DACHON"));
        }

        db.update("EXEC SP_NOPBAITHI ?, ?, ?, ?, ?", maSV, maMH, lan, diem, sourceDataTable);
    }
    
    // Thêm vào để lưu chi tiết bài thi khi nộp bài
    public void luuChiTietBaiThi(String maSV, String maMH, int lan, int stt, int cauHoi, String daChon) {
        db.update("INSERT INTO CT_BAITHI(MASV, MAMH, LAN, STT, CAUHOI, DACHON) VALUES(?, ?, ?, ?, ?, ?)",
                maSV, maMH, lan, stt, cauHoi, daChon);
    }

    // Lấy danh sách kết quả bài thi tổng quan
    public List<Map<String, Object>> getKetQuaThi(String maSV) {
        return db.queryForList("EXEC SP_SV_XEMKETQUA ?", maSV);
    }

    // Lấy chi tiết từng câu hỏi trong bài làm (Dành cho Sinh Viên - Không có mã câu hỏi gốc)
    public List<Map<String, Object>> getChiTietBaiThi(String maSV, String maMH, int lan) {
        return db.queryForList("EXEC SP_SV_XEMCHITIETBAITHI ?, ?, ?", maSV, maMH, lan);
    }

    // Lấy chi tiết từng câu hỏi trong bài làm (Dành cho Giáo Viên - Có mã câu hỏi gốc)
    public List<Map<String, Object>> getChiTietBaiThiGV(String maSV, String maMH, int lan) {
        return db.queryForList("EXEC SP_GV_XEMCHITIETBAITHI ?, ?, ?", maSV, maMH, lan);
    }
    
    // =====================================================
    // Lấy bảng điểm của 1 lớp (Dành cho GV và PGV)
    // =====================================================
    public List<Map<String, Object>> getBangDiemLop(String maLop, String maMH, int lan, String maGV) {
        return db.queryForList("EXEC SP_IN_BANGDIEM_GV ?, ?, ?, ?", maLop, maMH, lan, maGV);
    }
    
    public List<Map<String, Object>> getDanhSachCaThi_BangDiem(
            String maGV, String maLop, String maMH, Integer lan) {
        String maGVParam = (maGV != null && !maGV.isEmpty()) ? maGV : null;
        String maLopParam = (maLop != null && !maLop.isEmpty()) ? maLop : null;
        String maMHParam = (maMH != null && !maMH.isEmpty()) ? maMH : null;
        return db.queryForList(
            "EXEC SP_BANGDIEM_DANHSACH ?, ?, ?, ?",
            maGVParam, maLopParam, maMHParam, lan);
    }
    
 // Lưu tạm từng câu hỏi vào BAITHI_TAM
    public void luuTam(String maSV, String maMH, int lan, int cauHoi, int stt, String dapAnChon, int thoiGianConLai) {
        db.update("EXEC SP_BAITHI_LUUTAM ?, ?, ?, ?, ?, ?, ?",
            maSV, maMH, lan, cauHoi, stt, dapAnChon, thoiGianConLai);
    }

    // Kiểm tra có dữ liệu tạm không
    public boolean coBaiThiTam(String maSV, String maMH, int lan) {
        int count = db.queryForObject(
            "EXEC SP_KIEMTRA_BAITHI_TAM ?, ?, ?",
            Integer.class, maSV, maMH, lan);
        return count > 0;
    }

    // Khôi phục bài thi từ BAITHI_TAM
    public List<Map<String, Object>> khoiPhucBaiThi(String maSV, String maMH, int lan) {
        return db.queryForList("EXEC SP_BAITHI_KHOIPHUC ?, ?, ?", maSV, maMH, lan);
    }

    // Xóa dữ liệu tạm sau khi nộp bài
    public void xoaBaiThiTam(String maSV, String maMH, int lan) {
        db.update("EXEC SP_BAITHI_XOA ?, ?, ?", maSV, maMH, lan);
    }
    
    public List<Map<String, Object>> layDanhSachCaDangThiTam(String maSV) {
        return db.queryForList("EXEC SP_BAITHI_LAYDSCADANGTHI ?", maSV);
    }
    
    
 // Trừ giờ cho tất cả ca đang thi (gọi bởi job mỗi giây)
    public void giamThoiGianTatCa() {
        db.update("EXEC SP_BAITHI_GIAMTHOIGIAN_TATCA");
    }

    // Lấy giờ còn lại hiện tại (chỉ đọc, dùng cho heartbeat)
    public Integer layThoiGianConLai(String maSV, String maMH, int lan) {
        List<Integer> list = db.queryForList(
            "EXEC SP_BAITHI_LAYTHOIGIAN ?, ?, ?",
            Integer.class, maSV, maMH, lan);
        return list.isEmpty() ? null : list.get(0);
    }
    
}