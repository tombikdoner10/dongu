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
