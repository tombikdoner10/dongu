import 'package:flutter/material.dart';

/// Karanlik + neon palet. Butun renkler tek yerde toplanir; ekranlar dogrudan
/// sabit renk yazmaz.
abstract final class DColors {
  static const Color bgTop = Color(0xFF070B18);
  static const Color bgBottom = Color(0xFF0D1428);
  static const Color surface = Color(0xFF121B33);
  static const Color surfaceHigh = Color(0xFF1B2745);

  static const Color wall = Color(0xFF05080F);
  static const Color floor = Color(0xFF141E37);
  static const Color floorEdge = Color(0xFF1F2E52);

  static const Color text = Color(0xFFE6ECFF);
  static const Color textMuted = Color(0xFF8494BE);

  static const Color player = Color(0xFFFFF1D2);
  static const Color playerGlow = Color(0xFFFFC862);
  static const Color ghost = Color(0xFF7FB6FF);
  static const Color exit = Color(0xFF4DE0C0);
  static const Color crate = Color(0xFFC08E57);

  /// Solan kapi: hicbir plakaya bagli olmadigi icin kendi rengi vardir.
  static const Color fading = Color(0xFF6FE3FF);

  /// Kirilgan zemin.
  static const Color fragile = Color(0xFF8A7BA8);

  /// Buz: soguk ve parlak.
  static const Color ice = Color(0xFF9AD8FF);

  /// Tek yonlu gecidin oku.
  static const Color oneWay = Color(0xFF8FA6D8);

  /// Isinlanma kapisi. Ciftler renkle degil halka sayisiyla ayrilir; palet
  /// zaten kalabalik.
  static const Color teleport = Color(0xFFCFE0FF);

  /// Plaka/kapi gruplari: 0 kehribar, 1 gul, 2 menekse.
  static const List<Color> groups = <Color>[
    Color(0xFFFFB454),
    Color(0xFFFF6EA8),
    Color(0xFFA88BFF),
  ];

  static Color group(int index) => groups[index % groups.length];
}

/// Renk koru oyuncular icin: her grup ayrica bir sekille de anlatilir.
enum GroupSymbol { circle, triangle, square }

GroupSymbol symbolFor(int group) =>
    GroupSymbol.values[group % GroupSymbol.values.length];

ThemeData buildAppTheme() {
  final base = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: DColors.ghost,
      brightness: Brightness.dark,
      surface: DColors.surface,
    ),
    scaffoldBackgroundColor: DColors.bgTop,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: DColors.text,
      displayColor: DColors.text,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: DColors.ghost,
        foregroundColor: const Color(0xFF071022),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: DColors.text,
        side: const BorderSide(color: DColors.surfaceHigh, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}

/// Ekranlarin ortak zemini: yukaridan asagi hafif koyulasan gece grisi.
class NightBackground extends StatelessWidget {
  const NightBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[DColors.bgTop, DColors.bgBottom],
        ),
      ),
      child: child,
    );
  }
}
