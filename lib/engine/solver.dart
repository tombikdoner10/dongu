import 'game_state.dart';
import 'level.dart';
import 'models.dart';

/// Bir seviyenin dongu dongu cozumu.
class Solution {
  const Solution(this.loops);

  /// Her eleman bir dongude yapilan hamleler; sonuncusu kazanan dongudur.
  final List<List<GameAction>> loops;

  /// Kullanilan yanki sayisi (son dongu oyuncunun kendisidir).
  int get echoes => loops.length - 1;

  int get longestLoop =>
      loops.fold(0, (int a, List<GameAction> l) => l.length > a ? l.length : a);
}

/// Arama butcesi asilirsa firlatilir. Sessizce "cozulemez" demektense
/// gurultulu basarisizlik tercih edilir; boyle bir seviye zaten fazla buyuktur.
class SolverBudgetExceeded implements Exception {
  const SolverBudgetExceeded();

  @override
  String toString() => 'Cozucu butcesi asildi: seviye otomatik dogrulanamiyor.';
}

/// Seviyeyi **en az yanki** ile cozer; cozulemezse null doner.
///
/// Yaklasim: bir hayaletin gelecege tek etkisi kaydidir. Bu mekanik setinde
/// hayaletler kati olmadigi icin bir kopya yalnizca **plakaya oturarak** ya da
/// **sandik iterek** ise yarar. Bu yuzden aday kayitlar "bir yere en kisa
/// yoldan git ve orada bekle" ile sinirlandirilir; arama uzayi ussel olmaktan
/// cikip hucre sayisiyla olculebilir hale gelir.
///
/// Erken varmak hicbir zaman zarar vermedigi icin (kapi basili tutuldugu
/// surece acik kalir, kimseyi ezmez) en kisa yol secmek kayip yaratmaz.
///
/// Aday kayitlar ayrica **sonunda bir plaka basiyor olmak** sartina baglidir:
/// bir kopya ancak boyle ise yarar. Bu bir sezgiseldir, dolayisiyla cozucu
/// **tam degildir** — sandigi yalnizca yoldan cekmek icin harcanan bir yanki
/// gerektiren bir seviyeyi bulamayabilir ve "cozulemez" diyebilir. Buna
/// karsilik **yanlis pozitif uretmesi imkansizdir**: dondurdugu her cozum
/// motorda oynatilarak dogrulanir.
Solution? solve(Level level, {int nodeBudget = 6000000}) {
  for (var clones = 0; clones <= level.maxClones; clones++) {
    // Iki asama: once ucuz arama (adaylar yalnizca birakilan ize gore elenir).
    // Zamanlamaya duyarli seviyelerin cogu da bununla cozuluyor; cozulmezse
    // adaylara tur de katilarak tekrar denenir. Tek asamali titiz arama, ayni
    // sonucu bulmak icin onlarca kat daha uzun suruyordu.
    for (final turnKeyed in <bool>[false, true]) {
      if (turnKeyed && !level.timingSensitive) {
        break; // turdan bagimsiz seviyede ikinci asamanin getirisi yok
      }
      // Her deneme kendi butcesiyle calisir. Ortak butce kullanildiginda
      // dusuk yanki sayilarindaki titiz arama butceyi tuketip asil cozumun
      // bulunmasini engelliyordu.
      final budget = _Budget(nodeBudget);
      // Her asama icin taze ziyaret kumesi: ayni hayalet kumesine hep ayni
      // kalan hakla ulasilir, dolayisiyla eleme guvenlidir.
      try {
        final found = _search(level, <List<GameAction>>[], clones, budget,
            <String>{}, turnKeyed);
        if (found != null) {
          return found;
        }
      } on SolverBudgetExceeded {
        // Titiz arama pahalidir; tukendiyse "bulamadim" deyip devam ederiz.
        // Ucuz aramanin tukenmesi ise gercekten seviyenin fazla buyuk olmasi
        // demektir, o yuzden yukari birakilir.
        if (!turnKeyed) {
          rethrow;
        }
      }
    }
  }
  return null;
}

/// Yalnizca en az yanki sayisi; cozulemezse null.
int? minimumEchoes(Level level, {int nodeBudget = 6000000}) =>
    solve(level, nodeBudget: nodeBudget)?.echoes;

