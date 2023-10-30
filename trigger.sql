USE QUANLYXEKHACH
GO

-------TRIGGER

---đặt trạng thái hóa đơn trực tiếp
CREATE TRIGGER set_HoaDon_TrangThai
ON HOA_DON
FOR INSERT
AS
BEGIN
UPDATE HOA_DON
    SET TrangThai = 'Chưa thanh toán'
    WHERE MaHD IN (SELECT MaHD FROM INSERTED)
END;


--- đặt trạng thái hóa đơn online
CREATE TRIGGER set_HoaDonUD_TrangThai
ON HOA_DON_UD
FOR INSERT
AS
BEGIN
UPDATE HOA_DON_UD
    SET TrangThaiUD = 'Chưa thanh toán'
    WHERE MaHDUD IN (SELECT MaHDUD FROM INSERTED)
END;


---thay đổi số lượng vé mỗi khi bán được
CREATE TRIGGER CapNhatSoLuongVeXe
ON ChiTietHD
AFTER INSERT 
AS
BEGIN
    DECLARE @MaVe nchar(10);
    DECLARE @SoLuongVeDaBan int;


    -- Lấy MaVe từ bản ghi vừa chèn vào ChiTietHD
    SELECT @MaVe = MaVe FROM INSERTED;


    -- Tính số lượng vé đã bán cho MaVe
    SELECT @SoLuongVeDaBan = COUNT(*) FROM ChiTietHD WHERE MaVe = @MaVe;


    -- Cập nhật số lượng vé xe trong bảng VE_XE
    UPDATE VE_XE
    SET TinhTrang = CASE
        WHEN (SoLuong - @SoLuongVeDaBan) > 0 THEN N'Còn vé'
        ELSE N'Hết vé'
        END
    WHERE MaVe = @MaVe;
END;


---thay đổi số lượng vé khi bán onl
CREATE TRIGGER CapNhatSoLuongVeXeOnl
ON ChiTietHD_UD
AFTER INSERT
AS
BEGIN
    DECLARE @MaVe nchar(10);
    DECLARE @SoLuongVeDaBanOnl int;
    -- Lấy MaVe từ bản ghi vừa chèn vào ChiTietHDUD
    SELECT @MaVe = MaVe FROM INSERTED;
    -- Tính số lượng vé đã bán cho MaVe
    SELECT @SoLuongVeDaBanOnl = COUNT(*) FROM ChiTietHD_UD WHERE MaVe = @MaVe;
    -- Cập nhật số lượng vé xe trong bảng VE_XE
    UPDATE VE_XE
    SET TinhTrang = CASE
        WHEN (SoLuong - @SoLuongVeDaBanOnl) > 0 THEN N'Còn vé'
        ELSE N'Hết vé'
        END
    WHERE MaVe = @MaVe;
END;


--- kt vé còn không
CREATE TRIGGER KiemTraVeTrenTuyen
ON VE_XE
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @SoLuongVeTrongTuyen INT;
   
    -- Lấy số lượng vé còn lại trong tuyến xe tương ứng
    SELECT @SoLuongVeTrongTuyen = COUNT(*)
    FROM VE_XE
    WHERE MaTuyenXe = (SELECT MaTuyenXe FROM INSERTED) AND TinhTrang = 'Chưa thanh toán';
   
    -- Kiểm tra xem số lượng vé còn lại có đủ không
    IF @SoLuongVeTrongTuyen <= 0
        BEGIN
            RAISERROR ('Tuyến xe đã hết vé.', 16, 1);
        END
    ELSE
    BEGIN
        -- Chèn bản ghi vào bảng VE_XE nếu có đủ vé
        INSERT INTO VE_XE (MaVe, MaTuyenXe, BienSoXe, TinhTrang, DonGia)
        SELECT MaVe, MaTuyenXe, BienSoXe, TinhTrang, DonGia
        FROM INSERTED;
    END
END


---kt KH có trùng sdt không
CREATE TRIGGER TG_TrungSDT
ON dbo.KHACH_HANG
AFTER INSERT, UPDATE
AS
BEGIN
    -- Kiểm tra số điện thoại vừa thêm có bị trùng lặp
    IF EXISTS (
        SELECT *
        FROM inserted i
        WHERE EXISTS (
            SELECT *
            FROM dbo.KHACH_HANG k
            WHERE k.SDT = i.SDT AND k.MaKH <> i.MaKH
        )
    )
    BEGIN
 -- Nếu trùng thì rollback
 --PRINT N'Số điện thoại đã tồn tại'
        ROLLBACK;
    END
END
