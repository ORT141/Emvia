import 'package:emvia/core/utils/l10n.dart';
import 'package:emvia/game/emvia_game.dart';
import 'package:flutter/material.dart';

class CalmEffectOverlay extends StatefulWidget {
  const CalmEffectOverlay({super.key, required this.game});

  final EmviaGame game;

  @override
  State<CalmEffectOverlay> createState() => _CalmEffectOverlayState();
}

class _CalmEffectOverlayState extends State<CalmEffectOverlay> {
  @override
  void dispose() {
    try {
      widget.game.player.endInteraction();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.6),
                  radius: 1.2,
                  colors: [
                    Colors.white.withValues(alpha: 0.00),
                    Colors.lightBlueAccent.withValues(alpha: 0.16),
                    Colors.blue.withValues(alpha: 0.08),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.cyan.withValues(alpha: 0.06)),
          ),
          Positioned(
            left: 24,
            right: 24,
            top: 24,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                    width: 1.2,
                  ),
                ),
                child: Text(
                  L10n.of(context).calming,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
