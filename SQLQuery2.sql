﻿-- =============================================
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
-- 1. Bảng Người dùng (thay thế bảng TaiKhoan)
CREATE TABLE NguoiDung (
    MaNguoiDung NVARCHAR(10) PRIMARY KEY,
    MatKhau NVARCHAR(255) NOT NULL,
    SDT NVARCHAR(15),
    Email NVARCHAR(100),
    Loai INT NOT NULL, -- 1: Admin, 2: Giảng viên, 3: Sinh viên
    DiaChi NVARCHAR(200),
    CONSTRAINT CHK_Loai CHECK (Loai IN (1, 2, 3))
)
GO
-- Bước 1: Xóa ràng buộc UNIQUE trên cột TaiKhoan
-- Tên ràng buộc có thể khác nhau tùy theo lần tạo bảng, 
-- nên dùng đoạn code sau để tự động tìm và xóa tất cả UNIQUE liên quan đến TaiKhoan

DECLARE @ConstraintName NVARCHAR(128)

SELECT @ConstraintName = name 
FROM sys.key_constraints 
WHERE parent_object_id = OBJECT_ID('NguoiDung') 
  AND type = 'UQ' 
  AND OBJECTPROPERTY(OBJECT_ID(name), 'IsSystemNamed') = 1  -- Thường là tên hệ thống
  AND EXISTS (
      SELECT 1 
      FROM sys.columns c 
      JOIN sys.index_columns ic ON c.object_id = ic.object_id AND c.column_id = ic.column_id
      JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
      WHERE c.object_id = OBJECT_ID('NguoiDung') 
        AND c.name = 'TaiKhoan'
        AND i.name = @ConstraintName
  )

IF @ConstraintName IS NOT NULL
BEGIN
    EXEC('ALTER TABLE NguoiDung DROP CONSTRAINT [' + @ConstraintName + ']')
    PRINT 'Đã xóa ràng buộc UNIQUE: ' + @ConstraintName
END
ELSE
BEGIN
    PRINT 'Không tìm thấy ràng buộc UNIQUE trên cột TaiKhoan (hoặc đã xóa trước đó)'
END
GO

-- Bước 2: Xóa cột TaiKhoan
ALTER TABLE NguoiDung DROP CONSTRAINT UQ__NguoiDun__D5B8C7F029D3144A;
GO

ALTER TABLE NguoiDung DROP COLUMN TaiKhoan;
GO
-- Bước 3: Kiểm tra cấu trúc bảng sau khi sửa
EXEC sp_help 'NguoiDung';
-- Hoặc xem danh sách cột
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'NguoiDung'
ORDER BY ORDINAL_POSITION;
GO-- 2. Khoa
CREATE TABLE Khoa (
    maKhoa NVARCHAR(10) PRIMARY KEY,
    tenKhoa NVARCHAR(100) NOT NULL,
    sdt NVARCHAR(15),
    email NVARCHAR(100),
    TruongKhoa NVARCHAR(100)
)
GO

-- 3. Ngành
CREATE TABLE Nganh (
    maNganh NVARCHAR(10) PRIMARY KEY,
    tenNganh NVARCHAR(100) NOT NULL,
    maKhoa NVARCHAR(10) NOT NULL,
    trinhDoDaoTao NVARCHAR(50),
    soTinChi INT,
    FOREIGN KEY (maKhoa) REFERENCES Khoa(maKhoa)
)
GO

-- 4. Môn học
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

-- 5. Lớp hành chính
CREATE TABLE LopHanhChinh (
    MaLopHC NVARCHAR(10) PRIMARY KEY,
    TenLop NVARCHAR(50) NOT NULL,
    khoaHoc NVARCHAR(20),
    NganhHoc NVARCHAR(10) NOT NULL,
    SISO INT,
    FOREIGN KEY (NganhHoc) REFERENCES Nganh(maNganh)
)
GO

-- 6. Giảng viên (ĐÃ XÓA: sdt, email, DiaChi - lấy từ NguoiDung)
CREATE TABLE GiangVien (
    maGiangVien NVARCHAR(10) PRIMARY KEY,
    MaNguoiDung NVARCHAR(10) UNIQUE NOT NULL,
    TenGiangVien NVARCHAR(100) NOT NULL,
    GioiTinh NVARCHAR(10),
    NgaySinh DATE,
    TrinhDo NVARCHAR(50),
    Khoa NVARCHAR(10) NOT NULL,
    Mon NVARCHAR(100),
    FOREIGN KEY (Khoa) REFERENCES Khoa(maKhoa),
    FOREIGN KEY (MaNguoiDung) REFERENCES NguoiDung(MaNguoiDung)
)
GO

-- 7. Sinh viên (ĐÃ XÓA: sdt, email, DiaChi - lấy từ NguoiDung)
CREATE TABLE SinhVien (
    maSV NVARCHAR(10) PRIMARY KEY,
    MaNguoiDung NVARCHAR(10) UNIQUE NOT NULL,
    Hoten NVARCHAR(100) NOT NULL,
    GioiTinh NVARCHAR(10),
    NgaySinh DATE,
    NganhHoc NVARCHAR(10) NOT NULL,
    KhoaHoc NVARCHAR(20),
    MaLopHC NVARCHAR(10),
    TrangThai NVARCHAR(20),
    FOREIGN KEY (NganhHoc) REFERENCES Nganh(maNganh),
    FOREIGN KEY (MaNguoiDung) REFERENCES NguoiDung(MaNguoiDung),
    FOREIGN KEY (MaLopHC) REFERENCES LopHanhChinh(MaLopHC) -- ĐÃ THÊM KHÓA NGOẠI
)
GO

-- 8. Lớp học phần (ĐÃ SỬA: GiangVienPhuTrach từ text sang khóa ngoại)
CREATE TABLE LopHocPhan (
    maLopHP NVARCHAR(10) PRIMARY KEY,
    tenLop NVARCHAR(50),
    MaLopHocPhan NVARCHAR(20),
    MaMonHoc NVARCHAR(10) NOT NULL,
    maGiangVien NVARCHAR(10) NOT NULL, -- ĐÃ ĐỔI TÊN từ GiangVienPhuTrach
    ThoigianMo DATE,
    thoigianDong DATE,
    soLuongSinhVien INT,
    thuTuUuTien INT,
    FOREIGN KEY (MaMonHoc) REFERENCES MonHoc(maMonHoc),
    FOREIGN KEY (maGiangVien) REFERENCES GiangVien(maGiangVien) -- ĐÃ THÊM KHÓA NGOẠI
)
GO

-- 9. Lịch học (ĐÃ SỬA: GiaoThi không cần thiết, đã xóa)
CREATE TABLE LichHoc (
    maLichHoc NVARCHAR(10) PRIMARY KEY,
    maLopPhan NVARCHAR(10) NOT NULL,
    NgayHoc DATE,
    soTiet INT,
    phongHoc NVARCHAR(20),
    FOREIGN KEY (maLopPhan) REFERENCES LopHocPhan(maLopHP)
)
GO

-- 10. Lịch thi
CREATE TABLE LichThi (
    maLichThi NVARCHAR(10) PRIMARY KEY,
    MaLopPhan NVARCHAR(10) NOT NULL,
    NgayThi DATE,
    gioThi TIME,
    maPhong NVARCHAR(20),
    phongHoc NVARCHAR(20),
    hinhThucThi NVARCHAR(50),
    GiamThi NVARCHAR(100), -- Tạm giữ dạng text, nên tách bảng riêng sau
    FOREIGN KEY (MaLopPhan) REFERENCES LopHocPhan(maLopHP)
)
GO

-- 11. Phòng học
CREATE TABLE PhongHoc (
    maPhongHoc NVARCHAR(10) PRIMARY KEY,
    TenPhong NVARCHAR(50),
    sucChua INT,
    trangThai NVARCHAR(20)
)
GO

-- 12. Đăng ký học phần (ĐÃ SỬA: liên kết với LopHocPhan thay vì MonHoc)
CREATE TABLE DangKyHocPhan (
    maSV NVARCHAR(10),
    maLopHP NVARCHAR(10), -- ĐÃ ĐỔI từ maMonHoc
    ngayDK DATE,
    TrangThaiDK NVARCHAR(20),
    PRIMARY KEY (maSV, maLopHP),
    FOREIGN KEY (maSV) REFERENCES SinhVien(maSV),
    FOREIGN KEY (maLopHP) REFERENCES LopHocPhan(maLopHP) -- ĐÃ SỬA từ MonHoc
)
GO

-- 13. Đầu điểm (Giữa kỳ, Cuối kỳ, BT, ...)
CREATE TABLE DauDiem (
    MaDD NVARCHAR(10) PRIMARY KEY,
    TenDD NVARCHAR(50) NOT NULL,
    HeSoDiem FLOAT,
    loaiDiem NVARCHAR(50),
    moTa NVARCHAR(200)
)
GO

-- 14. Bảng điểm chi tiết (ĐÃ SỬA: thêm maLopHP để rõ ràng hơn)
CREATE TABLE BangDiem (
    MaBD NVARCHAR(10) PRIMARY KEY,
    MaSinhVien NVARCHAR(10) NOT NULL,
    MaMonHoc NVARCHAR(10) NOT NULL,
    maLopHP NVARCHAR(10), -- THÊM MỚI để biết điểm của lớp học phần nào
    MaDD NVARCHAR(10) NOT NULL,
    Diem FLOAT,
    FOREIGN KEY (MaSinhVien) REFERENCES SinhVien(maSV),
    FOREIGN KEY (MaMonHoc) REFERENCES MonHoc(maMonHoc),
    FOREIGN KEY (maLopHP) REFERENCES LopHocPhan(maLopHP), -- THÊM KHÓA NGOẠI
    FOREIGN KEY (MaDD) REFERENCES DauDiem(MaDD)
)
GO

-- 15. Điểm danh
CREATE TABLE DiemDanh (
    maDiemDanh NVARCHAR(10) PRIMARY KEY,
    NgayDiemDanh DATE,
    maSinhVien NVARCHAR(10) NOT NULL,
    maLichHoc NVARCHAR(10) NOT NULL,
    trangThai NVARCHAR(20), -- Có mặt / Vắng / Nghỉ phép
    FOREIGN KEY (maSinhVien) REFERENCES SinhVien(maSV),
    FOREIGN KEY (maLichHoc) REFERENCES LichHoc(maLichHoc)
)
GO





