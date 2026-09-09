// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Döngü';

  @override
  String get tagline => 'Geçmiş kendinle iş birliği yap';

  @override
  String get play => 'Oyna';

  @override
  String get levels => 'Seviyeler';

  @override
  String get settings => 'Ayarlar';

  @override
  String levelLabel(int number) {
    return 'Seviye $number';
  }

  @override
  String get turnsLabel => 'Tur';

  @override
  String get echoesLabel => 'Yankı';

  @override
  String get undo => 'Geri al';

  @override
  String get newLoop => 'Yeni döngü';

  @override
  String get restart => 'Baştan';

  @override
  String get wait => 'Bekle';

  @override
  String get levelComplete => 'Döngü kapandı';

  @override
  String get nextLevel => 'Sonraki';

  @override
  String get cloneLimitReached => 'Yankı hakkın bitti — seviye sıfırlandı';

  @override
  String get loopExhausted => 'Turlar bitti — yeni bir döngü başlat';

  @override
  String get outOfEchoes => 'Ne tur ne yankı kaldı — baştan başla';

  @override
  String get colorBlindMode => 'Renk körü sembolleri';

  @override
  String get language => 'Dil';

  @override
  String get locked => 'Kilitli';

  @override
  String echoesUsed(int count) {
    return '$count yankı';
  }

  @override
  String get perfect => 'En iyi çözüm';

  @override
  String get sound => 'Ses';

  @override
  String get introSkip => 'Geç';

  @override
  String get introNext => 'İleri';

  @override
  String get introStart => 'Başla';

  @override
  String get introTitle1 => 'Turların sayılı';

  @override
  String get introBody1 =>
      'Her hamle bir tur harcar. Turlar bitince döngü kapanır.';

  @override
  String get introTitle2 => 'Hamlelerin geri döner';

  @override
  String get introBody2 =>
      'Kapanan döngü, yaptığın her şeyi bir yankı olarak yeniden oynatır. Sen baştan başlarsın.';

  @override
  String get introTitle3 => 'Geçmişini geride bırak';

  @override
  String get introBody3 =>
      'Plakada duran bir yankı, kapıyı sen geçene kadar açık tutar.';

  @override
  String get endingTitle => 'Döngü tamamlandı';

  @override
  String get endingBody =>
      'Her döngüde seni geçmiş kendin taşıdı. Bu sonuncusuydu.';

  @override
  String get endingLevelsLabel => 'Bölüm';

  @override
  String get endingEchoesLabel => 'Toplam yankı';

  @override
  String get endingBack => 'Başa dön';

  @override
  String get endingOpen => 'Kapanış';
}
