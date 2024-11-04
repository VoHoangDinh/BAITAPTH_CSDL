﻿IF EXISTS (SELECT * FROM sys.databases WHERE name = N'THCSDL_NHOM1')
	BEGIN
		USE master
		ALTER database THCSDL_NHOM1 set single_user with rollback immediate
		DROP DATABASE THCSDL_NHOM1;
	END
create database THCSDL_NHOM1
go
use [THCSDL_NHOM1]
-- tạo bảng KHACHHANG
create table KHACHHANG
(
	MAKHACHHANG char(6) not null Primary key,
	TENCONGTY nvarchar(50) null,
	TENGIAODICH nvarchar(50) not null,
	DIACHI nvarchar(90) null,
	EMAIL varchar(50),
	DIENTHOAI varchar(11),
	FAX varchar(10),
	unique(DIENTHOAI, EMAIL, FAX)
)
-- tạo bảng NHANVIEN
CREATE TABLE NHANVIEN (
    MANHANVIEN CHAR(6) PRIMARY KEY NOT NULL,
    HO NVARCHAR(25) NOT NULL,
    TEN NVARCHAR(25) NOT NULL,
    NGAYSINH DATE CHECK (NGAYSINH < GETDATE()),
    NGAYLAMVIEC DATE CHECK (NGAYLAMVIEC <= GETDATE()),
						CHECK(NGAYSINH <= NGAYLAMVIEC),
    DIACHI NVARCHAR(90) NULL,
    DIENTHOAI VARCHAR(11) UNIQUE,
    LUONGCOBAN MONEY CHECK (LUONGCOBAN > 0),
    PHUCAP MONEY CHECK (PHUCAP >= 0) 
)
-- tạo bảng DONDATHANG
create table DONDATHANG
(
	SOHOADON char(6) primary key NOT NULL,
	MAKHACHHANG char(6) not null,
	MANHANVIEN char(6) not null,
	NGAYDATHANG date DEFAULT GETDATE(),
	NGAYGIAOHANG date,
	NGAYCHUYENHANG date,
	NOIGIAOHANG nvarchar(90) NULL,
	foreign key (MAKHACHHANG) references KhachHang(MAKHACHHANG)
		ON DELETE
			CASCADE
		ON UPDATE
			CASCADE,
	foreign key (MANHANVIEN) references NHANVIEN(MANHANVIEN)
		ON DELETE
			CASCADE
		ON UPDATE
			CASCADE
)
-- tạo bảng LOAIHANG
create table LOAIHANG
(
	MALOAIHANG char(6) primary key,
	TENLOAIHANG nvarchar(50) not null
)
-- Tạo Bảng NHACUNGCAP
CREATE TABLE NHACUNGCAP
(
	MACONGTY	CHAR(6)	PRIMARY KEY NOT NULL,
	TENCONGTY	NVARCHAR(50)	NOT NULL,
	TENGIAODICH	NVARCHAR(50)	NOT NULL,
	DIACHI	nVARCHAR(90) NOT NULL,
	DIENTHOAI	VARCHAR(11)	UNIQUE NULL,
	FAX	VARCHAR(10)	UNIQUE NULL,
	EMAIL	VARCHAR(50)	UNIQUE NULL
)
-- tạo bảng MATHANG
CREATE TABLE MATHANG (
    MAHANG CHAR(6) PRIMARY KEY NOT NULL,
    TENHANG NVARCHAR(50) NOT NULL,
    MACONGTY CHAR(6), 
    MALOAIHANG CHAR(6) NOT NULL,              
    SOLUONG INT CHECK (SOLUONG>=0),              
    DONVITINH NVARCHAR(50),   
    GIAHANG MONEY CHECK(GIAHANG>=0),
    FOREIGN KEY (MACONGTY) REFERENCES NHACUNGCAP(MACONGTY)
		ON DELETE
			CASCADE
		ON UPDATE
			CASCADE,
    FOREIGN KEY (MALOAIHANG) REFERENCES LOAIHANG(MALOAIHANG)
		ON DELETE
			CASCADE
		ON UPDATE
			CASCADE,
);

