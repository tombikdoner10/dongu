# Döngü

Geçmiş kendinle iş birliği yaptığın, tur tabanlı bir bulmaca oyunu.

Her seviyede sınırlı sayıda turun var. Turlar bitince döngü kapanır: yaptığın
her hamle bir **yankı** olarak yeniden oynanır, sen ise baştan başlarsın.
Kapıyı açık tutan plakaya basacak kimse yoksa, bir önceki döngüde oraya kendini
bırakırsın.

Flutter · Android · Türkçe ve İngilizce · çevrimdışı · sıfır izin

---

## Çalıştırma

```bash
flutter pub get
flutter run
```

## Doğrulama

```bash
pwsh dev/check.ps1        # flutter analyze + 143 test, ~10 sn
```

Geliştirme boyunca kullanılan tek doğrulama budur. Emülatör açmak bunun onlarca
katı maliyetli olduğu için mantık testlerle garantiye alınır.

---

## Mimari

```
lib/
  engine/     saf Dart oyun motoru — hiçbir Flutter bağımlılığı yok
    models.dart      hareketler, konumlar, kare türleri
    level.dart       ASCII harita çözümleyici
    game_state.dart  tur çözümleme, kapı mantığı, geri alma
    solver.dart      otomatik çözücü (aşağıya bakın)
  data/levels.dart   23 seviye, ASCII veri olarak
  services/          ilerleme kaydı, ses
  ui/                ekranlar ve tahta çizimi
```

Motorun saf Dart olması bilinçli: testler cihaz açmadan, saniyeler içinde
çalışıyor ve çözücü `dart run` ile doğrudan çalıştırılabiliyor.

### Oyun kuralları

- Bir tur = tek bir eylem (yukarı / aşağı / sola / sağa / bekle)
- Her yankı, aynı tur indeksindeki kayıtlı eylemini oynar
- **Kapı durumu turun başında sabitlenir.** Plakanın üstünde bir beden
  (oyuncu, yankı veya sandık) varsa kapı geçilebilir. Bu kural, plakanın hemen
  yanındaki kendi kapısından geçilebilmesine yol açar — seviye tasarlarken
  araya bir kare koyun.
- **Yankılar katı değildir**, sandıklar katıdır ve itilebilir
- Kırılgan zemin, üstünden bir beden çekilince çöker — ama karede hâlâ biri
  duruyorsa ayakta kalır. Seviye 23 tam olarak bunun üzerine kurulu.

## Seviye ekleme

Haritayı `lib/data/levels.dart` içine ASCII olarak yazın:

```
#  duvar        .  zemin       P  başlangıç    E  çıkış
1 2 3  plaka    4 5 6  ağır plaka (iki beden ister)
A B C  kapı     T  solan kapı  ~  kırılgan zemin   X  sandık
```

Sonra gerçek zorluğu çözücüye sorun:

```bash
dart run dev/level_report.dart      # her seviyenin par değeri ve süresi
dart run dev/solution_dump.dart 23  # tek bir seviyenin çözümü, hamle hamle
```

Çıkan `par` değeri tasarım niyetinizle uyuşuyorsa `par:` alanına yazın; test
onu dondurur, böylece bir harita değişikliği zorluğu sessizce kaydıramaz.

### Çözücü hakkında

Bir yankının geleceğe tek etkisi, geride **basılı bıraktığı plakadır**. Aday
kayıtlar bu gözleme dayanarak "bir yere en kısa yoldan git ve orada bekle" ile
sınırlanır; arama uzayı üstel olmaktan çıkar.

Bu bir sezgiseldir, dolayısıyla çözücü **tam değildir** — bulamadığı bir çözüm
olabilir ve "çözülemez" diyebilir. Buna karşılık **yanlış pozitif üretemez**:
döndürdüğü her çözüm motorda oynatılarak doğrulanır.

Zamanlamaya duyarlı seviyeler (kırılgan zeminde yankının *ne zaman* geçtiği
önemliyse) `timingSensitive: true` ile işaretlenir; çözücü o seviyelerde
adayları tur bazında da ayırır. Bayrak unutulursa hata gürültülüdür: rapor
"çözülemez" der.

---

## Geliştirici betikleri

| Betik | İş |
|---|---|
| `dev/check.ps1` | analiz + testler, kırpılmış özet |
| `dev/level_report.dart` | 23 seviyenin par değeri, süresi, doğrulaması |
| `dev/solution_dump.dart` | tek seviyenin çözümü, hamle hamle |
| `dev/solution_export.dart` | çözümleri makine okunur biçimde dışa aktarır |
| `dev/play_all.py` | bütün seviyeleri emülatörde gerçek dokunuşlarla oynar |
| `dev/make_sfx.py` | ses efektlerini sıfırdan sentezler |
| `dev/make_store_assets.py` | mağaza simgesi ve öne çıkan görseli çizer |
| `dev/make_screenshots.py` | mağaza ekran görüntülerini emülatörden toplar |
| `dev/build_privacy_page.py` | gizlilik politikası sayfasını üretir |

Ses efektleri, mağaza görselleri ve uygulama simgesi dahil **hiçbir hazır
varlık kullanılmıyor**; hepsi bu betiklerle üretiliyor. Telif riski sıfır.

---

## Yayın

Adım adım kontrol listesi: [`RELEASE.md`](RELEASE.md)

Gizlilik politikası `docs/` altında, dışarıya hiçbir istek atmayacak şekilde
(yazı tipleri sayfanın yanında) hazır.
