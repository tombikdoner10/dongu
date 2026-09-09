import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/levels.dart';
import '../engine/level.dart';
import '../l10n/app_localizations.dart';
import '../services/progress_store.dart';
import 'theme.dart';

/// Butun seviyeler bitince gosterilen kapanis ekrani.
///
/// Oyunun kendi fikrini son bir kez anlatir: halka cizilir, arkada biriken
/// yankilar gorunur, halka kapaninca oyuncu ortada kalir. Animasyon donerek
/// tekrarlar; oyunun adi zaten budur.
class EndingScreen extends StatefulWidget {
  const EndingScreen({required this.progress, super.key});

  final ProgressStore progress;

  @override
  State<EndingScreen> createState() => _EndingScreenState();
}

class _EndingScreenState extends State<EndingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5200),
  )..repeat();

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  /// Bitirilen seviye sayisi, harcanan toplam yanki ve par'a ulasilan seviye
  /// sayisi. Hepsi kayittan okunur; ayrica bir yerde tutulmaz.
  ({int levels, int echoes, int perfect}) get _tally {
    var levels = 0;
    var echoes = 0;
    var perfect = 0;
    for (final Level level in kLevels) {
      final best = widget.progress.bestEchoes(level.id);
      if (best == null) {
        continue;
      }
      levels++;
      echoes += best;
      if (best <= level.par) {
        perfect++;
      }
    }
    return (levels: levels, echoes: echoes, perfect: perfect);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tally = _tally;

    return Scaffold(
      body: NightBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: <Widget>[
                // Sabit yukseklik yerine esnek: kisa ekranlarda halka kuculur,
                // metin ve dugme tasmaz.
                Expanded(
                  flex: 6,
                  child: AnimatedBuilder(
                    animation: _loop,
                    builder: (BuildContext context, Widget? child) =>
                        CustomPaint(
                      painter: _ClosingLoop(_loop.value),
                      size: Size.infinite,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.endingTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: DColors.text,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.endingBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: DColors.textMuted,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _Stat(
                      value: '${tally.levels}',
                      label: l10n.endingLevelsLabel,
                      color: DColors.ghost,
                    ),
                    _Stat(
                      value: '${tally.echoes}',
                      label: l10n.endingEchoesLabel,
                      color: DColors.playerGlow,
                    ),
                    _Stat(
                      value: '${tally.perfect}',
                      label: l10n.perfect,
                      color: DColors.exit,
                    ),
                  ],
                ),
                const Spacer(flex: 4),
                FilledButton(
                  onPressed: () => Navigator.of(context)
                      .popUntil((Route<void> route) => route.isFirst),
                  child: Text(l10n.endingBack),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: DColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}

/// Kapanan halka.
///
/// Zaman cizgisi: 0.00-0.62 halka cizilir ve yankilar arkada birikir,
/// 0.62-0.78 oyuncu merkeze cekilir, 0.78-1.00 durur ve parlar.
class _ClosingLoop extends CustomPainter {
  const _ClosingLoop(this.t);

  final double t;

  static const int _echoCount = 6;
  static const double _traceEnd = 0.62;
  static const double _pullEnd = 0.78;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.36;
    const start = -math.pi / 2;

    // Sonuk halka: yolun tamami bastan bellidir.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = DColors.floorEdge,
    );

    final traced = (t / _traceEnd).clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      2 * math.pi * traced,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round
        ..color = DColors.exit,
    );

    // Halka kapandiktan sonra icine dogru yumusak bir parlama.
    if (traced >= 1) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9
          ..color = DColors.exit.withValues(alpha: 0.16)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }

    // Geride birakilan yankilar: her biri yay oradan gectikce belirir.
    for (var i = 0; i < _echoCount; i++) {
      final at = (i + 1) / (_echoCount + 1);
      if (traced <= at) {
        continue;
      }
      final fade = ((traced - at) * 5).clamp(0.0, 1.0);
      final angle = start + 2 * math.pi * at;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      canvas.drawCircle(
        point,
        9,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..color = DColors.ghost.withValues(alpha: 0.85 * fade),
      );
    }

    // Oyuncu: once yayin ucunda, sonra merkeze cekilir.
    final Offset player;
    if (t < _traceEnd) {
      final angle = start + 2 * math.pi * traced;
      player = center + Offset(math.cos(angle), math.sin(angle)) * radius;
    } else {
      final pull = ((t - _traceEnd) / (_pullEnd - _traceEnd)).clamp(0.0, 1.0);
      final eased = Curves.easeInOutCubic.transform(pull);
      player = Offset.lerp(center + Offset(0, -radius), center, eased)!;
    }

    canvas.drawCircle(
      player,
      22,
      Paint()
        ..color = DColors.playerGlow.withValues(alpha: 0.26)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawCircle(player, 10, Paint()..color = DColors.player);
  }

  @override
  bool shouldRepaint(_ClosingLoop oldDelegate) => oldDelegate.t != t;
}
