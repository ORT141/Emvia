import 'package:flutter/material.dart';
import 'package:emvia/game/emvia_game.dart';

class StressOverlay extends StatelessWidget {
  final EmviaGame game;

  const StressOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.stressNotifier,
      builder: (context, stressVal, _) {
        final profile = game.surveyProfile;
        final stressType = profile.aiStressType;
        final stressLevel = stressVal.toDouble();

        String fluidLevel = 'low';
        if (stressLevel >= 70) {
          fluidLevel = 'max';
        } else if (stressLevel >= 30) {
          fluidLevel = 'mid';
        }

        final bgPath = 'assets/images/stress/${stressType}_background.png';
        final fluidPath =
            'assets/images/stress/stressfluid_${stressType}_$fluidLevel.png';

        return Stack(
          children: [
            Positioned(
              top: 10,
              right: 10,
              child: SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(bgPath),
                    Image.asset(fluidPath, gaplessPlayback: true),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
