import 'package:shared_preferences/shared_preferences.dart';

/// Ilerleme ve ayarlar. Tamamen cihazda kalir; hicbir yere gonderilmez.
class ProgressStore {
  ProgressStore._(this._prefs);

  static const String _bestPrefix = 'best_';
  static const String _colorBlindKey = 'colorBlind';
  static const String _localeKey = 'locale';
  static const String _soundKey = 'sound';
  static const String _introKey = 'introSeen';

  final SharedPreferences _prefs;

  static Future<ProgressStore> open() async =>
      ProgressStore._(await SharedPreferences.getInstance());

  /// Seviyenin en iyi (en az) yanki sayisi; hic bitirilmediyse null.
  int? bestEchoes(int levelId) => _prefs.getInt('$_bestPrefix$levelId');

  bool isCompleted(int levelId) => bestEchoes(levelId) != null;

  /// Ilk seviye hep acik; digerleri bir oncekini bitirmeyi bekler.
  bool isUnlocked(int levelId) => levelId <= 1 || isCompleted(levelId - 1);

  Future<void> record(int levelId, int echoes) async {
    final previous = bestEchoes(levelId);
    if (previous == null || echoes < previous) {
      await _prefs.setInt('$_bestPrefix$levelId', echoes);
    }
  }

  bool get colorBlind => _prefs.getBool(_colorBlindKey) ?? false;

  Future<void> setColorBlind(bool value) =>
      _prefs.setBool(_colorBlindKey, value);

  /// null ise cihaz dili kullanilir.
  String? get localeCode => _prefs.getString(_localeKey);

  Future<void> setLocaleCode(String? code) => code == null
      ? _prefs.remove(_localeKey)
      : _prefs.setString(_localeKey, code);

  bool get soundOn => _prefs.getBool(_soundKey) ?? true;

  Future<void> setSoundOn(bool value) => _prefs.setBool(_soundKey, value);

  /// Giris ogreticisi bir kez gosterilir.
  bool get introSeen => _prefs.getBool(_introKey) ?? false;

  Future<void> setIntroSeen() => _prefs.setBool(_introKey, true);
}
