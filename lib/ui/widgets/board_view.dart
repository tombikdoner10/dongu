import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../engine/game_state.dart';
import '../../engine/level.dart';
import '../../engine/models.dart';
import '../theme.dart';

const Duration kMoveDuration = Duration(milliseconds: 160);

/// Tahtayi cizer: sabit kareler CustomPainter ile, hareketli varliklar
/// AnimatedPositioned ile. Boylece hareket akici, cizim ucuz olur.
class BoardView extends StatelessWidget {
  const BoardView({required this.state, super.key});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final level = state.level;
    final origin = Pos(level.contentLeft, level.contentTop);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final cell = math.min(
          constraints.maxWidth / level.contentCols,
          constraints.maxHeight / level.contentRows,
        );
        return Center(
          child: SizedBox(
            width: cell * level.contentCols,
            height: cell * level.contentRows,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: CustomPaint(painter: _BoardPainter(state: state)),
                ),
                for (var i = 0; i < state.boxes.length; i++)
                  _Entity(
                    key: ValueKey<String>('box$i'),
                    pos: state.boxes[i],
                    origin: origin,
                    cell: cell,
                    child: _Crate(cell: cell),
                  ),
                for (var i = 0; i < state.ghosts.length; i++)
                  _Entity(
                    key: ValueKey<String>('ghost$i'),
                    pos: state.ghosts[i],
                    origin: origin,
                    cell: cell,
                    child: _Ghost(cell: cell),
                  ),
                _Entity(
                  key: const ValueKey<String>('player'),
                  pos: state.player,
                  origin: origin,
                  cell: cell,
                  child: _Player(cell: cell),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Entity extends StatelessWidget {
  const _Entity({
    required this.pos,
    required this.origin,
    required this.cell,
    required this.child,
    super.key,
  });

  final Pos pos;

  /// Cizim alaninin sol ust karesi; dis duvar halkasi kirpildigi icin gerekir.
  final Pos origin;
  final double cell;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: kMoveDuration,
      curve: Curves.easeOutCubic,
      left: (pos.x - origin.x) * cell,
      top: (pos.y - origin.y) * cell,
      width: cell,
      height: cell,
      child: child,
    );
  }
}

class _Player extends StatelessWidget {
  const _Player({required this.cell});

  final double cell;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: cell * 0.56,
        height: cell * 0.56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: DColors.player,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: DColors.playerGlow.withValues(alpha: 0.6),
              blurRadius: cell * 0.55,
              spreadRadius: cell * 0.06,
            ),
          ],
        ),
      ),
    );
  }
}

class _Ghost extends StatelessWidget {
  const _Ghost({required this.cell});

  final double cell;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: cell * 0.52,
        height: cell * 0.52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: DColors.ghost.withValues(alpha: 0.16),
          border: Border.all(
            color: DColors.ghost.withValues(alpha: 0.75),
            width: math.max(1.4, cell * 0.045),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: DColors.ghost.withValues(alpha: 0.28),
              blurRadius: cell * 0.35,
            ),
          ],
        ),
      ),
    );
  }
}

class _Crate extends StatelessWidget {
  const _Crate({required this.cell});

