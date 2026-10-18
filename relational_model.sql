-- =====================================================================
-- BÀI THỰC HÀNH: CHUYỂN ĐỔI ERD SANG MÔ HÌNH DỮ LIỆU QUAN HỆ
-- FILE: relational_model.sql
-- HỆ QUẢN TRỊ CSDL: MySQL / MariaDB
-- =====================================================================

DROP DATABASE IF EXISTS quan_ly_vat_tu;
CREATE DATABASE quan_ly_vat_tu CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE quan_ly_vat_tu;

-- ---------------------------------------------------------------------
-- 1. BẢNG THỰC THỂ: NHACC (Nhà cung cấp)
-- ---------------------------------------------------------------------
CREATE TABLE NHACC (
    MaNCC VARCHAR(20) NOT NULL PRIMARY KEY,
    TenNCC VARCHAR(150) NOT NULL,
    DiaChi VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 2. BẢNG THUỘC TÍNH ĐA TRỊ: NHACC_SDT (Số điện thoại nhà cung cấp)
-- Tách thuộc tính đa trị SDT của NHACC thành bảng riêng để đạt chuẩn 1NF
-- ---------------------------------------------------------------------
CREATE TABLE NHACC_SDT (
    MaNCC VARCHAR(20) NOT NULL,
    SDT VARCHAR(20) NOT NULL,
    PRIMARY KEY (MaNCC, SDT),
    CONSTRAINT fk_sdt_nhacc FOREIGN KEY (MaNCC) 
        REFERENCES NHACC(MaNCC) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 3. BẢNG THỰC THỂ: VATTU (Danh mục vật tư)
-- ---------------------------------------------------------------------
CREATE TABLE VATTU (
    MaVT VARCHAR(20) NOT NULL PRIMARY KEY,
    TenVT VARCHAR(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 4. BẢNG THỰC THỂ: DONDH (Đơn đặt hàng - Quan hệ 1-N với NHACC)
-- ---------------------------------------------------------------------
CREATE TABLE DONDH (
    SoDH VARCHAR(20) NOT NULL PRIMARY KEY,
    NgayDH DATE NOT NULL,
    MaNCC VARCHAR(20) NOT NULL,
    CONSTRAINT fk_dondh_nhacc FOREIGN KEY (MaNCC) 
        REFERENCES NHACC(MaNCC) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 5. BẢNG THỰC THỂ: PHIEUNHAP (Phiếu nhập kho - Theo đơn đặt hàng)
-- ---------------------------------------------------------------------
CREATE TABLE PHIEUNHAP (
    SoPN VARCHAR(20) NOT NULL PRIMARY KEY,
    NgayNhap DATE NOT NULL,
    SoDH VARCHAR(20) NOT NULL,
    CONSTRAINT fk_phieunhap_dondh FOREIGN KEY (SoDH) 
        REFERENCES DONDH(SoDH) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 6. BẢNG THỰC THỂ: PHIEUXUAT (Phiếu xuất kho)
-- ---------------------------------------------------------------------
CREATE TABLE PHIEUXUAT (
    SoPX VARCHAR(20) NOT NULL PRIMARY KEY,
    NgayXuat DATE NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 7. BẢNG QUAN HỆ TRUNG GIAN: ChiTietDonDatHang (DONDH <-> VATTU : n-m)
-- ---------------------------------------------------------------------
CREATE TABLE ChiTietDonDatHang (
    SoDH VARCHAR(20) NOT NULL,
    MaVT VARCHAR(20) NOT NULL,
    PRIMARY KEY (SoDH, MaVT),
    CONSTRAINT fk_ctddh_dondh FOREIGN KEY (SoDH) 
        REFERENCES DONDH(SoDH) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_ctddh_vattu FOREIGN KEY (MaVT) 
        REFERENCES VATTU(MaVT) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 8. BẢNG QUAN HỆ TRUNG GIAN: ChiTietPhieuNhap (PHIEUNHAP <-> VATTU : n-m)
-- Mang theo 2 thuộc tính của quan hệ: DGNhap, SLNhap
-- ---------------------------------------------------------------------
CREATE TABLE ChiTietPhieuNhap (
    SoPN VARCHAR(20) NOT NULL,
    MaVT VARCHAR(20) NOT NULL,
    DGNhap DECIMAL(15, 2) NOT NULL CHECK (DGNhap >= 0),
    SLNhap INT NOT NULL CHECK (SLNhap > 0),
    PRIMARY KEY (SoPN, MaVT),
    CONSTRAINT fk_ctpn_phieunhap FOREIGN KEY (SoPN) 
        REFERENCES PHIEUNHAP(SoPN) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_ctpn_vattu FOREIGN KEY (MaVT) 
        REFERENCES VATTU(MaVT) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 9. BẢNG QUAN HỆ TRUNG GIAN: ChiTietPhieuXuat (PHIEUXUAT <-> VATTU : n-m)
-- Mang theo 2 thuộc tính của quan hệ: DGXuat, SLXuat
-- ---------------------------------------------------------------------
CREATE TABLE ChiTietPhieuXuat (
    SoPX VARCHAR(20) NOT NULL,
    MaVT VARCHAR(20) NOT NULL,
    DGXuat DECIMAL(15, 2) NOT NULL CHECK (DGXuat >= 0),
    SLXuat INT NOT NULL CHECK (SLXuat > 0),
    PRIMARY KEY (SoPX, MaVT),
    CONSTRAINT fk_ctpx_phieuxuat FOREIGN KEY (SoPX) 
        REFERENCES PHIEUXUAT(SoPX) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_ctpx_vattu FOREIGN KEY (MaVT) 
        REFERENCES VATTU(MaVT) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =====================================================================
-- PHẦN DỮ LIỆU THỬ NGHIỆM VÀ TRUY VẤN KIỂM TRA
-- =====================================================================

-- 1. Thêm Nhà cung cấp
INSERT INTO NHACC (MaNCC, TenNCC, DiaChi) VALUES
('NCC01', 'Công ty Cổ phần Thép Hòa Phát', 'Khu CN Phố Nối, Hưng Yên'),
('NCC02', 'Tổng Công ty Xi măng Vicem Hà Tiên', 'Quận 1, TP. Hồ Chí Minh'),
('NCC03', 'Công ty TNHH Nhựa Tiền Phong', 'An Dương, Hải Phòng');

-- 2. Thêm Số điện thoại đa trị (1 nhà cung cấp có nhiều số)
INSERT INTO NHACC_SDT (MaNCC, SDT) VALUES
('NCC01', '02431234567'),
('NCC01', '0912345678'),
('NCC02', '02839876543'),
('NCC02', '0987654321'),
('NCC03', '02253555777');

-- 3. Thêm Vật tư
INSERT INTO VATTU (MaVT, TenVT) VALUES
('VT01', 'Thép phi 10 xây dựng (Cây 11.7m)'),
('VT02', 'Xi măng Pooc-lăng PCB40 (Bao 50kg)'),
('VT03', 'Ống nhựa uPVC D90 (Cây 4m)'),
('VT04', 'Cát vàng xây dựng hạt lớn (m3)');

-- 4. Thêm Đơn đặt hàng
INSERT INTO DONDH (SoDH, NgayDH, MaNCC) VALUES
('DH01', '2026-10-01', 'NCC01'),
('DH02', '2026-10-05', 'NCC02'),
('DH03', '2026-10-10', 'NCC03');

-- 5. Chi tiết Đơn đặt hàng
INSERT INTO ChiTietDonDatHang (SoDH, MaVT) VALUES
('DH01', 'VT01'),
('DH01', 'VT02'),
('DH02', 'VT02'),
('DH03', 'VT03');

-- 6. Phiếu nhập (Nhập theo đơn đặt hàng)
INSERT INTO PHIEUNHAP (SoPN, NgayNhap, SoDH) VALUES
('PN01', '2026-10-03', 'DH01'),
('PN02', '2026-10-07', 'DH02');

-- 7. Chi tiết Phiếu nhập
INSERT INTO ChiTietPhieuNhap (SoPN, MaVT, DGNhap, SLNhap) VALUES
('PN01', 'VT01', 115000.00, 500),
('PN01', 'VT02', 85000.00, 300),
('PN02', 'VT02', 84000.00, 400);

-- 8. Phiếu xuất
INSERT INTO PHIEUXUAT (SoPX, NgayXuat) VALUES
('PX01', '2026-10-12'),
('PX02', '2026-10-15');

-- 9. Chi tiết Phiếu xuất
INSERT INTO ChiTietPhieuXuat (SoPX, MaVT, DGXuat, SLXuat) VALUES
('PX01', 'VT01', 130000.00, 200),
('PX01', 'VT02', 95000.00, 150),
('PX02', 'VT02', 96000.00, 100);

-- ---------------------------------------------------------------------
-- TRUY VẤN MẪU KIỂM TRA MÔ HÌNH QUAN HỆ
-- ---------------------------------------------------------------------

-- 1. Xem danh sách nhà cung cấp kèm danh sách số điện thoại (GROUP_CONCAT)
SELECT 
    ncc.MaNCC AS 'Mã NCC',
    ncc.TenNCC AS 'Tên Nhà Cung Cấp',
    ncc.DiaChi AS 'Địa Chỉ',
    GROUP_CONCAT(sdt.SDT SEPARATOR ' | ') AS 'Các số điện thoại'
FROM NHACC ncc
LEFT JOIN NHACC_SDT sdt ON ncc.MaNCC = sdt.MaNCC
GROUP BY ncc.MaNCC, ncc.TenNCC, ncc.DiaChi;

-- 2. Thống kê chi tiết các mặt hàng xuất kho và tổng tiền xuất
SELECT 
    px.SoPX AS 'Số Phiếu Xuất',
    px.NgayXuat AS 'Ngày Xuất',
    vt.MaVT AS 'Mã VT',
    vt.TenVT AS 'Tên Vật Tư',
    ct.SLXuat AS 'Số Lượng Xuất',
    ct.DGXuat AS 'Đơn Giá Xuất',
    (ct.SLXuat * ct.DGXuat) AS 'Thành Tiền (VND)'
FROM PHIEUXUAT px
JOIN ChiTietPhieuXuat ct ON px.SoPX = ct.SoPX
JOIN VATTU vt ON ct.MaVT = vt.MaVT
ORDER BY px.SoPX, vt.MaVT;