-- 1. NguoiDung (10 bản ghi)
INSERT INTO NguoiDung (MaNguoiDung, MatKhau, SDT, Email, Loai, DiaChi) VALUES
('ND001', 'admin123', '0901234567', 'admin@university.edu.vn', 1, '123 Nguyen Hue, Q1, TP.HCM'),
('ND002', 'gv123456', '0912345678', 'nguyenvana@university.edu.vn', 2, '456 Le Loi, Q3, TP.HCM'),
('ND003', 'gv123456', '0923456789', 'tranthib@university.edu.vn', 2, '789 Tran Hung Dao, Q5, TP.HCM'),
('ND004', 'gv123456', '0934567890', 'phamvanc@university.edu.vn', 2, '321 Vo Van Tan, Q3, TP.HCM'),
('ND005', 'sv123456', '0945678901', 'sv001@student.edu.vn', 3, '111 Ly Thuong Kiet, Tan Binh, TP.HCM'),
('ND006', 'sv123456', '0956789012', 'sv002@student.edu.vn', 3, '222 Hoang Van Thu, Phu Nhuan, TP.HCM'),
('ND007', 'sv123456', '0967890123', 'sv003@student.edu.vn', 3, '333 Cach Mang Thang 8, Q10, TP.HCM'),
('ND008', 'gv123456', '0978901234', 'lethid@university.edu.vn', 2, '444 Nguyen Thi Minh Khai, Q1, TP.HCM'),
('ND009', 'sv123456', '0989012345', 'sv004@student.edu.vn', 3, '555 Ba Thang Hai, Q10, TP.HCM'),
('ND010', 'sv123456', '0990123456', 'sv005@student.edu.vn', 3, '666 Dien Bien Phu, Binh Thanh, TP.HCM');
GO

-- 2. Khoa (10 bản ghi)
INSERT INTO Khoa (maKhoa, tenKhoa, sdt, email, TruongKhoa) VALUES
('CNTT', N'Công nghệ thông tin', '0281234567', 'cntt@university.edu.vn', N'PGS.TS Nguyen Van A'),
('KTPM', N'Kỹ thuật phần mềm', '0281234568', 'ktpm@university.edu.vn', N'TS Tran Thi B'),
('KHMT', N'Khoa học máy tính', '0281234569', 'khmt@university.edu.vn', N'PGS.TS Le Van C'),
('HTTT', N'Hệ thống thông tin', '0281234570', 'httt@university.edu.vn', N'TS Pham Van D'),
('MMT', N'Mạng máy tính', '0281234571', 'mmt@university.edu.vn', N'PGS Hoang Thi E'),
('ATTT', N'An toàn thông tin', '0281234572', 'attt@university.edu.vn', N'TS Nguyen Van F'),
('TTHCM', N'Truyền thông và Mạng', '0281234573', 'tthcm@university.edu.vn', N'PGS.TS Tran Van G'),
('KTDT', N'Kỹ thuật điện tử', '0281234574', 'ktdt@university.edu.vn', N'TS Le Thi H'),
('DTVT', N'Điện tử viễn thông', '0281234575', 'dtvt@university.edu.vn', N'PGS Pham Van I'),
('CNPM', N'Công nghệ phần mềm', '0281234576', 'cnpm@university.edu.vn', N'TS Hoang Van K');
GO

-- 3. Nganh (10 bản ghi)
INSERT INTO Nganh (maNganh, tenNganh, maKhoa, trinhDoDaoTao, soTinChi) VALUES
('N001', N'Công nghệ thông tin', 'CNTT', N'Đại học', 140),
('N002', N'Kỹ thuật phần mềm', 'KTPM', N'Đại học', 145),
('N003', N'Khoa học máy tính', 'KHMT', N'Đại học', 140),
('N004', N'Hệ thống thông tin', 'HTTT', N'Đại học', 135),
('N005', N'Mạng máy tính và truyền thông', 'MMT', N'Đại học', 140),
('N006', N'An toàn thông tin', 'ATTT', N'Đại học', 145),
('N007', N'Trí tuệ nhân tạo', 'CNTT', N'Đại học', 150),
('N008', N'Kỹ thuật điện tử', 'KTDT', N'Đại học', 140),
('N009', N'Điện tử viễn thông', 'DTVT', N'Đại học', 140),
('N010', N'Công nghệ đa phương tiện', 'CNPM', N'Đại học', 135);
GO

-- 4. MonHoc (10 bản ghi)
INSERT INTO MonHoc (maMonHoc, tenMonHoc, soTinChi, soTiet, thuTuUtien, maNganh) VALUES
('MH001', N'Lập trình C/C++', 3, 45, 1, 'N001'),
('MH002', N'Cấu trúc dữ liệu và giải thuật', 4, 60, 2, 'N001'),
('MH003', N'Cơ sở dữ liệu', 3, 45, 3, 'N001'),
('MH004', N'Lập trình hướng đối tượng', 3, 45, 2, 'N002'),
('MH005', N'Công nghệ Web', 3, 45, 4, 'N001'),
('MH006', N'Mạng máy tính', 3, 45, 3, 'N005'),
('MH007', N'Hệ điều hành', 3, 45, 3, 'N003'),
('MH008', N'Trí tuệ nhân tạo', 3, 45, 5, 'N007'),
('MH009', N'An toàn và bảo mật thông tin', 3, 45, 4, 'N006'),
('MH010', N'Phát triển ứng dụng di động', 3, 45, 5, 'N002');
GO

-- 5. LopHanhChinh (10 bản ghi)
INSERT INTO LopHanhChinh (MaLopHC, TenLop, khoaHoc, NganhHoc, SISO) VALUES
('LHC001', N'CNTT K18A', '2018-2022', 'N001', 45),
('LHC002', N'CNTT K18B', '2018-2022', 'N001', 42),
('LHC003', N'KTPM K19A', '2019-2023', 'N002', 40),
('LHC004', N'KHMT K19B', '2019-2023', 'N003', 38),
('LHC005', N'HTTT K20A', '2020-2024', 'N004', 43),
('LHC006', N'MMT K20B', '2020-2024', 'N005', 41),
('LHC007', N'ATTT K21A', '2021-2025', 'N006', 44),
('LHC008', N'CNTT K21B', '2021-2025', 'N001', 46),
('LHC009', N'KTPM K22A', '2022-2026', 'N002', 39),
('LHC010', N'KHMT K22B', '2022-2026', 'N003', 42);
GO

-- 6. GiangVien (10 bản ghi)
INSERT INTO GiangVien (maGiangVien, MaNguoiDung, TenGiangVien, GioiTinh, NgaySinh, TrinhDo, Khoa, Mon) VALUES
('GV001', 'ND002', N'Nguyễn Văn A', N'Nam', '1980-05-15', N'Tiến sĩ', 'CNTT', N'Lập trình C/C++'),
('GV002', 'ND003', N'Trần Thị B', N'Nữ', '1985-08-20', N'Thạc sĩ', 'KTPM', N'Công nghệ phần mềm'),
('GV003', 'ND004', N'Phạm Văn C', N'Nam', '1978-12-10', N'Tiến sĩ', 'KHMT', N'Trí tuệ nhân tạo'),
('GV004', 'ND008', N'Lê Thị D', N'Nữ', '1982-03-25', N'Thạc sĩ', 'HTTT', N'Cơ sở dữ liệu'),
('GV005', 'ND002', N'Hoàng Văn E', N'Nam', '1975-07-18', N'Phó giáo sư', 'MMT', N'Mạng máy tính'),
('GV006', 'ND003', N'Đỗ Thị F', N'Nữ', '1988-11-05', N'Thạc sĩ', 'ATTT', N'An toàn thông tin'),
('GV007', 'ND004', N'Vũ Văn G', N'Nam', '1981-09-30', N'Tiến sĩ', 'CNTT', N'Công nghệ Web'),
('GV008', 'ND008', N'Bùi Thị H', N'Nữ', '1986-02-14', N'Thạc sĩ', 'KTPM', N'Phát triển ứng dụng'),
('GV009', 'ND002', N'Mai Văn I', N'Nam', '1979-06-22', N'Tiến sĩ', 'KHMT', N'Hệ điều hành'),
('GV010', 'ND003', N'Lý Thị K', N'Nữ', '1983-04-17', N'Thạc sĩ', 'CNPM', N'Đa phương tiện');
GO

-- 7. SinhVien (10 bản ghi)
INSERT INTO SinhVien (maSV, MaNguoiDung, Hoten, GioiTinh, NgaySinh, NganhHoc, KhoaHoc, MaLopHC, TrangThai) VALUES
('SV001', 'ND005', N'Nguyễn Văn An', N'Nam', '2000-01-15', 'N001', '2018-2022', 'LHC001', N'Đang học'),
('SV002', 'ND006', N'Trần Thị Bình', N'Nữ', '2000-05-20', 'N001', '2018-2022', 'LHC002', N'Đang học'),
('SV003', 'ND007', N'Lê Văn Cường', N'Nam', '2001-03-10', 'N002', '2019-2023', 'LHC003', N'Đang học'),
('SV004', 'ND009', N'Phạm Thị Dung', N'Nữ', '2001-07-25', 'N003', '2019-2023', 'LHC004', N'Đang học'),
('SV005', 'ND010', N'Hoàng Văn Em', N'Nam', '2002-02-14', 'N004', '2020-2024', 'LHC005', N'Đang học'),
('SV006', 'ND005', N'Đỗ Thị Phương', N'Nữ', '2002-09-08', 'N005', '2020-2024', 'LHC006', N'Đang học'),
('SV007', 'ND006', N'Vũ Văn Giang', N'Nam', '2003-04-12', 'N006', '2021-2025', 'LHC007', N'Đang học'),
('SV008', 'ND007', N'Bùi Thị Hoa', N'Nữ', '2003-11-30', 'N001', '2021-2025', 'LHC008', N'Đang học'),
('SV009', 'ND009', N'Mai Văn Inh', N'Nam', '2004-06-18', 'N002', '2022-2026', 'LHC009', N'Đang học'),
('SV010', 'ND010', N'Lý Thị Kim', N'Nữ', '2004-08-22', 'N003', '2022-2026', 'LHC010', N'Đang học');
GO

-- 8. LopHocPhan (10 bản ghi)
INSERT INTO LopHocPhan (maLopHP, tenLop, MaLopHocPhan, MaMonHoc, maGiangVien, ThoigianMo, thoigianDong, soLuongSinhVien, thuTuUuTien) VALUES
('LHP001', N'C++ K18', 'LHP_MH001_01', 'MH001', 'GV001', '2024-01-08', '2024-05-15', 45, 1),
('LHP002', N'CTDL K18', 'LHP_MH002_01', 'MH002', 'GV001', '2024-01-08', '2024-05-15', 40, 2),
('LHP003', N'CSDL K19', 'LHP_MH003_01', 'MH003', 'GV004', '2024-01-08', '2024-05-15', 42, 3),
('LHP004', N'OOP K19', 'LHP_MH004_01', 'MH004', 'GV002', '2024-01-08', '2024-05-15', 38, 2),
('LHP005', N'Web K20', 'LHP_MH005_01', 'MH005', 'GV007', '2024-01-08', '2024-05-15', 43, 4),
('LHP006', N'Mạng K20', 'LHP_MH006_01', 'MH006', 'GV005', '2024-01-08', '2024-05-15', 41, 3),
('LHP007', N'HDH K21', 'LHP_MH007_01', 'MH007', 'GV009', '2024-01-08', '2024-05-15', 44, 3),
('LHP008', N'AI K21', 'LHP_MH008_01', 'MH008', 'GV003', '2024-01-08', '2024-05-15', 39, 5),
('LHP009', N'ATTT K22', 'LHP_MH009_01', 'MH009', 'GV006', '2024-01-08', '2024-05-15', 42, 4),
('LHP010', N'Mobile K22', 'LHP_MH010_01', 'MH010', 'GV008', '2024-01-08', '2024-05-15', 40, 5);
GO

