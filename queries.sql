-- ============================================================
--  VTYS-1 | queries.sql — İleri Düzey Analitik Sorgular
-- ============================================================
USE YemekSiparisDB;
GO

-- ============================================================
-- SORGU 1: SİPARİŞ FİŞİ (JOIN — 5 tablo)
-- Amaç   : Belirli bir siparişin tüm detaylarını tek sorguda göster.
--          Müşteri adı, restoran, ürünler, kurye bilgisi.
-- Tablolar: Siparisler + SiparisDetaylari + Urunler
--           + Kullanicilar + Restoranlar + Kuryeler
-- ============================================================
-- Tüm siparişlerin fişini getir (son 7 günün teslim edilmişleri)
SELECT
    s.SiparisID,
    s.SiparisTarihi,
    k.Ad + ' ' + k.Soyad                       AS MusteriAdi,
    k.Telefon                                   AS MusteriTelefon,
    r.RestoranAdi,
    u.UrunAdi,
    sd.Miktar,
    sd.BirimFiyat,
    sd.Miktar * sd.BirimFiyat                   AS KalemToplami,
    s.ToplamTutar,
    s.Durum,
    ISNULL(ky.Ad + ' ' + ky.Soyad, 'Atanmadı') AS KuryeAdi,
    CASE WHEN s.AskidaMi = 1
         THEN 'Askıda Yemek ile Ödendi'
         ELSE 'Normal Ödeme'
    END                                         AS OdemeTipi
FROM Siparisler        s
INNER JOIN Kullanicilar   k  ON s.KullaniciID = k.KullaniciID
INNER JOIN Restoranlar    r  ON s.RestoranID  = r.RestoranID
INNER JOIN SiparisDetaylari sd ON s.SiparisID = sd.SiparisID
INNER JOIN Urunler        u  ON sd.UrunID     = u.UrunID
LEFT  JOIN Kuryeler       ky ON s.KuryeID     = ky.KuryeID
WHERE s.SiparisTarihi >= DATEADD(DAY, -7, GETDATE())
ORDER BY s.SiparisID, sd.DetayID;
GO

-- ============================================================
-- SORGU 2: AGREGASYON — Son 30 Günde 5+ Sipariş Alan Restoranlar
-- Amaç   : Son 1 ayda en az 5 sipariş alan restoranların
--          sipariş sayısını ve ortalama sepet tutarını listele.
-- Fonksiyonlar: COUNT, AVG, SUM — GROUP BY + HAVING
-- ============================================================
SELECT
    r.RestoranAdi,
    r.Sehir,
    COUNT(s.SiparisID)    AS ToplamSiparisSayisi,
    AVG(s.ToplamTutar)    AS OrtalamaSepetiTL,
    SUM(s.ToplamTutar)    AS ToplamCiroTL,
    r.OrtalamaPuan
FROM Restoranlar  r
INNER JOIN Siparisler s ON r.RestoranID = s.RestoranID
WHERE s.SiparisTarihi >= DATEADD(MONTH, -1, GETDATE())
  AND s.Durum <> 'Iptal'
  AND r.IsActive = 1
GROUP BY r.RestoranID, r.RestoranAdi, r.Sehir, r.OrtalamaPuan
HAVING COUNT(s.SiparisID) >= 5
ORDER BY ToplamCiroTL DESC;
GO

-- ============================================================
-- SORGU 3: AGREGASYON — En Çok Satan 10 Ürün
-- Amaç   : Tüm zamanların en çok sipariş edilen ürünleri.
-- ============================================================
SELECT TOP 10
    u.UrunAdi,
    r.RestoranAdi,
    k.KategoriAdi,
    SUM(sd.Miktar)                          AS ToplamSatisAdedi,
    SUM(sd.Miktar * sd.BirimFiyat)          AS ToplamGelirTL
FROM SiparisDetaylari sd
INNER JOIN Urunler     u ON sd.UrunID     = u.UrunID
INNER JOIN Restoranlar r ON u.RestoranID  = r.RestoranID
INNER JOIN Kategoriler k ON u.KategoriID  = k.KategoriID
GROUP BY u.UrunID, u.UrunAdi, r.RestoranAdi, k.KategoriAdi
ORDER BY ToplamSatisAdedi DESC;
GO

-- ============================================================
-- SORGU 4: ALT SORGU — Hiç Askıda Yemek Bağışı Yapmamış
--          ama Aktif Kullanan Müşteriler  (NOT EXISTS)
-- Amaç   : Platformu kullanan ama bağışa katılmamış müşterileri bul.
-- ============================================================
SELECT
    k.KullaniciID,
    k.Ad + ' ' + k.Soyad AS MusteriAdi,
    k.Eposta,
    COUNT(s.SiparisID)   AS ToplamSiparisSayisi
FROM Kullanicilar k
INNER JOIN Siparisler s ON k.KullaniciID = s.KullaniciID
WHERE k.IsActive       = 1
  AND k.KullaniciTipi  = 'Musteri'
  AND NOT EXISTS (
      SELECT 1
      FROM AskidaBagislar ab
      WHERE ab.KullaniciID = k.KullaniciID
  )
GROUP BY k.KullaniciID, k.Ad, k.Soyad, k.Eposta
ORDER BY ToplamSiparisSayisi DESC;
GO

-- ============================================================
-- SORGU 5: ALT SORGU — Son 1 Haftada Askıda Yemek Kullananlar
-- Amaç   : Savunmada sorulabilecek örnek sorgu.
-- ============================================================
SELECT
    k.Ad + ' ' + k.Soyad  AS IhtiyacSahibiAdi,
    ak.KullanimTarihi,
    ak.KullanilanTutarTL,
    s.ToplamTutar,
    r.RestoranAdi
FROM AskidaKullanimi ak
INNER JOIN Kullanicilar k ON ak.KullaniciID = k.KullaniciID
INNER JOIN Siparisler   s ON ak.SiparisID   = s.SiparisID
INNER JOIN Restoranlar  r ON s.RestoranID   = r.RestoranID
WHERE ak.KullanimTarihi >= DATEADD(DAY, -7, GETDATE())
ORDER BY ak.KullanimTarihi DESC;
GO

-- ============================================================
-- SORGU 6: ALT SORGU — Havuza Bağış Yapan Kullanıcılar (IN)
-- Amaç   : Bağışçıları ve bağış sayılarını göster.
-- ============================================================
SELECT
    k.Ad + ' ' + k.Soyad AS BagisciAdi,
    COUNT(ab.BagisID)     AS BagisSayisi,
    SUM(ab.BagisTutarTL)  AS ToplamBagisTL
FROM Kullanicilar k
INNER JOIN AskidaBagislar ab ON k.KullaniciID = ab.KullaniciID
WHERE k.KullaniciID IN (
    SELECT DISTINCT KullaniciID
    FROM AskidaBagislar
    WHERE KullaniciID IS NOT NULL
)
GROUP BY k.KullaniciID, k.Ad, k.Soyad
ORDER BY ToplamBagisTL DESC;
GO