Solution? _search(
  Level level,
  List<List<GameAction>> ghosts,
  int remaining,
  _Budget budget,
  Set<String> seen,
  bool turnKeyed,
) {
  if (!seen.add(_ghostKey(ghosts))) {
    return null;
  }

  final explored = _explore(level, ghosts, budget, turnKeyed);
  if (explored.winning != null) {
    return Solution(<List<GameAction>>[...ghosts, explored.winning!]);
  }
  if (remaining == 0) {
    return null;
  }

  for (final candidate in explored.candidates) {
    final found = _search(
      level,
      <List<GameAction>>[...ghosts, candidate],
      remaining - 1,
      budget,
      seen,
      turnKeyed,
    );
    if (found != null) {
      return found;
    }
  }
  return null;
}

class _Explored {
  List<GameAction>? winning;
  final List<List<GameAction>> candidates = <List<GameAction>>[];
}

class _Node {
  _Node(this.state, this.parent, this.action);

  final GameState state;
  final int parent;
  final GameAction action;
}

/// Verilen hayaletlerle tek bir donguyu bastan sona tarar.
///
/// Tek gezinti iki isi birden yapar: kazanan hamle dizisini arar ve sonraki
/// dongulerde kullanilabilecek aday kayitlari toplar.
_Explored _explore(
  Level level,
  List<List<GameAction>> ghosts,
  _Budget budget,
  bool turnKeyed,
) {
  final result = _Explored();
  final root = GameState.withGhosts(level, ghosts);

  final nodes = <_Node>[_Node(root, -1, GameAction.wait)];
  final visited = <String>{root.stateKey};
  final candidateKeys = <String>{};

  for (var head = 0; head < nodes.length; head++) {
    budget.spend();
    final state = nodes[head].state;

    if (state.won) {
      result.winning = _pathTo(nodes, head);
      return result;
    }

    // Bir kopya ancak GERIDE BASILI BIR PLAKA birakirsa ise yarar: ya kendisi
    // plakada durur, ya da bir sandigi plakaya oturtmustur. Sandigi bos bir
    // kareye iten adaylar elenir; aksi halde dallanma carpani onlarca kat
    // buyuyup arama patliyor.
    if (state.turn > 0) {
      final standsOnPlate = level.tileAt(state.player).isPlate;
      final crateOnPlate =
          state.boxes.any((Pos box) => level.tileAt(box).isPlate);
      // Dugme ceviren bir kopya hicbir plakada durmasa da ise yarar: cevirdigi
      // kilit dongunun sonuna kadar acik kalir.
      final flippedToggle = state.latched.isNotEmpty;
      if (standsOnPlate || crateOnPlate || flippedToggle) {
        // Anahtar sandiklari ve cokmus zeminleri de icerir: ayni plakaya
        // farkli yollardan varmak gelecege farkli bir miras birakir.
        //
        // Zamanlamaya duyarli seviyelerde tur da anahtara girer. Aksi halde
        // "hemen gec" ile "iki tur bekleyip gec" ayni aday sayilir ve kisa
        // olan tutulur; oysa kirilgan bir koprude dogru cevap uzun olandir.
        final key = turnKeyed ? state.stateKey : state.effectKey;
        if (candidateKeys.add(key)) {
          result.candidates.add(_pathTo(nodes, head));
        }
      }
    }

    if (state.loopExhausted) {
      continue;
    }
    for (final action in GameAction.values) {
      final next = GameState.copy(state);
      next.step(action);
      if (visited.add(next.stateKey)) {
        nodes.add(_Node(next, head, action));
      }
    }
  }
  return result;
}

List<GameAction> _pathTo(List<_Node> nodes, int index) {
  final actions = <GameAction>[];
  var cursor = index;
  while (nodes[cursor].parent >= 0) {
    actions.add(nodes[cursor].action);
    cursor = nodes[cursor].parent;
  }
  return actions.reversed.toList();
}

/// Hayaletlerin sirasi sonucu degistirmez; kume anahtari siralanarak uretilir.
String _ghostKey(List<List<GameAction>> ghosts) {
  final encoded = ghosts
      .map((List<GameAction> loop) =>
          loop.map((GameAction a) => a.index).join('-'))
      .toList()
    ..sort();
  return encoded.join('|');
}

class _Budget {
  _Budget(this._remaining);

  int _remaining;

  void spend() {
    if (--_remaining < 0) {
      throw const SolverBudgetExceeded();
    }
  }
}