--Tạo bảng CHITIETDATHANG
CREATE TABLE CHITIETDATHANG
(
	SOHOADON	CHAR(6) NOT NULL
		FOREIGN KEY (SOHOADON) REFERENCES DONDATHANG(SOHOADON)
			ON DELETE 
				CASCADE
			ON UPDATE
				CASCADE,
	MAHANG	CHAR(6) NOT NULL
		FOREIGN KEY (MAHANG) REFERENCES MATHANG(MAHANG)
			ON DELETE 
				CASCADE
			ON UPDATE
				CASCADE,
	PRIMARY KEY(MAHANG,SOHOADON),
	GIABAN	MONEY NULL CHECK(GIABAN>=0),
	SOLUONG	INT NULL CHECK(SOLUONG>=0),
	MUCGIAMGIA	MONEY NULL CHECK(MUCGIAMGIA>=0)
)
-- câu 2:Bổ sung ràng buộc thiết lập giá trị mặc định bằng 1 cho cột SOLUONG  và bằng 0 cho cột MUCGIAMGIA trong bảng CHITIETDATHANG

ALTER TABLE CHITIETDATHANG
	ADD CONSTRAINT DF_CHITIETDATHANG_SOLUONG
		DEFAULT 1 FOR SOLUONG,
	CONSTRAINT DF_CHITIETDATHANG_MUCGIAMGIA
		DEFAULT 0 FOR MUCGIAMGIA
-- Câu 3: kiểm tra ngày giao hàng và ngày chuyển hàng phải sau hoặc bằng với ngày đặt hàng
ALTER TABLE DONDATHANG
	ADD CONSTRAINT CK_DONDATHANG_NGAYGIAOHANG 
		check(NGAYGIAOHANG >= NGAYDATHANG),
	CONSTRAINT CK_DONDATHANG_NGAYCHUYENHANG 
		check(NGAYCHUYENHANG >= NGAYDATHANG)
-- Câu 4: Bổ sung ràng buộc cho bảng NHANVIEN để đảm bảo rằng một nhân viên chỉ có thể làm việc trong công ty khi đủ 18 tuổi và không quá 60 tuổi.
ALTER TABLE NHANVIEN
	ADD CONSTRAINT CK_TUOINHANVIEN 
		CHECK (DATEDIFF(YEAR, NGAYSINH, NGAYLAMVIEC) >= 18 AND 
				DATEDIFF(YEAR, NGAYSINH, NGAYLAMVIEC) <= 60);
