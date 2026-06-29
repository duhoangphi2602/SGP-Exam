-- =======================================================
-- STAGE 1.3: THÊM TRIGGER RÀNG BUỘC TOÀN VẸN
-- =======================================================
USE THITRACNGHIEM;
GO

-- 1. Trigger kiểm tra dữ liệu khi Thêm/Sửa Đăng Ký Thi
CREATE OR ALTER TRIGGER TRG_CHECK_DANGKYTHI
ON GIAOVIEN_DANGKY
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra Ngày Thi không được ở quá khứ
    IF EXISTS (
        SELECT 1 FROM inserted 
        WHERE CAST(NGAYTHI AS DATE) < CAST(GETDATE() AS DATE)
    )
    BEGIN
        RAISERROR ('Ngày thi không được nhỏ hơn ngày hiện tại!', 16, 1);
        ROLLBACK TRAN;
        RETURN;
    END

    -- Kiểm tra số câu thi phải hợp lệ (từ 10 đến 100)
    IF EXISTS (
        SELECT 1 FROM inserted 
        WHERE SOCAUTHI < 10 OR SOCAUTHI > 100
    )
    BEGIN
        RAISERROR ('Số câu thi phải từ 10 đến 100 câu!', 16, 1);
        ROLLBACK TRAN;
        RETURN;
    END

    -- Kiểm tra tổng số câu hỏi trong ngân hàng đề có đủ để thi không
    -- (Rule đơn giản ở cấp độ DB: Tổng số câu của môn đó phải >= Số câu thi yêu cầu)
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        LEFT JOIN (
            SELECT MAMH, COUNT(CAUHOI) AS TongSoCau 
            FROM BODE 
            GROUP BY MAMH
        ) b ON i.MAMH = b.MAMH
        WHERE i.SOCAUTHI > ISNULL(b.TongSoCau, 0)
    )
    BEGIN
        RAISERROR ('Ngân hàng đề không đủ số câu hỏi cho ca thi này!', 16, 1);
        ROLLBACK TRAN;
        RETURN;
    END
END
GO

-- 2. Trigger ngăn xóa câu hỏi trong Bộ Đề nếu câu hỏi đã từng được thi
CREATE OR ALTER TRIGGER TRG_PREVENT_DELETE_BODE
ON BODE
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra xem câu hỏi có đang được dùng trong CT_BAITHI không
    IF EXISTS (
        SELECT 1 
        FROM deleted d
        JOIN CT_BAITHI ct ON d.CAUHOI = ct.CAUHOI
    )
    BEGIN
        RAISERROR ('Không thể xóa câu hỏi này vì đã có sinh viên làm bài!', 16, 1);
        ROLLBACK TRAN;
        RETURN;
    END

    -- Kiểm tra xem câu hỏi có đang nằm trong BAITHI_TAM (đang thi dở) không
    IF EXISTS (
        SELECT 1 
        FROM deleted d
        JOIN BAITHI_TAM bt ON d.CAUHOI = bt.CAUHOI
    )
    BEGIN
        RAISERROR ('Không thể xóa câu hỏi này vì đang có sinh viên thi dang dở!', 16, 1);
        ROLLBACK TRAN;
        RETURN;
    END

    -- Nếu không vi phạm, cho phép xóa
    DELETE FROM BODE 
    WHERE CAUHOI IN (SELECT CAUHOI FROM deleted);
END
GO
