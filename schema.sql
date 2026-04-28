-- ============================================================
--  VTYS-1 Dönem Projesi: Çevrimiçi Yemek Sipariş Platformu
--  Dosya   : schema.sql
--  Amaç    : Veritabanı şeması (DDL) — tablolar, kısıtlamalar
--  Uyumluluk: Microsoft SQL Server (MSSQL)
-- ============================================================

-- Veritabanını oluştur ve seç
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'YemekSiparisDB')
    CREATE DATABASE YemekSiparisDB;
GO
USE YemekSiparisDB;
GO

-- ============================================================
-- 1. KULLANICILAR
--    Sistemdeki tüm kullanıcılar (müşteri ve ihtiyaç sahibi).
--    KullaniciTipi: 'Musteri' veya 'IhtiyacSahibi'
--    DogrulanmisMi: IhtiyacSahibi kullanıcılar için admin onayı
-- ============================================================
CREATE TABLE Kullanicilar (
    KullaniciID    INT           IDENTITY(1,1) PRIMARY KEY,
    Ad             NVARCHAR(50)  NOT NULL,
    Soyad          NVARCHAR(50)  NOT NULL,
    Eposta         NVARCHAR(100) NOT NULL UNIQUE,
    Telefon        NVARCHAR(15)  NOT NULL UNIQUE,
    SifreHash      NVARCHAR(256) NOT NULL,
    KullaniciTipi  NVARCHAR(20)  NOT NULL DEFAULT 'Musteri'
                   CONSTRAINT chk_KullaniciTipi
                   CHECK (KullaniciTipi IN ('Musteri', 'IhtiyacSahibi')),
    DogrulanmisMi  BIT           NOT NULL DEFAULT 0,  -- IhtiyacSahibi onayı
    KayitTarihi    DATETIME      NOT NULL DEFAULT GETDATE(),
    IsActive       BIT           NOT NULL DEFAULT 1   -- Soft Delete
);
GO

-- ============================================================
-- 2. ADRESLER
--    Kullanıcıların kayıtlı teslimat adresleri.
--    Bir kullanıcının birden fazla adresi olabilir (1:N).
-- ============================================================
CREATE TABLE Adresler (
    AdresID      INT           IDENTITY(1,1) PRIMARY KEY,
    KullaniciID  INT           NOT NULL
                 CONSTRAINT fk_Adresler_Kullanicilar
                 REFERENCES Kullanicilar(KullaniciID),
    AdresBasligi NVARCHAR(50)  NOT NULL,  -- 'Ev', 'İş' vb.
    AdresSatiri  NVARCHAR(200) NOT NULL,
    Ilce         NVARCHAR(50)  NOT NULL,
    Sehir        NVARCHAR(50)  NOT NULL,
    PostaKodu    NVARCHAR(10)  NULL,
    IsActive     BIT           NOT NULL DEFAULT 1
);
GO

-- ============================================================
-- 3. KATEGORILER
--    Ürün kategorileri: Pizza, Burger, Döner vb.
-- ============================================================
CREATE TABLE Kategoriler (
    KategoriID   INT          IDENTITY(1,1) PRIMARY KEY,
    KategoriAdi  NVARCHAR(50) NOT NULL UNIQUE,
    IsActive     BIT          NOT NULL DEFAULT 1
);
GO

-- ============================================================
-- 4. RESTORANLAR
--    Platforma kayıtlı restoranlar.
--    OrtalamaPuan: 1.0 ile 5.0 arasında CHECK kısıtlaması var.
--    ToplamCiro  : Teslim edilen siparişlerden güncellenir (Trigger).
-- ============================================================
CREATE TABLE Restoranlar (
    RestoranID     INT            IDENTITY(1,1) PRIMARY KEY,
    RestoranAdi    NVARCHAR(100)  NOT NULL,
    Telefon        NVARCHAR(15)   NOT NULL UNIQUE,
    Eposta         NVARCHAR(100)  NULL UNIQUE,
    Adres          NVARCHAR(200)  NOT NULL,
    Sehir          NVARCHAR(50)   NOT NULL,
    OrtalamaPuan   DECIMAL(3,2)   NOT NULL DEFAULT 0.00
                   CONSTRAINT chk_RestoranPuan
                   CHECK (OrtalamaPuan BETWEEN 0.00 AND 5.00),
    ToplamCiro     DECIMAL(12,2)  NOT NULL DEFAULT 0.00
                   CONSTRAINT chk_RestoranCiro
                   CHECK (ToplamCiro >= 0),
    AcilisYili     INT            NULL,
    IsActive       BIT            NOT NULL DEFAULT 1
);
GO

