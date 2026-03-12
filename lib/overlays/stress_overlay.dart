import 'package:flutter/material.dart';
import 'package:emvia/game/emvia_game.dart';

class StressOverlay extends StatefulWidget {
  final EmviaGame game;

  const StressOverlay({super.key, required this.game});

  @override
  State<StressOverlay> createState() => _StressOverlayState();
}

class _StressOverlayState extends State<StressOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;
  int _lastStress = 0;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _shakeAnimation = Tween<double>(
      begin: -2,
      end: 2,
    ).chain(CurveTween(curve: Curves.linear)).animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _updateShake(int stressVal) {
    if (stressVal >= 70 && _lastStress < 70) {
      _shakeController.repeat(reverse: true);
    } else if (stressVal < 70 && _lastStress >= 70) {
      _shakeController.stop();
      _shakeController.value = 0;
    }
    _lastStress = stressVal;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.game.stressNotifier,
      builder: (context, stressVal, _) {
        _updateShake(stressVal);

        final profile = widget.game.surveyProfile;
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
              child: AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  );
                },
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
            ),
          ],
        );
      },
    );
  }
}
