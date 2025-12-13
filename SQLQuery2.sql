-- =============================================
-- TẠO CƠ SỞ DỮ LIỆU QUẢN LÝ SINH VIÊN - ĐIỂM - LỚP HỌC
-- Dùng cho SQL Server (đã thay toàn bộ VARCHAR → NVARCHAR)
-- Chỉ cần paste 1 lần → F5 là xong!
-- =============================================

USE master
GO

-- Xóa CSDL nếu đã tồn tại
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'QuanLySinhVien')
    DROP DATABASE QuanLySinhVien
GO

-- Tạo lại CSDL mới + Collation tiếng Việt tốt nhất
CREATE DATABASE QuanLySinhVien
COLLATE Vietnamese_CI_AS
GO

USE QuanLySinhVien
GO

-- 1. Khoa
CREATE TABLE Khoa (
    maKhoa NVARCHAR(10) PRIMARY KEY,
    tenKhoa NVARCHAR(100) NOT NULL,
    sdt NVARCHAR(15),
    email NVARCHAR(100),
    TruongKhoa NVARCHAR(100)
)
GO

-- 2. Ngành
CREATE TABLE Nganh (
    maNganh NVARCHAR(10) PRIMARY KEY,
    tenNganh NVARCHAR(100) NOT NULL,
    maKhoa NVARCHAR(10),
    trinhDoDaoTao NVARCHAR(50),
    soTinChi INT,
    FOREIGN KEY (maKhoa) REFERENCES Khoa(maKhoa)
)
GO

-- 3. Môn học
CREATE TABLE MonHoc (
    maMonHoc NVARCHAR(10) PRIMARY KEY,
    tenMonHoc NVARCHAR(100) NOT NULL,
    soTinChi INT NOT NULL,
    soTiet INT,
    thuTuUtien INT,
    maNganh NVARCHAR(10),
    FOREIGN KEY (maNganh) REFERENCES Nganh(maNganh)
)
GO

-- 4. Sinh viên
CREATE TABLE SinhVien (
    maSV NVARCHAR(10) PRIMARY KEY,
    Hoten NVARCHAR(100) NOT NULL,
    GioiTinh NVARCHAR(10),
    NgaySinh DATE,
    NganhHoc NVARCHAR(10),
    KhoaHoc NVARCHAR(20),
    MaLopHC NVARCHAR(10),
    sdt NVARCHAR(15),
    email NVARCHAR(100),
    DiaChi NVARCHAR(200),
    TrangThai NVARCHAR(20),
    FOREIGN KEY (NganhHoc) REFERENCES Nganh(maNganh)
)
GO

-- 5. Lớp hành chính
CREATE TABLE LopHanhChinh (
    MaLopHC NVARCHAR(10) PRIMARY KEY,
    TenLop NVARCHAR(50) NOT NULL,
    khoaHoc NVARCHAR(20),
    NganhHoc NVARCHAR(10),
    SISO INT,
    FOREIGN KEY (NganhHoc) REFERENCES Nganh(maNganh)
)
GO

-- 6. Giảng viên
CREATE TABLE GiangVien (
    maGiangVien NVARCHAR(10) PRIMARY KEY,
    TenGiangVien NVARCHAR(100) NOT NULL,
    GioiTinh NVARCHAR(10),
    NgaySinh DATE,
    TrinhDo NVARCHAR(50),
    Khoa NVARCHAR(10),
    Mon NVARCHAR(100),
    sdt NVARCHAR(15),
    email NVARCHAR(100),
    DiaChi NVARCHAR(200),
    FOREIGN KEY (Khoa) REFERENCES Khoa(maKhoa)
)
GO

-- 7. Lớp học phần
CREATE TABLE LopHocPhan (
    maLopHP NVARCHAR(10) PRIMARY KEY,
    tenLop NVARCHAR(50),
    MaLopHocPhan NVARCHAR(20),
    MaMonHoc NVARCHAR(10),
    GiangVienPhuTrach NVARCHAR(100),
    ThoigianMo DATE,
    thoigianDong DATE,
    soLuongSinhVien INT,
    thuTuUuTien INT,
    FOREIGN KEY (MaMonHoc) REFERENCES MonHoc(maMonHoc)
)
GO

-- 8. Lịch học
CREATE TABLE LichHoc (
    maLichHoc NVARCHAR(10) PRIMARY KEY,
    maLopPhan NVARCHAR(10),
    NgayHoc DATE,
    soTiet INT,
    phongHoc NVARCHAR(20),
    GiaoThi NVARCHAR(100),
    FOREIGN KEY (maLopPhan) REFERENCES LopHocPhan(maLopHP)
)
GO

