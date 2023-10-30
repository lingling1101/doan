use QUANLYXEKHACH
go

--- bảng công việc
CREATE TABLE CONG_VIEC(
    MaCV nchar(20) CONSTRAINT PK_CONG_VIEC PRIMARY KEY,
    TenCV nchar(10) NOT NULL,
    Luong float CHECK (Luong > 0)
)

---bảng ca làm việc
CREATE TABLE CA_LAM_VIEC(
    MaCa nchar(20),
    NgayLam date check (DATEDIFF(day, NgayLam, GETDATE())>=0),
    GioBatDau nchar(10),
    GioKetThuc nchar(10),
    CONSTRAINT PK_CaLamViec PRIMARY KEY (MaCa, NgayLam)
)

--bảng nhân viên
CREATE TABLE NHAN_VIEN(
    MaNV nchar(20) CONSTRAINT PK_NHAN_VIEN PRIMARY KEY,
    HoNV nchar(10) NOT NULL,
    TenNV nchar(10) NOT NULL,
    NgaySinh date check (DATEDIFF(year, NgaySinh, GETDATE())>=18),
    GioiTinh nvarchar(4),
    DiaChi nvarchar(100),
    SDT nchar(11) CHECK (len(SDT)=10),
    SoCa int,
    TroCap int,
    NgayTuyenDung date check (DATEDIFF(day, NgayTuyenDung, GETDATE())>0)
)

---bảng thực hiện công việc
CREATE TABLE ThucHien(
    MaNV nchar(20) CONSTRAINT FK_ThucHien_NV FOREIGN KEY REFERENCES NHAN_VIEN(MaNV),
    MaCV nchar(20) CONSTRAINT FK_ThucHien_CV FOREIGN KEY REFERENCES CONG_VIEC(MaCV),
    CONSTRAINT PK_ThucHien PRIMARY KEY (MaCV, MaNV)
)

---bảng phân công công việc
CREATE TABLE PhanCong(
    MaCa nchar(20),
    NgayLam date check (DATEDIFF(day, NgayLam, GETDATE())>=0),
    MaNV nchar(20) CONSTRAINT FK_PhanCong_NV FOREIGN KEY REFERENCES NHAN_VIEN(MaNV),
    CONSTRAINT FK_PhanCong_CaLamViec FOREIGN KEY (MaCa,NgayLam) REFERENCES CA_LAM_VIEC(MaCa, NgayLam),
    CONSTRAINT PK_PhanCong PRIMARY KEY (MaCa, MaNV, NgayLam)
)

---bảng khách hàng 
CREATE TABLE KHACH_HANG(
    MaKH nchar(20) CONSTRAINT PK_KHACH_HANG PRIMARY KEY,
    SDT nchar(11) CHECK (len(SDT)=10),
    TenKH nchar(20) NOT NULL
)

---bảng hóa đơn
CREATE TABLE HOA_DON(
    MaHD nchar(20) CONSTRAINT PK_HOA_DON PRIMARY KEY,
    MaKH nchar(20) CONSTRAINT FK_HoaDon_KH FOREIGN KEY REFERENCES KHACH_HANG(MaKH),
    MaNV nchar(20) CONSTRAINT FK_HoaDon_NV FOREIGN KEY REFERENCES NHAN_VIEN(MaNV),
    NgayLap date check (DATEDIFF(day, NgayLap, GETDATE())>=0),
    Gia int NOT NULL,
    TrangThai VARCHAR(20) NOT NULL CHECK (TrangThai IN ('Thanh toán', 'Chưa thanh toán'))
)

---bảng hóa đơn ứng dụng
CREATE TABLE HOA_DON_UD(
    MaHDUD nchar(20) CONSTRAINT PK_HoaDonUD PRIMARY KEY,
    NgayLap date check (DATEDIFF(day, NgayLap, GETDATE())>=0),
    MaNV nchar(20) CONSTRAINT FK_HoaDonUD_NV FOREIGN KEY REFERENCES NHAN_VIEN(MaNV),
    Gia int NOT NULL,
    TrangThaiUD VARCHAR(20) NOT NULL CHECK (TrangThaiUD IN ('Thanh toán', 'Chưa thanh toán'))
)

