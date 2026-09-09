import 'dart:async';

import 'package:flutter/material.dart';

import '../data/levels.dart';
import '../engine/game_state.dart';
import '../engine/level.dart';
import '../engine/models.dart';
import '../l10n/app_localizations.dart';
import '../services/progress_store.dart';
import '../services/sfx.dart';
import 'ending_screen.dart';
import 'theme.dart';
import 'widgets/board_view.dart';
import 'widgets/control_pad.dart';
import 'widgets/loop_bar.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({required this.level, required this.progress, super.key});

  final Level level;
  final ProgressStore progress;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameState _state = GameState(widget.level);

  Level? get _nextLevel {
    final index = kLevels.indexWhere((Level l) => l.id == widget.level.id);
    return index >= 0 && index + 1 < kLevels.length ? kLevels[index + 1] : null;
  }

  /// Son seviye de bitince kapanis ekranina cikilir; oyunun bittigi bir yerde
  /// soylenmezse yuz bolumun sonu ucuncu bolumun sonuyla ayni gorunur.
  bool get _gameComplete =>
      kLevels.every((Level l) => widget.progress.isCompleted(l.id));

  void _openEnding() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EndingScreen(progress: widget.progress),
      ),
    );
  }

  void _act(GameAction action) {
    final wasAt = _state.player;
    final openBefore = _state.openGroups.length;

    if (!_state.step(action)) {
      return;
    }
    setState(() {});

    if (_state.won) {
      sfx.play(Sound.win);
      unawaited(widget.progress.record(widget.level.id, _state.cloneCount));
    } else if (action.isMove && _state.player == wasAt) {
      sfx.play(Sound.blocked);
    } else {
      sfx.play(Sound.move);
    }

    // Kapi durumu degistiyse ustune bir katman daha bindirilir.
    final openAfter = _state.openGroups.length;
    if (openAfter > openBefore) {
      sfx.play(Sound.doorOpen);
    } else if (openAfter < openBefore) {
      sfx.play(Sound.doorClose);
    }
  }

  void _newLoop() {
    final result = _state.startNewLoop();
    setState(() {});
    sfx.play(Sound.loop);
    if (result == LoopResult.cloneLimitReached) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: DColors.surfaceHigh,
            content: Text(AppLocalizations.of(context)!.cloneLimitReached),
          ),
        );
    }
  }

  void _undo() {
    setState(_state.undo);
    sfx.play(Sound.undo);
  }

  void _restart() {
    setState(_state.restartLevel);
    sfx.play(Sound.loop);
  }

  void _openLevel(Level level) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(level: level, progress: widget.progress),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final turkish = Localizations.localeOf(context).languageCode == 'tr';
    final outOfTurns = _state.loopExhausted && !_state.won;
    // Turlar da yanki hakki da bittiyse "yeni dongu" dugmesi kapalidir;
    // oyuncuya yapamayacagi seyi soylememek icin ayri bir mesaj gerekir.
    final stuck = outOfTurns && !_state.canStartNewLoop;
    final canPlay = !_state.won && !_state.loopExhausted;

    return Scaffold(
      body: NightBackground(
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  _TopBar(
                    title: l10n.levelLabel(widget.level.id),
                    subtitle: widget.level.title(turkish),
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  LoopBar(
                    state: _state,
                    turnsLabel: l10n.turnsLabel,
                    echoesLabel: l10n.echoesLabel,
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragEnd: (DragEndDetails d) {
                        final v = d.primaryVelocity ?? 0;
                        if (v.abs() < 120) return;
                        _act(v > 0 ? GameAction.right : GameAction.left);
                      },
                      onVerticalDragEnd: (DragEndDetails d) {
                        final v = d.primaryVelocity ?? 0;
                        if (v.abs() < 120) return;
                        _act(v > 0 ? GameAction.down : GameAction.up);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: BoardView(state: _state),
                      ),
                    ),
                  ),
                  _StatusLine(
                    text: stuck
                        ? l10n.outOfEchoes
                        : outOfTurns
                            ? l10n.loopExhausted
                            : widget.level.hint(turkish),
                    highlighted: outOfTurns,
                  ),
                  const SizedBox(height: 6),
                  ControlPad(
                    onAction: _act,
                    enabled: canPlay,
                    waitLabel: l10n.wait,
                  ),
                  const SizedBox(height: 10),
                  _ActionRow(
                    undoLabel: l10n.undo,
                    newLoopLabel: l10n.newLoop,
                    restartLabel: l10n.restart,
                    canUndo: _state.canUndo && !_state.won,
                    canLoop: _state.canStartNewLoop,
                    // Turlar bittiginde yapilacak tek sey budur; goze batsin.
                    pulseLoop: outOfTurns && _state.canStartNewLoop,
                    onUndo: _undo,
                    onNewLoop: _newLoop,
                    onRestart: _restart,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
              if (_state.won)
                _WinOverlay(
                  title: l10n.levelComplete,
                  echoes: l10n.echoesUsed(_state.cloneCount),
                  perfect: _state.cloneCount <= widget.level.par,
                  perfectLabel: l10n.perfect,
                  nextLabel:
                      _nextLevel == null ? l10n.endingOpen : l10n.nextLevel,
                  levelsLabel: l10n.levels,
                  onNext: _nextLevel != null
                      ? () => _openLevel(_nextLevel!)
                      : _gameComplete
                          ? _openEnding
                          : null,
                  onLevels: () => Navigator.of(context).pop(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 20, 4),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: DColors.textMuted),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: DColors.textMuted,
                  fontSize: 11,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: DColors.text,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.text, required this.highlighted});

  final String text;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 6),
      child: ConstrainedBox(
        // Alt sinir kisa ipuclarinda duzenin ziplamasini onler; ust sinir yok,
        // cunku dar ekranlarda uzun bir ipucu ucuncu satira tasiyor ve sabit
        // yukseklik onu kirpiyordu. Tahta Expanded oldugu icin farki o karsilar.
        constraints: const BoxConstraints(minHeight: 42),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: highlighted ? DColors.groups[1] : DColors.textMuted,
              fontSize: 13,
              height: 1.35,
            ),
            child: Text(text, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.undoLabel,
    required this.newLoopLabel,
    required this.restartLabel,
    required this.canUndo,
    required this.canLoop,
    required this.pulseLoop,
    required this.onUndo,
    required this.onNewLoop,
    required this.onRestart,
  });

  final String undoLabel;
  final String newLoopLabel;
  final String restartLabel;
  final bool canUndo;
  final bool canLoop;
  final bool pulseLoop;
  final VoidCallback onUndo;
  final VoidCallback onNewLoop;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _TextAction(
          icon: Icons.undo_rounded,
          label: undoLabel,
          onTap: canUndo ? onUndo : null,
        ),
        _TextAction(
          icon: Icons.refresh_rounded,
          label: newLoopLabel,
          onTap: canLoop ? onNewLoop : null,
          accent: true,
          pulse: pulseLoop,
        ),
        _TextAction(
          icon: Icons.restart_alt_rounded,
          label: restartLabel,
          onTap: onRestart,
        ),
      ],
    );
  }
}

class _TextAction extends StatelessWidget {
  const _TextAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accent = false,
    this.pulse = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool accent;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final color = (accent ? DColors.ghost : DColors.textMuted)
        .withValues(alpha: enabled ? 1 : 0.3);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _Pulse(
                active: pulse,
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                    color: color, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dikkat cekmesi gereken bir dugmeyi yavasca buyutup kucultur.
class _Pulse extends StatefulWidget {
  const _Pulse({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  // Denetleyici bilerek initState'te kuruluyor. `late final` ile tembel
  // kurulsaydi ve nabiz hic calismasaydi, ilk erisim dispose() icinde olur;
  // widget o an agactan kopmus oldugu icin Flutter hata firlatirdi.
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.active) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_Pulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.active && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return widget.child;
    }
    return ScaleTransition(
      scale: Tween<double>(begin: 1, end: 1.28).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: widget.child,
    );
  }
}

class _WinOverlay extends StatefulWidget {
  const _WinOverlay({
    required this.title,
    required this.echoes,
    required this.perfect,
    required this.perfectLabel,
    required this.nextLabel,
    required this.levelsLabel,
    required this.onNext,
    required this.onLevels,
  });

  final String title;
  final String echoes;

  /// Seviyenin par degerine ulasildi mi?
  final bool perfect;
  final String perfectLabel;
  final String nextLabel;
  final String levelsLabel;
  final VoidCallback? onNext;
  final VoidCallback onLevels;

  @override
  State<_WinOverlay> createState() => _WinOverlayState();
}

class _WinOverlayState extends State<_WinOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Sirali giris icin zaman diliminden egri uretir.
  Animation<double> _stage(double begin, double end,
          [Curve curve = Curves.easeOutCubic]) =>
      CurvedAnimation(
        parent: _controller,
        curve: Interval(begin, end, curve: curve),
      );

  @override
  Widget build(BuildContext context) {
    final backdrop = _stage(0, 0.3);
    final icon = _stage(0.08, 0.6, Curves.easeOutBack);
    final burst = _stage(0.08, 0.75);
    final title = _stage(0.3, 0.68);
    final echoes = _stage(0.4, 0.78);
    final buttons = _stage(0.55, 1);

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, _) {
          return ColoredBox(
            color: DColors.bgTop.withValues(alpha: 0.9 * backdrop.value),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        // Disari dogru genisleyip sonen halka.
                        Transform.scale(
                          scale: 0.3 + burst.value * 1.5,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: DColors.exit.withValues(
                                  alpha: 0.5 * (1 - burst.value),
                                ),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: 0.5 + icon.value * 0.5,
                          child: Opacity(
                            opacity: icon.value.clamp(0, 1),
                            child: Icon(
                              Icons.all_inclusive_rounded,
                              size: 56,
                              color: DColors.exit.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _Rise(
                    animation: title,
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: DColors.text,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _Rise(
                    animation: echoes,
                    child: Text(
                      widget.echoes,
                      style: const TextStyle(
                          color: DColors.textMuted, fontSize: 14),
                    ),
                  ),
                  if (widget.perfect) ...<Widget>[
                    const SizedBox(height: 8),
                    _Rise(
                      animation: echoes,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(Icons.star_rounded,
                              size: 16, color: DColors.exit),
                          const SizedBox(width: 6),
                          Text(
                            widget.perfectLabel,
                            style: const TextStyle(
                              color: DColors.exit,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  _Rise(
                    animation: buttons,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (widget.onNext != null)
                          FilledButton(
                            onPressed: widget.onNext,
                            child: Text(widget.nextLabel),
                          ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: widget.onLevels,
                          child: Text(
                            widget.levelsLabel,
                            style: const TextStyle(color: DColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Asagidan hafifce yukselerek belirir.
class _Rise extends StatelessWidget {
  const _Rise({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: animation.value.clamp(0, 1),
      child: Transform.translate(
        offset: Offset(0, 16 * (1 - animation.value)),
        child: child,
      ),
    );
  }
}
