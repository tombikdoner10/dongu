import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'l10n/app_localizations.dart';
import 'services/progress_store.dart';
import 'services/sfx.dart';
import 'ui/home_screen.dart';
import 'ui/intro_screen.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
    <DeviceOrientation>[DeviceOrientation.portraitUp],
  );
  final progress = await ProgressStore.open();
  await sfx.init(enabled: progress.soundOn);
  runApp(DonguApp(progress: progress));
}

class DonguApp extends StatefulWidget {
  const DonguApp({required this.progress, super.key});

  final ProgressStore progress;

  @override
  State<DonguApp> createState() => _DonguAppState();
}

class _DonguAppState extends State<DonguApp> {
  late String? _localeCode = widget.progress.localeCode;
  late bool _introDone = widget.progress.introSeen;

  void _setLocale(String? code) {
    setState(() => _localeCode = code);
    unawaited(widget.progress.setLocaleCode(code));
  }

  void _finishIntro() {
    setState(() => _introDone = true);
    unawaited(widget.progress.setIntroSeen());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Döngü',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: _localeCode == null ? null : Locale(_localeCode!),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: _introDone
          ? HomeScreen(
              progress: widget.progress,
              localeCode: _localeCode,
              onLocaleChanged: _setLocale,
            )
          : IntroScreen(onDone: _finishIntro),
    );
  }
}