-- 9. LichHoc (10 bản ghi)
INSERT INTO LichHoc (maLichHoc, maLopPhan, NgayHoc, soTiet, phongHoc) VALUES
('LH001', 'LHP001', '2024-01-09', 3, 'A101'),
('LH002', 'LHP001', '2024-01-11', 3, 'A101'),
('LH003', 'LHP002', '2024-01-10', 4, 'B202'),
('LH004', 'LHP003', '2024-01-12', 3, 'C303'),
('LH005', 'LHP004', '2024-01-09', 3, 'A102'),
('LH006', 'LHP005', '2024-01-11', 3, 'D404'),
('LH007', 'LHP006', '2024-01-10', 3, 'B203'),
('LH008', 'LHP007', '2024-01-12', 3, 'C304'),
('LH009', 'LHP008', '2024-01-09', 3, 'A103'),
('LH010', 'LHP009', '2024-01-11', 3, 'D405');
GO

-- 10. LichThi (10 bản ghi)
INSERT INTO LichThi (maLichThi, MaLopPhan, NgayThi, gioThi, maPhong, phongHoc, hinhThucThi, GiamThi) VALUES
('LT001', 'LHP001', '2024-05-20', '08:00', 'P001', 'A101', N'Thi viết', N'Nguyễn Văn A, Trần Thị B'),
('LT002', 'LHP002', '2024-05-21', '08:00', 'P002', 'B202', N'Thi viết', N'Nguyễn Văn A, Lê Văn C'),
('LT003', 'LHP003', '2024-05-22', '08:00', 'P003', 'C303', N'Thi viết', N'Lê Thị D, Phạm Văn C'),
('LT004', 'LHP004', '2024-05-23', '14:00', 'P004', 'A102', N'Thi thực hành', N'Trần Thị B, Hoàng Văn E'),
('LT005', 'LHP005', '2024-05-24', '08:00', 'P005', 'D404', N'Thi thực hành', N'Vũ Văn G, Đỗ Thị F'),
('LT006', 'LHP006', '2024-05-25', '08:00', 'P006', 'B203', N'Thi viết', N'Hoàng Văn E, Mai Văn I'),
('LT007', 'LHP007', '2024-05-26', '14:00', 'P007', 'C304', N'Thi viết', N'Mai Văn I, Bùi Thị H'),
('LT008', 'LHP008', '2024-05-27', '08:00', 'P008', 'A103', N'Thi viết', N'Phạm Văn C, Lý Thị K'),
('LT009', 'LHP009', '2024-05-28', '14:00', 'P009', 'D405', N'Thi thực hành', N'Đỗ Thị F, Vũ Văn G'),
('LT010', 'LHP010', '2024-05-29', '08:00', 'P010', 'A104', N'Thi thực hành', N'Bùi Thị H, Lý Thị K');
GO

-- 11. PhongHoc (10 bản ghi)
INSERT INTO PhongHoc (maPhongHoc, TenPhong, sucChua, trangThai) VALUES
('P001', 'A101', 50, N'Hoạt động'),
('P002', 'A102', 45, N'Hoạt động'),
('P003', 'A103', 50, N'Hoạt động'),
('P004', 'B202', 60, N'Hoạt động'),
('P005', 'B203', 55, N'Hoạt động'),
('P006', 'C303', 50, N'Hoạt động'),
('P007', 'C304', 45, N'Bảo trì'),
('P008', 'D404', 50, N'Hoạt động'),
('P009', 'D405', 55, N'Hoạt động'),
('P010', 'A104', 40, N'Hoạt động');
GO

-- 12. DangKyHocPhan (10 bản ghi)
INSERT INTO DangKyHocPhan (maSV, maLopHP, ngayDK, TrangThaiDK) VALUES
('SV001', 'LHP001', '2024-01-02', N'Đã duyệt'),
('SV001', 'LHP002', '2024-01-02', N'Đã duyệt'),
('SV002', 'LHP001', '2024-01-03', N'Đã duyệt'),
('SV003', 'LHP004', '2024-01-02', N'Đã duyệt'),
('SV004', 'LHP007', '2024-01-03', N'Đã duyệt'),
('SV005', 'LHP003', '2024-01-02', N'Đã duyệt'),
('SV006', 'LHP006', '2024-01-03', N'Đã duyệt'),
('SV007', 'LHP009', '2024-01-02', N'Đã duyệt'),
('SV008', 'LHP001', '2024-01-04', N'Chờ duyệt'),
('SV009', 'LHP004', '2024-01-04', N'Đã duyệt');
GO

-- 13. DauDiem (10 bản ghi)
INSERT INTO DauDiem (MaDD, TenDD, HeSoDiem, loaiDiem, moTa) VALUES
('DD001', N'Chuyên cần', 0.1, N'Thường xuyên', N'Điểm chuyên cần, tham gia lớp'),
('DD002', N'Bài tập 1', 0.1, N'Thường xuyên', N'Điểm bài tập thường xuyên'),
('DD003', N'Bài tập 2', 0.1, N'Thường xuyên', N'Điểm bài tập thường xuyên'),
('DD004', N'Kiểm tra giữa kỳ', 0.2, N'Giữa kỳ', N'Điểm kiểm tra giữa kỳ'),
('DD005', N'Thực hành', 0.2, N'Thực hành', N'Điểm thực hành'),
('DD006', N'Tiểu luận', 0.1, N'Khác', N'Điểm tiểu luận cuối kỳ'),
('DD007', N'Thi cuối kỳ', 0.3, N'Cuối kỳ', N'Điểm thi cuối kỳ'),
('DD008', N'Đồ án', 0.2, N'Khác', N'Điểm đồ án môn học'),
('DD009', N'Thuyết trình', 0.1, N'Khác', N'Điểm thuyết trình'),
('DD010', N'Vấn đáp', 0.1, N'Khác', N'Điểm vấn đáp');
GO

-- 14. BangDiem (10 bản ghi)
INSERT INTO BangDiem (MaBD, MaSinhVien, MaMonHoc, maLopHP, MaDD, Diem) VALUES
('BD001', 'SV001', 'MH001', 'LHP001', 'DD001', 9.0),
('BD002', 'SV001', 'MH001', 'LHP001', 'DD002', 8.5),
('BD003', 'SV001', 'MH001', 'LHP001', 'DD004', 8.0),
('BD004', 'SV001', 'MH002', 'LHP002', 'DD001', 9.5),
('BD005', 'SV002', 'MH001', 'LHP001', 'DD001', 8.0),
('BD006', 'SV003', 'MH004', 'LHP004', 'DD002', 7.5),
('BD007', 'SV004', 'MH007', 'LHP007', 'DD004', 8.5),
('BD008', 'SV005', 'MH003', 'LHP003', 'DD001', 9.0),
('BD009', 'SV006', 'MH006', 'LHP006', 'DD005', 7.0),
('BD010', 'SV007', 'MH009', 'LHP009', 'DD007', 8.0);
GO

-- 15. DiemDanh (10 bản ghi)
INSERT INTO DiemDanh (maDiemDanh, NgayDiemDanh, maSinhVien, maLichHoc, trangThai) VALUES
('DD0001', '2024-01-09', 'SV001', 'LH001', N'Có mặt'),
('DD0002', '2024-01-09', 'SV002', 'LH001', N'Có mặt'),
('DD0003', '2024-01-09', 'SV008', 'LH001', N'Vắng'),
('DD0004', '2024-01-11', 'SV001', 'LH002', N'Có mặt'),
('DD0005', '2024-01-10', 'SV001', 'LH003', N'Có mặt'),
('DD0006', '2024-01-12', 'SV005', 'LH004', N'Có mặt'),
('DD0007', '2024-01-09', 'SV003', 'LH005', N'Nghỉ phép'),
('DD0008', '2024-01-11', 'SV008', 'LH006', N'Có mặt'),
('DD0009', '2024-01-10', 'SV006', 'LH007', N'Có mặt'),
('DD0010', '2024-01-12', 'SV004', 'LH008', N'Có mặt');
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
-- ============================================
-- PROCEDURES CHO BẢNG NGƯỜI DÙNG
-- ============================================

-- Thêm người dùng
-- ============================================
-- PROCEDURES CHO BẢNG KHOA
-- ============================================
-- Thêm khoa
CREATE PROCEDURE sp_ThemKhoa
    @MaKhoa NVARCHAR(10),
    @TenKhoa NVARCHAR(100),
    @SDT NVARCHAR(15) = NULL,
    @Email NVARCHAR(100) = NULL,
    @TruongKhoa NVARCHAR(100) = NULL,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Khoa WHERE maKhoa = @MaKhoa)
        BEGIN
            SET @Result = 1; -- Mã khoa đã tồn tại
            RETURN;
        END
        INSERT INTO Khoa (maKhoa, tenKhoa, sdt, email, TruongKhoa)
        VALUES (@MaKhoa, @TenKhoa, @SDT, @Email, @TruongKhoa);
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Sửa khoa
CREATE PROCEDURE sp_SuaKhoa
    @MaKhoa NVARCHAR(10),
    @TenKhoa NVARCHAR(100) = NULL,
    @SDT NVARCHAR(15) = NULL,
    @Email NVARCHAR(100) = NULL,
    @TruongKhoa NVARCHAR(100) = NULL,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Khoa WHERE maKhoa = @MaKhoa)
        BEGIN
            SET @Result = 1; -- Mã khoa không tồn tại
            RETURN;
        END
        UPDATE Khoa
        SET
            tenKhoa = COALESCE(@TenKhoa, tenKhoa),
            sdt = COALESCE(@SDT, sdt),
            email = COALESCE(@Email, email),
            TruongKhoa = COALESCE(@TruongKhoa, TruongKhoa)
        WHERE maKhoa = @MaKhoa;
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Xóa khoa
CREATE PROCEDURE sp_XoaKhoa
    @MaKhoa NVARCHAR(10),
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Khoa WHERE maKhoa = @MaKhoa)
        BEGIN
            SET @Result = 1; -- Mã khoa không tồn tại
            RETURN;
        END
        DELETE FROM Khoa WHERE maKhoa = @MaKhoa;
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Lấy tất cả khoa
CREATE PROCEDURE sp_GetAllKhoa
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT maKhoa, tenKhoa, sdt, email, TruongKhoa
        FROM Khoa
        ORDER BY maKhoa;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi lấy dữ liệu Khoa: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO

-- Tìm kiếm khoa
CREATE PROCEDURE sp_SearchKhoa
    @MaKhoa NVARCHAR(10) = NULL,
    @TenKhoa NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT maKhoa, tenKhoa, sdt, email, TruongKhoa
        FROM Khoa
        WHERE (@MaKhoa IS NULL OR maKhoa LIKE '%' + @MaKhoa + '%')
          AND (@TenKhoa IS NULL OR tenKhoa LIKE '%' + @TenKhoa + '%')
        ORDER BY maKhoa;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi tìm kiếm Khoa: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO

