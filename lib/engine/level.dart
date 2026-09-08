import 'models.dart';

/// ASCII bir haritadan uretilen, degismeyen seviye tanimi.
///
/// Harita alfabesi:
///   "#" duvar, "." zemin, "P" baslangic, "E" cikis, "X" sandik
///   "1 2 3" plaka, "4 5 6" agir plaka (iki beden ister),
///   "7 8 9" dugme (basilinca kalici acar/kapatir)
///   "A B C" kapi, "T" solan kapi
///
/// Grup eslesmesi sutun sutundur: 1/4/7 -> A, 2/5/8 -> B, 3/6/9 -> C. Yani
/// plaka "1" ile dugme "7" ayni kapiyi surer; iki farkli kapi isteniyorsa
/// saglayicilar da farkli sutundan secilmelidir.
///   "~" kirilgan zemin, "*" buz
///   "^ v < >" tek yonlu gecit (yalnizca o yonde girilir)
///   "( )" ve "[ ]" isinlanma cifti
class Level {
  Level._({
    required this.id,
    required this.titleTr,
    required this.titleEn,
    required this.hintTr,
    required this.hintEn,
    required this.grid,
    required this.spawn,
    required this.exit,
    required this.boxSpawns,
    required this.teleportPartners,
    required this.maxTurns,
    required this.maxClones,
    required this.fadeTurns,
    required this.timingSensitive,
    required this.par,
    required this.solution,
    required this.contentLeft,
    required this.contentTop,
    required this.contentCols,
    required this.contentRows,
  });

