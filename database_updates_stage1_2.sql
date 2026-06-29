-- =======================================================
-- STAGE 1.2: TRANSACTION VỚI TABLE-VALUED PARAMETER (TVP)
-- =======================================================
USE THITRACNGHIEM;
GO

-- 1. Tạo User-Defined Table Type để truyền mảng đáp án từ Java xuống SQL
IF TYPE_ID('TYPE_CT_BAITHI') IS NOT NULL
    DROP TYPE TYPE_CT_BAITHI;
GO

CREATE TYPE TYPE_CT_BAITHI AS TABLE (
    STT INT,
    CAUHOI INT,
    DACHON CHAR(1)
);
GO

-- 2. Tạo Stored Procedure SP_NOPBAITHI sử dụng Transaction
CREATE OR ALTER PROCEDURE SP_NOPBAITHI
    @MASV CHAR(10),
    @MAMH CHAR(5),
    @LAN SMALLINT,
    @DIEM FLOAT,
    @ChiTiet TYPE_CT_BAITHI READONLY
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRAN;
        
        -- 2.1 Ghi điểm vào BANGDIEM (Dùng lại logic của sp_GhiDiem nếu cần, hoặc viết trực tiếp)
        IF EXISTS (SELECT 1 FROM BANGDIEM WHERE MASV = @MASV AND MAMH = @MAMH AND LAN = @LAN)
        BEGIN
            UPDATE BANGDIEM SET DIEM = @DIEM WHERE MASV = @MASV AND MAMH = @MAMH AND LAN = @LAN;
        END
        ELSE
        BEGIN
            INSERT INTO BANGDIEM (MASV, MAMH, LAN, NGAYTHI, DIEM)
            VALUES (@MASV, @MAMH, @LAN, GETDATE(), @DIEM);
        END
        
        -- 2.2 Xóa chi tiết bài thi cũ nếu có (đề phòng thi lại hoặc lỗi)
        DELETE FROM CT_BAITHI WHERE MASV = @MASV AND MAMH = @MAMH AND LAN = @LAN;
        
        -- 2.3 Insert hàng loạt từ TVP vào CT_BAITHI
        INSERT INTO CT_BAITHI (MASV, MAMH, LAN, STT, CAUHOI, DACHON)
        SELECT @MASV, @MAMH, @LAN, STT, CAUHOI, DACHON
        FROM @ChiTiet;
        
        -- 2.4 Xóa bài thi tạm
        DELETE FROM BAITHI_TAM WHERE MASV = @MASV AND MAMH = @MAMH AND LAN = @LAN;
        
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO
