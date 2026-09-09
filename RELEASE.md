# Döngü — Play Store yayın kontrol listesi

Bu belge, oyunu mağazaya çıkarmak için gereken adımları sırayla anlatır.
Kod tarafındaki hazırlık tamamlandı; kalan adımların çoğu senin hesabınla
yapılacak işler.

---

## 1. İmzalama anahtarı (yalnızca bir kez, senin yapman gerekiyor)

Bu anahtarı **ben oluşturmuyorum**: parolası bir kimlik bilgisi ve yalnızca
sende kalmalı.

```bash
keytool -genkey -v -keystore %USERPROFILE%\dongu-upload.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Komut sana bir parola ve birkaç kimlik bilgisi soracak. Sonra
`android/key.properties` dosyasını şu içerikle oluştur:

```properties
storePassword=<girdiğin parola>
keyPassword=<girdiğin parola>
keyAlias=upload
storeFile=C:/Users/egeay/dongu-upload.jks
```

> **Bu iki dosyayı asla paylaşma ve asla kaybetme.**
> `android/.gitignore` ikisini de yok sayacak şekilde ayarlı.
> Anahtarı kaybedersen aynı uygulamayı güncelleyemezsin — Play App Signing'e
> kaydolman bu riski azaltır, ilk yüklemede seçeneği kabul et.

Anahtar yoksa `flutter build apk --release` hata vermez, hata ayıklama
anahtarıyla imzalar. Bu yerel denemeler için iyidir ama **mağazaya
yüklenemez**.

## 2. Yükleme paketini derle

```bash
flutter build appbundle --release
```

Çıktı: `build/app/outputs/bundle/release/app-release.aab`

Play Console APK değil **AAB** ister.

## 3. Gizlilik politikasını yayınla

`docs/gizlilik.html` hazır ve iki dilli. İçinde doldurman gereken **iki yer**
var, ikisi de `[İLETİŞİM E-POSTASI]` / `[CONTACT EMAIL]` olarak işaretli.

E-posta adresini oraya senin yazman gerekiyor: herkese açık bir belgeye kendi
adresini koymak senin kararın, ben varsayarak yazmadım.

Sayfa **dışarıya hiçbir istek atmaz**: yazı tipleri `docs/fonts/` içinde,
sayfanın yanında duruyor (SIL OFL 1.1, lisans metni aynı klasörde). Gizlilik
politikası sayfasının kendisinin üçüncü taraf çağırması tuhaf kaçardı.

Metni veya tasarımı değiştirmek gerekirse `docs/_privacy-fragment.html`
düzenlenir ve sayfa yeniden üretilir:

```bash
python dev/build_privacy_page.py
```

Yayınlama seçenekleri:

- **GitHub Pages** — depoyu GitHub'a koy, Settings › Pages › Source: `docs/`
  klasörü. URL: `https://<kullanıcı-adın>.github.io/<depo>/gizlilik.html`
- Elindeki herhangi bir statik barındırma da olur; Play yalnızca herkese açık
  ve çalışan bir bağlantı ister.

## 4. Play Console'da uygulamayı oluştur

- Geliştirici hesabı: tek seferlik **25 USD** kayıt ücreti
- Uygulama adı: **Döngü** · Varsayılan dil: Türkçe · Tür: Oyun
- Ücretsiz

Mağaza metinleri hazır: `store/listing-tr.md` ve `store/listing-en.md`.

## 5. Mağaza görselleri

| Gerekli | Dosya | Durum |
|---|---|---|
| Uygulama simgesi 512×512 | `store/icon-512.png` | hazır |
| Öne çıkan görsel 1024×500 | `store/feature-1024x500.png` | hazır |
| Telefon ekran görüntüsü (en az 2, en fazla 8) | `store/screenshots/` | 6 kare hazır |

Görsellerin tamamı kod içinde geometriyle üretildi; hazır görsel, stok fotoğraf
veya üçüncü taraf font kullanılmadı.

## 6. Veri güvenliği (Data Safety) formu

Bu formu doldurmak kolay, çünkü oyun gerçekten hiçbir şey toplamıyor:

| Soru | Cevap |
|---|---|
| Uygulamanız kullanıcı verisi topluyor veya paylaşıyor mu? | **Hayır** |
| Veriler aktarım sırasında şifreleniyor mu? | Uygulanamaz (veri gönderilmiyor) |
| Kullanıcılar verilerinin silinmesini isteyebilir mi? | Uygulanamaz |
| Reklam kimliği (AD_ID) kullanılıyor mu? | **Hayır** |

Doğrulama: `AndroidManifest.xml` içinde **hiçbir izin yok**. Görünen tek izin
`INTERNET` ve o da Flutter'ın yalnızca `debug`/`profile` derlemelerine eklediği
hot reload izni — yayın derlemesine girmez.

## 7. İçerik derecelendirme anketi

- Şiddet: yok · Cinsellik: yok · Küfür: yok · Kumar: yok
- Korkutucu içerik: yok · Kullanıcılar arası etkileşim: yok
- Konum paylaşımı: yok · Dijital satın alma: yok

Beklenen sonuç: **Herkes / 3+**

## 8. Kapalı test zorunluluğu (dikkat)

Kasım 2023'ten sonra açılan **bireysel** (kişisel) geliştirici hesapları için
Google, prodüksiyona çıkmadan önce şunu şart koşuyor:

- En az **12 test kullanıcısı** kapalı teste katılmalı
- Test **14 gün kesintisiz** sürmeli
- Ardından prodüksiyon erişimi için başvurulur

Kurumsal (organization) hesaplarda bu şart yok. Kural zaman zaman
güncelleniyor — Play Console sana kendi durumundaki güncel şartı gösterir,
oradan teyit et.

Yani: yükleme yaptığın gün yayında olmayacak. Buna göre plan yap.

## 9. Sürüm yükseltirken

`pubspec.yaml` içindeki satır:

```yaml
version: 1.0.0+1
```

`1.0.0` = kullanıcıya görünen sürüm, `+1` = `versionCode`.
Play'e her yeni yüklemede **`+` sonrası sayı artmak zorunda**.

---

## Yayın öncesi son kontrol

```bash
pwsh dev/check.ps1                      # analiz + 836 test
dart run dev/level_report.dart          # 100 seviyenin tamamı çözülebilir mi
flutter build appbundle --release       # yükleme paketi
```
