// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Döngü';

  @override
  String get tagline => 'Cooperate with your past self';

  @override
  String get play => 'Play';

  @override
  String get levels => 'Levels';

  @override
  String get settings => 'Settings';

  @override
  String levelLabel(int number) {
    return 'Level $number';
  }

  @override
  String get turnsLabel => 'Turns';

  @override
  String get echoesLabel => 'Echoes';

  @override
  String get undo => 'Undo';

  @override
  String get newLoop => 'New loop';

  @override
  String get restart => 'Restart';

  @override
  String get wait => 'Wait';

  @override
  String get levelComplete => 'Loop closed';

  @override
  String get nextLevel => 'Next';

  @override
  String get cloneLimitReached => 'Out of echoes — level reset';

  @override
  String get loopExhausted => 'Turns are up — start a new loop';

  @override
  String get outOfEchoes => 'Out of turns and echoes — restart the level';

  @override
  String get colorBlindMode => 'Colour-blind symbols';

  @override
  String get language => 'Language';

  @override
  String get locked => 'Locked';

  @override
  String echoesUsed(int count) {
    return '$count echoes';
  }

  @override
  String get perfect => 'Best possible';

  @override
  String get sound => 'Sound';

  @override
  String get introSkip => 'Skip';

  @override
  String get introNext => 'Next';

  @override
  String get introStart => 'Begin';

  @override
  String get introTitle1 => 'Your turns are counted';

  @override
  String get introBody1 =>
      'Every move spends one turn. When they run out, the loop closes.';

  @override
  String get introTitle2 => 'Your moves come back';

  @override
  String get introBody2 =>
      'The closed loop replays everything you did, as an echo. You start over, fresh.';

  @override
  String get introTitle3 => 'Leave your past behind';

  @override
  String get introBody3 =>
      'An echo standing on a plate holds the gate open — long enough for you to walk through.';
}
