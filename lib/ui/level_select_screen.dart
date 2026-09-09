import 'package:flutter/material.dart';

import '../data/levels.dart';
import '../engine/level.dart';
import '../l10n/app_localizations.dart';
import '../services/progress_store.dart';
import 'game_screen.dart';
import 'theme.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({required this.progress, super.key});

  final ProgressStore progress;

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  static const double _pad = 20;
  static const double _gap = 14;
  static const double _aspect = 1.35;

  ScrollController? _controller;

  /// Oyuncunun kaldigi yer: acik ama bitmemis ilk seviye.
  int get _resumeIndex {
    for (var i = 0; i < kLevels.length; i++) {
      if (widget.progress.isUnlocked(kLevels[i].id) &&
          !widget.progress.isCompleted(kLevels[i].id)) {
        return i;
      }
    }
    return kLevels.length - 1;
  }

  /// Liste yuz seviyeye cikinca hep bastan acilmak oyuncuyu her seferinde
  /// onlarca satir kaydirmaya zorluyordu; kaldigi satirdan aciyoruz.
  ScrollController _controllerFor(double width) {
    if (_controller != null) {
      return _controller!;
    }
    final cardWidth = (width - 2 * _pad - _gap) / 2;
    final rowPitch = cardWidth / _aspect + _gap;
    // Bir ust satir da gorunsun; nerede oldugu baglamiyla anlasilir.
    final target = (_resumeIndex ~/ 2 - 1) * rowPitch;
    return _controller =
        ScrollController(initialScrollOffset: target > 0 ? target : 0);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _open(Level level) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(level: level, progress: widget.progress),
      ),
    );
    if (mounted) {
      setState(() {}); // Donunce rozetler ve kilitler tazelenir.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final turkish = Localizations.localeOf(context).languageCode == 'tr';

    return Scaffold(
      body: NightBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 20, 8),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: DColors.textMuted),
                    ),
                    Text(
                      l10n.levels,
                      style: const TextStyle(
                        color: DColors.text,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) =>
                      GridView.builder(
                  controller: _controllerFor(constraints.maxWidth),
                  padding: const EdgeInsets.fromLTRB(_pad, 4, _pad, 24),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: _gap,
                    crossAxisSpacing: _gap,
                    childAspectRatio: _aspect,
                  ),
                  itemCount: kLevels.length,
                  itemBuilder: (BuildContext context, int index) {
                    final level = kLevels[index];
                    final unlocked = widget.progress.isUnlocked(level.id);
                    final best = widget.progress.bestEchoes(level.id);
                    return _LevelCard(
                      number: level.id,
                      title: level.title(turkish),
                      lockedLabel: l10n.locked,
                      badge: best == null ? null : l10n.echoesUsed(best),
                      perfect: best != null && best <= level.par,
                      unlocked: unlocked,
                      onTap: unlocked ? () => _open(level) : null,
                    );
                  },
                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.number,
    required this.title,
    required this.lockedLabel,
    required this.badge,
    required this.perfect,
    required this.unlocked,
    required this.onTap,
  });

  final int number;
  final String title;
  final String lockedLabel;
  final String? badge;

  /// Seviyenin par degerine ulasildi mi?
  final bool perfect;
  final bool unlocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DColors.surface.withValues(alpha: unlocked ? 1 : 0.45),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: DColors.surfaceHigh.withValues(alpha: unlocked ? 1 : 0.4),
              width: 1.4,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '$number',
                style: TextStyle(
                  color: unlocked
                      ? DColors.ghost
                      : DColors.textMuted.withValues(alpha: 0.5),
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                unlocked ? title : lockedLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: unlocked
                      ? DColors.text
                      : DColors.textMuted.withValues(alpha: 0.6),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: <Widget>[
                  if (!unlocked)
                    Icon(Icons.lock_outline_rounded,
                        size: 14,
                        color: DColors.textMuted.withValues(alpha: 0.6)),
                  if (perfect) ...<Widget>[
                    const Icon(Icons.star_rounded,
                        size: 14, color: DColors.exit),
                    const SizedBox(width: 4),
                  ],
                  if (badge != null)
                    Text(
                      badge!,
                      style: const TextStyle(
                          color: DColors.exit,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
