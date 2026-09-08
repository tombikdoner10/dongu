// ignore_for_file: avoid_print

// Seviyelerin birbirini ne kadar tekrar ettigini olcer.
//
//     dart run dev/level_variety.dart
//
// Her seviye icin yapisal bir imza uretir: satirlarin bicimi, kullanilan
// mekanikler, cikisin konumu. Ayni imzayi paylasan seviyeler oyuncuya "bunu
// zaten oynadim" hissi verir.

import 'package:dongu/data/levels.dart';
import 'package:dongu/engine/level.dart';
import 'package:dongu/engine/models.dart';

/// Bir satiri kaba bicimine indirger: koridor mu, acik alan mi, duvar mi.
String _rowShape(Level level, int y) {
  var open = 0;
  for (var x = level.contentLeft; x < level.contentLeft + level.contentCols; x++) {
    if (level.grid[y][x].type != TileType.wall) {
      open++;
    }
  }
  if (open == 0) return '#';
  if (open == 1) return '|'; // tek karelik koridor
  if (open >= level.contentCols - 1) return 'O'; // bastan basa acik
  return 'm'; // karisik
}

String _shapeSignature(Level level) {
  final buffer = StringBuffer();
  for (var y = level.contentTop; y < level.contentTop + level.contentRows; y++) {
    buffer.write(_rowShape(level, y));
  }
  return buffer.toString();
}

Set<String> _mechanics(Level level) {
  final found = <String>{};
  for (final row in level.grid) {
    for (final tile in row) {
      switch (tile.type) {
        case TileType.plate:
          found.add('plaka');
        case TileType.heavyPlate:
          found.add('agir');
        case TileType.toggle:
          found.add('dugme');
        case TileType.fadingDoor:
          found.add('solan');
        case TileType.fragile:
          found.add('kirilgan');
        case TileType.ice:
          found.add('buz');
        case TileType.oneWay:
          found.add('tekyon');
        case TileType.teleport:
          found.add('isinlanma');
        case TileType.wall:
        case TileType.floor:
        case TileType.exit:
        case TileType.door:
          break;
      }
    }
  }
  if (level.boxSpawns.isNotEmpty) found.add('sandik');
  return found;
}

/// Cikis, baslangica gore nerede? Yon cesitliligi de bir tekrar olcusudur.
String _exitDirection(Level level) {
  final dx = level.exit.x - level.spawn.x;
  final dy = level.exit.y - level.spawn.y;
  if (dy.abs() > dx.abs()) return dy > 0 ? 'asagi' : 'yukari';
  if (dx.abs() > 0) return dx > 0 ? 'saga' : 'sola';
  return 'ayni';
}

void main() {
  final byShape = <String, List<Level>>{};
  final byDirection = <String, int>{};
  var singleCorridor = 0;

  print('id  seviye              olcu    imza                 mekanikler');
  print('-' * 78);
  for (final level in kLevels) {
    final shape = _shapeSignature(level);
    byShape.putIfAbsent(shape, () => <Level>[]).add(level);
    final direction = _exitDirection(level);
    byDirection[direction] = (byDirection[direction] ?? 0) + 1;
    if (shape.contains('|||')) singleCorridor++;

    print('${level.id.toString().padRight(4)}'
        '${level.titleTr.padRight(20)}'
        '${'${level.contentCols}x${level.contentRows}'.padRight(8)}'
        '${shape.padRight(21)}'
        '${(_mechanics(level).toList()..sort()).join(', ')}');
  }

  print('');
  print('=== ayni yapiyi paylasan seviyeler ===');
  final repeats = byShape.entries.where((e) => e.value.length > 1).toList()
    ..sort((a, b) => b.value.length.compareTo(a.value.length));
  for (final entry in repeats) {
    final ids = entry.value.map((Level l) => l.id).join(', ');
    print('${entry.value.length} seviye  ${entry.key.padRight(21)} -> $ids');
  }

  final duplicated = repeats.fold<int>(0, (int a, e) => a + e.value.length);
  print('');
  print('toplam seviye            : ${kLevels.length}');
  print('benzersiz yapi           : ${byShape.length}');
  print('bir yapiyi paylasan      : $duplicated seviye');
  print('uc+ karelik dikey koridor: $singleCorridor seviye');
  print('cikis yonu dagilimi      : $byDirection');
}