-- 9. Lịch thi
CREATE TABLE LichThi (
    maLichThi NVARCHAR(10) PRIMARY KEY,
    MaLopPhan NVARCHAR(10),
    NgayThi DATE,
    gioThi TIME,
    maPhong NVARCHAR(20),
    phongHoc NVARCHAR(20),
    hinhThucThi NVARCHAR(50),
    GiamThi NVARCHAR(100),
    FOREIGN KEY (MaLopPhan) REFERENCES LopHocPhan(maLopHP)
)
GO

-- 10. Phòng học
CREATE TABLE PhongHoc (
    maPhongHoc NVARCHAR(10) PRIMARY KEY,
    TenPhong NVARCHAR(50),
    sucChua INT,
    trangThai NVARCHAR(20)
)
GO

-- 11. Đăng ký học phần
CREATE TABLE DangKiHocPhan (
    maSV NVARCHAR(10),
    maMonHoc NVARCHAR(10),
    ngayDK DATE,
    TrangThaiDK NVARCHAR(20),
    PRIMARY KEY (maSV, maMonHoc),
    FOREIGN KEY (maSV) REFERENCES SinhVien(maSV),
    FOREIGN KEY (maMonHoc) REFERENCES MonHoc(maMonHoc)
)
GO

-- 12. Đầu điểm (Giữa kỳ, Cuối kỳ, BT, ...)
CREATE TABLE DauDiem (
    MaDD NVARCHAR(10) PRIMARY KEY,
    TenDD NVARCHAR(50) NOT NULL,
    HeSoDiem FLOAT,
    loaiDiem NVARCHAR(50),
    moTa NVARCHAR(200)
)
GO

-- 13. Bảng điểm chi tiết
CREATE TABLE BangDiem (
    MaBD NVARCHAR(10) PRIMARY KEY,
    MaSinhVien NVARCHAR(10),
    MaMonHoc NVARCHAR(10),
    MaDD NVARCHAR(10),
    Diem FLOAT,
    FOREIGN KEY (MaSinhVien) REFERENCES SinhVien(maSV),
    FOREIGN KEY (MaMonHoc) REFERENCES MonHoc(maMonHoc),
    FOREIGN KEY (MaDD) REFERENCES DauDiem(MaDD)
)
GO

-- 14. Điểm danh
CREATE TABLE DiemDanh (
    maDiemDanh NVARCHAR(10) PRIMARY KEY,
    NgayDiemDanh DATE,
    maSinhVien NVARCHAR(10),
    maLichHoc NVARCHAR(10),
    trangThai NVARCHAR(20), -- Có mặt / Vắng / Nghỉ phép
    FOREIGN KEY (maSinhVien) REFERENCES SinhVien(maSV),
    FOREIGN KEY (maLichHoc) REFERENCES LichHoc(maLichHoc)
)
GO

-- 15. Tài khoản đăng nhập
CREATE TABLE TaiKhoan (
    TenDangNhap NVARCHAR(50) PRIMARY KEY,
    MatKhau NVARCHAR(255) NOT NULL,
    quyenhan NVARCHAR(20), -- Admin, GiangVien, SinhVien
    maNguoiDung NVARCHAR(10) -- liên kết đến maSV hoặc maGiangVien
)
GO

-- =============================================
-- DỮ LIỆU MẪU (chạy thử ngay được luôn)
-- =============================================

INSERT INTO Khoa VALUES 
('CNTT', N'Công nghệ Thông tin', '028 3899 1234', 'cntt@hcmute.edu.vn', N'PGS.TS Nguyễn Văn A'),
('KT', N'Kỹ thuật Điện - Điện tử', '028 3899 5678', 'ktdt@hcmute.edu.vn', N'TS Trần Thị B')
GO

INSERT INTO Nganh VALUES 
('7480201', N'Công nghệ thông tin', 'CNTT', N'Đại học chính quy', 140),
('7520201', N'Kỹ thuật điện', 'KT', N'Đại học chính quy', 135)
GO

INSERT INTO MonHoc VALUES 
('INT1001', N'Lập trình C', 3, 60, 1, '7480201'),
('INT2008', N'Cơ sở dữ liệu', 4, 75, 3, '7480201'),
('ELE1001', N'Mạch điện', 3, 60, 1, '7520201')
GO

INSERT INTO LopHanhChinh VALUES 
('21DTH1', N'21DTH1 - CNTT', 'K2021', '7480201', 65)
GO

