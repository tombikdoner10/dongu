// ignore_for_file: avoid_print

// Bir seviyenin cozumunu dongu dongu yazar; seviyenin gercekten tasarlanan
// fikri gerektirdigini gozle dogrulamak icin.
//
//     dart run dev/solution_dump.dart 23

import 'package:dongu/data/levels.dart';
import 'package:dongu/engine/level.dart';
import 'package:dongu/engine/models.dart';
import 'package:dongu/engine/solver.dart';

String _glyph(GameAction action) => switch (action) {
      GameAction.up => '^',
      GameAction.down => 'v',
      GameAction.left => '<',
      GameAction.right => '>',
      GameAction.wait => '.',
    };

void main(List<String> args) {
  final id = args.isEmpty ? kLevels.last.id : int.parse(args.first);
  final level = kLevels.firstWhere((Level l) => l.id == id);

  print('Seviye ${level.id} - ${level.titleTr}');
  for (final row in level.grid) {
    print('  ${row.map(_tileGlyph).join()}');
  }

  final solution = solve(level);
  if (solution == null) {
    print('  cozulemedi');
    return;
  }

  print('');
  for (var i = 0; i < solution.loops.length; i++) {
    final last = i == solution.loops.length - 1;
    final label = last ? 'oyuncu ' : 'yanki ${i + 1}';
    print('  $label: ${solution.loops[i].map(_glyph).join(' ')}');
  }
  print('  (^ yukari, v asagi, < sol, > sag, . bekle)');
}

String _tileGlyph(Tile tile) => switch (tile.type) {
      TileType.wall => '#',
      TileType.floor => '.',
      TileType.exit => 'E',
      TileType.plate => '${tile.group + 1}',
      TileType.heavyPlate => '${tile.group + 4}',
      TileType.door => String.fromCharCode(65 + tile.group),
      TileType.fadingDoor => 'T',
      TileType.fragile => '~',
    };
