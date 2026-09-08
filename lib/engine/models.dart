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

  /// Uzerine basildiginda grubun durumunu kalici olarak degistirir; orada
  /// durmak gerekmez. Plakanin tersi: "biri kalmali" kisitini kaldirir.
  toggle,

  /// Grubundaki plaka basiliyken ya da dugmesi acikken gecilir.
  door,

  /// Her dongunun yalnizca ilk birkac turunda acik olan kapi. Hicbir plakaya
  /// bagli degildir; tamamen tur sayacina baglidir.
  fadingDoor,

  /// Uzerinden bir beden cekildiginde coken zemin. Cokme dongu basinda geri
  /// alinir.
  fragile,

  /// Uzerine adim atan beden, bir engele kadar ayni yonde kayar.
  ice,

  /// Yalnizca belirli bir yonde girilebilen kare. Yon [Tile.oneWayDirection].
  oneWay,

  /// Cifti olan isinlanma kapisi; uzerine gelen beden esine tasinir.
  teleport,
}

/// Haritadaki sabit bir kare.
///
/// [group] birden fazla is gorur: plaka/dugme/kapi icin renk grubu, tek yonlu
/// gecit icin yon, isinlanma kapisi icin cift numarasi.
@immutable
class Tile {
  const Tile(this.type, [this.group = -1]);

  final TileType type;
  final int group;

  bool get isPlate =>
      type == TileType.plate || type == TileType.heavyPlate;

  /// Grubun acilmasi icin plakanin uzerinde kac beden gerekir.
  int get requiredBodies => type == TileType.heavyPlate ? 2 : 1;

  /// Tek yonlu gecidin izin verdigi yon.
  GameAction get oneWayDirection => switch (group) {
        0 => GameAction.up,
        1 => GameAction.down,
        2 => GameAction.left,
        _ => GameAction.right,
      };

  static const Tile wall = Tile(TileType.wall);
  static const Tile floor = Tile(TileType.floor);
  static const Tile exit = Tile(TileType.exit);
  static const Tile fragile = Tile(TileType.fragile);
  static const Tile fadingDoor = Tile(TileType.fadingDoor);
  static const Tile ice = Tile(TileType.ice);
}
