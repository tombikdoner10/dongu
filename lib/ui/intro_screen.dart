import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'theme.dart';

/// Ilk aciliste bir kez gosterilen giris ogreticisi.
///
/// Metin yerine hareket anlatir: her sayfada mekanigi canlandiran kucuk bir
/// gosterim doner.
class IntroScreen extends StatefulWidget {
  const IntroScreen({required this.onDone, super.key});

  final VoidCallback onDone;

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pages = PageController();
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  )..repeat();

  int _index = 0;

  @override
  void dispose() {
    _loop.dispose();
    _pages.dispose();
    super.dispose();
  }

  void _next(int pageCount) {
    if (_index >= pageCount - 1) {
      widget.onDone();
      return;
    }
    _pages.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = <_PageData>[
      _PageData(l10n.introTitle1, l10n.introBody1, _Art.turns),
      _PageData(l10n.introTitle2, l10n.introBody2, _Art.echo),
      _PageData(l10n.introTitle3, l10n.introBody3, _Art.plate),
    ];
    final last = _index == pages.length - 1;

    return Scaffold(
      body: NightBackground(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: widget.onDone,
                  child: Text(
                    l10n.introSkip,
                    style: const TextStyle(color: DColors.textMuted),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pages,
                  itemCount: pages.length,
                  onPageChanged: (int i) => setState(() => _index = i),
                  itemBuilder: (BuildContext context, int i) {
                    final page = pages[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 34),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 150,
                            child: AnimatedBuilder(
                              animation: _loop,
                              builder: (BuildContext context, _) =>
                                  CustomPaint(
                                size: const Size(double.infinity, 150),
                                painter: _ArtPainter(page.art, _loop.value),
                              ),
                            ),
                          ),
                          const SizedBox(height: 44),
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: DColors.text,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            page.body,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: DColors.textMuted,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for (var i = 0; i < pages.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _index ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: i == _index
                            ? DColors.ghost
                            : DColors.surfaceHigh,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () => _next(pages.length),
                child: Text(last ? l10n.introStart : l10n.introNext),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}

enum _Art { turns, echo, plate }

class _PageData {
  const _PageData(this.title, this.body, this.art);

  final String title;
  final String body;
  final _Art art;
}

class _ArtPainter extends CustomPainter {
  _ArtPainter(this.art, this.t);

  final _Art art;

  /// 0..1 arasi donen zaman.
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (art == _Art.turns) {
      _paintTurns(canvas, size);
    } else if (art == _Art.echo) {
      _paintEcho(canvas, size);
    } else {
      _paintPlate(canvas, size);
    }
  }

  /// Tur cubugu dolu baslar, hamle harcandikca soner.
  void _paintTurns(Canvas canvas, Size size) {
    const count = 8;
    final spent = (t * (count + 1)).floor().clamp(0, count);
    final gap = size.width * 0.02;
    final barWidth = (size.width * 0.62 - gap * (count - 1)) / count;
    final left = (size.width - size.width * 0.62) / 2;
    final y = size.height * 0.5;

    for (var i = 0; i < count; i++) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left + i * (barWidth + gap), y - 5, barWidth, 10),
        const Radius.circular(5),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = i < count - spent
              ? DColors.ghost.withValues(alpha: 0.85)
              : DColors.surfaceHigh,
      );
    }

    final dot = Offset(
      left + (count - spent).clamp(0, count) * (barWidth + gap) - gap / 2,
      y - 26,
    );
    canvas.drawCircle(dot, 6, Paint()..color = DColors.player);
    canvas.drawCircle(
      dot,
      13,
      Paint()
        ..color = DColors.playerGlow.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  /// Oyuncu bir yol izler; yanki ayni yolu geriden tekrar eder.
  void _paintEcho(Canvas canvas, Size size) {
    final y = size.height * 0.5;
    final x0 = size.width * 0.2;
    final x1 = size.width * 0.8;

    canvas.drawLine(
      Offset(x0, y),
      Offset(x1, y),
      Paint()
        ..strokeWidth = 2
        ..color = DColors.floorEdge,
    );

    final lead = x0 + (x1 - x0) * t;
    final lagT = (t - 0.26) % 1.0;
    final lag = x0 + (x1 - x0) * lagT;

    canvas.drawCircle(
      Offset(lag, y),
      11,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = DColors.ghost.withValues(alpha: 0.8),
    );
    canvas.drawCircle(Offset(lead, y), 10, Paint()..color = DColors.player);
    canvas.drawCircle(
      Offset(lead, y),
      20,
      Paint()
        ..color = DColors.playerGlow.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }

  /// Yanki plakaya oturur, kapi acilir, oyuncu gecer.
  void _paintPlate(Canvas canvas, Size size) {
    final y = size.height * 0.5;
    final plate = Offset(size.width * 0.32, y);
    final gate = Offset(size.width * 0.66, y);
    final amber = DColors.group(0);

    // Plaka
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: plate, width: 46, height: 46),
        const Radius.circular(10),
      ),
      Paint()..color = amber.withValues(alpha: 0.14),
    );
    canvas.drawCircle(
      plate,
      10,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = amber,
    );

    // Yanki: sagdan gelir, plakaya oturur ve kalir.
    final arrive = math.min(t / 0.35, 1.0);
    final ghost = Offset(
      size.width * 0.12 + (plate.dx - size.width * 0.12) * arrive,
      y,
    );
    final onPlate = arrive >= 1.0;

    // Kapi: yanki plakadayken yalnizca soluk bir cerceve.
    final gateRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: gate, width: 46, height: 46),
      const Radius.circular(10),
    );
    if (onPlate) {
      canvas.drawRRect(
        gateRect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = amber.withValues(alpha: 0.4),
      );
    } else {
      canvas.drawRRect(gateRect, Paint()..color = amber.withValues(alpha: 0.85));
    }

    canvas.drawCircle(
      ghost,
      11,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = DColors.ghost.withValues(alpha: 0.85),
    );

    // Oyuncu kapi acildiktan sonra soldan saga gecer.
    if (t > 0.45) {
      final walk = ((t - 0.45) / 0.5).clamp(0.0, 1.0);
      final px = size.width * 0.14 + (size.width * 0.86 - size.width * 0.14) * walk;
      canvas.drawCircle(Offset(px, y), 10, Paint()..color = DColors.player);
      canvas.drawCircle(
        Offset(px, y),
        20,
        Paint()
          ..color = DColors.playerGlow.withValues(alpha: 0.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }
  }

  @override
  bool shouldRepaint(_ArtPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.art != art;
}