ALTER TABLE KHACHHANG
	ADD CONSTRAINT CK_KHACHHANG_DIENTHOAI CHECK(DIENTHOAI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
									OR DIENTHOAI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
		CONSTRAINT CK_KHACHANG_FAX CHECK (FAX not like '%[^0-9]%'),
		CONSTRAINT CK_KHACHHANG_Email CHECK (Email like '[a-z]%@%_')
ALTER TABLE NHACUNGCAP
	ADD CONSTRAINT CK_NHACUNGCAP_DIENTHOAI CHECK(DIENTHOAI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
									OR DIENTHOAI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
		CONSTRAINT CK_NHACUNGCAP_FAX CHECK (FAX not like '%[^0-9]%'),
		CONSTRAINT CK_NHACUNGCAP_Email CHECK (Email like '[a-z]%@%_')
ALTER TABLE NHANVIEN
	ADD CONSTRAINT CK_NHANVIEN_DIENTHOAI CHECK(DIENTHOAI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
									OR DIENTHOAI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
ALTER TABLE MATHANG
	ADD CONSTRAINT DF_MATHANG_DONVITINH DEFAULT N'Cái' FOR DONVITINH
INSERT INTO KHACHHANG (MAKHACHHANG, TENCONGTY, TENGIAODICH, DIACHI, EMAIL, DIENTHOAI, FAX)
VALUES
    ('KH0001', N'CÔNG TY A', N'GIAO DỊCH 1', N'26_NGUYỄN HỮU THỌ', 'NGUYENVANA@GMAIL.COM', '0123456789', '1234132123'),
    ('KH0002', NULL, N'GIAO DỊCH 2', N'26_NGUYỄN HỮU THỌ', 'NGUYENVANB@GMAIL.COM', '0123456780', '1234132120'),
    ('KH0003', N'CÔNG TY C', N'GIAO DỊCH 3', N'26_NGUYỄN HỮU THỌ', 'NGUYENVANC@GMAIL.COM', '0123456790', '1234132124'),
    ('KH0004', NULL, N'GIAO DỊCH 4', N'26_NGUYỄN HỮU THỌ', 'NGUYENVAND@GMAIL.COM', '0123456700', '1234132125'),
    ('KH0005', N'CÔNG TY R', N'GIAO DỊCH 5', N'26_NGUYỄN HỮU THỌ', 'NGUYENVANE@GMAIL.COM', '0123456711', '1234132126'),
    ('KH0006', NULL, N'GIAO DỊCH 6', N'26_NGUYỄN HỮU THỌ', 'NGUYENVANF@GMAIL.COM', '0123456722', '1234132127'),
    ('KH0007', NULL, N'GIAO DỊCH 7', N'26_NGUYỄN HỮU THỌ', 'NGUYENVANG@GMAIL.COM', '0123456733', '1234135221'),
    ('KH0008', NULL, N'GIAO DỊCH 8', N'26_NGUYỄN HỮU THỌ', 'NGUYENVANH@GMAIL.COM', '0123456744', '1234132129'),
    ('KH0009', NULL, N'GIAO DỊCH 9', N'26_NGUYỄN HỮU THỌ', 'NGUYENVANK@GMAIL.COM', '0123456755', '1234122130'),
    ('KH0010', N'CÔNG TY P', N'GIAO DỊCH 10', N'26_NGUYỄN HỮU THỌ', 'NGUYENVALA@GMAIL.COM', '0123456766', '1231322131');
SET DATEFORMAT ymd
INSERT INTO NHANVIEN (MANHANVIEN, HO, TEN, NGAYSINH, NGAYLAMVIEC, DIACHI, DIENTHOAI, LUONGCOBAN, PHUCAP)
VALUES
    ('NV0001', N'Trần', N'An', '1990-01-15', GETDATE(), N'123 Đường A', '0123456789', 5000000, 1000000),
    ('NV0002', N'Nguyễn', N'Bình', '1985-06-20', GETDATE(), N'456 Đường B', '0123456790', 6000000, 1200000),
    ('NV0003', N'Lê', N'Cường', '1992-03-05', GETDATE(), N'789 Đường C', '0123456701', 5500000, 1100000),
    ('NV0004', N'Phạm', N'Duy', '1988-09-12', GETDATE(), N'101 Đường D', '0123456712', 5800000, 900000),
    ('NV0005', N'Võ', N'Em', '1995-12-01', GETDATE(), N'202 Đường E', '0123456723', 5200000, 950000),
    ('NV0006', N'Đinh', N'Phúc', '1980-08-30', GETDATE(), N'303 Đường F', '0123456734', 7000000, 1500000),
    ('NV0007', N'Tô', N'Quốc', '1993-04-25', GETDATE(), N'404 Đường G', '0123456745', 5900000, 1300000),
    ('NV0008', N'Hồ', N'Tuấn', '1987-11-15', GETDATE(), N'505 Đường H', '0123456756', 6400000, 1250000),
    ('NV0009', N'Ngô', N'Văn', '1991-07-19', GETDATE(), N'606 Đường I', '0123456767', 5300000, 1000000),
    ('NV0010', N'Bùi', N'Giang', '1989-02-22', GETDATE(), N'707 Đường J', '0123456778', 6600000, 1150000);
SET DATEFORMAT ymd
INSERT INTO DONDATHANG (SOHOADON, MAKHACHHANG, MANHANVIEN, NGAYDATHANG, NGAYGIAOHANG, NGAYCHUYENHANG, NOIGIAOHANG)
VALUES
    ('HD0001', 'KH0001', 'NV0001', GETDATE(), DATEADD(DAY, 3, GETDATE()), DATEADD(DAY, 4, GETDATE()), N'Địa điểm giao hàng A'),
    ('HD0002', 'KH0002', 'NV0002', GETDATE(), DATEADD(DAY, 5, GETDATE()), null, N'Địa điểm giao hàng B'),
    ('HD0003', 'KH0003', 'NV0001', GETDATE(), DATEADD(DAY, 2, GETDATE()), DATEADD(DAY, 3, GETDATE()), N'Địa điểm giao hàng C'),
	('HD0004', 'KH0004', 'NV0003', GETDATE(), DATEADD(DAY, 2, GETDATE()), DATEADD(DAY, 3, GETDATE()), N'Địa điểm giao hàng D'),
    ('HD0005', 'KH0005', 'NV0005', GETDATE(), DATEADD(DAY, 1, GETDATE()), DATEADD(DAY, 2, GETDATE()), N'Địa điểm giao hàng E'),
    ('HD0006', 'KH0006', 'NV0004', GETDATE(), DATEADD(DAY, 4, GETDATE()), DATEADD(DAY, 5, GETDATE()), null),
    ('HD0007', 'KH0007', 'NV0007', GETDATE(), DATEADD(DAY, 3, GETDATE()), DATEADD(DAY, 4, GETDATE()), N'Địa điểm giao hàng G'),
    ('HD0008', 'KH0008', 'NV0006', GETDATE(), DATEADD(DAY, 5, GETDATE()), DATEADD(DAY, 6, GETDATE()),null),
    ('HD0009', 'KH0009', 'NV0008', GETDATE(), DATEADD(DAY, 2, GETDATE()), DATEADD(DAY, 3, GETDATE()), N'Địa điểm giao hàng I'),
    ('HD0010', 'KH0010', 'NV0009', GETDATE(), DATEADD(DAY, 4, GETDATE()), null, N'Địa điểm giao hàng J');
INSERT INTO NHACUNGCAP (MACONGTY, TENCONGTY, TENGIAODICH, DIACHI, EMAIL, DIENTHOAI, FAX)
VALUES
    ('CT0001', N'CÔNG TY VINAMILK', N'GIAO DỊCH 1', N'26_NGUYỄN VĂN LINH', 'CONTYA@GMAIL.COM', '0128456789', '1934132123'),
    ('CT0002', N'CÔNG TY B', N'GIAO DỊCH 2', N'26_NGUYỄN VĂN LINH', 'CONTYB@GMAIL.COM', '0128456780', '1934132120'),
    ('CT0003', N'CÔNG TY C', N'GIAO DỊCH 3', N'26_NGUYỄN VĂN LINH', 'CONTYC@GMAIL.COM', '0128456790', '1934132124'),
    ('CT0004', N'CÔNG TY D', N'GIAO DỊCH 4', N'26_NGUYỄN VĂN LINH', 'CONTYD@GMAIL.COM', '0128456700', '1934132125'),
    ('CT0005', N'CÔNG TY R', N'GIAO DỊCH 5', N'26_NGUYỄN VĂN LINH', 'CONTYE@GMAIL.COM', '0128456711', '1934132126'),
    ('CT0006', N'CÔNG TY T', N'GIAO DỊCH 6', N'26_NGUYỄN VĂN LINH', 'CONTYF@GMAIL.COM', '0128456722', '194132127'),
    ('CT0007', N'CÔNG TY K', N'GIAO DỊCH 7', N'26_NGUYỄN VĂN LINH', 'CONTYG@GMAIL.COM', '0128456733', '1934135221'),
    ('CT0008', N'CÔNG TY M', N'GIAO DỊCH 8', N'26_NGUYỄN VĂN LINH', 'CONTYH@GMAIL.COM', '0128456744', '1934132129'),
    ('CT0009', N'CÔNG TY O', N'GIAO DỊCH 9', N'26_NGUYỄN VĂN LINH', 'CONTYK@GMAIL.COM', '0128456755', '1934122130'),
    ('CT0010', N'CÔNG TY VINAMILK', N'GIAO DỊCH 10', N'26_NGUYỄN VĂN LINH', 'CONTYP@GMAIL.COM', '0128456766', '1931322131');
INSERT INTO LOAIHANG (MALOAIHANG, TENLOAIHANG)
VALUES ('LH0001', N'Điện thoại'),
		('LH0002', N'Máy tính'),
		('LH0003', N'Balo'),
		('LH0004', N'Sách'),
		('LH0005', N'Vở'),
		('LH0006', N'Bàn'),
		('LH0007', N'Ghế'),
		('LH0008', N'Đồ gia dụng'),
		('LH0009', N'Tủ lạnh'),
		('LH0010', N'Tivi');
INSERT INTO MATHANG(MAHANG, TENHANG, MACONGTY, MALOAIHANG, SOLUONG, DONVITINH, GIAHANG)
VALUES ('MH0001', N'iPhone 16', 'CT0001', 'LH0001', 400, N'Cái', 160000000),
		('MH0002', N'Tivi SONY', 'CT0003', 'LH0010', 100, N'Cái', 8000000),
		('MH0003', N'Ghế nhựa', 'CT0009', 'LH0007', 100, N'Cái', 900000),
		('MH0004', N'Tủ lạng', 'CT0002', 'LH0009', 100, N'Cái', 40000000),
		('MH0005', N'Máy tính Dell', 'CT0005', 'LH0002', 200, N'Cái', 36000000),
		('MH0006', N'Vở', 'CT0001', 'LH0005', 500, N'Cuốn', 200000),
		('MH0007', N'Sách', 'CT0010', 'LH0004', 500, N'Cuốn', 1000000),
		('MH0008', N'Bàn nhựa', 'CT0005', 'LH0006', 500, N'Cái', 3500000),
		('MH0009', N'Nồi cơm điện', 'CT0002', 'LH0008', 100, N'Cái', 4500000),
		('MH0010', N'MacBook', 'CT0002', 'LH0002', 100, N'Cái', 36000000);
INSERT INTO CHITIETDATHANG (SOHOADON,MAHANG,SOLUONG,GIABAN,MUCGIAMGIA)
VALUES ('HD0001', 'MH0001', 20, 7000000, default),
		('HD0002', 'MH0001', 3, 6000000, default),
		('HD0003', 'MH0002', 400, 300000, default),
		('HD0002', 'MH0002', 50, 400000, default),
		('HD0001', 'MH0005', 100, 5000000, default),
		('HD0006', 'MH0005', 2, 700000, default),
		('HD0007', 'MH0001', 10, 900000, default),
		('HD0007', 'MH0003', 5, 200000, default),
		('HD0009', 'MH0007', 100, 10000,default),
		('HD0010', 'MH0006', 9, 80000,default);	
--Tuan8---------------
--Câu a:Cập nhật lại giá trị trường NGAYCHUYENHANG của những bản ghi có NGAYCHUYENHANG chưa xác định (NULL) trong bảng DONDATHANG bằng với giá trị của trường NGAYDATHANG.
update DONDATHANG
set NGAYCHUYENHANG = NGAYDATHANG
where NGAYCHUYENHANG IS NULL
select *
from DONDATHANG 
--Câu b:Tăng số lượng hàng của những mặt hàng do công ty VINAMILK cung cấp lên gấp đôi
update MATHANG
set SOLUONG = SOLUONG*2
from NHACUNGCAP 
where NHACUNGCAP.MACONGTY = MATHANG.MACONGTY
and TENCONGTY = N'CÔNG TY VINAMILK'
select *
from MATHANG
--Câu c:Cập nhật giá trị của trường NOIGIAOHANG trong bảng DONDATHANG bằng địa chỉ của khách hàng đối với những đơn đặt hàng chưa xác định được nơi giao hàng (giá trị trường NOIGIAOHANG bằng NULL).
UPDATE DONDATHANG 
SET NOIGIAOHANG = KH.DIACHI
FROM DONDATHANG DDH
JOIN KHACHHANG KH ON DDH.MAKHACHHANG = KH.MAKHACHHANG
WHERE DDH.NOIGIAOHANG IS NULL;
select *
from DONDATHANG