-- ============================================
-- PROCEDURES CHO BẢNG SINH VIÊN
-- ============================================
-- Thêm sinh viên
CREATE PROCEDURE sp_ThemSinhVien
    @MaSV NVARCHAR(10),
    @MaNguoiDung NVARCHAR(10),
    @Hoten NVARCHAR(100),
    @GioiTinh NVARCHAR(10) = NULL,
    @NgaySinh DATE = NULL,
    @NganhHoc NVARCHAR(10),
    @KhoaHoc NVARCHAR(20) = NULL,
    @MaLopHC NVARCHAR(10) = NULL,
    @TrangThai NVARCHAR(20) = NULL,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM SinhVien WHERE maSV = @MaSV)
        BEGIN
            SET @Result = 1; -- Mã sinh viên đã tồn tại
            RETURN;
        END
        IF NOT EXISTS (SELECT 1 FROM NguoiDung WHERE MaNguoiDung = @MaNguoiDung)
        BEGIN
            SET @Result = 2; -- Người dùng không tồn tại
            RETURN;
        END
        IF EXISTS (SELECT 1 FROM SinhVien WHERE MaNguoiDung = @MaNguoiDung)
        BEGIN
            SET @Result = 3; -- Người dùng đã được gán cho sinh viên khác
            RETURN;
        END
        IF NOT EXISTS (SELECT 1 FROM Nganh WHERE maNganh = @NganhHoc)
        BEGIN
            SET @Result = 4; -- Ngành không tồn tại
            RETURN;
        END
        IF @MaLopHC IS NOT NULL AND NOT EXISTS (SELECT 1 FROM LopHanhChinh WHERE MaLopHC = @MaLopHC)
        BEGIN
            SET @Result = 5; -- Lớp hành chính không tồn tại
            RETURN;
        END
        INSERT INTO SinhVien (maSV, MaNguoiDung, Hoten, GioiTinh, NgaySinh, NganhHoc, KhoaHoc, MaLopHC, TrangThai)
        VALUES (@MaSV, @MaNguoiDung, @Hoten, @GioiTinh, @NgaySinh, @NganhHoc, @KhoaHoc, @MaLopHC, @TrangThai);
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Sửa sinh viên
CREATE PROCEDURE sp_SuaSinhVien
    @MaSV NVARCHAR(10),
    @MaNguoiDung NVARCHAR(10) = NULL,
    @Hoten NVARCHAR(100) = NULL,
    @GioiTinh NVARCHAR(10) = NULL,
    @NgaySinh DATE = NULL,
    @NganhHoc NVARCHAR(10) = NULL,
    @KhoaHoc NVARCHAR(20) = NULL,
    @MaLopHC NVARCHAR(10) = NULL,
    @TrangThai NVARCHAR(20) = NULL,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM SinhVien WHERE maSV = @MaSV)
        BEGIN
            SET @Result = 1; -- Mã sinh viên không tồn tại
            RETURN;
        END
        IF @MaNguoiDung IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM NguoiDung WHERE MaNguoiDung = @MaNguoiDung)
            BEGIN
                SET @Result = 2; -- Người dùng không tồn tại
                RETURN;
            END
            IF EXISTS (SELECT 1 FROM SinhVien WHERE MaNguoiDung = @MaNguoiDung AND maSV != @MaSV)
            BEGIN
                SET @Result = 3; -- Người dùng đã được gán cho sinh viên khác
                RETURN;
            END
        END
        IF @NganhHoc IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Nganh WHERE maNganh = @NganhHoc)
        BEGIN
            SET @Result = 4; -- Ngành không tồn tại
            RETURN;
        END
        IF @MaLopHC IS NOT NULL AND NOT EXISTS (SELECT 1 FROM LopHanhChinh WHERE MaLopHC = @MaLopHC)
        BEGIN
            SET @Result = 5; -- Lớp hành chính không tồn tại
            RETURN;
        END
        UPDATE SinhVien
        SET
            MaNguoiDung = COALESCE(@MaNguoiDung, MaNguoiDung),
            Hoten = COALESCE(@Hoten, Hoten),
            GioiTinh = COALESCE(@GioiTinh, GioiTinh),
            NgaySinh = COALESCE(@NgaySinh, NgaySinh),
            NganhHoc = COALESCE(@NganhHoc, NganhHoc),
            KhoaHoc = COALESCE(@KhoaHoc, KhoaHoc),
            MaLopHC = COALESCE(@MaLopHC, MaLopHC),
            TrangThai = COALESCE(@TrangThai, TrangThai)
        WHERE maSV = @MaSV;
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Xóa sinh viên
CREATE PROCEDURE sp_XoaSinhVien
    @MaSV NVARCHAR(10),
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM SinhVien WHERE maSV = @MaSV)
        BEGIN
            SET @Result = 1; -- Mã sinh viên không tồn tại
            RETURN;
        END
        DELETE FROM SinhVien WHERE maSV = @MaSV;
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Lấy tất cả sinh viên
CREATE PROCEDURE sp_GetAllSinhVien
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT maSV, MaNguoiDung, Hoten, GioiTinh, NgaySinh, NganhHoc, KhoaHoc, MaLopHC, TrangThai
        FROM SinhVien
        ORDER BY maSV;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi lấy dữ liệu Sinh viên: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO

-- Tìm kiếm sinh viên
CREATE PROCEDURE sp_SearchSinhVien
    @MaSV NVARCHAR(10) = NULL,
    @Hoten NVARCHAR(100) = NULL,
    @NganhHoc NVARCHAR(10) = NULL,
    @MaLopHC NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT maSV, MaNguoiDung, Hoten, GioiTinh, NgaySinh, NganhHoc, KhoaHoc, MaLopHC, TrangThai
        FROM SinhVien
        WHERE (@MaSV IS NULL OR maSV LIKE '%' + @MaSV + '%')
          AND (@Hoten IS NULL OR Hoten LIKE '%' + @Hoten + '%')
          AND (@NganhHoc IS NULL OR NganhHoc = @NganhHoc)
          AND (@MaLopHC IS NULL OR MaLopHC = @MaLopHC)
        ORDER BY maSV;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi tìm kiếm Sinh viên: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO
CREATE PROCEDURE sp_ThemNguoiDung
    @MaNguoiDung NVARCHAR(10),
    @TaiKhoan NVARCHAR(50),
    @MatKhau NVARCHAR(255),
    @SDT NVARCHAR(15) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Loai INT,
    @DiaChi NVARCHAR(200) = NULL,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM NguoiDung WHERE MaNguoiDung = @MaNguoiDung)
        BEGIN
            SET @Result = 1; -- Mã người dùng đã tồn tại
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM NguoiDung WHERE TaiKhoan = @TaiKhoan)
        BEGIN
            SET @Result = 2; -- Tài khoản đã tồn tại
            RETURN;
        END

        IF @Loai NOT IN (1, 2, 3)
        BEGIN
            SET @Result = 3; -- Loại người dùng không hợp lệ
            RETURN;
        END

        INSERT INTO NguoiDung (MaNguoiDung, TaiKhoan, MatKhau, SDT, Email, Loai, DiaChi)
        VALUES (@MaNguoiDung, @TaiKhoan, @MatKhau, @SDT, @Email, @Loai, @DiaChi);

        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Sửa người dùng
CREATE PROCEDURE sp_SuaNguoiDung
    @MaNguoiDung NVARCHAR(10),
    @TaiKhoan NVARCHAR(50) = NULL,
    @MatKhau NVARCHAR(255) = NULL,
    @SDT NVARCHAR(15) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Loai INT = NULL,
    @DiaChi NVARCHAR(200) = NULL,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM NguoiDung WHERE MaNguoiDung = @MaNguoiDung)
        BEGIN
            SET @Result = 1; -- Mã người dùng không tồn tại
            RETURN;
        END

        IF @TaiKhoan IS NOT NULL AND EXISTS (SELECT 1 FROM NguoiDung WHERE TaiKhoan = @TaiKhoan AND MaNguoiDung != @MaNguoiDung)
        BEGIN
            SET @Result = 2; -- Tài khoản đã tồn tại
            RETURN;
        END

        IF @Loai IS NOT NULL AND @Loai NOT IN (1, 2, 3)
        BEGIN
            SET @Result = 3; -- Loại người dùng không hợp lệ
            RETURN;
        END

        UPDATE NguoiDung
        SET 
            TaiKhoan = COALESCE(@TaiKhoan, TaiKhoan),
            MatKhau = COALESCE(@MatKhau, MatKhau),
            SDT = COALESCE(@SDT, SDT),
            Email = COALESCE(@Email, Email),
            Loai = COALESCE(@Loai, Loai),
            DiaChi = COALESCE(@DiaChi, DiaChi)
        WHERE MaNguoiDung = @MaNguoiDung;

        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Xóa người dùng
CREATE PROCEDURE sp_XoaNguoiDung
    @MaNguoiDung NVARCHAR(10),
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM NguoiDung WHERE MaNguoiDung = @MaNguoiDung)
        BEGIN
            SET @Result = 1; -- Mã người dùng không tồn tại
            RETURN;
        END

        DELETE FROM NguoiDung WHERE MaNguoiDung = @MaNguoiDung;
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Lấy tất cả người dùng
CREATE PROCEDURE sp_GetAllNguoiDung
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT MaNguoiDung, TaiKhoan, SDT, Email, Loai, DiaChi
        FROM NguoiDung
        ORDER BY MaNguoiDung;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi lấy dữ liệu NguoiDung: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO
use QuanLySinhVien
-- Tìm kiếm người dùng
ALTER PROCEDURE sp_SearchNguoiDung
    @MaNguoiDung NVARCHAR(10) = NULL,
    @TaiKhoan     NVARCHAR(50) = NULL,
    @MatKhau      NVARCHAR(255) = NULL,
    @SDT          NVARCHAR(15) = NULL,
    @Email        NVARCHAR(100) = NULL,
    @Loai         INT = 0,
    @DiaChi       NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT 
            MaNguoiDung,
            
            SDT,
            Email,
            Loai,
            DiaChi
        FROM NguoiDung
        WHERE 
            (@MaNguoiDung IS NULL OR MaNguoiDung LIKE '%' + @MaNguoiDung + '%')
          
          AND (@MatKhau      IS NULL OR MatKhau      = @MatKhau)
          AND (@SDT          IS NULL OR SDT          LIKE '%' + @SDT + '%')
          AND (@Email        IS NULL OR Email        LIKE '%' + @Email + '%')
          AND (@Loai = 0 OR Loai         = @Loai)
          AND (@DiaChi       IS NULL OR DiaChi       LIKE '%' + @DiaChi + '%')
        ORDER BY MaNguoiDung;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi tìm kiếm NguoiDung: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO
-- ============================================
-- PROCEDURES CHO BẢNG NGÀNH
-- ============================================

