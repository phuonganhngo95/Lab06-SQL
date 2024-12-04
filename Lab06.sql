use master
go

use Lab06
go

-- Bài 1
-- 1.
create procedure spud_LayDanhsachVATTU
as
begin
	select * from VATTU
	order by TenVTu ASC
end
go

-- 2.
create procedure spud_LayDanhsach_NHACC
	@mancc char(3) null
as
begin
	if @mancc is null
	begin
		select * from NHACC
	end
	else
	begin
		select * from NHACC
		where MaNCC = @mancc
	end
end
go

-- 3.
create procedure spud_PXUAT_BcaoPxuat
	@sopn char(4) null
as
begin
	if @sopn is null
	begin
		select PX.*, CT.*, VT.TenVTu
		from PXUAT PX
		inner join CTPXUAT CT on PX.SoPx = CT.SoPx
		inner join VATTU VT on CT.Mavtu = VT.Mavtu
	end
	else 
	begin
		select PX.*, CT.*, VT.TenVTu
		from PXUAT PX
		inner join CTPXUAT CT on PX.SoPx = CT.SoPx
		inner join VATTU VT on CT.Mavtu = VT.Mavtu
		where PX.SoPx = @sopn
	end
end
go

-- 4.
create procedure spud_PNHAP_BcaoPNhap
	@Sopn char(4) null
as
begin
	if @Sopn is null
	begin
		select PN.SoPn, PN.NgayNhap, CT.Mavtu, CT.SLNhap, VT.TenVTu
		from PNHAP PN
		inner join CTPNHAP CT on PN.SoPn = CT.SoPn
		inner join VATTU VT on CT.Mavtu = VT.Mavtu
	end
	else
	begin
		select PN.SoPn, PN.NgayNhap, CT.Mavtu, CT.SLNhap, VT.TenVTu
		from PNHAP PN
		inner join CTPNHAP CT on PN.SoPn = CT.SoPn
		inner join VATTU VT on CT.Mavtu = VT.Mavtu
		where PN.SoPn = @Sopn
	end
end
go

-- 5.
create procedure spud_TONKHO_BcaoTonKho
	@namthang char(6)
as
begin
	select TK.*, VT.TenVTu
	from TONKHO TK
	inner join VATTU VT on TK.Mavtu = VT.Mavtu
	where TK.NamThang = @namthang
end

-- Bài 2
-- 1.
create procedure spud_VATTU_Them
    @mavtu char(4),
    @tenvtu nvarchar(100),
    @dvtinh nvarchar(10),
    @phantram real
as
begin
    if exists (select 1 from VATTU where Mavtu = @mavtu)
    begin
        print N'Mã vật tư đã tồn tại'
        return
    end
    if exists (select 1 from VATTU where TenVTu = @tenvtu)
    begin
        print N'Tên vật tư đã tồn tại'
        return
    end
    if (@dvtinh = '')
    begin
        print N'Đơn vị tính không được để trống'
        return
    end
    if (@phantram < 0 or @phantram > 100)
    begin
        print N'Phần trăm phải nằm trong khoảng từ 0 đến 100'
        return
    end

    insert into VATTU (Mavtu, TenVTu, Dvtinh, PhanTram) values
	(@mavtu, @tenvtu, @dvtinh, @phantram)

    print N'Thêm dữ liệu thành công'
end
go

-- 2.
create procedure spud_VATTU_Xoa
	@mavtu char(4)
as
begin
	if not exists(select 1 from VATTU where Mavtu = @mavtu)
	begin
		print N'Mã vật tư không tồn tại'
		return
	end

	delete from VATTU where Mavtu = @mavtu
	print N'Xóa dữ liệu thành công'
end
go

-- 3.
create procedure spud_VATTU_Sua
	@mavtu char(4),
    @tenvtu nvarchar(100),
    @dvtinh nvarchar(10),
    @phantram real
as
begin
	update VATTU
	set
		TenVTu = ISNULL(@tenvtu, TenVTu),
		Dvtinh = ISNULL(@dvtinh, Dvtinh),
		Phantram = ISNULL(@phantram, Phantram)
	where Mavtu = @mavtu
end
go

-- Bài 3
-- 1.
create procedure spud_DONDH_TinhThanhTien
	@sodh int,
	@mavtu int,
	@thanhtien money output
as
begin
	select @thanhtien = SoDH * Mavtu
	from CTDONDH
	where SoDH = @sodh and Mavtu = @mavtu
end
go

-- 2.
create procedure spud_PNHAP_TinhTongSLNHang
	@sodh int,
	@mavtu int,
	@tongsl int output
as
begin
	select @tongsl = SUM(SLNhap)
	from CTPNHAP CT
	inner join PNHAP PN on CT.SoPn = PN.SoPn
	where SoDH = @sodh and Mavtu = @mavtu
end
go

-- 3.
create procedure spud_TONKHO_TinhSLDau
	@namthang char(6),
	@mavtu int,
	@sldauki int output
as
begin
	select @sldauki = SLDau
	from TONKHO
	where NamThang = @namthang and Mavtu = @mavtu
end
go

-- 4.
create procedure spud_TONKHO_TinhTongNX
	@namthang char(6),
	@mavtu int,
	@tongslnhap int output,
	@tongslxuat int output
as
begin
	select @tongslnhap = SUM(CT.SLNhap)
	from CTPNHAP CT
	inner join PNHAP PN on CT.SoPn = PN.SoPn
	inner join VATTU VT on CT.Mavtu = VT.Mavtu
	inner join TONKHO TK on VT.Mavtu = TK.Mavtu
	where TK.NamThang = @namthang and VT.Mavtu = @mavtu

	select @tongslxuat = SUM(SLXuat)
	from CTPXUAT CTX
	inner join PXUAT PX on CTX.SoPx = PX.SoPx
	inner join VATTU VT on CTX.Mavtu = VT.Mavtu
	inner join TONKHO TK on VT.Mavtu = TK.Mavtu
	where TK.NamThang = @namthang and VT.Mavtu = @mavtu
end
go