  final double cell;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: cell * 0.72,
        height: cell * 0.72,
        decoration: BoxDecoration(
          color: DColors.crate.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(cell * 0.14),
          border: Border.all(
            color: DColors.crate,
            width: math.max(1.4, cell * 0.05),
          ),
        ),
        child: Center(
          child: Container(
            width: cell * 0.26,
            height: cell * 0.26,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(cell * 0.05),
              border: Border.all(
                color: DColors.crate.withValues(alpha: 0.8),
                width: math.max(1, cell * 0.03),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  _BoardPainter({required this.state});

  final GameState state;

  Level get level => state.level;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / level.contentCols;
    final open = state.openGroups;

    for (var y = 0; y < level.rows; y++) {
      for (var x = 0; x < level.cols; x++) {
        final here = Pos(x, y);
        final tile = level.grid[y][x];
        if (tile.type == TileType.wall) {
          continue; // Duvarlar bosluk kalir; zemin karolari yuzer gibi durur.
        }
        final rect = Rect.fromLTWH(
          (x - level.contentLeft) * cell,
          (y - level.contentTop) * cell,
          cell,
          cell,
        );

        if (tile.type == TileType.fragile && state.collapsed.contains(here)) {
          _paintPit(canvas, rect, cell);
          continue;
        }

        _paintFloor(canvas, rect, cell);

        switch (tile.type) {
          case TileType.exit:
            _paintExit(canvas, rect, cell);
          case TileType.plate:
            _paintPlate(canvas, rect, cell, tile.group);
          case TileType.heavyPlate:
            _paintHeavyPlate(canvas, rect, cell, tile.group,
                state.bodiesOn(here), tile.requiredBodies);
          case TileType.door:
            _paintDoor(canvas, rect, cell, tile.group,
                open.contains(tile.group));
          case TileType.fadingDoor:
            _paintFadingDoor(canvas, rect, cell);
          case TileType.fragile:
            _paintFragile(canvas, rect, cell);
          case TileType.toggle:
            _paintToggle(canvas, rect, cell, tile.group,
                state.latched.contains(tile.group));
          case TileType.ice:
            _paintIce(canvas, rect, cell);
          case TileType.oneWay:
            _paintOneWay(canvas, rect, cell, tile.oneWayDirection);
          case TileType.teleport:
            _paintTeleport(canvas, rect, cell, tile.group);
          case TileType.wall:
          case TileType.floor:
            break;
        }
      }
    }
  }

  void _paintFloor(Canvas canvas, Rect rect, double cell) {
    final inner = rect.deflate(cell * 0.045);
    final rrect =
        RRect.fromRectAndRadius(inner, Radius.circular(cell * 0.16));
    canvas.drawRRect(rrect, Paint()..color = DColors.floor);
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, cell * 0.025)
        ..color = DColors.floorEdge,
    );
  }