INSERT INTO SinhVien VALUES 
('21133001', N'Nguyễn Văn An', N'Nam', '2003-05-15', '7480201', 'K2021', '21DTH1', '0901234567', 'an.nv21133001@hcmute.edu.vn', N'Quận 9, TP.HCM', N'Đang học'),
('21133002', N'Trần Thị Bé', N'Nữ', '2003-08-20', '7480201', 'K2021', '21DTH1', '0909876543', 'be.tt21133002@hcmute.edu.vn', N'Bình Thạnh, TP.HCM', N'Đang học')
GO

INSERT INTO GiangVien VALUES 
('GV001', N'Lê Văn Cường', N'Nam', '1980-03-10', N'Tiến sĩ', 'CNTT', N'Cơ sở dữ liệu', '0912345678', 'cuong.lv@hcmute.edu.vn', N'Quận 1, TP.HCM')
GO

INSERT INTO DauDiem VALUES 
('DD01', N'Giữa kỳ', 0.4, N'Giữa kỳ', N'Điểm giữa kỳ'),
('DD02', N'Cuối kỳ', 0.6, N'Cuối kỳ', N'Điểm thi cuối kỳ')
GO

INSERT INTO BangDiem VALUES 
('BD001', '21133001', 'INT2008', 'DD01', 8.5),
('BD002', '21133001', 'INT2008', 'DD02', 7.8),
('BD003', '21133002', 'INT2008', 'DD01', 9.0),
('BD004', '21133002', 'INT2008', 'DD02', 8.5)
GO

PRINT N'=== TẠO CƠ SỞ DỮ LIỆU THÀNH CÔNG! ==='
PRINT N'   Tên CSDL: QuanLySinhVien'
PRINT N'   Hỗ trợ đầy đủ tiếng Việt có dấu'
PRINT N'   Đã chèn sẵn dữ liệu mẫu để test ngay'
GO
use QuanLySinhVien
/*tạo procedure*/
CREATE PROCEDURE sp_ThemKhoa
    @MaKhoa NVARCHAR(20),
    @TenKhoa NVARCHAR(100),
    @SDT VARCHAR(15),
    @Email VARCHAR(100),
    @TruongKhoa NVARCHAR(20),     -- mã giảng viên làm trưởng khoa
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Mặc định là thành công
    SET @Result = 0;

    BEGIN TRY
        
        -- 1. Kiểm tra mã khoa đã tồn tại chưa
        IF EXISTS (SELECT 1 FROM Khoa WHERE MaKhoa = @MaKhoa)
        BEGIN
            SET @Result = 1;     -- 1 = Mã khoa đã tồn tại
            RETURN;
        END

        -- 2. Kiểm tra trưởng khoa có tồn tại trong bảng giảng viên không
        IF NOT EXISTS (SELECT 1 FROM GiangVien WHERE maGiangVien = @TruongKhoa)
        BEGIN
            SET @Result = 2;     -- 2 = Trưởng khoa không tồn tại
            RETURN;
        END

        -- 3. Thêm khoa mới
        INSERT INTO Khoa (MaKhoa, TenKhoa, SDT, Email, TruongKhoa)
        VALUES (@MaKhoa, @TenKhoa, @SDT, @Email, @TruongKhoa);

        SET @Result = 0;         -- Thành công

    END TRY

    BEGIN CATCH
        SET @Result = ERROR_NUMBER(); -- mã lỗi SQL Server
    END CATCH
END
DECLARE @KQ INT;

EXEC sp_ThemKhoa
    @MaKhoa = 'CNTT2',   -- trùng
    @TenKhoa = N'Công Nghệ Thông Tin',
    @SDT = '0123456789',
    @Email = 'cntt@school.edu.vn',
    @TruongKhoa = 'GV001',
    @Result = @KQ OUTPUT;
