import 'package:meta/meta.dart';

/// Oyuncunun tek bir turda yapabilecegi hareketler.
enum GameAction { up, down, left, right, wait }

extension GameActionDelta on GameAction {
  int get dx => switch (this) {
        GameAction.left => -1,
        GameAction.right => 1,
        _ => 0,
      };

  int get dy => switch (this) {
        GameAction.up => -1,
        GameAction.down => 1,
        _ => 0,
      };

  bool get isMove => this != GameAction.wait;
}

/// Izgara uzerindeki bir hucre. [x] sutun, [y] satir.
@immutable
class Pos {
  const Pos(this.x, this.y);

  final int x;
  final int y;

  Pos moved(GameAction action) => Pos(x + action.dx, y + action.dy);

  @override
  bool operator ==(Object other) =>
      other is Pos && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => '($x,$y)';
}

enum TileType {
  wall,
  floor,
  exit,

  /// Uzerinde bir beden varken grubunu acar.
  plate,

  /// Acilmasi icin uzerinde **iki** beden gerekir. Yankilar birbirini
  /// engellemedigi icin ayni kareye yiginabilirler.
  heavyPlate,

  /// Grubundaki plaka basiliyken gecilir.
  door,

  /// Her dongunun yalnizca ilk birkac turunda acik olan kapi. Hicbir plakaya
  /// bagli degildir; tamamen tur sayacina baglidir.
  fadingDoor,

  /// Uzerinden bir beden cekildiginde coken zemin. Cokme dongu basinda geri
  /// alinir.
  fragile,
}

/// Haritadaki sabit bir kare. [group] yalnizca plaka ve kapilar icin
/// anlamlidir; ayni gruptaki plaka ilgili kapiyi acar.
@immutable
class Tile {
  const Tile(this.type, [this.group = -1]);

  final TileType type;
  final int group;

  bool get isPlate =>
      type == TileType.plate || type == TileType.heavyPlate;

  /// Grubun acilmasi icin plakanin uzerinde kac beden gerekir.
  int get requiredBodies => type == TileType.heavyPlate ? 2 : 1;

  static const Tile wall = Tile(TileType.wall);
  static const Tile floor = Tile(TileType.floor);
  static const Tile exit = Tile(TileType.exit);
  static const Tile fragile = Tile(TileType.fragile);
  static const Tile fadingDoor = Tile(TileType.fadingDoor);
}
