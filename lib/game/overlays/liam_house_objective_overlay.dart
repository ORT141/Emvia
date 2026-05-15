import 'package:flutter/material.dart';

import '../../l10n/app_localizations_gen.dart';
import '../emvia_game.dart';
import '../scenes/liam/house_scene.dart';
import 'glass_ui.dart';

class LiamHouseObjectiveOverlay extends StatelessWidget {
  final EmviaGame game;

  const LiamHouseObjectiveOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizationsGen.of(context)!;
    final scene = game.currentScene;
    if (scene is! HouseScene) return const SizedBox.shrink();

    return IgnorePointer(
      child: SafeArea(
        child: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ValueListenableBuilder<int>(
              valueListenable: scene.remainingClutterNotifier,
              builder: (context, remaining, _) {
                return GlassPanel(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.liam_space_title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${l.liam_space_prompt}\nRemaining items: $remaining',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
