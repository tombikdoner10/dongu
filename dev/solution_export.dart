// ignore_for_file: avoid_print

// Her seviyenin cozumunu makine okunur bicimde yazar; dev/play_all.py bunu
// emulatorde gercek dokunuslara cevirir.
//
//     dart run dev/solution_export.dart > solutions.txt
//
// Bicim:  id|par|LOOP,LOOP,...     (U yukari, D asagi, L sol, R sag, W bekle)

import 'package:dongu/data/levels.dart';
import 'package:dongu/engine/models.dart';
import 'package:dongu/engine/solver.dart';

String _glyph(GameAction action) => switch (action) {
      GameAction.up => 'U',
      GameAction.down => 'D',
      GameAction.left => 'L',
      GameAction.right => 'R',
      GameAction.wait => 'W',
    };

void main() {
  for (final level in kLevels) {
    final solution = solve(level);
    if (solution == null) {
      print('${level.id}|${level.par}|COZULEMEDI');
      continue;
    }
    final loops = solution.loops
        .map((List<GameAction> loop) => loop.map(_glyph).join())
        .join(',');
    print('${level.id}|${level.par}|$loops');
  }
}
