-- ============================================================
--  VTYS-1 | data.sql — Mock Veriler
--  Sıra: Önce bağımsız tablolar, sonra FK'lı tablolar
-- ============================================================
USE YemekSiparisDB;
GO

-- ============================================================
-- 1. KATEGORİLER (10 adet)
-- ============================================================
INSERT INTO Kategoriler (KategoriAdi) VALUES
('Pizza'), ('Burger'), ('Döner'), ('Sushi'), ('Makarna'),
('Salata'), ('Tatlı'), ('İçecek'), ('Kahvaltı'), ('Vegan');
GO

-- ============================================================
-- 2. RESTORANLAR (5 adet)
-- ============================================================
INSERT INTO Restoranlar (RestoranAdi, Telefon, Eposta, Adres, Sehir, OrtalamaPuan, AcilisYili) VALUES
('Pizza Palace',        '02121110001', 'info@pizzapalace.com',   'Bağcılar Cad. No:12',       'İstanbul', 4.50, 2015),
('Burger House',        '02121110002', 'info@burgerhouse.com',   'Kadıköy Mah. No:5',         'İstanbul', 4.20, 2018),
('Döner Sarayı',        '03121110003', 'info@donersarayi.com',   'Kızılay Sok. No:8',         'Ankara',   4.70, 2010),
('Sushi World',         '02321110004', 'info@sushiworld.com',    'Alsancak Blv. No:33',       'İzmir',    4.80, 2019),
('Makarna Dünyası',     '02121110005', 'info@makarnaci.com',     'Beşiktaş Cad. No:21',       'İstanbul', 4.10, 2017);
GO

-- ============================================================
-- 3. KULLANICILAR (20 adet — 18 Musteri, 2 IhtiyacSahibi)
-- ============================================================
INSERT INTO Kullanicilar (Ad, Soyad, Eposta, Telefon, SifreHash, KullaniciTipi, DogrulanmisMi) VALUES
('Ahmet',   'Yılmaz',   'ahmet@mail.com',   '05301000001', 'hash001', 'Musteri',      0),
('Ayşe',    'Kaya',     'ayse@mail.com',    '05301000002', 'hash002', 'Musteri',      0),
('Mehmet',  'Demir',    'mehmet@mail.com',  '05301000003', 'hash003', 'Musteri',      0),
('Fatma',   'Çelik',    'fatma@mail.com',   '05301000004', 'hash004', 'Musteri',      0),
('Ali',     'Şahin',    'ali@mail.com',     '05301000005', 'hash005', 'Musteri',      0),
('Zeynep',  'Arslan',   'zeynep@mail.com',  '05301000006', 'hash006', 'Musteri',      0),
('Mustafa', 'Koç',      'mustafa@mail.com', '05301000007', 'hash007', 'Musteri',      0),
('Emine',   'Kurt',     'emine@mail.com',   '05301000008', 'hash008', 'Musteri',      0),
('İbrahim', 'Özdemir',  'ibrahim@mail.com', '05301000009', 'hash009', 'Musteri',      0),
('Hatice',  'Aydın',    'hatice@mail.com',  '05301000010', 'hash010', 'Musteri',      0),
('Hüseyin', 'Güneş',    'huseyin@mail.com', '05301000011', 'hash011', 'Musteri',      0),
('Merve',   'Yıldız',   'merve@mail.com',   '05301000012', 'hash012', 'Musteri',      0),
('Emre',    'Aktaş',    'emre@mail.com',    '05301000013', 'hash013', 'Musteri',      0),
('Selin',   'Bozkurt',  'selin@mail.com',   '05301000014', 'hash014', 'Musteri',      0),
('Burak',   'Erdoğan',  'burak@mail.com',   '05301000015', 'hash015', 'Musteri',      0),
('Ceren',   'Polat',    'ceren@mail.com',   '05301000016', 'hash016', 'Musteri',      0),
('Oğuz',    'Tekin',    'oguz@mail.com',    '05301000017', 'hash017', 'Musteri',      0),
('Büşra',   'Güler',    'busra@mail.com',   '05301000018', 'hash018', 'Musteri',      0),
-- İhtiyaç Sahipleri (doğrulanmış — Askıda Yemek kullanabilir)
('Kadir',   'Yoksul',   'kadir@mail.com',   '05301000019', 'hash019', 'IhtiyacSahibi', 1),
('Leyla',   'Dar',      'leyla@mail.com',   '05301000020', 'hash020', 'IhtiyacSahibi', 1);
GO

