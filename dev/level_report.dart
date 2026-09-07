// ignore_for_file: avoid_print

// Her seviyeyi cozucuden gecirir ve gercek zorlugunu bildirir.
//
//     dart run dev/level_report.dart
//
// "yanki" sutunu seviyenin gercekten kac kopya gerektirdigidir (par). Tasarim
// niyetiyle uyusmuyorsa harita duzeltilir; uyusuyorsa deger levels.dart'a
// yazilip testle dondurulur.

import 'package:dongu/data/levels.dart';
import 'package:dongu/engine/game_state.dart';
import 'package:dongu/engine/level.dart';
import 'package:dongu/engine/solver.dart';

/// Cozucunun buldugu cozumu motorda oynatip gercekten kazandigini dogrular.
bool _replayWins(Level level, Solution solution) {
  final state = GameState(level);
  for (var loop = 0; loop < solution.loops.length; loop++) {
    for (final action in solution.loops[loop]) {
      state.step(action);
    }
    if (loop < solution.loops.length - 1) {
      state.startNewLoop();
    }
  }
  return state.won;
}

void main() {
  print('id  seviye              yanki  par  tur/limit  kopya  sure   dogrulama');
  print('-' * 78);

  for (final level in kLevels) {
    final watch = Stopwatch()..start();
    Solution? solution;
    String? failure;
    try {
      solution = solve(level);
    } on SolverBudgetExceeded {
      failure = 'BUTCE ASILDI';
    }
    watch.stop();

    if (solution == null) {
      print('${level.id.toString().padRight(4)}'
          '${level.titleTr.padRight(20)}'
          '${failure ?? 'COZULEMEZ'}');
      continue;
    }

    final ok = _replayWins(level, solution);
    final matchesPar = solution.echoes == level.par;
    print(
      '${level.id.toString().padRight(4)}'
      '${level.titleTr.padRight(20)}'
      '${solution.echoes.toString().padRight(7)}'
      '${level.par.toString().padRight(5)}'
      '${'${solution.longestLoop}/${level.maxTurns}'.padRight(11)}'
      '${level.maxClones.toString().padRight(7)}'
      '${'${watch.elapsedMilliseconds}ms'.padRight(7)}'
      '${ok ? 'oynandi' : 'TEKRAR OYNAMADI'}'
      '${matchesPar ? '' : '  <-- PAR UYUSMUYOR'}',
    );
  }

  // Elle yazilmis cozumler hala duruyorsa onlari da capraz kontrol et.
  print('');
  for (final level in kLevels) {
    if (level.solution.isEmpty) {
      continue;
    }
    final state = GameState(level);
    for (var loop = 0; loop < level.solution.length; loop++) {
      for (final action in level.solution[loop]) {
        state.step(action);
      }
      if (loop < level.solution.length - 1) {
        state.startNewLoop();
      }
    }
    final echoes = level.solution.length - 1;
    print('Seviye ${level.id}: elle yazilan cozum '
        '${state.won ? 'kazaniyor' : 'KAZANMIYOR'}, $echoes yanki');
  }
}