  /// Cokmus kirilgan zemin: artik gecilemez, bosluk gibi cizilir.
  void _paintPit(Canvas canvas, Rect rect, double cell) {
    final inner = rect.deflate(cell * 0.045);
    final rrect =
        RRect.fromRectAndRadius(inner, Radius.circular(cell * 0.16));
    canvas.drawRRect(
      rrect,
      Paint()..color = DColors.bgTop.withValues(alpha: 0.9),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, cell * 0.025)
        ..color = DColors.fragile.withValues(alpha: 0.22),
    );
  }

  /// Saglam kirilgan zemin: uzerinde catlaklar var, bir kez gecilebilecegi
  /// bir bakista anlasilsin.
  void _paintFragile(Canvas canvas, Rect rect, double cell) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, cell * 0.035)
      ..strokeCap = StrokeCap.round
      ..color = DColors.fragile.withValues(alpha: 0.75);
    final c = rect.center;
    canvas.drawLine(
      Offset(c.dx - cell * 0.22, c.dy - cell * 0.12),
      Offset(c.dx - cell * 0.02, c.dy + cell * 0.04),
      paint,
    );
    canvas.drawLine(
      Offset(c.dx - cell * 0.02, c.dy + cell * 0.04),
      Offset(c.dx + cell * 0.1, c.dy - cell * 0.14),
      paint,
    );
    canvas.drawLine(
      Offset(c.dx - cell * 0.02, c.dy + cell * 0.04),
      Offset(c.dx + cell * 0.2, c.dy + cell * 0.2),
      paint,
    );
  }

  /// Dugme: plakadan farkli olsun diye kare. Cevrildiginde ici dolar.
  void _paintToggle(
      Canvas canvas, Rect rect, double cell, int group, bool isOn) {
    final color = DColors.group(group);
    final body = RRect.fromRectAndRadius(
        rect.deflate(cell * 0.2), Radius.circular(cell * 0.07));
    canvas.drawRRect(
      body,
      Paint()..color = color.withValues(alpha: isOn ? 0.85 : 0.12),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.4, cell * 0.05)
        ..color = color.withValues(alpha: isOn ? 1 : 0.7),
    );
    _paintSymbol(
      canvas,
      rect.center,
      cell * 0.12,
      symbolFor(group),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, cell * 0.035)
        ..color = isOn ? DColors.bgTop.withValues(alpha: 0.8) : color,
    );
  }

  /// Buz: soguk zemin, uzerinde kayma hissi veren ince parlamalar.
  void _paintIce(Canvas canvas, Rect rect, double cell) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          rect.deflate(cell * 0.045), Radius.circular(cell * 0.16)),
      Paint()..color = DColors.ice.withValues(alpha: 0.15),
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, cell * 0.03)
      ..strokeCap = StrokeCap.round
      ..color = DColors.ice.withValues(alpha: 0.5);
    for (final offset in <double>[0.26, 0.5]) {
      canvas.drawLine(
        Offset(rect.left + cell * offset, rect.top + cell * (offset + 0.2)),
        Offset(rect.left + cell * (offset + 0.24),
            rect.top + cell * (offset - 0.04)),
        paint,
      );
    }
  }

  /// Tek yonlu gecit: izin verilen yone bakan dolu ok.
  void _paintOneWay(
      Canvas canvas, Rect rect, double cell, GameAction direction) {
    final centre = rect.center;
    final radius = cell * 0.22;
    final dx = direction.dx.toDouble();
    final dy = direction.dy.toDouble();
    final tip = Offset(centre.dx + dx * radius, centre.dy + dy * radius);
    final back = Offset(
        centre.dx - dx * radius * 0.65, centre.dy - dy * radius * 0.65);
    // Yone dik birim vektor: okun tabanini acmak icin.
    final px = -dy;
    final py = dx;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(back.dx + px * radius * 0.8, back.dy + py * radius * 0.8)
      ..lineTo(back.dx - px * radius * 0.8, back.dy - py * radius * 0.8)
      ..close();
    canvas.drawPath(
        path, Paint()..color = DColors.oneWay.withValues(alpha: 0.8));
  }

  /// Isinlanma kapisi: ic ice halkalar. Cift numarasi halka sayisini belirler.
  void _paintTeleport(Canvas canvas, Rect rect, double cell, int pair) {
    final centre = rect.center;
    canvas.drawCircle(
      centre,
      cell * 0.3,
      Paint()
        ..color = DColors.teleport.withValues(alpha: 0.12)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, cell * 0.12),
    );
    final rings = 2 + pair;
    for (var i = 0; i < rings; i++) {
      final radius = cell * (0.3 - i * 0.09);
      canvas.drawCircle(
        centre,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, cell * 0.03)
          ..color = DColors.teleport.withValues(alpha: i == 0 ? 0.9 : 0.5),
      );
    }
  }

  void _paintExit(Canvas canvas, Rect rect, double cell) {
    final center = rect.center;
    canvas.drawCircle(
      center,
      cell * 0.34,
      Paint()
        ..color = DColors.exit.withValues(alpha: 0.16)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, cell * 0.18),
    );
    for (final factor in <double>[0.32, 0.2]) {
      canvas.drawCircle(
        center,
        cell * factor,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.2, cell * 0.04)
          ..color = DColors.exit.withValues(alpha: factor > 0.25 ? 0.9 : 0.5),
      );
    }
  }

  void _paintPlate(Canvas canvas, Rect rect, double cell, int group) {
    final color = DColors.group(group);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          rect.deflate(cell * 0.16), Radius.circular(cell * 0.12)),
      Paint()..color = color.withValues(alpha: 0.12),
    );
    _paintSymbol(
      canvas,
      rect.center,
      cell * 0.2,
      symbolFor(group),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.4, cell * 0.05)
        ..color = color.withValues(alpha: 0.95),
    );
  }

  /// Agir plaka: cift halka, altinda kac beden gerektigini gosteren noktalar.
  void _paintHeavyPlate(Canvas canvas, Rect rect, double cell, int group,
      int bodies, int required) {
    final color = DColors.group(group);
    final satisfied = bodies >= required;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
          rect.deflate(cell * 0.12), Radius.circular(cell * 0.12)),
      Paint()..color = color.withValues(alpha: satisfied ? 0.22 : 0.12),
    );

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.4, cell * 0.05)
      ..color = color.withValues(alpha: 0.95);
    _paintSymbol(canvas, rect.center, cell * 0.2, symbolFor(group), stroke);
    _paintSymbol(canvas, rect.center, cell * 0.29, symbolFor(group),
        stroke..color = color.withValues(alpha: 0.5));

    // Doluluk noktalari: kac beden var, kac gerekiyor.
    final dotY = rect.bottom - cell * 0.16;
    final spacing = cell * 0.13;
    final startX = rect.center.dx - spacing * (required - 1) / 2;
    for (var i = 0; i < required; i++) {
      canvas.drawCircle(
        Offset(startX + i * spacing, dotY),
        cell * 0.04,
        Paint()
          ..color = i < bodies
              ? color
              : color.withValues(alpha: 0.28),
      );
    }
  }

  void _paintDoor(
      Canvas canvas, Rect rect, double cell, int group, bool isOpen) {
    final color = DColors.group(group);
    final body = RRect.fromRectAndRadius(
        rect.deflate(cell * 0.1), Radius.circular(cell * 0.14));

    if (isOpen) {
      // Acik kapi: yalnizca soluk bir cerceve; gecilebildigi bir bakista belli.
      canvas.drawRRect(
        body,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, cell * 0.03)
          ..color = color.withValues(alpha: 0.35),
      );
      return;
    }

    canvas.drawRRect(body, Paint()..color = color.withValues(alpha: 0.85));
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, cell * 0.03)
        ..color = color,
    );
    _paintSymbol(
      canvas,
      rect.center,
      cell * 0.18,
      symbolFor(group),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.4, cell * 0.05)
        ..color = DColors.bgTop.withValues(alpha: 0.75),
    );
  }

  /// Solan kapi: acikken kalan tur sayisi cizgi cizgi gosterilir.
  void _paintFadingDoor(Canvas canvas, Rect rect, double cell) {
    const color = DColors.fading;
    final body = RRect.fromRectAndRadius(
        rect.deflate(cell * 0.1), Radius.circular(cell * 0.14));

    if (!state.fadingOpen) {
      canvas.drawRRect(body, Paint()..color = color.withValues(alpha: 0.8));
      canvas.drawRRect(
        body,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, cell * 0.03)
          ..color = color,
      );
      return;
    }

    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, cell * 0.03)
        ..color = color.withValues(alpha: 0.4),
    );

    final left = state.fadingTurnsLeft;
    final total = level.fadeTurns;
    final barWidth = cell * 0.5;
    final gap = cell * 0.03;
    final segment = (barWidth - gap * (total - 1)) / total;
    final startX = rect.center.dx - barWidth / 2;
    for (var i = 0; i < total; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
              startX + i * (segment + gap), rect.center.dy - cell * 0.03,
              segment, cell * 0.06),
          Radius.circular(cell * 0.03),
        ),
        Paint()..color = color.withValues(alpha: i < left ? 0.95 : 0.2),
      );
    }
  }

  /// Renk koru oyuncular icin her grup ayrica bir sekille de anlatilir.
  void _paintSymbol(Canvas canvas, Offset center, double radius,
      GroupSymbol symbol, Paint paint) {
    if (symbol == GroupSymbol.circle) {
      canvas.drawCircle(center, radius, paint);
    } else if (symbol == GroupSymbol.square) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: center, width: radius * 1.9, height: radius * 1.9),
          Radius.circular(radius * 0.28),
        ),
        paint,
      );
    } else {
      final path = Path()
        ..moveTo(center.dx, center.dy - radius)
        ..lineTo(center.dx + radius * 0.92, center.dy + radius * 0.72)
        ..lineTo(center.dx - radius * 0.92, center.dy + radius * 0.72)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  // Tahta kucuk ve yalnizca setState ile yeniden kurulur; her seferinde
  // yeniden cizmek, hangi alanin degistigini takip etmekten ucuzdur.
  @override
  bool shouldRepaint(_BoardPainter oldDelegate) => true;
}