  /// Haritayi cozumler. Bozuk bir harita [FormatException] firlatir; boylece
  /// hatali seviye testte aninda yakalanir, oyuncuya asla ulasmaz.
  factory Level.parse({
    required int id,
    required String titleTr,
    required String titleEn,
    required String hintTr,
    required String hintEn,
    required String map,
    required int maxTurns,
    required int maxClones,
    required int par,
    int fadeTurns = 0,
    bool timingSensitive = false,
    List<List<GameAction>> solution = const <List<GameAction>>[],
  }) {
    final rows = map
        .split(RegExp(r'\r?\n'))
        .map((String line) => line.trim())
        .where((String line) => line.isNotEmpty)
        .toList();

    if (rows.isEmpty) {
      throw FormatException('Seviye $id: harita bos.');
    }

    const oneWayChars = <String, int>{'^': 0, 'v': 1, '<': 2, '>': 3};
    const teleportChars = <String, int>{'(': 0, ')': 0, '[': 1, ']': 1};

    final grid = <List<Tile>>[];
    final boxes = <Pos>[];
    final teleportEnds = <int, List<Pos>>{};
    var hasToggle = false;
    Pos? spawn;
    Pos? exit;

    for (var y = 0; y < rows.length; y++) {
      if (rows[y].length != rows.first.length) {
        throw FormatException('Seviye $id: ${y + 1}. satirin uzunlugu farkli.');
      }
      final row = <Tile>[];
      for (var x = 0; x < rows[y].length; x++) {
        final char = rows[y][x];
        final here = Pos(x, y);
        if (char == '#') {
          row.add(Tile.wall);
        } else if (char == '.') {
          row.add(Tile.floor);
        } else if (char == 'P') {
          row.add(Tile.floor);
          spawn = here;
        } else if (char == 'X') {
          row.add(Tile.floor);
          boxes.add(here);
        } else if (char == 'E') {
          row.add(Tile.exit);
          exit = here;
        } else if (char == '~') {
          row.add(Tile.fragile);
        } else if (char == '*') {
          row.add(Tile.ice);
        } else if (char == 'T') {
          row.add(Tile.fadingDoor);
        } else if (char == '1' || char == '2' || char == '3') {
          row.add(Tile(TileType.plate, int.parse(char) - 1));
        } else if (char == '4' || char == '5' || char == '6') {
          row.add(Tile(TileType.heavyPlate, int.parse(char) - 4));
        } else if (char == '7' || char == '8' || char == '9') {
          row.add(Tile(TileType.toggle, int.parse(char) - 7));
          hasToggle = true;
        } else if (char == 'A' || char == 'B' || char == 'C') {
          row.add(Tile(TileType.door, char.codeUnitAt(0) - 65));
        } else if (oneWayChars.containsKey(char)) {
          row.add(Tile(TileType.oneWay, oneWayChars[char]!));
        } else if (teleportChars.containsKey(char)) {
          final pair = teleportChars[char]!;
          row.add(Tile(TileType.teleport, pair));
          teleportEnds.putIfAbsent(pair, () => <Pos>[]).add(here);
        } else {
          throw FormatException(
              'Seviye $id: bilinmeyen harita karakteri "$char".');
        }
      }
      grid.add(row);
    }

    // Duvarlar cizilmedigi icin dis duvar halkasi bos yer kaplar. Ciziminin
    // kirpilabilmesi icin duvar disi karelerin sinir kutusu hesaplanir.
    var minX = grid.first.length;
    var maxX = -1;
    var minY = grid.length;
    var maxY = -1;
    for (var y = 0; y < grid.length; y++) {
      for (var x = 0; x < grid[y].length; x++) {
        if (grid[y][x].type == TileType.wall) {
          continue;
        }
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
    if (maxX < 0) {
      throw FormatException('Seviye $id: haritada hic zemin yok.');
    }

    final hasFadingDoor = grid.any((List<Tile> row) =>
        row.any((Tile tile) => tile.type == TileType.fadingDoor));
    if (hasFadingDoor && fadeTurns <= 0) {
      throw FormatException(
          'Seviye $id: solan kapi var ama fadeTurns verilmemis.');
    }

    // Isinlanma kapilari cift olmak zorunda; tek kalan bir kapi oyuncuyu
    // sessizce yutardi.
    final partners = <Pos, Pos>{};
    teleportEnds.forEach((int pair, List<Pos> ends) {
      if (ends.length != 2) {
        throw FormatException('Seviye $id: $pair numarali isinlanma cifti '
            '${ends.length} uclu; tam iki olmali.');
      }
      partners[ends[0]] = ends[1];
      partners[ends[1]] = ends[0];
    });

    if (spawn == null) {
      throw FormatException('Seviye $id: baslangic (P) yok.');
    }
    if (exit == null) {
      throw FormatException('Seviye $id: cikis (E) yok.');
    }

    return Level._(
      id: id,
      titleTr: titleTr,
      titleEn: titleEn,
      hintTr: hintTr,
      hintEn: hintEn,
      grid: grid,
      spawn: spawn,
      exit: exit,
      boxSpawns: boxes,
      teleportPartners: partners,
      maxTurns: maxTurns,
      maxClones: maxClones,
      fadeTurns: fadeTurns,
      // Dugmeli seviyelerde bir yankinin dugmeye **ne zaman** bastigi sonucu
      // degistirir; cozucu bu seviyelerde adaylari tur bazinda ayirmali.
      timingSensitive: timingSensitive || hasToggle,
      par: par,
      solution: solution,
      contentLeft: minX,
      contentTop: minY,
      contentCols: maxX - minX + 1,
      contentRows: maxY - minY + 1,
    );
  }

  final int id;
  final String titleTr;
  final String titleEn;
  final String hintTr;
  final String hintEn;
  final List<List<Tile>> grid;
  final Pos spawn;
  final Pos exit;
  final List<Pos> boxSpawns;

  /// Her isinlanma kapisindan esine.
  final Map<Pos, Pos> teleportPartners;

  /// Bir dongude oynanabilecek en fazla tur.
  final int maxTurns;

  /// Bankaya yatirilabilecek en fazla hayalet sayisi.
  final int maxClones;

  /// Solan kapilarin acik kaldigi tur sayisi (her dongunun basindan itibaren).
  final int fadeTurns;

  /// Bir yankinin **ne zaman** hareket ettigi sonucu degistiriyorsa true.
  /// Kirilgan zeminli ve dugmeli seviyelerde olabilir: erken gecen yanki
  /// koprüyu oyuncudan once yakar, erken basan yanki dugmeyi ters cevirir.
  /// Cozucu boyle seviyelerde adaylari tur bazinda da ayirir; pahali oldugu
  /// icin yalnizca gerektiginde acilir.
  final bool timingSensitive;

  /// Seviyenin gercekten gerektirdigi en az yanki sayisi. Cozucu bunu bulur;
  /// test dondurur, boylece bir harita degisikligi zorlugu sessizce kaydiramaz.
  final int par;

  /// Dongu dongu yazilmis ornek cozum. Testler bunu motordan gecirerek her
  /// seviyenin gercekten cozulebilir oldugunu dogrular.
  final List<List<GameAction>> solution;

  /// Cizilecek alanin sinir kutusu: dis duvar halkasi disarida birakilir.
  final int contentLeft;
  final int contentTop;
  final int contentCols;
  final int contentRows;

  int get rows => grid.length;
  int get cols => grid.first.length;

  bool inBounds(Pos p) => p.y >= 0 && p.y < rows && p.x >= 0 && p.x < cols;

  Tile tileAt(Pos p) => grid[p.y][p.x];

  String title(bool turkish) => turkish ? titleTr : titleEn;

  String hint(bool turkish) => turkish ? hintTr : hintEn;
}
