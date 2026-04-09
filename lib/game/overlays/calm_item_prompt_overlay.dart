import 'package:emvia/game/emvia_game.dart';
import 'package:emvia/l10n/app_localizations_gen.dart';
import 'package:flutter/material.dart';

class CalmingItemPromptOverlay extends StatelessWidget {
  const CalmingItemPromptOverlay({super.key, required this.game});

  final EmviaGame game;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizationsGen.of(context)!;
    return IgnorePointer(
      ignoring: true,
      child: Container(
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.only(top: 28),
        child: FractionallySizedBox(
          widthFactor: 0.92,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l.calmingItemTooltipTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l.calmingItemTooltipBody,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