---bảng chi phí xe
CREATE TABLE CHI_PHI_XE(
    MaChiPhi nchar(20) CONSTRAINT PK_CHI_PHI_XE PRIMARY KEY,
    LoaiPhi nchar(10) NOT NULL,
    ChiPhi float NOT NULL
)

---bảng xe
CREATE TABLE XE(
    BienSoXe nchar(20) CONSTRAINT PK_XE PRIMARY KEY,
    SoLuongGhe int check (SoLuongGhe > 0)
)

---bảng phát sinh chi phí
CREATE TABLE PhatSinh(
    MaChiPhi nchar(20) CONSTRAINT FK_PhatSinh_ChiPhi FOREIGN KEY REFERENCES CHI_PHI_XE(MaChiPhi),
    BienSoXe nchar(20) CONSTRAINT FK_PhatSinh_Xe FOREIGN KEY REFERENCES Xe(BienSoXe),
    NgayPS date check (DATEDIFF(day, NgayPS, GETDATE())>=0),
    CONSTRAINT PK_PhatSinh PRIMARY KEY (MaChiPhi, BienSoXe)
)

---bảng tuyến xe
CREATE TABLE TUYEN_XE(
    MaTuyenXe nvarchar(20) CONSTRAINT PK_TUYEN_XE PRIMARY KEY ,
	TenTuyen nvarchar(30) NOT NULL,
    TGXuatPhat nvarchar(10) NOT NULL,
    DiemDi nvarchar(20)  NOT NULL,
    TGDen nvarchar(10) NOT NULL,
    DiemDen nvarchar(20) NOT NULL,
    
  
)

---bảng chi tiết tuyến xe
CREATE TABLE ChiTietTX(
    MaTuyenXe nvarchar(20) CONSTRAINT FK_ChiTietTX_TuyenXe FOREIGN KEY REFERENCES TUYEN_XE(MaTuyenXe),
    BienSoXe nchar(20) CONSTRAINT FK_ChiTietTX_Xe FOREIGN KEY REFERENCES Xe(BienSoXe),
    CONSTRAINT PK_ChiTietTX PRIMARY KEY (MaTuyenXe, BienSoXe)
)

---bảng vé xe
-- Sửa bảng "VE_XE" và đặt MaVe, BienSoXe và MaTuyenXe làm các ràng buộc duy nhất
CREATE TABLE VE_XE (
    MaVe nchar(20) NOT NULL,
	MaTuyenXe nvarchar(20),
    BienSoXe nchar(20) NOT NULL,
    SoLuong int NOT NULL,
	DonGia float NOT NULL,
    TinhTrang nchar(20) DEFAULT N'Hết Vé',       
    CONSTRAINT FK_TuyenXe_Xe FOREIGN KEY (MaTuyenXe) REFERENCES TUYEN_XE(MaTuyenXe),
    CONSTRAINT FK_VeXe_BienSoXe FOREIGN KEY (BienSoXe) REFERENCES XE(BienSoXe),
	PRIMARY KEY( MaVe, MaTuyenXe, BienSoXe),
);




---bảng chi tiết hóa đơn

CREATE TABLE ChiTietHD(
    MaHD nchar(20) CONSTRAINT FK_ChiTietHD_HoaDon FOREIGN KEY REFERENCES HOA_DON(MaHD),
    MaVe nchar(20),
    SoLuong int check (SoLuong >0),
	DonGia float NOT NULL,
	TongTien float NOT NULL,
    CONSTRAINT PK_ChiTietHD PRIMARY KEY (MaHD, MaVe)
)


---bảng chi tiết hóa đơn ứng dụng
CREATE TABLE ChiTietHD_UD(
    MaHDUD nchar(20) CONSTRAINT FK_ChiTietHDUD_HoaDonUD FOREIGN KEY REFERENCES HOA_DON_UD(MaHDUD),
    MaVe nchar(20) ,
    SoLuong int check (SoLuong>0),
    DonGia float NOT NULL,
    TongTien float NOT NULL,
    CONSTRAINT PK_ChiTietHDUD PRIMARY KEY (MaHDUD, MaVe)
)
