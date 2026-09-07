import 'package:dongu/data/levels.dart';
import 'package:dongu/l10n/app_localizations.dart';
import 'package:dongu/main.dart';
import 'package:dongu/services/progress_store.dart';
import 'package:dongu/ui/game_screen.dart';
import 'package:dongu/ui/level_select_screen.dart';
import 'package:dongu/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Emulator yerine widget testi: milisaniyede, cihazsiz ve deterministik.
/// Emulator surumu (dev/play_all.py) zinciri bir kez uctan uca kanitliyor;
/// gunluk regresyonu buradaki testler tutuyor.

const Map<String, Object> _fresh = <String, Object>{
  'flutter.locale': 'tr',
  'flutter.introSeen': true,
};

Future<ProgressStore> _seed([
  Map<String, Object> values = _fresh,
]) async {
  SharedPreferences.setMockInitialValues(values);
  return ProgressStore.open();
}

Widget _screen(Widget child) => MaterialApp(
      locale: const Locale('tr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: buildAppTheme(),
      home: child,
    );

/// Bir kontrol dugmesine basar ve hareket animasyonunu ilerletir.
///
/// Bilerek pumpAndSettle degil: turlar bittiginde "yeni dongu" dugmesi
/// surekli nabiz animasyonu yapar ve pumpAndSettle asla dinmez.
Future<void> _press(WidgetTester tester, IconData icon) async {
  await tester.tap(find.byIcon(icon));
  await tester.pump(const Duration(milliseconds: 220));
}

const IconData _right = Icons.keyboard_arrow_right_rounded;
const IconData _wait = Icons.hourglass_empty_rounded;
const IconData _undo = Icons.undo_rounded;
const IconData _newLoop = Icons.refresh_rounded;
const IconData _restart = Icons.restart_alt_rounded;

void main() {
  testWidgets('ogretici ilk aciliste cikar, gecilince bir daha cikmaz',
      (WidgetTester tester) async {
    final store = await _seed(<String, Object>{'flutter.locale': 'tr'});
    await tester.pumpWidget(DonguApp(progress: store));
    await tester.pump();

    expect(find.text('Turların sayılı'), findsOneWidget);

    await tester.tap(find.text('Geç'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('DÖNGÜ'), findsOneWidget);
    expect(store.introSeen, isTrue);
  });

  testWidgets('ana ekrandan oynanip kazanilinca ilerleme kaydedilir',
      (WidgetTester tester) async {
    final store = await _seed();
    await tester.pumpWidget(DonguApp(progress: store));
    await tester.pump();

    await tester.tap(find.text('Oyna'));
    await tester.pumpAndSettle();
    expect(find.text('Uyanış'), findsOneWidget);

    for (var i = 0; i < 4; i++) {
      await _press(tester, _right);
    }
    await tester.pump(const Duration(milliseconds: 1400));

    expect(find.text('Döngü kapandı'), findsOneWidget);
    expect(find.text('En iyi çözüm'), findsOneWidget,
        reason: 'par ile bitirildi, yildiz gorunmeli');
    expect(store.bestEchoes(1), 0);
  });

  testWidgets('kazanma ekranindaki Sonraki bir sonraki seviyeye gecirir',
      (WidgetTester tester) async {
    final store = await _seed();
    await tester.pumpWidget(
      _screen(GameScreen(level: kLevels.first, progress: store)),
    );
    await tester.pump();

    for (var i = 0; i < 4; i++) {
      await _press(tester, _right);
    }
    await tester.pump(const Duration(milliseconds: 1400));

    await tester.tap(find.text('Sonraki'));
    await tester.pumpAndSettle();
    expect(find.text('İlk Yankı'), findsOneWidget);
  });

  testWidgets('geri al ve bastan tur sayacini duzeltir',
      (WidgetTester tester) async {
    final store = await _seed();
    await tester.pumpWidget(
      _screen(GameScreen(level: kLevels.first, progress: store)),
    );
    await tester.pump();
    expect(find.text('8'), findsOneWidget, reason: 'seviye 1 sekiz turluk');

    await _press(tester, _right);
    expect(find.text('7'), findsOneWidget);

    await _press(tester, _undo);
    expect(find.text('8'), findsOneWidget);

    await _press(tester, _right);
    await _press(tester, _right);
    expect(find.text('6'), findsOneWidget);

    await _press(tester, _restart);
    expect(find.text('8'), findsOneWidget);
  });

  testWidgets('turlar bitince dogru mesaj cikar, yanki da bitince degisir',
      (WidgetTester tester) async {
    // Seviye 2: 7 tur, 1 yanki hakki.
    final level = kLevels[1];
    final store = await _seed();
    await tester.pumpWidget(_screen(GameScreen(level: level, progress: store)));
    await tester.pump();

    for (var i = 0; i < level.maxTurns; i++) {
      await _press(tester, _wait);
    }
    expect(find.text('Turlar bitti — yeni bir döngü başlat'), findsOneWidget);

    await _press(tester, _newLoop);
    for (var i = 0; i < level.maxTurns; i++) {
      await _press(tester, _wait);
    }

    // Yanki hakki bittigi icin "yeni dongu" artik kapali; mesaj bunu soylemeli.
    expect(find.text('Ne tur ne yankı kaldı — baştan başla'), findsOneWidget);
    expect(find.text('Turlar bitti — yeni bir döngü başlat'), findsNothing);

    await _press(tester, _restart);
    expect(find.text('7'), findsOneWidget, reason: 'bastan basladi');
  });

  testWidgets('bitirilen seviye bir sonrakini acar, otekiler kilitli kalir',
      (WidgetTester tester) async {
    final store = await _seed(<String, Object>{
      'flutter.locale': 'tr',
      'flutter.introSeen': true,
      'flutter.best_1': 0,
    });
    await tester.pumpWidget(_screen(LevelSelectScreen(progress: store)));
    await tester.pump();

    expect(find.text('Uyanış'), findsOneWidget, reason: '1 bitirildi');
    expect(find.text('İlk Yankı'), findsOneWidget, reason: '2 acildi');
    expect(find.text('Çifte Kapı'), findsNothing, reason: '3 hala kilitli');
    expect(find.text('Kilitli'), findsWidgets);
  });

  testWidgets('dil secimi arayuzu aninda degistirir',
      (WidgetTester tester) async {
    final store = await _seed();
    await tester.pumpWidget(DonguApp(progress: store));
    await tester.pump();
    expect(find.text('Oyna'), findsOneWidget);

    await tester.tap(find.text('EN'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Oyna'), findsNothing);
  });

  testWidgets('ses dugmesi tercihi kaydeder', (WidgetTester tester) async {
    final store = await _seed();
    await tester.pumpWidget(DonguApp(progress: store));
    await tester.pump();
    expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.volume_up_rounded));
    await tester.pump();

    expect(find.byIcon(Icons.volume_off_rounded), findsOneWidget);
    expect(store.soundOn, isFalse);
  });

  testWidgets('yanki birakilinca kapi acilir ve seviye bitirilir',
      (WidgetTester tester) async {
    // Seviye 2'nin tam cozumu arayuz uzerinden: once plakaya yanki birak.
    final store = await _seed();
    await tester.pumpWidget(
      _screen(GameScreen(level: kLevels[1], progress: store)),
    );
    await tester.pump();

    const left = Icons.keyboard_arrow_left_rounded;
    await _press(tester, left);
    await _press(tester, left);
    await _press(tester, _newLoop);

    await _press(tester, Icons.keyboard_arrow_down_rounded);
    for (var i = 0; i < 5; i++) {
      await _press(tester, _right);
    }
    await tester.pump(const Duration(milliseconds: 1400));

    expect(find.text('Döngü kapandı'), findsOneWidget);
    expect(store.bestEchoes(2), 1);
  });
}
