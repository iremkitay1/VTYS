# Çevrimiçi Yemek Sipariş Platformu — Veritabanı Projesi
## VTYS-1 Dönem Projesi

## 📂 Dosya Yapısı

| Dosya | İçerik |
|---|---|
| `schema.sql` | CREATE TABLE, PK, FK, CHECK, UNIQUE, NOT NULL kısıtlamaları |
| `data.sql` | INSERT INTO — 5 restoran, 50 ürün, 20 kullanıcı, 102 sipariş |
| `objects.sql` | VIEW (3 adet), TRIGGER (3 adet), INDEX (3 adet) |
| `queries.sql` | JOIN, GROUP BY+HAVING, NOT EXISTS, IN subquery sorguları |
| `er_diagram.png` | Varlık-İlişki (ER) Diyagramı |
| `er_diyagrami.md` | ER Diyagramı — Mermaid kodu + dbdiagram.io kodu |
| `is_kurallari.md` | Sistemin 24 iş kuralı + savunma notları |
| `ai_beyani.md` | AI kullanım dürüstlük beyanı |

## 🗂️ Tablolar (11 Tablo)

| Tablo | Açıklama |
|---|---|
| `Kullanicilar` | Platform kullanıcıları (Musteri / IhtiyacSahibi) |
| `Adresler` | Kullanıcı teslimat adresleri (1:N) |
| `Kategoriler` | Ürün kategorileri (Pizza, Burger…) |
| `Restoranlar` | Platforma kayıtlı restoranlar |
| `Urunler` | Menü ürünleri — Soft Delete destekli |
| `Kuryeler` | Teslimat personeli |
| `Siparisler` | Verilen siparişler (5 durum) |
| `SiparisDetaylari` | Sipariş satır kalemleri |
| `AskidaYemekHavuzu` | Global hayırseverlik havuzu |
| `AskidaBagislar` | Bağış kayıtları (anonim destekli) |
| `AskidaKullanimi` | Havuzdan yapılan kullanımlar |

## ▶️ Kurulum Sırası (SSMS)

```sql
-- 1. schema.sql çalıştır  → Veritabanı + tablolar oluşur
-- 2. data.sql çalıştır    → Mock veriler yüklenir
-- 3. objects.sql çalıştır → View, Trigger, Index oluşur
-- 4. queries.sql çalıştır → Sorgular test edilir
```

## 🌟 Askıda Yemek Modülü

Hayırsever müşteriler `AskidaBagislar` tablosu üzerinden havuza TL bağışı yapar.
`DogrulanmisMi = 1` olan ihtiyaç sahipleri `AskidaKullanimi` tablosu üzerinden
siparişlerini havuzdan finanse edebilir.
Bakiye hareketi **Trigger** (`trg_AskidaBagisBakiyeArttir`, `trg_AskidaKullanimBakiyeDus`)
ile otomatik güncellenir — uygulama katmanı bypass edilse bile kural işler.