-- ============================================================
-- 4. ADRESLER (her kullanıcıya 1 adres)
-- ============================================================
INSERT INTO Adresler (KullaniciID, AdresBasligi, AdresSatiri, Ilce, Sehir) VALUES
(1,  'Ev', 'Atatürk Mah. No:1',  'Bağcılar',   'İstanbul'),
(2,  'Ev', 'Cumhuriyet Cd. No:2','Kadıköy',    'İstanbul'),
(3,  'İş', 'İnönü Sk. No:3',     'Çankaya',    'Ankara'),
(4,  'Ev', 'Fatih Mah. No:4',    'Fatih',      'İstanbul'),
(5,  'Ev', 'Gazi Cd. No:5',      'Alsancak',   'İzmir'),
(6,  'Ev', 'Barış Mah. No:6',    'Beşiktaş',   'İstanbul'),
(7,  'İş', 'Millet Cd. No:7',    'Kızılay',    'Ankara'),
(8,  'Ev', 'Lale Sk. No:8',      'Karşıyaka',  'İzmir'),
(9,  'Ev', 'Karanfil Cd. No:9',  'Şişli',      'İstanbul'),
(10, 'Ev', 'Yıldız Mah. No:10',  'Üsküdar',    'İstanbul'),
(11, 'Ev', 'Papatya Sk. No:11',  'Bornova',    'İzmir'),
(12, 'Ev', 'Zambak Cd. No:12',   'Etimesgut',  'Ankara'),
(13, 'İş', 'Gül Mah. No:13',     'Maltepe',    'İstanbul'),
(14, 'Ev', 'Menekşe Sk. No:14',  'Çankaya',    'Ankara'),
(15, 'Ev', 'Nilüfer Cd. No:15',  'Pendik',     'İstanbul'),
(16, 'Ev', 'Sümbül Mah. No:16',  'Konak',      'İzmir'),
(17, 'İş', 'Akasya Sk. No:17',   'Beyoğlu',    'İstanbul'),
(18, 'Ev', 'Çınar Cd. No:18',    'Mamak',      'Ankara'),
(19, 'Ev', 'Ihlamur Sk. No:19',  'Sultangazi', 'İstanbul'),
(20, 'Ev', 'Servi Mah. No:20',   'Altındağ',   'Ankara');
GO

-- ============================================================
-- 5. KURYELER (5 adet)
-- ============================================================
INSERT INTO Kuryeler (Ad, Soyad, Telefon, Plaka) VALUES
('Taner',  'Kılıç',   '05401000001', '34 AAA 001'),
('Serkan', 'Bulut',   '05401000002', '06 BBB 002'),
('Caner',  'Avcı',    '05401000003', '35 CCC 003'),
('Deniz',  'Doğan',   '05401000004', '34 DDD 004'),
('Ufuk',   'Çetin',   '05401000005', '06 EEE 005');
GO

-- ============================================================
-- 6. ÜRÜNLER (50 adet — her restorana 10 ürün)
-- ============================================================
-- Pizza Palace (RestoranID=1, Kategori Pizza=1, Tatlı=7, İçecek=8)
INSERT INTO Urunler (RestoranID, KategoriID, UrunAdi, Fiyat) VALUES
(1,1,'Margherita Pizza',        89.90),
(1,1,'Karışık Pizza',          109.90),
(1,1,'Vejeteryan Pizza',        99.90),
(1,1,'BBQ Tavuklu Pizza',      119.90),
(1,1,'4 Peynirli Pizza',       129.90),
(1,1,'Pepperoni Pizza',        114.90),
(1,1,'Mantarlı Pizza',          94.90),
(1,7,'Çikolatalı Brownie',      39.90),
(1,8,'Kola (500ml)',            24.90),
(1,8,'Limonata',                29.90);

-- Burger House (RestoranID=2, Kategori Burger=2, İçecek=8, Tatlı=7)
INSERT INTO Urunler (RestoranID, KategoriID, UrunAdi, Fiyat) VALUES
(2,2,'Klasik Burger',           79.90),
(2,2,'Çift Etli Burger',       109.90),
(2,2,'Tavuk Burger',            74.90),
(2,2,'Mantar Burger',           84.90),
(2,2,'Bacon Burger',            99.90),
(2,2,'Vegan Burger',            89.90),
(2,2,'Balık Burger',            89.90),
(2,7,'Dondurma (2 Top)',        34.90),
(2,8,'Ayran (300ml)',           19.90),
(2,8,'Milkshake Çikolata',      44.90);

