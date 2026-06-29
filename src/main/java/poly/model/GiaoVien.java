package poly.model;

public class GiaoVien {
    private String maGV;
    private String ho;
    private String ten;
    private String soDTLL;
    private String diaChi;
    private boolean hasAccount;
    private String tenNhom;

    public GiaoVien() {}

    public String getMaGV() { return maGV; }
    public void setMaGV(String maGV) { this.maGV = maGV; }
    public String getHo() { return ho; }
    public void setHo(String ho) { this.ho = ho; }
    public String getTen() { return ten; }
    public void setTen(String ten) { this.ten = ten; }
    public String getSoDTLL() { return soDTLL; }
    public void setSoDTLL(String soDTLL) { this.soDTLL = soDTLL; }
    public String getDiaChi() { return diaChi; }
    public void setDiaChi(String diaChi) { this.diaChi = diaChi; }
    
    public boolean isHasAccount() { return hasAccount; }
    public void setHasAccount(boolean hasAccount) { this.hasAccount = hasAccount; }
    public String getTenNhom() { return tenNhom; }
    public void setTenNhom(String tenNhom) { this.tenNhom = tenNhom; }
}