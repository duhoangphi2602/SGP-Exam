package poly.dto;

public class DiemSinhVienDTO {
    private int stt;
    private String maSV;
    private String hoTen;
    private double diem;
    private String diemChu;

    public DiemSinhVienDTO() {}

    public DiemSinhVienDTO(int stt, String maSV, String hoTen, double diem, String diemChu) {
        this.stt = stt;
        this.maSV = maSV;
        this.hoTen = hoTen;
        this.diem = diem;
        this.diemChu = diemChu;
    }

    // Getters and Setters
    public int getStt() { return stt; }
    public void setStt(int stt) { this.stt = stt; }
    public String getMaSV() { return maSV; }
    public void setMaSV(String maSV) { this.maSV = maSV; }
    public String getHoTen() { return hoTen; }
    public void setHoTen(String hoTen) { this.hoTen = hoTen; }
    public double getDiem() { return diem; }
    public void setDiem(double diem) { this.diem = diem; }
    public String getDiemChu() { return diemChu; }
    public void setDiemChu(String diemChu) { this.diemChu = diemChu; }
}