-- Thêm ngành
CREATE PROCEDURE sp_ThemNganh
    @MaNganh NVARCHAR(10),
    @TenNganh NVARCHAR(100),
    @MaKhoa NVARCHAR(10),
    @TrinhDoDaoTao NVARCHAR(50) = NULL,
    @SoTinChi INT = NULL,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Nganh WHERE MaNganh = @MaNganh)
        BEGIN
            SET @Result = 1; -- Mã ngành đã tồn tại
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Khoa WHERE MaKhoa = @MaKhoa)
        BEGIN
            SET @Result = 2; -- Khoa không tồn tại
            RETURN;
        END

        INSERT INTO Nganh (MaNganh, TenNganh, MaKhoa, TrinhDoDaoTao, SoTinChi)
        VALUES (@MaNganh, @TenNganh, @MaKhoa, @TrinhDoDaoTao, @SoTinChi);

        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Sửa ngành
CREATE PROCEDURE sp_SuaNganh
    @MaNganh NVARCHAR(10),
    @TenNganh NVARCHAR(100) = NULL,
    @MaKhoa NVARCHAR(10) = NULL,
    @TrinhDoDaoTao NVARCHAR(50) = NULL,
    @SoTinChi INT = NULL,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Nganh WHERE MaNganh = @MaNganh)
        BEGIN
            SET @Result = 1; -- Mã ngành không tồn tại
            RETURN;
        END

        IF @MaKhoa IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Khoa WHERE MaKhoa = @MaKhoa)
        BEGIN
            SET @Result = 2; -- Khoa không tồn tại
            RETURN;
        END

        UPDATE Nganh
        SET 
            TenNganh = COALESCE(@TenNganh, TenNganh),
            MaKhoa = COALESCE(@MaKhoa, MaKhoa),
            TrinhDoDaoTao = COALESCE(@TrinhDoDaoTao, TrinhDoDaoTao),
            SoTinChi = COALESCE(@SoTinChi, SoTinChi)
        WHERE MaNganh = @MaNganh;

        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Xóa ngành
CREATE PROCEDURE sp_XoaNganh
    @MaNganh NVARCHAR(10),
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Nganh WHERE MaNganh = @MaNganh)
        BEGIN
            SET @Result = 1; -- Mã ngành không tồn tại
            RETURN;
        END

        DELETE FROM Nganh WHERE MaNganh = @MaNganh;
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Lấy tất cả ngành
CREATE PROCEDURE sp_GetAllNganh
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT MaNganh, TenNganh, MaKhoa, TrinhDoDaoTao, SoTinChi
        FROM Nganh
        ORDER BY MaNganh;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi lấy dữ liệu Ngành: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO

-- Tìm kiếm ngành
CREATE PROCEDURE sp_SearchNganh
    @MaNganh NVARCHAR(10) = NULL,
    @TenNganh NVARCHAR(100) = NULL,
    @MaKhoa NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT MaNganh, TenNganh, MaKhoa, TrinhDoDaoTao, SoTinChi
        FROM Nganh
        WHERE (@MaNganh IS NULL OR MaNganh LIKE '%' + @MaNganh + '%')
          AND (@TenNganh IS NULL OR TenNganh LIKE '%' + @TenNganh + '%')
          AND (@MaKhoa IS NULL OR MaKhoa = @MaKhoa)
        ORDER BY MaNganh;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi tìm kiếm Ngành: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO

-- ============================================
-- PROCEDURES CHO BẢNG MÔN HỌC
-- ============================================

-- Thêm môn học
CREATE PROCEDURE sp_ThemMonHoc
    @MaMonHoc NVARCHAR(10),
    @TenMonHoc NVARCHAR(100),
    @SoTinChi INT,
    @SoTiet INT = NULL,
    @ThuTuUtien INT = NULL,
    @MaNganh NVARCHAR(10) = NULL,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM MonHoc WHERE MaMonHoc = @MaMonHoc)
        BEGIN
            SET @Result = 1; -- Mã môn học đã tồn tại
            RETURN;
        END

        IF @MaNganh IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Nganh WHERE MaNganh = @MaNganh)
        BEGIN
            SET @Result = 2; -- Ngành không tồn tại
            RETURN;
        END

        INSERT INTO MonHoc (MaMonHoc, TenMonHoc, SoTinChi, SoTiet, ThuTuUtien, MaNganh)
        VALUES (@MaMonHoc, @TenMonHoc, @SoTinChi, @SoTiet, @ThuTuUtien, @MaNganh);

        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Sửa môn học
CREATE PROCEDURE sp_SuaMonHoc
    @MaMonHoc NVARCHAR(10),
    @TenMonHoc NVARCHAR(100) = NULL,
    @SoTinChi INT = NULL,
    @SoTiet INT = NULL,
    @ThuTuUtien INT = NULL,
    @MaNganh NVARCHAR(10) = NULL,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM MonHoc WHERE MaMonHoc = @MaMonHoc)
        BEGIN
            SET @Result = 1; -- Mã môn học không tồn tại
            RETURN;
        END

        IF @MaNganh IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Nganh WHERE MaNganh = @MaNganh)
        BEGIN
            SET @Result = 2; -- Ngành không tồn tại
            RETURN;
        END

        UPDATE MonHoc
        SET 
            TenMonHoc = COALESCE(@TenMonHoc, TenMonHoc),
            SoTinChi = COALESCE(@SoTinChi, SoTinChi),
            SoTiet = COALESCE(@SoTiet, SoTiet),
            ThuTuUtien = COALESCE(@ThuTuUtien, ThuTuUtien),
            MaNganh = COALESCE(@MaNganh, MaNganh)
        WHERE MaMonHoc = @MaMonHoc;

        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Xóa môn học
CREATE PROCEDURE sp_XoaMonHoc
    @MaMonHoc NVARCHAR(10),
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM MonHoc WHERE MaMonHoc = @MaMonHoc)
        BEGIN
            SET @Result = 1; -- Mã môn học không tồn tại
            RETURN;
        END

        DELETE FROM MonHoc WHERE MaMonHoc = @MaMonHoc;
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Lấy tất cả môn học
CREATE PROCEDURE sp_GetAllMonHoc
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT MaMonHoc, TenMonHoc, SoTinChi, SoTiet, ThuTuUtien, MaNganh
        FROM MonHoc
        ORDER BY MaMonHoc;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi lấy dữ liệu Môn học: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO

-- Tìm kiếm môn học
CREATE PROCEDURE sp_SearchMonHoc
    @MaMonHoc NVARCHAR(10) = NULL,
    @TenMonHoc NVARCHAR(100) = NULL,
    @MaNganh NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT MaMonHoc, TenMonHoc, SoTinChi, SoTiet, ThuTuUtien, MaNganh
        FROM MonHoc
        WHERE (@MaMonHoc IS NULL OR MaMonHoc LIKE '%' + @MaMonHoc + '%')
          AND (@TenMonHoc IS NULL OR TenMonHoc LIKE '%' + @TenMonHoc + '%')
          AND (@MaNganh IS NULL OR MaNganh = @MaNganh)
        ORDER BY MaMonHoc;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi tìm kiếm Môn học: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO

-- ============================================
-- PROCEDURES CHO BẢNG LỚP HÀNH CHÍNH
-- ============================================

-- Thêm lớp hành chính
CREATE PROCEDURE sp_ThemLopHanhChinh
    @MaLopHC NVARCHAR(10),
    @TenLop NVARCHAR(50),
    @KhoaHoc NVARCHAR(20) = NULL,
    @NganhHoc NVARCHAR(10),
    @SISO INT = NULL,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM LopHanhChinh WHERE MaLopHC = @MaLopHC)
        BEGIN
            SET @Result = 1; -- Mã lớp đã tồn tại
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Nganh WHERE MaNganh = @NganhHoc)
        BEGIN
            SET @Result = 2; -- Ngành không tồn tại
            RETURN;
        END

        INSERT INTO LopHanhChinh (MaLopHC, TenLop, KhoaHoc, NganhHoc, SISO)
        VALUES (@MaLopHC, @TenLop, @KhoaHoc, @NganhHoc, @SISO);

        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Sửa lớp hành chính
CREATE PROCEDURE sp_SuaLopHanhChinh
    @MaLopHC NVARCHAR(10),
    @TenLop NVARCHAR(50) = NULL,
    @KhoaHoc NVARCHAR(20) = NULL,
    @NganhHoc NVARCHAR(10) = NULL,
    @SISO INT = NULL,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM LopHanhChinh WHERE MaLopHC = @MaLopHC)
        BEGIN
            SET @Result = 1; -- Mã lớp không tồn tại
            RETURN;
        END

        IF @NganhHoc IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Nganh WHERE MaNganh = @NganhHoc)
        BEGIN
            SET @Result = 2; -- Ngành không tồn tại
            RETURN;
        END

        UPDATE LopHanhChinh
        SET 
            TenLop = COALESCE(@TenLop, TenLop),
            KhoaHoc = COALESCE(@KhoaHoc, KhoaHoc),
            NganhHoc = COALESCE(@NganhHoc, NganhHoc),
            SISO = COALESCE(@SISO, SISO)
        WHERE MaLopHC = @MaLopHC;

        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Xóa lớp hành chính
CREATE PROCEDURE sp_XoaLopHanhChinh
    @MaLopHC NVARCHAR(10),
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM LopHanhChinh WHERE MaLopHC = @MaLopHC)
        BEGIN
            SET @Result = 1; -- Mã lớp không tồn tại
            RETURN;
        END

        DELETE FROM LopHanhChinh WHERE MaLopHC = @MaLopHC;
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Lấy tất cả lớp hành chính
CREATE PROCEDURE sp_GetAllLopHanhChinh
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT MaLopHC, TenLop, KhoaHoc, NganhHoc, SISO
        FROM LopHanhChinh
        ORDER BY MaLopHC;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi lấy dữ liệu Lớp hành chính: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO

-- Tìm kiếm lớp hành chính
CREATE PROCEDURE sp_SearchLopHanhChinh
    @MaLopHC NVARCHAR(10) = NULL,
    @TenLop NVARCHAR(50) = NULL,
    @KhoaHoc NVARCHAR(20) = NULL,
    @NganhHoc NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT MaLopHC, TenLop, KhoaHoc, NganhHoc, SISO
        FROM LopHanhChinh
        WHERE (@MaLopHC IS NULL OR MaLopHC LIKE '%' + @MaLopHC + '%')
          AND (@TenLop IS NULL OR TenLop LIKE '%' + @TenLop + '%')
          AND (@KhoaHoc IS NULL OR KhoaHoc = @KhoaHoc)
          AND (@NganhHoc IS NULL OR NganhHoc = @NganhHoc)
        ORDER BY MaLopHC;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi tìm kiếm Lớp hành chính: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO

-- ============================================
-- PROCEDURES CHO BẢNG GIẢNG VIÊN
-- ============================================

