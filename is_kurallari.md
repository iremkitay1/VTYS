# İş Kuralları Belgesi
## Çevrimiçi Yemek Sipariş Platformu — YemekSiparisDB

---

## 1. Kullanıcı Yönetimi

**KR-01:** Sistemde iki tür kullanıcı bulunur: `Musteri` ve `IhtiyacSahibi`.  
**KR-02:** Her kullanıcının e-posta adresi ve telefon numarası sistemde benzersiz (UNIQUE) olmalıdır; iki farklı kullanıcı aynı e-posta veya telefonu kaydedemez.  
**KR-03:** Kullanıcılar fiziksel olarak silinmez. `IsActive = 0` yapılarak pasife çekilir (Soft Delete).  
**KR-04:** `IhtiyacSahibi` tipi kullanıcıların Askıda Yemek havuzundan yararlanabilmesi için bir yönetici tarafından `DogrulanmisMi = 1` yapılarak onaylanması zorunludur.

---

## 2. Adres Yönetimi

**KR-05:** Bir kullanıcının birden fazla kayıtlı teslimat adresi olabilir (1:N ilişki).  
**KR-06:** Sipariş verilirken kullanıcının kayıtlı adreslerinden biri seçilmek zorundadır.

---

## 3. Restoran ve Menü Yönetimi

**KR-07:** Restoranların ortalama puanı 0.00 ile 5.00 arasında olmalıdır (CHECK kısıtlaması).  
**KR-08:** Restoran toplam cirosu 0'ın altına düşemez (CHECK kısıtlaması).  
**KR-09:** Bir ürünün fiyatı 0'dan büyük olmak zorundadır (CHECK kısıtlaması).  
**KR-10:** Restoran bir ürünü menüden kaldırmak istediğinde ürün silinmez; `IsActive = 0` yapılır. Bu sayede geçmiş siparişlerdeki fiyat bilgisi korunur (Soft Delete + veri bütünlüğü).

---

## 4. Sipariş Yönetimi

**KR-11:** Bir sipariş şu durumlardan birinde olabilir: `Beklemede`, `Hazirlaniyor`, `Yolda`, `TeslimEdildi`, `Iptal`. Başka bir değer girilemez (CHECK kısıtlaması).  
**KR-12:** Sipariş toplam tutarı 0'dan küçük olamaz (CHECK kısıtlaması).  
**KR-13:** Bir siparişteki her kalemin miktarı en az 1 olmalıdır (CHECK kısıtlaması).  
**KR-14:** Siparişe atanan kurye bilgisi isteğe bağlıdır (NULL olabilir); sipariş önce oluşturulur, kurye sonradan atanır.

---

## 5. Kurye Yönetimi

**KR-15:** Kuryeler de fiziksel olarak silinmez; `IsActive = 0` ile pasife çekilir.  
**KR-16:** Her siparişe en fazla bir kurye atanabilir (1:1 ilişki, FK üzerinden sağlanır).

---

## 6. "Askıda Yemek" Modülü — Özel Kurallar

**KR-17 (Bağış Yapma):** Herhangi bir müşteri Askıda Yemek havuzuna TL bazında bağış yapabilir. Bağışçı kimliğini gizlemek istediğinde `AnonimMi = 1` seçilir; sorgularda ve raporlarda bu kişinin adı "Anonim Hayırsever" olarak gösterilir.  

**KR-18 (Anonim Bağış):** Anonim bağışlarda `KullaniciID` alanı NULL bırakılabilir. Bu tasarım, kayıtlı olmayan bağışçıları da kapsar.  

**KR-19 (Havuza Ekleme — Trigger):** `AskidaBagislar` tablosuna her yeni kayıt eklendiğinde `trg_AskidaBagisBakiyeArttir` tetikleyicisi devreye girerek `AskidaYemekHavuzu.MevcutBakiye` ve `ToplamBagisTL` alanlarını otomatik artırır. Manuel güncelleme gerekmez.  

**KR-20 (Kullanım Hakkı):** Yalnızca `DogrulanmisMi = 1` olan `IhtiyacSahibi` kullanıcılar havuzdan yararlanabilir. Bu kontrol uygulama katmanında yapılır.  

**KR-21 (Bakiye Kontrolü — Trigger):** `AskidaKullanimi` tablosuna kayıt eklendiğinde `trg_AskidaKullanimBakiyeDus` tetikleyicisi çalışır:  
  - Mevcut havuz bakiyesi `KullanilanTutarTL`'den küçükse işlem ROLLBACK yapılır ve hata fırlatılır.  
  - Yeterli bakiye varsa `MevcutBakiye` düşürülür, `ToplamKullanimTL` artırılır.

**KR-22 (Tekil Kullanım):** Bir sipariş en fazla bir Askıda Yemek kullanımına bağlanabilir. `AskidaKullanimi.SiparisID` kolonu UNIQUE kısıtlamasına sahiptir.  

**KR-23 (İşaretleme):** Askıda Yemek ile finanse edilen siparişler `Siparisler.AskidaMi = 1` ile işaretlenir. Bu alan raporlarda ve sorgularda normal siparişlerden ayrıştırmak için kullanılır.

---

## 7. Ciro Güncelleme (Trigger)

**KR-24:** Bir sipariş `TeslimEdildi` statüsüne güncellendiğinde `trg_SiparisTeslimCiroGuncelle` tetikleyicisi devreye girer ve ilgili restoranın `ToplamCiro` alanı sipariş tutarı kadar artırılır. Aynı sipariş için bu işlem tekrar çalışmaması adına trigger, yalnızca `TeslimEdildi`'ye **yeni geçen** siparişleri yakalar (deleted/inserted tablolarını karşılaştırır).

---

## Özet Tablo Rehberi

| Tablo | Temel Amacı |
|---|---|
| `Kullanicilar` | Müşteri ve ihtiyaç sahibi profillerini tutar |
| `Adresler` | Kullanıcıların birden fazla teslimat adresi |
| `Kategoriler` | Ürün kategorileri (Pizza, Burger, Döner…) |
| `Restoranlar` | Platforma kayıtlı restoranlar |
| `Urunler` | Restoran menü ürünleri (Soft Delete destekli) |
| `Kuryeler` | Teslimat personeli |
| `Siparisler` | Verilen siparişler (durum + tutar) |
| `SiparisDetaylari` | Sipariş satır kalemleri (hangi ürün, kaç adet) |
| `AskidaYemekHavuzu` | Global hayırseverlik havuzu (tek satır) |
| `AskidaBagislar` | Havuza yapılan bağışlar (anonim destekli) |
| `AskidaKullanimi` | Havuzdan yapılan kullanımlar (ihtiyaç sahibi) |