-- ============================================================
-- 5. URUNLER
--    Restoranların menüsündeki ürünler.
--    Fiyat > 0 CHECK kısıtlaması var.
--    IsActive = 0 → ürün menüden kaldırıldı (Soft Delete).
-- ============================================================
CREATE TABLE Urunler (
    UrunID       INT            IDENTITY(1,1) PRIMARY KEY,
    RestoranID   INT            NOT NULL
                 CONSTRAINT fk_Urunler_Restoranlar
                 REFERENCES Restoranlar(RestoranID),
    KategoriID   INT            NOT NULL
                 CONSTRAINT fk_Urunler_Kategoriler
                 REFERENCES Kategoriler(KategoriID),
    UrunAdi      NVARCHAR(100)  NOT NULL,
    Aciklama     NVARCHAR(300)  NULL,
    Fiyat        DECIMAL(8,2)   NOT NULL
                 CONSTRAINT chk_UrunFiyat
                 CHECK (Fiyat > 0),
    IsActive     BIT            NOT NULL DEFAULT 1
);
GO

-- ============================================================
-- 6. KURYELER
--    Teslimatçılar. Bir sipariş tek kuryeye atanır.
-- ============================================================
CREATE TABLE Kuryeler (
    KuryeID    INT          IDENTITY(1,1) PRIMARY KEY,
    Ad         NVARCHAR(50) NOT NULL,
    Soyad      NVARCHAR(50) NOT NULL,
    Telefon    NVARCHAR(15) NOT NULL UNIQUE,
    Plaka      NVARCHAR(10) NULL,
    IsActive   BIT          NOT NULL DEFAULT 1
);
GO

-- ============================================================
-- 7. SIPARISLER
--    Her sipariş tek müşteriye, tek restorana ve (atanırsa)
--    tek kuryeye aittir.
--    Durum: 'Beklemede','Hazirlaniyor','Yolda','TeslimEdildi','Iptal'
--    ToplamTutar >= 0 CHECK kısıtlaması var.
--    AskidaMi: Bu sipariş Askıda Yemek havuzundan mı finanse edildi?
-- ============================================================
CREATE TABLE Siparisler (
    SiparisID       INT            IDENTITY(1,1) PRIMARY KEY,
    KullaniciID     INT            NOT NULL
                    CONSTRAINT fk_Siparisler_Kullanicilar
                    REFERENCES Kullanicilar(KullaniciID),
    RestoranID      INT            NOT NULL
                    CONSTRAINT fk_Siparisler_Restoranlar
                    REFERENCES Restoranlar(RestoranID),
    AdresID         INT            NOT NULL
                    CONSTRAINT fk_Siparisler_Adresler
                    REFERENCES Adresler(AdresID),
    KuryeID         INT            NULL
                    CONSTRAINT fk_Siparisler_Kuryeler
                    REFERENCES Kuryeler(KuryeID),
    Durum           NVARCHAR(20)   NOT NULL DEFAULT 'Beklemede'
                    CONSTRAINT chk_SiparisDurum
                    CHECK (Durum IN ('Beklemede','Hazirlaniyor','Yolda','TeslimEdildi','Iptal')),
    ToplamTutar     DECIMAL(10,2)  NOT NULL DEFAULT 0.00
                    CONSTRAINT chk_SiparisTutar
                    CHECK (ToplamTutar >= 0),
    SiparisTarihi   DATETIME       NOT NULL DEFAULT GETDATE(),
    TeslimTarihi    DATETIME       NULL,
    AskidaMi        BIT            NOT NULL DEFAULT 0,
    IsActive        BIT            NOT NULL DEFAULT 1
);
GO

-- ============================================================
-- 8. SİPARİŞ DETAYLARI
--    Bir siparişin hangi ürünleri içerdiği ve miktarları.
--    Miktar >= 1, BirimFiyat > 0 CHECK kısıtlamaları var.
-- ============================================================
CREATE TABLE SiparisDetaylari (
    DetayID      INT           IDENTITY(1,1) PRIMARY KEY,
    SiparisID    INT           NOT NULL
                 CONSTRAINT fk_DetayAlar_Siparisler
                 REFERENCES Siparisler(SiparisID),
    UrunID       INT           NOT NULL
                 CONSTRAINT fk_DetayAlar_Urunler
                 REFERENCES Urunler(UrunID),
    Miktar       INT           NOT NULL DEFAULT 1
                 CONSTRAINT chk_DetayMiktar
                 CHECK (Miktar >= 1),
    BirimFiyat   DECIMAL(8,2)  NOT NULL
                 CONSTRAINT chk_DetayBirimFiyat
                 CHECK (BirimFiyat > 0)
);
GO

