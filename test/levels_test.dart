import 'package:dongu/data/levels.dart';
import 'package:dongu/engine/game_state.dart';
import 'package:dongu/engine/level.dart';
import 'package:dongu/engine/models.dart';
import 'package:dongu/engine/solver.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bir cozumu dongu dongu motorda oynatir.
GameState _play(Level level, List<List<GameAction>> loops) {
  final state = GameState(level);
  for (var loop = 0; loop < loops.length; loop++) {
    for (final action in loops[loop]) {
      state.step(action);
    }
    if (loop < loops.length - 1) {
      state.startNewLoop();
    }
  }
  return state;
}

void main() {
  test('seviye kimlikleri 1..n, sirali ve benzersiz', () {
    expect(
      kLevels.map((Level level) => level.id).toList(),
      List<int>.generate(kLevels.length, (int i) => i + 1),
    );
  });

  for (final level in kLevels) {
    group('Seviye ${level.id} - ${level.titleTr}', () {
      late Solution solution;

      setUpAll(() {
        final found = solve(level);
        expect(found, isNotNull,
            reason: 'seviye ${level.id} cozucu tarafindan cozulemedi');
        solution = found!;
      });

      test('cozucunun cozumu gercekten kazandiriyor', () {
        // Cozucuye korukoru guvenmeyelim: buldugu cozum motorda oynatilir.
        expect(_play(level, solution.loops).won, isTrue);
      });

      test('zorluk beyan edilen par ile ayni', () {
        expect(solution.echoes, level.par,
            reason: 'seviye ${level.id} artik ${solution.echoes} yanki '
                'gerektiriyor, par ${level.par} yaziyor');
      });

      test('par ve tur sinirlari tutarli', () {
        expect(level.par, lessThanOrEqualTo(level.maxClones));
        expect(solution.longestLoop, lessThanOrEqualTo(level.maxTurns));
      });

      test('her kapinin plakasi, her plakanin kapisi var', () {
        // "1 2 3" ile "4 5 6" ayni gruplarin hafif/agir bicimleridir; kolayca
        // karistirilir. Plakasiz bir kapi seviyeyi cozulemez yapar, kapisiz bir
        // plaka ise oyuncuyu bosuna oyalar.
        final plateGroups = <int>{};
        final doorGroups = <int>{};
        for (final row in level.grid) {
          for (final tile in row) {
            if (tile.isPlate) {
              plateGroups.add(tile.group);
            } else if (tile.type == TileType.door) {
              doorGroups.add(tile.group);
            }
          }
        }
        expect(doorGroups.difference(plateGroups), isEmpty,
            reason: 'seviye ${level.id}: plakasi olmayan kapi grubu var');
        expect(plateGroups.difference(doorGroups), isEmpty,
            reason: 'seviye ${level.id}: kapisi olmayan plaka grubu var');
      });

      test('plaka kendi kapisinin bitisiginde degil', () {
        // Kapi durumu turun BASINDA sabitlenir: plakanin uzerindeki beden,
        // hemen bitisikteki kendi kapisindan gecebilir (hamle degerlendirilirken
        // hala plakadadir). Bu, kapiyi bedavaya cevirir ve seviyeyi tasarlanandan
        // kolay yapar. Iki kez bu tuzaga dusuldugu icin artik testle yakalaniyor.
        for (var y = 0; y < level.rows; y++) {
          for (var x = 0; x < level.cols; x++) {
            final tile = level.grid[y][x];
            if (!tile.isPlate) {
              continue;
            }
            for (final step in <Pos>[
              Pos(x + 1, y),
              Pos(x - 1, y),
              Pos(x, y + 1),
              Pos(x, y - 1),
            ]) {
              if (!level.inBounds(step)) {
                continue;
              }
              final neighbour = level.tileAt(step);
              expect(
                neighbour.type == TileType.door &&
                    neighbour.group == tile.group,
                isFalse,
                reason: 'seviye ${level.id}: ($x,$y) plakasi kendi kapisinin '
                    'bitisiginde — plakadaki beden kapidan sizabilir',
              );
            }
          }
        }
      });

      test('ogretici disindaki seviyeler yanki gerektiriyor', () {
        // par == 0 demek "duz yuruyerek gecilir" demek; bu yalnizca giris
        // seviyesinde kabul edilebilir.
        if (level.maxClones > 0) {
          expect(level.par, greaterThan(0),
              reason: 'seviye ${level.id} yanki olmadan cozulebiliyor');
        }
      });

      test('elle yazilmis cozum varsa hala kazandiriyor', () {
        if (level.solution.isEmpty) {
          return;
        }
        expect(_play(level, level.solution).won, isTrue);
        expect(level.solution.length - 1, lessThanOrEqualTo(level.maxClones));
      });
    });
  }
}
