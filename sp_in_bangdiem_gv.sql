USE [THITRACNGHIEM]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- SP_IN_BANGDIEM_GV: Lấy bảng điểm cho giáo viên/giáo vụ (Tối ưu chiếu trước, kết sau)
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[SP_IN_BANGDIEM_GV]
    @MALOP nchar(15),
    @MAMH nchar(5),
    @LAN smallint,
    @MAGV nchar(8) -- NULL nếu là Giáo vụ (PGV)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Nếu là giáo viên, kiểm tra xem có quyền không (đã đăng ký và đã kết thúc thi chưa)
    IF @MAGV IS NOT NULL AND LEN(TRIM(@MAGV)) > 0
    BEGIN
        IF NOT EXISTS (
            SELECT 1 
            FROM GIAOVIEN_DANGKY 
            WHERE MALOP = @MALOP AND MAMH = @MAMH AND LAN = @LAN AND MAGV = @MAGV
              AND DATEADD(minute, THOIGIAN, NGAYTHI) < GETDATE()
        )
        BEGIN
            -- Không có quyền hoặc chưa thi xong -> Trả về kết quả rỗng
            SELECT TOP 0 
                MASV, HO, TEN, CAST(0 AS float) AS DIEM, CAST('' AS varchar(1)) AS DIEM_CHU 
            FROM SINHVIEN;
            RETURN;
        END
    END
    
    -- 2. Tối ưu: Lọc danh sách sinh viên của lớp trước
    ;WITH SV_Lop AS (
        SELECT MASV, HO, TEN 
        FROM SINHVIEN 
        WHERE MALOP = @MALOP
    ),
    -- Lọc bảng điểm trước
    BD_Mon AS (
        SELECT MASV, DIEM 
        FROM BANGDIEM 
        WHERE MAMH = @MAMH AND LAN = @LAN
    )
    -- 3. JOIN và tính điểm chữ trực tiếp trên SQL
    SELECT 
        sv.MASV, 
        sv.HO, 
        sv.TEN, 
        bd.DIEM,
        CASE 
            WHEN bd.DIEM >= 8.5 THEN 'A'
            WHEN bd.DIEM >= 7.0 THEN 'B'
            WHEN bd.DIEM >= 5.5 THEN 'C'
            WHEN bd.DIEM >= 4.0 THEN 'D'
            WHEN bd.DIEM IS NULL THEN NULL
            ELSE 'F'
        END AS DIEM_CHU
    FROM SV_Lop sv
    LEFT JOIN BD_Mon bd ON sv.MASV = bd.MASV
    ORDER BY sv.TEN, sv.HO;
END
GO