-- ============================================================
-- 9. ASKIDA YEMEK HAVUZU
--    Platformdaki tek (global) hayırseverlik havuzu.
--    MevcutBakiye: Trigger ile otomatik güncellenir.
-- ============================================================
CREATE TABLE AskidaYemekHavuzu (
    HavuzID            INT           IDENTITY(1,1) PRIMARY KEY,
    MevcutBakiye       DECIMAL(10,2) NOT NULL DEFAULT 0.00
                       CONSTRAINT chk_HavuzBakiye
                       CHECK (MevcutBakiye >= 0),
    ToplamBagisTL      DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    ToplamKullanimTL   DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    GuncellemeTarihi   DATETIME      NOT NULL DEFAULT GETDATE()
);
GO

-- İlk havuz satırını ekle (tek havuz)
INSERT INTO AskidaYemekHavuzu (MevcutBakiye, ToplamBagisTL, ToplamKullanimTL)
VALUES (0.00, 0.00, 0.00);
GO

-- ============================================================
-- 10. ASKIDA BAGISLAR
--     Müşterilerin havuza yaptığı bağışlar.
--     KullaniciID NULL olabilir → anonim bağış.
--     AnonimMi = 1 ise kimlik sorgularda gizlenir.
--     BagisTutarTL > 0 CHECK kısıtlaması var.
-- ============================================================
CREATE TABLE AskidaBagislar (
    BagisID        INT            IDENTITY(1,1) PRIMARY KEY,
    HavuzID        INT            NOT NULL DEFAULT 1
                   CONSTRAINT fk_Bagislar_Havuz
                   REFERENCES AskidaYemekHavuzu(HavuzID),
    KullaniciID    INT            NULL    -- NULL = anonim bağış
                   CONSTRAINT fk_Bagislar_Kullanicilar
                   REFERENCES Kullanicilar(KullaniciID),
    BagisTutarTL   DECIMAL(10,2)  NOT NULL
                   CONSTRAINT chk_BagisTutar
                   CHECK (BagisTutarTL > 0),
    AnonimMi       BIT            NOT NULL DEFAULT 0,
    BagisTarihi    DATETIME       NOT NULL DEFAULT GETDATE(),
    Aciklama       NVARCHAR(200)  NULL
);
GO

-- ============================================================
-- 11. ASKIDA KULLANIMI
--     İhtiyaç sahibi kullanıcıların havuzdan yaptığı kullanımlar.
--     Bir sipariş en fazla bir Askıda Yemek kullanımına bağlıdır.
--     KullanilanTutarTL > 0 CHECK kısıtlaması var.
-- ============================================================
CREATE TABLE AskidaKullanimi (
    KullanimID         INT           IDENTITY(1,1) PRIMARY KEY,
    HavuzID            INT           NOT NULL DEFAULT 1
                       CONSTRAINT fk_Kullanim_Havuz
                       REFERENCES AskidaYemekHavuzu(HavuzID),
    KullaniciID        INT           NOT NULL
                       CONSTRAINT fk_Kullanim_Kullanicilar
                       REFERENCES Kullanicilar(KullaniciID),
    SiparisID          INT           NOT NULL UNIQUE  -- Bir sipariş bir kez kullanılabilir
                       CONSTRAINT fk_Kullanim_Siparisler
                       REFERENCES Siparisler(SiparisID),
    KullanilanTutarTL  DECIMAL(10,2) NOT NULL
                       CONSTRAINT chk_KullanimTutar
                       CHECK (KullanilanTutarTL > 0),
    KullanimTarihi     DATETIME      NOT NULL DEFAULT GETDATE()
);
GO

-- ============================================================
-- TABLO ÖZETİ
-- Kullanicilar       → platform kullanıcıları
-- Adresler           → kullanıcı teslimat adresleri
-- Kategoriler        → ürün kategorileri
-- Restoranlar        → platforma kayıtlı restoranlar
-- Urunler            → restoran menü ürünleri
-- Kuryeler           → teslimat kuryeler
-- Siparisler         → verilen siparişler
-- SiparisDetaylari   → sipariş satır kalemleri
-- AskidaYemekHavuzu  → global hayırseverlik havuzu
-- AskidaBagislar     → havuza yapılan bağışlar
-- AskidaKullanimi    → havuzdan yapılan kullanımlar
-- ============================================================
