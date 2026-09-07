import 'level.dart';
import 'models.dart';

/// [GameState.startNewLoop] sonucu.
enum LoopResult {
  /// Kayit hayalete donustu, yeni dongu basladi.
  ok,

  /// Hayalet hakki dolmustu; seviye bastan basladi.
  cloneLimitReached,

  /// Seviye zaten kazanilmis.
  alreadyWon,
}

class _Mover {
  _Mover(this.index, this.action);

  /// -1 ise oyuncu, degilse hayalet indeksi.
  final int index;
  final GameAction action;

  bool get isPlayer => index < 0;
}

class _Snapshot {
  _Snapshot(
    this.player,
    this.ghosts,
    this.boxes,
    this.collapsed,
    this.recordings,
    this.current,
    this.turn,
    this.won,
  );

  final Pos player;
  final List<Pos> ghosts;
  final List<Pos> boxes;
  final Set<Pos> collapsed;
  final List<List<GameAction>> recordings;
  final List<GameAction> current;
  final int turn;
  final bool won;
}

/// Tek bir seviyenin oynanis durumu.
///
/// Bilerek saf Dart: hicbir Flutter bagimliligi yok, boylece testler cihaz
/// acmadan saniyeler icinde calisir.
class GameState {
  GameState(this.level) {
    restartLevel();
  }

  /// Hazir hayalet kayitlariyla bastan baslar. Cozucu, bir donguyu belirli
  /// yankilar altinda tarayabilmek icin bunu kullanir.
  GameState.withGhosts(this.level, List<List<GameAction>> ghostRecordings) {
    recordings = ghostRecordings.map(List<GameAction>.of).toList();
    current = <GameAction>[];
    won = false;
    _resetBodies();
  }

  /// Arama ve dogrulama icin ucuz kopya. Gecmis yigini kopyalanmaz.
  GameState.copy(GameState other) : level = other.level {
    player = other.player;
    ghosts = List<Pos>.of(other.ghosts);
    boxes = List<Pos>.of(other.boxes);
    collapsed = Set<Pos>.of(other.collapsed);
    recordings = other.recordings.map(List<GameAction>.of).toList();
    current = List<GameAction>.of(other.current);
    turn = other.turn;
    won = other.won;
  }

  final Level level;

  late Pos player;
  late List<Pos> ghosts;
  late List<Pos> boxes;

  /// Bu dongude cokmus kirilgan zeminler.
  late Set<Pos> collapsed;

  /// Tamamlanmis dongulerin kayitlari; her biri bir hayaleti surer.
  late List<List<GameAction>> recordings;

  /// Icinde bulunulan dongude su ana kadar yapilan hamleler.
  late List<GameAction> current;

  late int turn;
  late bool won;

  final List<_Snapshot> _history = <_Snapshot>[];
  static const int _maxHistory = 400;

  int get cloneCount => recordings.length;

  int get turnsLeft => level.maxTurns - turn;

  bool get loopExhausted => turn >= level.maxTurns;

  bool get canUndo => _history.isNotEmpty;

  bool get canStartNewLoop => !won && recordings.length < level.maxClones;

  /// Solan kapilar su an gecilebilir mi?
  bool get fadingOpen => turn < level.fadeTurns;

  /// Solan kapilarin kapanmasina kalan tur.
  int get fadingTurnsLeft =>
      level.fadeTurns > turn ? level.fadeTurns - turn : 0;

  /// Su an acik olan kapi gruplari.
  Set<int> get openGroups => _openGroups();

  bool isDoorOpen(int group) => _openGroups().contains(group);

  /// Verilen karede kac beden duruyor. Agir plakalarin gostergesi icin.
  int bodiesOn(Pos p) {
    var count = player == p ? 1 : 0;
    for (final ghost in ghosts) {
      if (ghost == p) count++;
    }
    for (final box in boxes) {
      if (box == p) count++;
    }
    return count;
  }

  /// Arama sirasinda tekrar eden durumlari elemek icin anahtar.
  String get stateKey => '$effectKey|$turn';

  /// Bir kaydin gelecege birakabilecegi izin tamami: nerede durdugu, sandiklari
  /// nereye koydugu ve hangi zeminleri cokerttigi. Tur bilincli olarak disarida
  /// birakilir; ayni ize varan iki yoldan kisa olani her zaman en az iyisidir.
  String get effectKey {
    final boxKey = List<Pos>.of(boxes)..sort(_byPosition);
    final collapsedKey = List<Pos>.of(collapsed)..sort(_byPosition);
    return '$player|${boxKey.join(',')}|${collapsedKey.join(',')}';
  }

  void restartLevel() {
    recordings = <List<GameAction>>[];
    current = <GameAction>[];
    won = false;
    _history.clear();
    _resetBodies();
  }

  void _resetBodies() {
    player = level.spawn;
    ghosts = List<Pos>.filled(recordings.length, level.spawn, growable: true);
    boxes = List<Pos>.of(level.boxSpawns);
    collapsed = <Pos>{};
    turn = 0;
  }

