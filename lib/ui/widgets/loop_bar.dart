import 'package:flutter/material.dart';

import '../../engine/game_state.dart';
import '../theme.dart';

/// Kalan tur ve kullanilan yanki sayisini gosterir.
class LoopBar extends StatelessWidget {
  const LoopBar({
    required this.state,
    required this.turnsLabel,
    required this.echoesLabel,
    super.key,
  });

  final GameState state;
  final String turnsLabel;
  final String echoesLabel;

  @override
  Widget build(BuildContext context) {
    final level = state.level;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                turnsLabel.toUpperCase(),
                style: const TextStyle(
                  color: DColors.textMuted,
                  fontSize: 11,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${state.turnsLeft}',
                style: TextStyle(
                  color: state.turnsLeft <= 2 ? DColors.groups[1] : DColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (level.maxClones > 0) ...<Widget>[
                Text(
                  echoesLabel.toUpperCase(),
                  style: const TextStyle(
                    color: DColors.textMuted,
                    fontSize: 11,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                for (var i = 0; i < level.maxClones; i++)
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < state.cloneCount
                            ? DColors.ghost
                            : Colors.transparent,
                        border: Border.all(
                          color: DColors.ghost.withValues(
                              alpha: i < state.cloneCount ? 1 : 0.35),
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              for (var i = 0; i < level.maxTurns; i++)
                Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i == level.maxTurns - 1 ? 0 : 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: i < state.turn
                          ? DColors.surfaceHigh
                          : DColors.ghost.withValues(alpha: 0.65),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