-- Thêm giảng viên
CREATE PROCEDURE sp_ThemGiangVien
    @MaGiangVien NVARCHAR(10),
    @MaNguoiDung NVARCHAR(10),
    @TenGiangVien NVARCHAR(100),
    @GioiTinh NVARCHAR(10) = NULL,
    @NgaySinh DATE = NULL,
    @TrinhDo NVARCHAR(50) = NULL,
    @Khoa NVARCHAR(10),
    @Mon NVARCHAR(100) = NULL,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM GiangVien WHERE MaGiangVien = @MaGiangVien)
        BEGIN
            SET @Result = 1; -- Mã giảng viên đã tồn tại
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM NguoiDung WHERE MaNguoiDung = @MaNguoiDung)
        BEGIN
            SET @Result = 2; -- Người dùng không tồn tại
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM GiangVien WHERE MaNguoiDung = @MaNguoiDung)
        BEGIN
            SET @Result = 3; -- Người dùng đã được gán cho giảng viên khác
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Khoa WHERE MaKhoa = @Khoa)
        BEGIN
            SET @Result = 4; -- Khoa không tồn tại
            RETURN;
        END

        INSERT INTO GiangVien (MaGiangVien, MaNguoiDung, TenGiangVien, GioiTinh, NgaySinh, TrinhDo, Khoa, Mon)
        VALUES (@MaGiangVien, @MaNguoiDung, @TenGiangVien, @GioiTinh, @NgaySinh, @TrinhDo, @Khoa, @Mon);

        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Sửa giảng viên
CREATE PROCEDURE sp_SuaGiangVien
    @MaGiangVien NVARCHAR(10),
    @MaNguoiDung NVARCHAR(10) = NULL,
    @TenGiangVien NVARCHAR(100) = NULL,
    @GioiTinh NVARCHAR(10) = NULL,
    @NgaySinh DATE = NULL,
    @TrinhDo NVARCHAR(50) = NULL,
    @Khoa NVARCHAR(10) = NULL,
    @Mon NVARCHAR(100) = NULL,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM GiangVien WHERE MaGiangVien = @MaGiangVien)
        BEGIN
            SET @Result = 1; -- Mã giảng viên không tồn tại
            RETURN;
        END

        IF @MaNguoiDung IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM NguoiDung WHERE MaNguoiDung = @MaNguoiDung)
            BEGIN
                SET @Result = 2; -- Người dùng không tồn tại
                RETURN;
            END

            IF EXISTS (SELECT 1 FROM GiangVien WHERE MaNguoiDung = @MaNguoiDung AND MaGiangVien != @MaGiangVien)
            BEGIN
                SET @Result = 3; -- Người dùng đã được gán cho giảng viên khác
                RETURN;
            END
        END

        IF @Khoa IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Khoa WHERE MaKhoa = @Khoa)
        BEGIN
            SET @Result = 4; -- Khoa không tồn tại
            RETURN;
        END

        UPDATE GiangVien
        SET 
            MaNguoiDung = COALESCE(@MaNguoiDung, MaNguoiDung),
            TenGiangVien = COALESCE(@TenGiangVien, TenGiangVien),
            GioiTinh = COALESCE(@GioiTinh, GioiTinh),
            NgaySinh = COALESCE(@NgaySinh, NgaySinh),
            TrinhDo = COALESCE(@TrinhDo, TrinhDo),
            Khoa = COALESCE(@Khoa, Khoa),
            Mon = COALESCE(@Mon, Mon)
        WHERE MaGiangVien = @MaGiangVien;

        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Xóa giảng viên
CREATE PROCEDURE sp_XoaGiangVien
    @MaGiangVien NVARCHAR(10),
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM GiangVien WHERE MaGiangVien = @MaGiangVien)
        BEGIN
            SET @Result = 1; -- Mã giảng viên không tồn tại
            RETURN;
        END

        DELETE FROM GiangVien WHERE MaGiangVien = @MaGiangVien;
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO
-- ============================================
-- PROCEDURES CHO BẢNG GIẢNG VIÊN (TIẾP TỤC)
-- ============================================

-- Lấy tất cả giảng viên
CREATE PROCEDURE sp_GetAllGiangVien
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT maGiangVien, MaNguoiDung, TenGiangVien, GioiTinh, NgaySinh, TrinhDo, Khoa, Mon
        FROM GiangVien
        ORDER BY maGiangVien;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi lấy dữ liệu Giảng viên: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO

-- Tìm kiếm giảng viên
CREATE PROCEDURE sp_SearchGiangVien
    @MaGiangVien NVARCHAR(10) = NULL,
    @TenGiangVien NVARCHAR(100) = NULL,
    @Khoa NVARCHAR(10) = NULL,
    @Mon NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT maGiangVien, MaNguoiDung, TenGiangVien, GioiTinh, NgaySinh, TrinhDo, Khoa, Mon
        FROM GiangVien
        WHERE (@MaGiangVien IS NULL OR maGiangVien LIKE '%' + @MaGiangVien + '%')
          AND (@TenGiangVien IS NULL OR TenGiangVien LIKE '%' + @TenGiangVien + '%')
          AND (@Khoa IS NULL OR Khoa = @Khoa)
          AND (@Mon IS NULL OR Mon LIKE '%' + @Mon + '%')
        ORDER BY maGiangVien;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi tìm kiếm Giảng viên: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO
-- ============================================
-- PROCEDURES CHO BẢNG LỚP HỌC PHẦN (TIẾP TỤC)
-- ============================================
-- Xóa lớp học phần
CREATE PROCEDURE sp_XoaLopHocPhan
    @MaLopHP NVARCHAR(10),
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM LopHocPhan WHERE maLopHP = @MaLopHP)
        BEGIN
            SET @Result = 1; -- Mã lớp học phần không tồn tại
            RETURN;
        END
        DELETE FROM LopHocPhan WHERE maLopHP = @MaLopHP;
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Lấy tất cả lớp học phần
CREATE PROCEDURE sp_GetAllLopHocPhan
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT maLopHP, tenLop, MaLopHocPhan, MaMonHoc, maGiangVien, ThoigianMo, thoigianDong, soLuongSinhVien, thuTuUuTien
        FROM LopHocPhan
        ORDER BY maLopHP;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi lấy dữ liệu Lớp học phần: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO

-- Tìm kiếm lớp học phần
CREATE PROCEDURE sp_SearchLopHocPhan
    @MaLopHP NVARCHAR(10) = NULL,
    @MaMonHoc NVARCHAR(10) = NULL,
    @MaGiangVien NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT maLopHP, tenLop, MaLopHocPhan, MaMonHoc, maGiangVien, ThoigianMo, thoigianDong, soLuongSinhVien, thuTuUuTien
        FROM LopHocPhan
        WHERE (@MaLopHP IS NULL OR maLopHP LIKE '%' + @MaLopHP + '%')
          AND (@MaMonHoc IS NULL OR MaMonHoc = @MaMonHoc)
          AND (@MaGiangVien IS NULL OR maGiangVien = @MaGiangVien)
        ORDER BY maLopHP;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi tìm kiếm Lớp học phần: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO

-- ============================================
-- PROCEDURES CHO BẢNG LỊCH HỌC
-- ============================================
-- Thêm lịch học
CREATE PROCEDURE sp_ThemLichHoc
    @MaLichHoc NVARCHAR(10),
    @MaLopPhan NVARCHAR(10),
    @NgayHoc DATE,
    @SoTiet INT = NULL,
    @PhongHoc NVARCHAR(20) = NULL,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM LichHoc WHERE maLichHoc = @MaLichHoc)
        BEGIN
            SET @Result = 1; -- Mã lịch học đã tồn tại
            RETURN;
        END
        IF NOT EXISTS (SELECT 1 FROM LopHocPhan WHERE maLopHP = @MaLopPhan)
        BEGIN
            SET @Result = 2; -- Lớp học phần không tồn tại
            RETURN;
        END
        INSERT INTO LichHoc (maLichHoc, maLopPhan, NgayHoc, soTiet, phongHoc)
        VALUES (@MaLichHoc, @MaLopPhan, @NgayHoc, @SoTiet, @PhongHoc);
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Sửa lịch học
CREATE PROCEDURE sp_SuaLichHoc
    @MaLichHoc NVARCHAR(10),
    @MaLopPhan NVARCHAR(10) = NULL,
    @NgayHoc DATE = NULL,
    @SoTiet INT = NULL,
    @PhongHoc NVARCHAR(20) = NULL,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM LichHoc WHERE maLichHoc = @MaLichHoc)
        BEGIN
            SET @Result = 1; -- Mã lịch học không tồn tại
            RETURN;
        END
        IF @MaLopPhan IS NOT NULL AND NOT EXISTS (SELECT 1 FROM LopHocPhan WHERE maLopHP = @MaLopPhan)
        BEGIN
            SET @Result = 2; -- Lớp học phần không tồn tại
            RETURN;
        END
        UPDATE LichHoc
        SET
            maLopPhan = COALESCE(@MaLopPhan, maLopPhan),
            NgayHoc = COALESCE(@NgayHoc, NgayHoc),
            soTiet = COALESCE(@SoTiet, soTiet),
            phongHoc = COALESCE(@PhongHoc, phongHoc)
        WHERE maLichHoc = @MaLichHoc;
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Xóa lịch học
CREATE PROCEDURE sp_XoaLichHoc
    @MaLichHoc NVARCHAR(10),
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM LichHoc WHERE maLichHoc = @MaLichHoc)
        BEGIN
            SET @Result = 1; -- Mã lịch học không tồn tại
            RETURN;
        END
        DELETE FROM LichHoc WHERE maLichHoc = @MaLichHoc;
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Lấy tất cả lịch học
CREATE PROCEDURE sp_GetAllLichHoc
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT maLichHoc, maLopPhan, NgayHoc, soTiet, phongHoc
        FROM LichHoc
        ORDER BY NgayHoc DESC, maLichHoc;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi lấy dữ liệu Lịch học: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO

-- Tìm kiếm lịch học
CREATE PROCEDURE sp_SearchLichHoc
    @MaLichHoc NVARCHAR(10) = NULL,
    @MaLopPhan NVARCHAR(10) = NULL,
    @NgayHoc DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT maLichHoc, maLopPhan, NgayHoc, soTiet, phongHoc
        FROM LichHoc
        WHERE (@MaLichHoc IS NULL OR maLichHoc LIKE '%' + @MaLichHoc + '%')
          AND (@MaLopPhan IS NULL OR maLopPhan = @MaLopPhan)
          AND (@NgayHoc IS NULL OR NgayHoc = @NgayHoc)
        ORDER BY NgayHoc DESC;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi tìm kiếm Lịch học: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO

