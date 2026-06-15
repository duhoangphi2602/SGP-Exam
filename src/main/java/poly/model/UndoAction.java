package poly.model;

public class UndoAction {
    private String loai;     // "INSERT", "UPDATE", "DELETE"
    private String entity;   // "MONHOC"
    private Object oldData;  // dữ liệu cũ (null nếu INSERT)
    private Object newData;  // dữ liệu mới (null nếu DELETE)

    public UndoAction(String loai, String entity, Object oldData, Object newData) {
        this.loai = loai;
        this.entity = entity;
        this.oldData = oldData;
        this.newData = newData;
    }

    public String getLoai() { return loai; }
    public String getEntity() { return entity; }
    public Object getOldData() { return oldData; }
    public Object getNewData() { return newData; }
}