  /// Bir tur oynatir. Hamle kabul edildiyse true doner.
  bool step(GameAction action) {
    if (won || loopExhausted) {
      return false;
    }
    _pushHistory();
    current.add(action);

    // Kapi durumu turun BASINDA sabitlenir ve tur icinde degismez.
    final open = _openGroups();

    final movers = <_Mover>[];
    for (var i = 0; i < ghosts.length; i++) {
      final recorded = recordings[i];
      final ghostAction =
          turn < recorded.length ? recorded[turn] : GameAction.wait;
      if (ghostAction.isMove) {
        movers.add(_Mover(i, ghostAction));
      }
    }
    if (action.isMove) {
      movers.add(_Mover(-1, action));
    }

    final vacated = _resolve(movers, open);
    _collapseVacatedFragileTiles(vacated);

    turn++;
    if (player == level.exit) {
      won = true;
    }
    return true;
  }

  /// Icinde bulunulan donguyu kapatip kaydi hayalete cevirir.
  LoopResult startNewLoop() {
    if (won) {
      return LoopResult.alreadyWon;
    }
    if (recordings.length >= level.maxClones) {
      restartLevel();
      return LoopResult.cloneLimitReached;
    }
    _pushHistory();
    recordings.add(List<GameAction>.of(current));
    current = <GameAction>[];
    _resetBodies();
    return LoopResult.ok;
  }

  void undo() {
    if (_history.isEmpty) {
      return;
    }
    final snapshot = _history.removeLast();
    player = snapshot.player;
    ghosts = List<Pos>.of(snapshot.ghosts);
    boxes = List<Pos>.of(snapshot.boxes);
    collapsed = Set<Pos>.of(snapshot.collapsed);
    recordings = snapshot.recordings.map(List<GameAction>.of).toList();
    current = List<GameAction>.of(snapshot.current);
    turn = snapshot.turn;
    won = snapshot.won;
  }

  void _pushHistory() {
    _history.add(
      _Snapshot(
        player,
        List<Pos>.of(ghosts),
        List<Pos>.of(boxes),
        Set<Pos>.of(collapsed),
        recordings.map(List<GameAction>.of).toList(),
        List<GameAction>.of(current),
        turn,
        won,
      ),
    );
    if (_history.length > _maxHistory) {
      _history.removeAt(0);
    }
  }

  /// Plakalarin uzerindeki beden sayisi esigi gecen gruplar.
  Set<int> _openGroups() {
    final counts = <Pos, int>{};
    void tally(Pos p) => counts[p] = (counts[p] ?? 0) + 1;

    tally(player);
    for (final ghost in ghosts) {
      tally(ghost);
    }
    for (final box in boxes) {
      tally(box);
    }

    final groups = <int>{};
    counts.forEach((Pos position, int count) {
      final tile = level.tileAt(position);
      if (tile.isPlate && count >= tile.requiredBodies) {
        groups.add(tile.group);
      }
    });
    return groups;
  }

  /// Hicbir ilerleme kalmayana kadar tekrar tekrar dener. Boylece "yankinin
  /// hemen arkasindan yurume" zinciri, listenin sirasindan bagimsiz cozulur.
  ///
  /// Bosaltilan kareleri dondurur; kirilgan zeminlerin cokmesi icin gerekir.
  Set<Pos> _resolve(List<_Mover> movers, Set<int> open) {
    final vacated = <Pos>{};
    final pending = List<_Mover>.of(movers);
    while (pending.isNotEmpty) {
      final moved = <_Mover>[];
      for (final mover in pending) {
        final from = mover.isPlayer ? player : ghosts[mover.index];
        if (_tryMove(mover, open)) {
          moved.add(mover);
          vacated.add(from);
        }
      }
      if (moved.isEmpty) {
        break;
      }
      pending.removeWhere(moved.contains);
    }
    return vacated;
  }

  /// Uzerinden cekilen kirilgan zemin coker. Karede hala bir beden duruyorsa
  /// zemin ayakta kalir: kimse bosluga dusmez.
  void _collapseVacatedFragileTiles(Set<Pos> vacated) {
    for (final position in vacated) {
      if (level.tileAt(position).type != TileType.fragile) {
        continue;
      }
      if (bodiesOn(position) > 0) {
        continue;
      }
      collapsed.add(position);
    }
  }

  bool _tryMove(_Mover mover, Set<int> open) {
    final from = mover.isPlayer ? player : ghosts[mover.index];
    final to = from.moved(mover.action);
    if (!_passable(to, open)) {
      return false;
    }

    // Hayaletler kati degildir (gecmisin yankisisin), sandiklar katidir.
    final boxIndex = boxes.indexOf(to);
    if (boxIndex >= 0) {
      final beyond = to.moved(mover.action);
      if (!_passable(beyond, open) || boxes.contains(beyond)) {
        return false;
      }
      boxes[boxIndex] = beyond;
    }

    if (mover.isPlayer) {
      player = to;
    } else {
      ghosts[mover.index] = to;
    }
    return true;
  }

  bool _passable(Pos p, Set<int> open) {
    if (!level.inBounds(p)) {
      return false;
    }
    final tile = level.tileAt(p);
    switch (tile.type) {
      case TileType.wall:
        return false;
      case TileType.door:
        return open.contains(tile.group);
      case TileType.fadingDoor:
        return fadingOpen;
      case TileType.fragile:
        return !collapsed.contains(p);
      case TileType.floor:
      case TileType.exit:
      case TileType.plate:
      case TileType.heavyPlate:
        return true;
    }
  }

  static int _byPosition(Pos a, Pos b) => a.y != b.y ? a.y - b.y : a.x - b.x;
}
