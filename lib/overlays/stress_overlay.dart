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
      if (_shakeController.status != AnimationStatus.forward &&
          _shakeController.status != AnimationStatus.reverse) {
        _shakeController.repeat(reverse: true);
      }
    } else if (stressVal < 70 && _lastStress >= 70) {
      _shakeController.stop();
      _shakeController.value = 0;
    }
    _lastStress = stressVal;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildNoiseOverlay(),
        ValueListenableBuilder<int>(
          valueListenable: widget.game.stressNotifier,
          builder: (context, stressVal, _) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _updateShake(stressVal);
            });

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
                  top: MediaQuery.of(context).padding.top + 8,
                  right: MediaQuery.of(context).padding.right + 8,
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
        ),
      ],
    );
  }

  Widget _buildNoiseOverlay() {
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.game.stressNotifier,
        widget.game.backpack.itemsListenable,
      ]),
      builder: (context, _) {
        final stress = widget.game.stressLevel;
        final hasHeadphones = widget.game.selectedTools.contains('headphones');

        if (hasHeadphones || stress < 30) return const SizedBox.shrink();

        final shake = stress >= 70 ? (stress - 70) / 10.0 : 0.0;

        return IgnorePointer(
          child: AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  _shakeAnimation.value * shake * 2,
                  _shakeAnimation.value * shake * 2,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