-- Döner Sarayı (RestoranID=3, Kategori Döner=3, Salata=6, İçecek=8)
INSERT INTO Urunler (RestoranID, KategoriID, UrunAdi, Fiyat) VALUES
(3,3,'Tavuk Döner Dürüm',       69.90),
(3,3,'Et Döner Dürüm',          79.90),
(3,3,'Karışık Döner Tabak',     99.90),
(3,3,'İskender',               109.90),
(3,3,'Lahmacun',                34.90),
(3,3,'Pide Kaşarlı',            54.90),
(3,3,'Tavuk Kanat (8 adet)',    79.90),
(3,6,'Mevsim Salatası',         39.90),
(3,8,'Şalgam Suyu',             19.90),
(3,8,'Ayran (500ml)',           22.90);

-- Sushi World (RestoranID=4, Kategori Sushi=4, Salata=6, İçecek=8)
INSERT INTO Urunler (RestoranID, KategoriID, UrunAdi, Fiyat) VALUES
(4,4,'Somon Nigiri (4 adet)',   89.90),
(4,4,'Ton Balığı Maki (8 adet)',79.90),
(4,4,'California Roll (8 adet)',94.90),
(4,4,'Spicy Tuna Roll',         99.90),
(4,4,'Dragon Roll',            119.90),
(4,4,'Tempura Roll',           109.90),
(4,4,'Avokado Roll',            89.90),
(4,6,'Edamame',                 39.90),
(4,8,'Yeşil Çay',               24.90),
(4,8,'Japon Birası',            49.90);

-- Makarna Dünyası (RestoranID=5, Kategori Makarna=5, Salata=6, İçecek=8)
INSERT INTO Urunler (RestoranID, KategoriID, UrunAdi, Fiyat) VALUES
(5,5,'Spaghetti Bolognese',     89.90),
(5,5,'Penne Arrabbiata',        79.90),
(5,5,'Fettuccine Alfredo',      94.90),
(5,5,'Lasagne',                 99.90),
(5,5,'Carbonara',               94.90),
(5,5,'Pesto Makarna',           84.90),
(5,5,'Deniz Ürünlü Linguine',  119.90),
(5,6,'Caprese Salata',          54.90),
(5,8,'San Pellegrino',          29.90),
(5,8,'Ev Yapımı Limonata',      34.90);
GO

-- ============================================================
-- 7. SİPARİŞLER (100 adet)
--    KullaniciID 1-18, RestoranID 1-5, AdresID 1-18
--    Kuryeler: 1-5, Son 3 ayda çeşitli tarihler
--    AskidaMi = 0 (normal), 1 (havuzdan finanse)
-- ============================================================
-- Değişkenler döngü DIŞINDA declare edilmeli (SQL Server kuralı)
DECLARE @i     INT;
DECLARE @kid   INT;
DECLARE @rid   INT;
DECLARE @aid   INT;
DECLARE @kurid INT;
DECLARE @gun   INT;
DECLARE @tarih DATETIME;
DECLARE @durum NVARCHAR(20);
DECLARE @teslim DATETIME;
DECLARE @tutar DECIMAL(10,2);

SET @i = 1;
WHILE @i <= 100
BEGIN
    SET @kid   = ((@i - 1) % 18) + 1;        -- KullaniciID 1-18
    SET @rid   = ((@i - 1) % 5)  + 1;        -- RestoranID  1-5
    SET @aid   = @kid;                         -- AdresID = KullaniciID
    SET @kurid = ((@i - 1) % 5)  + 1;        -- KuryeID     1-5
    SET @gun   = (@i % 85) + 1;
    SET @tarih = DATEADD(DAY, -@gun, GETDATE());

    SET @durum =
        CASE
            WHEN @i % 5 = 0 THEN 'Iptal'
            WHEN @i % 5 = 1 THEN 'Beklemede'
            WHEN @i % 5 = 2 THEN 'Hazirlaniyor'
            WHEN @i % 5 = 3 THEN 'Yolda'
            ELSE                  'TeslimEdildi'
        END;

    SET @teslim =
        CASE WHEN @durum = 'TeslimEdildi'
             THEN DATEADD(MINUTE, 40, @tarih)
             ELSE NULL
        END;

    SET @tutar = CAST(50 + (@i * 7) % 200 AS DECIMAL(10,2));

    INSERT INTO Siparisler
        (KullaniciID, RestoranID, AdresID, KuryeID, Durum, ToplamTutar, SiparisTarihi, TeslimTarihi, AskidaMi)
    VALUES
        (@kid, @rid, @aid, @kurid, @durum, @tutar, @tarih, @teslim, 0);

    SET @i = @i + 1;
END;
GO