-- ============================================
-- PROCEDURES CHO BẢNG LỊCH THI
-- ============================================
-- Thêm lịch thi
CREATE PROCEDURE sp_ThemLichThi
    @MaLichThi NVARCHAR(10),
    @MaLopPhan NVARCHAR(10),
    @NgayThi DATE,
    @GioThi TIME = NULL,
    @MaPhong NVARCHAR(20) = NULL,
    @PhongHoc NVARCHAR(20) = NULL,
    @HinhThucThi NVARCHAR(50) = NULL,
    @GiamThi NVARCHAR(100) = NULL,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM LichThi WHERE maLichThi = @MaLichThi)
        BEGIN
            SET @Result = 1; -- Mã lịch thi đã tồn tại
            RETURN;
        END
        IF NOT EXISTS (SELECT 1 FROM LopHocPhan WHERE maLopHP = @MaLopPhan)
        BEGIN
            SET @Result = 2; -- Lớp học phần không tồn tại
            RETURN;
        END
        INSERT INTO LichThi (maLichThi, MaLopPhan, NgayThi, gioThi, maPhong, phongHoc, hinhThucThi, GiamThi)
        VALUES (@MaLichThi, @MaLopPhan, @NgayThi, @GioThi, @MaPhong, @PhongHoc, @HinhThucThi, @GiamThi);
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Sửa lịch thi
CREATE PROCEDURE sp_SuaLichThi
    @MaLichThi NVARCHAR(10),
    @MaLopPhan NVARCHAR(10) = NULL,
    @NgayThi DATE = NULL,
    @GioThi TIME = NULL,
    @MaPhong NVARCHAR(20) = NULL,
    @PhongHoc NVARCHAR(20) = NULL,
    @HinhThucThi NVARCHAR(50) = NULL,
    @GiamThi NVARCHAR(100) = NULL,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM LichThi WHERE maLichThi = @MaLichThi)
        BEGIN
            SET @Result = 1; -- Mã lịch thi không tồn tại
            RETURN;
        END
        IF @MaLopPhan IS NOT NULL AND NOT EXISTS (SELECT 1 FROM LopHocPhan WHERE maLopHP = @MaLopPhan)
        BEGIN
            SET @Result = 2; -- Lớp học phần không tồn tại
            RETURN;
        END
        UPDATE LichThi
        SET
            MaLopPhan = COALESCE(@MaLopPhan, MaLopPhan),
            NgayThi = COALESCE(@NgayThi, NgayThi),
            gioThi = COALESCE(@GioThi, gioThi),
            maPhong = COALESCE(@MaPhong, maPhong),
            phongHoc = COALESCE(@PhongHoc, phongHoc),
            hinhThucThi = COALESCE(@HinhThucThi, hinhThucThi),
            GiamThi = COALESCE(@GiamThi, GiamThi)
        WHERE maLichThi = @MaLichThi;
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Xóa lịch thi
CREATE PROCEDURE sp_XoaLichThi
    @MaLichThi NVARCHAR(10),
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM LichThi WHERE maLichThi = @MaLichThi)
        BEGIN
            SET @Result = 1; -- Mã lịch thi không tồn tại
            RETURN;
        END
        DELETE FROM LichThi WHERE maLichThi = @MaLichThi;
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Lấy tất cả lịch thi
CREATE PROCEDURE sp_GetAllLichThi
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT maLichThi, MaLopPhan, NgayThi, gioThi, maPhong, phongHoc, hinhThucThi, GiamThi
        FROM LichThi
        ORDER BY NgayThi DESC, gioThi;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi lấy dữ liệu Lịch thi: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO

-- Tìm kiếm lịch thi
CREATE PROCEDURE sp_SearchLichThi
    @MaLichThi NVARCHAR(10) = NULL,
    @MaLopPhan NVARCHAR(10) = NULL,
    @NgayThi DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT maLichThi, MaLopPhan, NgayThi, gioThi, maPhong, phongHoc, hinhThucThi, GiamThi
        FROM LichThi
        WHERE (@MaLichThi IS NULL OR maLichThi LIKE '%' + @MaLichThi + '%')
          AND (@MaLopPhan IS NULL OR MaLopPhan = @MaLopPhan)
          AND (@NgayThi IS NULL OR NgayThi = @NgayThi)
        ORDER BY NgayThi DESC;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi tìm kiếm Lịch thi: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO

-- ============================================
-- PROCEDURES CHO BẢNG PHÒNG HỌC
-- ============================================
-- Thêm phòng học
CREATE PROCEDURE sp_ThemPhongHoc
    @MaPhongHoc NVARCHAR(10),
    @TenPhong NVARCHAR(50),
    @SucChua INT = NULL,
    @TrangThai NVARCHAR(20) = NULL,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM PhongHoc WHERE maPhongHoc = @MaPhongHoc)
        BEGIN
            SET @Result = 1; -- Mã phòng đã tồn tại
            RETURN;
        END
        INSERT INTO PhongHoc (maPhongHoc, TenPhong, sucChua, trangThai)
        VALUES (@MaPhongHoc, @TenPhong, @SucChua, @TrangThai);
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Sửa phòng học
CREATE PROCEDURE sp_SuaPhongHoc
    @MaPhongHoc NVARCHAR(10),
    @TenPhong NVARCHAR(50) = NULL,
    @SucChua INT = NULL,
    @TrangThai NVARCHAR(20) = NULL,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM PhongHoc WHERE maPhongHoc = @MaPhongHoc)
        BEGIN
            SET @Result = 1; -- Mã phòng không tồn tại
            RETURN;
        END
        UPDATE PhongHoc
        SET
            TenPhong = COALESCE(@TenPhong, TenPhong),
            sucChua = COALESCE(@SucChua, sucChua),
            trangThai = COALESCE(@TrangThai, trangThai)
        WHERE maPhongHoc = @MaPhongHoc;
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Xóa phòng học
CREATE PROCEDURE sp_XoaPhongHoc
    @MaPhongHoc NVARCHAR(10),
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM PhongHoc WHERE maPhongHoc = @MaPhongHoc)
        BEGIN
            SET @Result = 1; -- Mã phòng không tồn tại
            RETURN;
        END
        DELETE FROM PhongHoc WHERE maPhongHoc = @MaPhongHoc;
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Lấy tất cả phòng học
CREATE PROCEDURE sp_GetAllPhongHoc
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT maPhongHoc, TenPhong, sucChua, trangThai
        FROM PhongHoc
        ORDER BY maPhongHoc;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi lấy dữ liệu Phòng học: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO

-- Tìm kiếm phòng học
CREATE PROCEDURE sp_SearchPhongHoc
    @MaPhongHoc NVARCHAR(10) = NULL,
    @TenPhong NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT maPhongHoc, TenPhong, sucChua, trangThai
        FROM PhongHoc
        WHERE (@MaPhongHoc IS NULL OR maPhongHoc LIKE '%' + @MaPhongHoc + '%')
          AND (@TenPhong IS NULL OR TenPhong LIKE '%' + @TenPhong + '%')
        ORDER BY maPhongHoc;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi tìm kiếm Phòng học: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO

-- ============================================
-- PROCEDURES CHO BẢNG ĐĂNG KÝ HỌC PHẦN
-- ============================================
-- Thêm đăng ký học phần
CREATE PROCEDURE sp_ThemDangKyHocPhan
    @MaSV NVARCHAR(10),
    @MaLopHP NVARCHAR(10),
    @NgayDK DATE = NULL,
    @TrangThaiDK NVARCHAR(20) = NULL,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM SinhVien WHERE maSV = @MaSV)
        BEGIN
            SET @Result = 1; -- Sinh viên không tồn tại
            RETURN;
        END
        IF NOT EXISTS (SELECT 1 FROM LopHocPhan WHERE maLopHP = @MaLopHP)
        BEGIN
            SET @Result = 2; -- Lớp học phần không tồn tại
            RETURN;
        END
        IF EXISTS (SELECT 1 FROM DangKyHocPhan WHERE maSV = @MaSV AND maLopHP = @MaLopHP)
        BEGIN
            SET @Result = 3; -- Đã đăng ký học phần này rồi
            RETURN;
        END
        INSERT INTO DangKyHocPhan (maSV, maLopHP, ngayDK, TrangThaiDK)
        VALUES (@MaSV, @MaLopHP, @NgayDK, @TrangThaiDK);
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Sửa đăng ký học phần (chủ yếu cập nhật trạng thái)
CREATE PROCEDURE sp_SuaDangKyHocPhan
    @MaSV NVARCHAR(10),
    @MaLopHP NVARCHAR(10),
    @NgayDK DATE = NULL,
    @TrangThaiDK NVARCHAR(20) = NULL,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM DangKyHocPhan WHERE maSV = @MaSV AND maLopHP = @MaLopHP)
        BEGIN
            SET @Result = 1; -- Bản ghi đăng ký không tồn tại
            RETURN;
        END
        UPDATE DangKyHocPhan
        SET
            ngayDK = COALESCE(@NgayDK, ngayDK),
            TrangThaiDK = COALESCE(@TrangThaiDK, TrangThaiDK)
        WHERE maSV = @MaSV AND maLopHP = @MaLopHP;
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Xóa đăng ký học phần
CREATE PROCEDURE sp_XoaDangKyHocPhan
    @MaSV NVARCHAR(10),
    @MaLopHP NVARCHAR(10),
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM DangKyHocPhan WHERE maSV = @MaSV AND maLopHP = @MaLopHP)
        BEGIN
            SET @Result = 1; -- Bản ghi đăng ký không tồn tại
            RETURN;
        END
        DELETE FROM DangKyHocPhan WHERE maSV = @MaSV AND maLopHP = @MaLopHP;
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Lấy tất cả đăng ký học phần
CREATE PROCEDURE sp_GetAllDangKyHocPhan
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT maSV, maLopHP, ngayDK, TrangThaiDK
        FROM DangKyHocPhan
        ORDER BY maSV, maLopHP;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi lấy dữ liệu Đăng ký học phần: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO

-- Tìm kiếm đăng ký học phần
CREATE PROCEDURE sp_SearchDangKyHocPhan
    @MaSV NVARCHAR(10) = NULL,
    @MaLopHP NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT maSV, maLopHP, ngayDK, TrangThaiDK
        FROM DangKyHocPhan
        WHERE (@MaSV IS NULL OR maSV = @MaSV)
          AND (@MaLopHP IS NULL OR maLopHP = @MaLopHP)
        ORDER BY maSV, maLopHP;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi tìm kiếm Đăng ký học phần: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO

-- ============================================
-- PROCEDURES CHO BẢNG ĐẦU ĐIỂM
-- ============================================
-- Thêm đầu điểm
CREATE PROCEDURE sp_ThemDauDiem
    @MaDD NVARCHAR(10),
    @TenDD NVARCHAR(50),
    @HeSoDiem FLOAT = NULL,
    @LoaiDiem NVARCHAR(50) = NULL,
    @MoTa NVARCHAR(200) = NULL,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM DauDiem WHERE MaDD = @MaDD)
        BEGIN
            SET @Result = 1; -- Mã đầu điểm đã tồn tại
            RETURN;
        END
        INSERT INTO DauDiem (MaDD, TenDD, HeSoDiem, loaiDiem, moTa)
        VALUES (@MaDD, @TenDD, @HeSoDiem, @LoaiDiem, @MoTa);
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Sửa đầu điểm
CREATE PROCEDURE sp_SuaDauDiem
    @MaDD NVARCHAR(10),
    @TenDD NVARCHAR(50) = NULL,
    @HeSoDiem FLOAT = NULL,
    @LoaiDiem NVARCHAR(50) = NULL,
    @MoTa NVARCHAR(200) = NULL,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM DauDiem WHERE MaDD = @MaDD)
        BEGIN
            SET @Result = 1; -- Mã đầu điểm không tồn tại
            RETURN;
        END
        UPDATE DauDiem
        SET
            TenDD = COALESCE(@TenDD, TenDD),
            HeSoDiem = COALESCE(@HeSoDiem, HeSoDiem),
            loaiDiem = COALESCE(@LoaiDiem, loaiDiem),
            moTa = COALESCE(@MoTa, moTa)
        WHERE MaDD = @MaDD;
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Xóa đầu điểm
CREATE PROCEDURE sp_XoaDauDiem
    @MaDD NVARCHAR(10),
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM DauDiem WHERE MaDD = @MaDD)
        BEGIN
            SET @Result = 1; -- Mã đầu điểm không tồn tại
            RETURN;
        END
        DELETE FROM DauDiem WHERE MaDD = @MaDD;
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Lấy tất cả đầu điểm
CREATE PROCEDURE sp_GetAllDauDiem
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT MaDD, TenDD, HeSoDiem, loaiDiem, moTa
        FROM DauDiem
        ORDER BY MaDD;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi lấy dữ liệu Đầu điểm: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO

