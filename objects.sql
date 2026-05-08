-- ============================================================
--  VTYS-1 | objects.sql — View, Trigger, Index
-- ============================================================
USE YemekSiparisDB;
GO

-- ============================================================
-- VIEW 1: vw_AktifRestoranMenuleri
-- Amaç   : Aktif restoranların aktif ürünlerini kategoriyle göster
-- Kullanım: SELECT * FROM vw_AktifRestoranMenuleri WHERE Sehir='İstanbul'
-- ============================================================
CREATE OR ALTER VIEW vw_AktifRestoranMenuleri AS
SELECT
    r.RestoranID,
    r.RestoranAdi,
    r.Sehir,
    r.OrtalamaPuan,
    k.KategoriAdi,
    u.UrunID,
    u.UrunAdi,
    u.Fiyat
FROM Restoranlar r
INNER JOIN Urunler    u ON r.RestoranID  = u.RestoranID
INNER JOIN Kategoriler k ON u.KategoriID = k.KategoriID
WHERE r.IsActive = 1
  AND u.IsActive = 1;
GO

-- ============================================================
-- VIEW 2: vw_AskidaYemekHavuzDurumu
-- Amaç   : Havuz bakiyesi + toplam bağış/kullanım istatistiği
--          + her bağışçının adı (anonim ise 'Anonim Hayırsever')
-- Kullanım: SELECT * FROM vw_AskidaYemekHavuzDurumu
-- ============================================================
CREATE OR ALTER VIEW vw_AskidaYemekHavuzDurumu AS
SELECT
    h.HavuzID,
    h.MevcutBakiye,
    h.ToplamBagisTL,
    h.ToplamKullanimTL,
    h.GuncellemeTarihi,
    b.BagisID,
    b.BagisTutarTL,
    b.BagisTarihi,
    -- Anonim ise isim gizlenir
    CASE WHEN b.AnonimMi = 1 THEN 'Anonim Hayırsever'
         ELSE k.Ad + ' ' + k.Soyad
    END AS BagisciAdi
FROM AskidaYemekHavuzu h
LEFT JOIN AskidaBagislar  b ON h.HavuzID    = b.HavuzID
LEFT JOIN Kullanicilar    k ON b.KullaniciID = k.KullaniciID;
GO

-- ============================================================
-- VIEW 3 (BONUS): vw_SonSiparisler
-- Amaç   : Son 30 günün teslim edilmiş siparişleri + müşteri adı
-- ============================================================
CREATE OR ALTER VIEW vw_SonSiparisler AS
SELECT
    s.SiparisID,
    k.Ad + ' ' + k.Soyad  AS MusteriAdi,
    r.RestoranAdi,
    s.ToplamTutar,
    s.Durum,
    s.SiparisTarihi,
    s.AskidaMi
FROM Siparisler    s
INNER JOIN Kullanicilar k ON s.KullaniciID = k.KullaniciID
INNER JOIN Restoranlar  r ON s.RestoranID  = r.RestoranID
WHERE s.SiparisTarihi >= DATEADD(DAY, -30, GETDATE())
  AND s.IsActive = 1;
GO

-- ============================================================
-- TRIGGER 1: trg_SiparisTeslimCiroGuncelle
-- Amaç: Bir sipariş 'TeslimEdildi' statüsüne geçtiğinde
--       restoranın ToplamCiro alanını otomatik artır.
-- Tetikleme: Siparisler tablosunda UPDATE sonrası
-- ============================================================
CREATE OR ALTER TRIGGER trg_SiparisTeslimCiroGuncelle
ON Siparisler
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Sadece Durum 'TeslimEdildi' olan siparişler
    UPDATE Restoranlar
    SET ToplamCiro = ToplamCiro + i.ToplamTutar
    FROM Restoranlar r
    INNER JOIN inserted i ON r.RestoranID = i.RestoranID
    INNER JOIN deleted  d ON i.SiparisID  = d.SiparisID
    WHERE i.Durum = 'TeslimEdildi'
      AND d.Durum <> 'TeslimEdildi';  -- Sadece yeni TeslimEdildi geçişlerinde
END;
GO

-- ============================================================
-- TRIGGER 2: trg_AskidaKullanimBakiyeDus
-- Amaç: AskidaKullanimi tablosuna yeni satır eklendiğinde
--       AskidaYemekHavuzu.MevcutBakiye'yi otomatik düşür.
-- Tetikleme: AskidaKullanimi tablosunda INSERT sonrası
-- Güvenlik : Bakiye yetersizse işlemi geri al (ROLLBACK).
-- ============================================================
CREATE OR ALTER TRIGGER trg_AskidaKullanimBakiyeDus
ON AskidaKullanimi
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @kullanilanTutar DECIMAL(10,2);
    DECLARE @havuzID INT;
    DECLARE @mevcutBakiye DECIMAL(10,2);

    SELECT @kullanilanTutar = KullanilanTutarTL,
           @havuzID         = HavuzID
    FROM inserted;

    SELECT @mevcutBakiye = MevcutBakiye
    FROM AskidaYemekHavuzu
    WHERE HavuzID = @havuzID;

    -- Bakiye kontrolü
    IF @mevcutBakiye < @kullanilanTutar
    BEGIN
        RAISERROR('Askıda Yemek havuzunda yeterli bakiye yok!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- Bakiyeyi düş, kullanım toplamını artır
    UPDATE AskidaYemekHavuzu
    SET MevcutBakiye     = MevcutBakiye - @kullanilanTutar,
        ToplamKullanimTL = ToplamKullanimTL + @kullanilanTutar,
        GuncellemeTarihi = GETDATE()
    WHERE HavuzID = @havuzID;
END;
GO

-- ============================================================
-- TRIGGER 3 (BONUS): trg_AskidaBagisBakiyeArttir
-- Amaç: AskidaBagislar tablosuna yeni bağış eklendiğinde
--       havuz bakiyesini ve toplam bağış tutarını güncelle.
-- ============================================================
CREATE OR ALTER TRIGGER trg_AskidaBagisBakiyeArttir
ON AskidaBagislar
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE AskidaYemekHavuzu
    SET MevcutBakiye     = MevcutBakiye + i.BagisTutarTL,
        ToplamBagisTL    = ToplamBagisTL + i.BagisTutarTL,
        GuncellemeTarihi = GETDATE()
    FROM AskidaYemekHavuzu h
    INNER JOIN inserted i ON h.HavuzID = i.HavuzID;
END;
GO

-- ============================================================
-- İNDEKSLER — PK dışı, sık sorgulanan kolonlar
-- ============================================================

-- Index 1: Siparişleri KullaniciID'ye göre hızlı getir
-- (Kullanıcı "siparişlerim" sayfası için kritik)
CREATE NONCLUSTERED INDEX idx_Siparisler_KullaniciID
ON Siparisler(KullaniciID);
GO

-- Index 2: Siparişleri tarihe göre hızlı sırala/filtrele
-- (Analitik sorgularda sık kullanılır)
CREATE NONCLUSTERED INDEX idx_Siparisler_Tarih
ON Siparisler(SiparisTarihi DESC);
GO

-- Index 3 (BONUS): Ürünleri restorana göre hızlı filtrele
-- (Menü sayfası açılırken kullanılır)
CREATE NONCLUSTERED INDEX idx_Urunler_RestoranID
ON Urunler(RestoranID)
WHERE IsActive = 1;  -- Filtered index: sadece aktif ürünler
GO
