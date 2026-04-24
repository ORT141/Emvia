import 'package:emvia/game/emvia_game.dart';
import 'package:emvia/l10n/app_localizations_gen.dart';
import 'package:flutter/material.dart';
import '../glass_ui.dart';

class CalmingItemPromptOverlay extends StatelessWidget {
  const CalmingItemPromptOverlay({super.key, required this.game});

  final EmviaGame game;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizationsGen.of(context)!;
    final size = MediaQuery.of(context).size;
    final isSmall = size.shortestSide < 600;

    return IgnorePointer(
      ignoring: true,
      child: Container(
        alignment: Alignment.topCenter,
        margin: EdgeInsets.only(top: isSmall ? 12 : 28),
        child: FractionallySizedBox(
          widthFactor: isSmall ? 0.95 : 0.92,
          child: GlassPanel(
            padding: EdgeInsets.symmetric(
              vertical: isSmall ? 10 : 14,
              horizontal: isSmall ? 14 : 18,
            ),
            borderRadius: BorderRadius.circular(isSmall ? 16 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l.calmingItemTooltipTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: isSmall ? 14 : null,
                  ),
                ),
                SizedBox(height: isSmall ? 4 : 8),
                Text(
                  l.calmingItemTooltipBody,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    fontSize: isSmall ? 12 : null,
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
