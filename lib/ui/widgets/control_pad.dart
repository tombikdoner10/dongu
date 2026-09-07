import 'package:flutter/material.dart';

import '../../engine/models.dart';
import '../theme.dart';

/// Yon tuslari. Tahtada kaydirma da calisir; bu ikinci, garantili yol.
class ControlPad extends StatelessWidget {
  const ControlPad({
    required this.onAction,
    required this.enabled,
    required this.waitLabel,
    super.key,
  });

  final ValueChanged<GameAction> onAction;
  final bool enabled;
  final String waitLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _PadButton(
          icon: Icons.keyboard_arrow_up_rounded,
          enabled: enabled,
          onTap: () => onAction(GameAction.up),
          semanticLabel: 'yukari',
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _PadButton(
              icon: Icons.keyboard_arrow_left_rounded,
              enabled: enabled,
              onTap: () => onAction(GameAction.left),
              semanticLabel: 'sola',
            ),
            const SizedBox(width: 6),
            _PadButton(
              icon: Icons.hourglass_empty_rounded,
              enabled: enabled,
              onTap: () => onAction(GameAction.wait),
              semanticLabel: waitLabel,
              accent: true,
            ),
            const SizedBox(width: 6),
            _PadButton(
              icon: Icons.keyboard_arrow_right_rounded,
              enabled: enabled,
              onTap: () => onAction(GameAction.right),
              semanticLabel: 'saga',
            ),
          ],
        ),
        const SizedBox(height: 6),
        _PadButton(
          icon: Icons.keyboard_arrow_down_rounded,
          enabled: enabled,
          onTap: () => onAction(GameAction.down),
          semanticLabel: 'asagi',
        ),
      ],
    );
  }
}

class _PadButton extends StatelessWidget {
  const _PadButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
    required this.semanticLabel,
    this.accent = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final String semanticLabel;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ? DColors.ghost : DColors.text;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: DColors.surface.withValues(alpha: enabled ? 1 : 0.4),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: enabled ? onTap : null,
          child: Container(
            width: 62,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (accent ? DColors.ghost : DColors.surfaceHigh)
                    .withValues(alpha: enabled ? 0.9 : 0.3),
                width: 1.4,
              ),
            ),
            child: Icon(
              icon,
              size: accent ? 24 : 30,
              color: color.withValues(alpha: enabled ? 1 : 0.35),
            ),
          ),
        ),
      ),
    );
  }
}