-- Tìm kiếm đầu điểm
CREATE PROCEDURE sp_SearchDauDiem
    @MaDD NVARCHAR(10) = NULL,
    @TenDD NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT MaDD, TenDD, HeSoDiem, loaiDiem, moTa
        FROM DauDiem
        WHERE (@MaDD IS NULL OR MaDD LIKE '%' + @MaDD + '%')
          AND (@TenDD IS NULL OR TenDD LIKE '%' + @TenDD + '%')
        ORDER BY MaDD;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi tìm kiếm Đầu điểm: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO

-- ============================================
-- PROCEDURES CHO BẢNG BẢNG ĐIỂM
-- ============================================
-- Thêm điểm chi tiết
CREATE PROCEDURE sp_ThemBangDiem
    @MaBD NVARCHAR(10),
    @MaSinhVien NVARCHAR(10),
    @MaMonHoc NVARCHAR(10),
    @MaLopHP NVARCHAR(10) = NULL,
    @MaDD NVARCHAR(10),
    @Diem FLOAT,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM BangDiem WHERE MaBD = @MaBD)
        BEGIN
            SET @Result = 1; -- Mã bảng điểm đã tồn tại
            RETURN;
        END
        IF NOT EXISTS (SELECT 1 FROM SinhVien WHERE maSV = @MaSinhVien)
        BEGIN
            SET @Result = 2; -- Sinh viên không tồn tại
            RETURN;
        END
        IF NOT EXISTS (SELECT 1 FROM MonHoc WHERE maMonHoc = @MaMonHoc)
        BEGIN
            SET @Result = 3; -- Môn học không tồn tại
            RETURN;
        END
        IF @MaLopHP IS NOT NULL AND NOT EXISTS (SELECT 1 FROM LopHocPhan WHERE maLopHP = @MaLopHP)
        BEGIN
            SET @Result = 4; -- Lớp học phần không tồn tại
            RETURN;
        END
        IF NOT EXISTS (SELECT 1 FROM DauDiem WHERE MaDD = @MaDD)
        BEGIN
            SET @Result = 5; -- Đầu điểm không tồn tại
            RETURN;
        END
        INSERT INTO BangDiem (MaBD, MaSinhVien, MaMonHoc, maLopHP, MaDD, Diem)
        VALUES (@MaBD, @MaSinhVien, @MaMonHoc, @MaLopHP, @MaDD, @Diem);
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Sửa điểm chi tiết
CREATE PROCEDURE sp_SuaBangDiem
    @MaBD NVARCHAR(10),
    @MaSinhVien NVARCHAR(10) = NULL,
    @MaMonHoc NVARCHAR(10) = NULL,
    @MaLopHP NVARCHAR(10) = NULL,
    @MaDD NVARCHAR(10) = NULL,
    @Diem FLOAT = NULL,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM BangDiem WHERE MaBD = @MaBD)
        BEGIN
            SET @Result = 1; -- Mã bảng điểm không tồn tại
            RETURN;
        END
        IF @MaSinhVien IS NOT NULL AND NOT EXISTS (SELECT 1 FROM SinhVien WHERE maSV = @MaSinhVien)
        BEGIN
            SET @Result = 2; -- Sinh viên không tồn tại
            RETURN;
        END
        IF @MaMonHoc IS NOT NULL AND NOT EXISTS (SELECT 1 FROM MonHoc WHERE maMonHoc = @MaMonHoc)
        BEGIN
            SET @Result = 3; -- Môn học không tồn tại
            RETURN;
        END
        IF @MaLopHP IS NOT NULL AND NOT EXISTS (SELECT 1 FROM LopHocPhan WHERE maLopHP = @MaLopHP)
        BEGIN
            SET @Result = 4; -- Lớp học phần không tồn tại
            RETURN;
        END
        IF @MaDD IS NOT NULL AND NOT EXISTS (SELECT 1 FROM DauDiem WHERE MaDD = @MaDD)
        BEGIN
            SET @Result = 5; -- Đầu điểm không tồn tại
            RETURN;
        END
        UPDATE BangDiem
        SET
            MaSinhVien = COALESCE(@MaSinhVien, MaSinhVien),
            MaMonHoc = COALESCE(@MaMonHoc, MaMonHoc),
            maLopHP = COALESCE(@MaLopHP, maLopHP),
            MaDD = COALESCE(@MaDD, MaDD),
            Diem = COALESCE(@Diem, Diem)
        WHERE MaBD = @MaBD;
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Xóa điểm chi tiết
CREATE PROCEDURE sp_XoaBangDiem
    @MaBD NVARCHAR(10),
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM BangDiem WHERE MaBD = @MaBD)
        BEGIN
            SET @Result = 1; -- Mã bảng điểm không tồn tại
            RETURN;
        END
        DELETE FROM BangDiem WHERE MaBD = @MaBD;
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Lấy tất cả bảng điểm
CREATE PROCEDURE sp_GetAllBangDiem
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT MaBD, MaSinhVien, MaMonHoc, maLopHP, MaDD, Diem
        FROM BangDiem
        ORDER BY MaSinhVien, MaMonHoc, MaDD;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi lấy dữ liệu Bảng điểm: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO

-- Tìm kiếm bảng điểm
CREATE PROCEDURE sp_SearchBangDiem
    @MaSinhVien NVARCHAR(10) = NULL,
    @MaMonHoc NVARCHAR(10) = NULL,
    @MaLopHP NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT MaBD, MaSinhVien, MaMonHoc, maLopHP, MaDD, Diem
        FROM BangDiem
        WHERE (@MaSinhVien IS NULL OR MaSinhVien = @MaSinhVien)
          AND (@MaMonHoc IS NULL OR MaMonHoc = @MaMonHoc)
          AND (@MaLopHP IS NULL OR maLopHP = @MaLopHP)
        ORDER BY MaSinhVien, MaMonHoc;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi tìm kiếm Bảng điểm: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO

-- ============================================
-- PROCEDURES CHO BẢNG ĐIỂM DANH
-- ============================================
-- Thêm điểm danh
CREATE PROCEDURE sp_ThemDiemDanh
    @MaDiemDanh NVARCHAR(10),
    @NgayDiemDanh DATE,
    @MaSinhVien NVARCHAR(10),
    @MaLichHoc NVARCHAR(10),
    @TrangThai NVARCHAR(20) = NULL,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM DiemDanh WHERE maDiemDanh = @MaDiemDanh)
        BEGIN
            SET @Result = 1; -- Mã điểm danh đã tồn tại
            RETURN;
        END
        IF NOT EXISTS (SELECT 1 FROM SinhVien WHERE maSV = @MaSinhVien)
        BEGIN
            SET @Result = 2; -- Sinh viên không tồn tại
            RETURN;
        END
        IF NOT EXISTS (SELECT 1 FROM LichHoc WHERE maLichHoc = @MaLichHoc)
        BEGIN
            SET @Result = 3; -- Lịch học không tồn tại
            RETURN;
        END
        INSERT INTO DiemDanh (maDiemDanh, NgayDiemDanh, maSinhVien, maLichHoc, trangThai)
        VALUES (@MaDiemDanh, @NgayDiemDanh, @MaSinhVien, @MaLichHoc, @TrangThai);
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Sửa điểm danh
CREATE PROCEDURE sp_SuaDiemDanh
    @MaDiemDanh NVARCHAR(10),
    @NgayDiemDanh DATE = NULL,
    @MaSinhVien NVARCHAR(10) = NULL,
    @MaLichHoc NVARCHAR(10) = NULL,
    @TrangThai NVARCHAR(20) = NULL,
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM DiemDanh WHERE maDiemDanh = @MaDiemDanh)
        BEGIN
            SET @Result = 1; -- Mã điểm danh không tồn tại
            RETURN;
        END
        IF @MaSinhVien IS NOT NULL AND NOT EXISTS (SELECT 1 FROM SinhVien WHERE maSV = @MaSinhVien)
        BEGIN
            SET @Result = 2; -- Sinh viên không tồn tại
            RETURN;
        END
        IF @MaLichHoc IS NOT NULL AND NOT EXISTS (SELECT 1 FROM LichHoc WHERE maLichHoc = @MaLichHoc)
        BEGIN
            SET @Result = 3; -- Lịch học không tồn tại
            RETURN;
        END
        UPDATE DiemDanh
        SET
            NgayDiemDanh = COALESCE(@NgayDiemDanh, NgayDiemDanh),
            maSinhVien = COALESCE(@MaSinhVien, maSinhVien),
            maLichHoc = COALESCE(@MaLichHoc, maLichHoc),
            trangThai = COALESCE(@TrangThai, trangThai)
        WHERE maDiemDanh = @MaDiemDanh;
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Xóa điểm danh
CREATE PROCEDURE sp_XoaDiemDanh
    @MaDiemDanh NVARCHAR(10),
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Result = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM DiemDanh WHERE maDiemDanh = @MaDiemDanh)
        BEGIN
            SET @Result = 1; -- Mã điểm danh không tồn tại
            RETURN;
        END
        DELETE FROM DiemDanh WHERE maDiemDanh = @MaDiemDanh;
        SET @Result = 0;
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_NUMBER();
    END CATCH
END
GO

-- Lấy tất cả điểm danh
CREATE PROCEDURE sp_GetAllDiemDanh
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT maDiemDanh, NgayDiemDanh, maSinhVien, maLichHoc, trangThai
        FROM DiemDanh
        ORDER BY NgayDiemDanh DESC, maSinhVien;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi lấy dữ liệu Điểm danh: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO

-- Tìm kiếm điểm danh
CREATE PROCEDURE sp_SearchDiemDanh
    @MaSinhVien NVARCHAR(10) = NULL,
    @MaLichHoc NVARCHAR(10) = NULL,
    @NgayDiemDanh DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT maDiemDanh, NgayDiemDanh, maSinhVien, maLichHoc, trangThai
        FROM DiemDanh
        WHERE (@MaSinhVien IS NULL OR maSinhVien = @MaSinhVien)
          AND (@MaLichHoc IS NULL OR maLichHoc = @MaLichHoc)
          AND (@NgayDiemDanh IS NULL OR NgayDiemDanh = @NgayDiemDanh)
        ORDER BY NgayDiemDanh DESC;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Lỗi khi tìm kiếm Điểm danh: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO
PRINT N'=== TẠO THÀNH CÔNG 7 STORED PROCEDURES CHO BẢNG KHOA ==='