SELECT @KQ AS KetQua;
select * from Khoa
/**
    procedure sửa khoa
*/
CREATE PROCEDURE sp_SuaKhoa
    @MaKhoa NVARCHAR(20),        -- bắt buộc, dùng để tìm khoa cần sửa
    @TenKhoa NVARCHAR(100) = NULL,
    @SDT VARCHAR(15) = NULL,
    @Email VARCHAR(100) = NULL,
    @TruongKhoa NVARCHAR(20) = NULL,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;

    BEGIN TRY

        -- 1. Kiểm tra mã khoa có tồn tại không
        IF NOT EXISTS (SELECT 1 FROM Khoa WHERE MaKhoa = @MaKhoa)
        BEGIN
            SET @Result = 1;     -- 1 = Mã khoa không tồn tại
            RETURN;
        END

        -- 2. Nếu sửa trưởng khoa thì kiểm tra giảng viên tồn tại
        IF @TruongKhoa IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM GiangVien WHERE maGiangVien = @TruongKhoa)
            BEGIN
                SET @Result = 2;  -- 2 = Trưởng khoa không tồn tại
                RETURN;
            END
        END

        -- 3. Cập nhật theo từng trường không NULL
        UPDATE Khoa
        SET 
            TenKhoa = COALESCE(@TenKhoa, TenKhoa),
            SDT     = COALESCE(@SDT, SDT),
            Email   = COALESCE(@Email, Email),
            TruongKhoa = COALESCE(@TruongKhoa, TruongKhoa)
        WHERE MaKhoa = @MaKhoa;

        SET @Result = 0;   -- thành công

    END TRY

    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END

DECLARE @KQ INT;

EXEC sp_SuaKhoa
    @MaKhoa = 'CNTT',
    @SDT = '0988001123',
    @Result = @KQ OUTPUT;

SELECT @KQ;

select * from Khoa

/*
    procedure xóa khoa
*/
CREATE PROCEDURE sp_XoaKhoa
    @MaKhoa NVARCHAR(20),
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;

    BEGIN TRY
        -- 1. Kiểm tra mã khoa tồn tại
        IF NOT EXISTS (SELECT 1 FROM Khoa WHERE MaKhoa = @MaKhoa)
        BEGIN
            SET @Result = 1; -- 1 = mã khoa không tồn tại
            RETURN;
        END

        -- 2. Xóa các bản ghi tham chiếu trong bảng Ngành
        DELETE FROM Nganh WHERE MaKhoa = @MaKhoa;

        -- 3. Xóa Khoa
        DELETE FROM Khoa WHERE MaKhoa = @MaKhoa;

        SET @Result = 0; -- thành công

    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER(); -- lỗi SQL Server
    END CATCH
END
/*
pro lấy tất cả dữ liệu
*/
CREATE PROCEDURE sp_GetAllKhoa
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT 
            MaKhoa,
            TenKhoa,
            SDT,
            Email,
            TruongKhoa
        FROM Khoa
        ORDER BY MaKhoa;
    END TRY
    BEGIN CATCH
        -- Nếu có lỗi SQL Server, ném lỗi ra
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi lấy dữ liệu Khoa: %s', 16, 1, @ErrorMessage);
    END CATCH
END
/*
procedure tìm kiếm với Id
*/
CREATE PROCEDURE sp_TimKhoaTheoMa
    @MaKhoa NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT 
            MaKhoa,
            TenKhoa,
            SDT,
            Email,
            TruongKhoa
        FROM Khoa
        WHERE MaKhoa LIKE '%' + @MaKhoa + '%'
        ORDER BY MaKhoa;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi tìm kiếm Khoa: %s', 16, 1, @ErrorMessage);
    END CATCH
END
/*
pro Tìm kiếm theo tên
*/
CREATE PROCEDURE sp_TimKhoaTheoTen
    @TenKhoa NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT 
            MaKhoa,
            TenKhoa,
            SDT,
            Email,
            TruongKhoa
        FROM Khoa
        WHERE TenKhoa LIKE '%' + @TenKhoa + '%'
        ORDER BY MaKhoa;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi tìm kiếm Khoa theo tên: %s', 16, 1, @ErrorMessage);
    END CATCH
END

/*
Tìm kiếm linh hoạt theo tham số truyển vào
*/
CREATE PROCEDURE sp_SearchAllKhoa
    @MaKhoa NVARCHAR(20) = NULL,
    @TenKhoa NVARCHAR(100) = NULL,
    @SDT VARCHAR(15) = NULL,
    @Email NVARCHAR(100) = NULL,
    @TruongKhoa NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT 
            MaKhoa,
            TenKhoa,
            SDT,
            Email,
            TruongKhoa
        FROM Khoa
        WHERE (@MaKhoa IS NULL OR MaKhoa = @MaKhoa)
          AND (@TenKhoa IS NULL OR TenKhoa LIKE '%' + @TenKhoa + '%')
          AND (@SDT IS NULL OR SDT = @SDT)
          AND (@Email IS NULL OR Email = @Email)
          AND (@TruongKhoa IS NULL OR TruongKhoa = @TruongKhoa)
        ORDER BY MaKhoa;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi lấy dữ liệu Khoa: %s', 16, 1, @ErrorMessage);
    END CATCH
END
