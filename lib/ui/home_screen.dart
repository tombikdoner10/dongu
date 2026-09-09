import 'dart:async';

import 'package:flutter/material.dart';

import '../data/levels.dart';
import '../engine/level.dart';
import '../l10n/app_localizations.dart';
import '../services/progress_store.dart';
import '../services/sfx.dart';
import 'ending_screen.dart';
import 'game_screen.dart';
import 'level_select_screen.dart';
import 'theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.progress,
    required this.onLocaleChanged,
    required this.localeCode,
    super.key,
  });

  final ProgressStore progress;
  final ValueChanged<String?> onLocaleChanged;
  final String? localeCode;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bool _soundOn = widget.progress.soundOn;

  /// Devam edilecek seviye: bitirilmemis ilk acik seviye.
  bool get _gameComplete =>
      kLevels.every((Level level) => widget.progress.isCompleted(level.id));

  Level get _resumeLevel {
    for (final level in kLevels) {
      if (widget.progress.isUnlocked(level.id) &&
          !widget.progress.isCompleted(level.id)) {
        return level;
      }
    }
    return kLevels.first;
  }

  void _toggleSound() {
    setState(() => _soundOn = !_soundOn);
    sfx.enabled = _soundOn;
    unawaited(widget.progress.setSoundOn(_soundOn));
    if (_soundOn) {
      sfx.play(Sound.doorOpen);
    }
  }

  Future<void> _push(Widget screen) async {
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => screen));
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: NightBackground(
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        onPressed: _toggleSound,
                        tooltip: l10n.sound,
                        icon: Icon(
                          _soundOn
                              ? Icons.volume_up_rounded
                              : Icons.volume_off_rounded,
                          color: _soundOn ? DColors.ghost : DColors.textMuted,
                          size: 22,
                        ),
                      ),
                      _LanguageChip(
                        current: widget.localeCode,
                        onChanged: widget.onLocaleChanged,
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.all_inclusive_rounded,
                      size: 64,
                      color: DColors.ghost.withValues(alpha: 0.85),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      l10n.appTitle.toUpperCase(),
                      style: const TextStyle(
                        color: DColors.text,
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.tagline,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: DColors.textMuted,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 48),
                    FilledButton(
                      onPressed: () => _push(
                        GameScreen(
                          level: _resumeLevel,
                          progress: widget.progress,
                        ),
                      ),
                      child: Text(l10n.play),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () =>
                          _push(LevelSelectScreen(progress: widget.progress)),
                      child: Text(l10n.levels),
                    ),
                    // Kapanis bir kez gorulup kaybolmasin: oyunu bitiren
                    // oyuncu ona buradan geri donebilir.
                    if (_gameComplete)
                      TextButton(
                        onPressed: () =>
                            _push(EndingScreen(progress: widget.progress)),
                        child: Text(
                          l10n.endingOpen,
                          style: const TextStyle(color: DColors.exit),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({required this.current, required this.onChanged});

  /// null ise cihaz dili kullaniliyor demektir.
  final String? current;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final active = current ?? Localizations.localeOf(context).languageCode;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final code in const <String>['tr', 'en'])
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onChanged(code),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: active == code
                        ? DColors.ghost
                        : DColors.surfaceHigh,
                    width: 1.4,
                  ),
                ),
                child: Text(
                  code.toUpperCase(),
                  style: TextStyle(
                    color:
                        active == code ? DColors.ghost : DColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
