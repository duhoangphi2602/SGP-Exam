-- =======================================================
-- FIX LỖI STAGE 2: BỔ SUNG TRẠNG THÁI TÀI KHOẢN CHO GIÁO VIÊN
-- (Sử dụng sys.database_principals thay vì bảng TAIKHOAN)
-- =======================================================
USE THITRACNGHIEM;
GO

-- 1. Cập nhật SP_GV_GETALL
CREATE OR ALTER PROCEDURE SP_GV_GETALL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT GV.MAGV, GV.HO, GV.TEN, GV.SODTLL, GV.DIACHI,
           CAST(CASE WHEN DP.principal_id IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS HAS_ACCOUNT,
           RP.name AS TEN_NHOM
    FROM GIAOVIEN GV
    LEFT JOIN sys.database_principals DP ON GV.MAGV = DP.name AND DP.type IN ('S', 'U')
    LEFT JOIN sys.database_role_members RM ON DP.principal_id = RM.member_principal_id
    LEFT JOIN sys.database_principals RP ON RM.role_principal_id = RP.principal_id
    ORDER BY GV.TEN, GV.HO;
END
GO

-- 2. Cập nhật SP_GV_GETBYMA
CREATE OR ALTER PROCEDURE SP_GV_GETBYMA
    @MAGV CHAR(8)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT GV.MAGV, GV.HO, GV.TEN, GV.SODTLL, GV.DIACHI,
           CAST(CASE WHEN DP.principal_id IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS HAS_ACCOUNT,
           RP.name AS TEN_NHOM
    FROM GIAOVIEN GV
    LEFT JOIN sys.database_principals DP ON GV.MAGV = DP.name AND DP.type IN ('S', 'U')
    LEFT JOIN sys.database_role_members RM ON DP.principal_id = RM.member_principal_id
    LEFT JOIN sys.database_principals RP ON RM.role_principal_id = RP.principal_id
    WHERE GV.MAGV = @MAGV;
END
GO

-- 3. Cập nhật SP_GV_GETBYTEN
CREATE OR ALTER PROCEDURE SP_GV_GETBYTEN
    @TEN NVARCHAR(40)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT GV.MAGV, GV.HO, GV.TEN, GV.SODTLL, GV.DIACHI,
           CAST(CASE WHEN DP.principal_id IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS HAS_ACCOUNT,
           RP.name AS TEN_NHOM
    FROM GIAOVIEN GV
    LEFT JOIN sys.database_principals DP ON GV.MAGV = DP.name AND DP.type IN ('S', 'U')
    LEFT JOIN sys.database_role_members RM ON DP.principal_id = RM.member_principal_id
    LEFT JOIN sys.database_principals RP ON RM.role_principal_id = RP.principal_id
    WHERE GV.TEN LIKE N'%' + @TEN + N'%'
    ORDER BY GV.TEN, GV.HO;
END
GO