-- ============================================================
-- 8. SİPARİŞ DETAYLARI
--    Her siparişe 1-3 kalem ürün ekle
-- ============================================================
-- Değişkenler döngü DIŞINDA declare edilmeli (SQL Server kuralı)
DECLARE @s   INT;
DECLARE @res INT;
DECLARE @u1  INT;
DECLARE @u2  INT;
DECLARE @u3  INT;
DECLARE @bp1 DECIMAL(8,2);
DECLARE @bp2 DECIMAL(8,2);
DECLARE @bp3 DECIMAL(8,2);

SET @s = 1;
WHILE @s <= 100
BEGIN
    SET @res = ((@s - 1) % 5)      + 1;   -- RestoranID 1-5
    SET @u1  = ((@res - 1) * 10)   + 1;   -- İlk ürün offseti
    SET @u2  = @u1 + 1;
    SET @u3  = @u1 + 2;

    SELECT @bp1 = Fiyat FROM Urunler WHERE UrunID = @u1;
    SELECT @bp2 = Fiyat FROM Urunler WHERE UrunID = @u2;
    SELECT @bp3 = Fiyat FROM Urunler WHERE UrunID = @u3;

    INSERT INTO SiparisDetaylari (SiparisID, UrunID, Miktar, BirimFiyat) VALUES
        (@s, @u1, 1, @bp1),
        (@s, @u2, 1, @bp2);

    IF @s % 3 = 0
        INSERT INTO SiparisDetaylari (SiparisID, UrunID, Miktar, BirimFiyat) VALUES
            (@s, @u3, 1, @bp3);

    SET @s = @s + 1;
END;
GO

-- ============================================================
-- 9. ASKIDA YEMEK HAVUZU — Bağışlar (10 bağış)
-- ============================================================
INSERT INTO AskidaBagislar (HavuzID, KullaniciID, BagisTutarTL, AnonimMi, Aciklama) VALUES
(1, 1,  100.00, 0, 'Hayırlı olsun!'),
(1, 3,  250.00, 0, 'Geçmiş olsun'),
(1, 5,   50.00, 1, NULL),            -- anonim
(1, 7,  150.00, 0, 'Destek olmak istedim'),
(1, 9,   75.00, 1, NULL),            -- anonim
(1, 11, 200.00, 0, 'Az da olsa'),
(1, 13,  80.00, 1, NULL),            -- anonim
(1, 15, 120.00, 0, 'Hayırlı işler'),
(1, 17,  60.00, 0, 'Bir nebze destek'),
(1, 2,   90.00, 1, NULL);            -- anonim
GO

-- Havuz bakiyesini güncelle (bağışlar toplamı = 1175 TL)
UPDATE AskidaYemekHavuzu
SET MevcutBakiye     = 1175.00,
    ToplamBagisTL    = 1175.00,
    GuncellemeTarihi = GETDATE()
WHERE HavuzID = 1;
GO

-- ============================================================
-- 10. ASKIDA YEMEK KULLANIMI
--     İhtiyaç sahipleri için 2 örnek sipariş (AskidaMi=1)
-- ============================================================

-- KullaniciID=19 (Kadir) için sipariş (SiparisID=101)
INSERT INTO Siparisler (KullaniciID, RestoranID, AdresID, KuryeID, Durum, ToplamTutar, SiparisTarihi, AskidaMi)
VALUES (19, 3, 19, 1, 'TeslimEdildi', 69.90, DATEADD(DAY,-2,GETDATE()), 1);

-- KullaniciID=20 (Leyla) için sipariş (SiparisID=102)
INSERT INTO Siparisler (KullaniciID, RestoranID, AdresID, KuryeID, Durum, ToplamTutar, SiparisTarihi, AskidaMi)
VALUES (20, 1, 20, 2, 'TeslimEdildi', 89.90, DATEADD(DAY,-1,GETDATE()), 1);
GO

-- Askıda Yemek kullanım kayıtları
INSERT INTO AskidaKullanimi (HavuzID, KullaniciID, SiparisID, KullanilanTutarTL) VALUES
(1, 19, 101, 69.90),
(1, 20, 102, 89.90);
GO

-- Havuz bakiyesini kullanım sonrası güncelle
UPDATE AskidaYemekHavuzu
SET MevcutBakiye     = MevcutBakiye - 159.80,
    ToplamKullanimTL = ToplamKullanimTL + 159.80,
    GuncellemeTarihi = GETDATE()
WHERE HavuzID = 1;
GO

-- ============================================================
-- SOFT DELETE Örneği — Bir ürünü pasife çek
-- ============================================================
-- UrunID=10 (Limonata) pasife alındı
UPDATE Urunler SET IsActive = 0 WHERE UrunID = 10;
GO
