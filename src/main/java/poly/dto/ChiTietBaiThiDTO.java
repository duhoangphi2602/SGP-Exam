package poly.dto;

public class ChiTietBaiThiDTO {
    private int cauSo;
    private String noiDung;
    private String dapAnA;
    private String dapAnB;
    private String dapAnC;
    private String dapAnD;
    private String dapAnSV;
    private String dapAnDung;

    public ChiTietBaiThiDTO() {}

    public ChiTietBaiThiDTO(int cauSo, String noiDung, String dapAnA, String dapAnB, String dapAnC, String dapAnD, String dapAnSV, String dapAnDung) {
        this.cauSo = cauSo;
        this.noiDung = noiDung;
        this.dapAnA = dapAnA;
        this.dapAnB = dapAnB;
        this.dapAnC = dapAnC;
        this.dapAnD = dapAnD;
        this.dapAnSV = dapAnSV;
        this.dapAnDung = dapAnDung;
    }

    // Getters and Setters
    public int getCauSo() { return cauSo; }
    public void setCauSo(int cauSo) { this.cauSo = cauSo; }
    public String getNoiDung() { return noiDung; }
    public void setNoiDung(String noiDung) { this.noiDung = noiDung; }
    public String getDapAnA() { return dapAnA; }
    public void setDapAnA(String dapAnA) { this.dapAnA = dapAnA; }
    public String getDapAnB() { return dapAnB; }
    public void setDapAnB(String dapAnB) { this.dapAnB = dapAnB; }
    public String getDapAnC() { return dapAnC; }
    public void setDapAnC(String dapAnC) { this.dapAnC = dapAnC; }
    public String getDapAnD() { return dapAnD; }
    public void setDapAnD(String dapAnD) { this.dapAnD = dapAnD; }
    public String getDapAnSV() { return dapAnSV; }
    public void setDapAnSV(String dapAnSV) { this.dapAnSV = dapAnSV; }
    public String getDapAnDung() { return dapAnDung; }
    public void setDapAnDung(String dapAnDung) { this.dapAnDung = dapAnDung; }
}