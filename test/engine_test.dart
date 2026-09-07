import 'package:dongu/engine/game_state.dart';
import 'package:dongu/engine/level.dart';
import 'package:dongu/engine/models.dart';
import 'package:flutter_test/flutter_test.dart';

Level _level(String map,
        {int maxTurns = 12, int maxClones = 2, int fadeTurns = 0}) =>
    Level.parse(
      id: 0,
      titleTr: 'test',
      titleEn: 'test',
      hintTr: '',
      hintEn: '',
      map: map,
      maxTurns: maxTurns,
      maxClones: maxClones,
      fadeTurns: fadeTurns,
      par: 0,
    );

void main() {
  group('hareket', () {
    test('duvara yurumek konumu degistirmez', () {
      final state = GameState(_level('''
#####
#P.E#
#####
'''));
      state.step(GameAction.up);
      expect(state.player, const Pos(1, 1));
      expect(state.turn, 1, reason: 'engellense de tur ilerlemeli');
    });

    test('cikisa varinca kazanilir', () {
      final state = GameState(_level('''
#####
#P.E#
#####
'''));
      state.step(GameAction.right);
      expect(state.won, isFalse);
      state.step(GameAction.right);
      expect(state.won, isTrue);
    });

    test('tur hakki dolunca hamle reddedilir', () {
      final state = GameState(_level('''
#####
#P.E#
#####
''', maxTurns: 2));
      expect(state.step(GameAction.wait), isTrue);
      expect(state.step(GameAction.wait), isTrue);
      expect(state.loopExhausted, isTrue);
      expect(state.step(GameAction.wait), isFalse);
    });
  });

  group('plaka ve kapi', () {
    test('plakaya basilmadan kapidan gecilemez', () {
      final state = GameState(_level('''
#######
#.1PAE#
#######
'''));
      state.step(GameAction.right);
      expect(state.player, const Pos(3, 1), reason: 'kapi kapali, gecilmemeli');
    });

    test('plakadaki beden kapiyi acar, cekilince kapanir', () {
      final state = GameState(_level('''
#######
#.1PAE#
#######
'''));
      state.step(GameAction.left);
      expect(state.isDoorOpen(0), isTrue);
      state.step(GameAction.right);
      expect(state.isDoorOpen(0), isFalse);
    });

    test('hayalet kaydini ayni tur indeksinde tekrar oynar', () {
      final state = GameState(_level('''
#######
#.1PAE#
#######
'''));
      state.step(GameAction.left);
      expect(state.startNewLoop(), LoopResult.ok);
      expect(state.cloneCount, 1);
      expect(state.ghosts.single, const Pos(3, 1),
          reason: 'hayalet dogus noktasinda baslar');

      state.step(GameAction.wait);
      expect(state.ghosts.single, const Pos(2, 1),
          reason: 'hayalet ilk kayitli hamlesini oynadi');
      expect(state.isDoorOpen(0), isTrue);

      state.step(GameAction.right);
      state.step(GameAction.right);
      expect(state.won, isTrue);
    });
  });

  group('sandik', () {
    test('sandik itilir, arkasi duvarsa itilemez', () {
      final state = GameState(_level('''
#######
#PX.#E#
#######
'''));
      state.step(GameAction.right);
      expect(state.boxes.single, const Pos(3, 1));
      expect(state.player, const Pos(2, 1));
      state.step(GameAction.right);
      expect(state.boxes.single, const Pos(3, 1),
          reason: 'duvara dayali sandik itilemez');
      expect(state.player, const Pos(2, 1));
    });

    test('sandik plakayi kalici olarak basili tutar', () {
      final state = GameState(_level('''
#######
#PX1.E#
#######
'''));
      expect(state.isDoorOpen(0), isFalse);
      state.step(GameAction.right);
      expect(state.boxes.single, const Pos(3, 1));
      expect(state.isDoorOpen(0), isTrue);
      state.step(GameAction.left);
      expect(state.isDoorOpen(0), isTrue,
          reason: 'oyuncu uzaklassa da sandik plakada kalir');
    });
  });

  group('dongu yonetimi', () {
    test('geri al onceki duruma dondurur', () {
      final state = GameState(_level('''
#####
#P.E#
#####
'''));
      state.step(GameAction.wait);
      state.step(GameAction.right);
      expect(state.player, const Pos(2, 1));
      state.undo();
      expect(state.player, const Pos(1, 1));
      expect(state.turn, 1);
      state.undo();
      expect(state.turn, 0);
      expect(state.canUndo, isFalse);
    });

    test('hayalet hakki dolunca seviye sifirlanir', () {
      final state = GameState(_level('''
#####
#P.E#
#####
''', maxClones: 1));
      state.step(GameAction.wait);
      expect(state.startNewLoop(), LoopResult.ok);
      expect(state.startNewLoop(), LoopResult.cloneLimitReached);
      expect(state.cloneCount, 0);
      expect(state.player, const Pos(1, 1));
    });
  });

  group('kirilgan zemin', () {
    test('uzerinden cekilince coker ve bir daha gecilemez', () {
      final state = GameState(_level('''
#######
#P~..E#
#######
'''));
      state.step(GameAction.right);
      expect(state.player, const Pos(2, 1));
      expect(state.collapsed, isEmpty, reason: 'daha uzerinde duruyoruz');

      state.step(GameAction.right);
      expect(state.collapsed, contains(const Pos(2, 1)));

      state.step(GameAction.left);
      expect(state.player, const Pos(3, 1),
          reason: 'cokmus zemine geri donulemez');
    });

    test('bir adim geriden gelen yanki zemini ayakta tutar', () {
      // Seviye 23'un cekirdegi: oyuncu bir kareyi terk ettigi turda yanki
      // ayni kareye adim atarsa zemin cokmez, ikisi de gecebilir.
      final state = GameState(_level('''
#######
#P~~.E#
#######
''', maxClones: 1));
      state.step(GameAction.wait);
      state.step(GameAction.right);
      expect(state.startNewLoop(), LoopResult.ok);

      state.step(GameAction.right); // oyuncu (2,1)'e, yanki bekliyor
      expect(state.player, const Pos(2, 1));

      state.step(GameAction.right); // oyuncu (3,1)'e, yanki (2,1)'e
      expect(state.ghosts.single, const Pos(2, 1));
      expect(state.collapsed, isNot(contains(const Pos(2, 1))),
          reason: 'yanki uzerine bastigi icin zemin ayakta kalmali');

      state.step(GameAction.right); // oyuncu (4,1)'e, yanki yerinde kaliyor
      expect(state.collapsed, contains(const Pos(3, 1)),
          reason: 'arkasinda kimse kalmayan zemin coker');
      expect(state.collapsed, isNot(contains(const Pos(2, 1))));
    });

    test('cokmus zeminler yeni donguda geri gelir', () {
      final state = GameState(_level('''
#######
#P~..E#
#######
''', maxClones: 1));
      state.step(GameAction.right);
      state.step(GameAction.right);
      expect(state.collapsed, isNotEmpty);

      expect(state.startNewLoop(), LoopResult.ok);
      expect(state.collapsed, isEmpty);
    });
  });

  group('agir plaka', () {
    test('tek beden yetmez, iki beden acar', () {
      final state = GameState(_level('''
#######
#.4PAE#
#######
'''));
      state.step(GameAction.left);
      expect(state.player, const Pos(2, 1));
      expect(state.isDoorOpen(0), isFalse,
          reason: 'agir plaka tek bedenle acilmaz');

      expect(state.startNewLoop(), LoopResult.ok);
      state.step(GameAction.left);
      expect(state.bodiesOn(const Pos(2, 1)), 2,
          reason: 'yanki ve oyuncu ayni karede yigildi');
      expect(state.isDoorOpen(0), isTrue);
    });
  });

  group('solan kapi', () {
    test('yalnizca ilk turlarda gecilir', () {
      final state = GameState(_level('''
#######
#P.TE.#
#######
''', fadeTurns: 1));
      expect(state.fadingOpen, isTrue);
      state.step(GameAction.right);
      expect(state.player, const Pos(2, 1));

      expect(state.fadingOpen, isFalse, reason: 'sure doldu');
      state.step(GameAction.right);
      expect(state.player, const Pos(2, 1),
          reason: 'solan kapi kapandi, gecilemez');
    });

    test('solan kapi varken fadeTurns zorunlu', () {
      expect(
        () => _level('''
#######
#P.TE.#
#######
'''),
        throwsFormatException,
      );
    });
  });

  group('harita cozumleyici', () {
    test('satir uzunlugu tutmayan harita reddedilir', () {
      expect(() => _level('''
#####
#P.E#
####
'''), throwsFormatException);
    });

    test('baslangici olmayan harita reddedilir', () {
      expect(() => _level('''
#####
#..E#
#####
'''), throwsFormatException);
    });
  });
}
