import 'package:flutter/material.dart';
import 'package:emvia/game/emvia_game.dart';

class TapGameOverlay extends StatefulWidget {
  final EmviaGame game;

  const TapGameOverlay({super.key, required this.game});

  @override
  State<TapGameOverlay> createState() => _TapGameOverlayState();
}

class _TapGameOverlayState extends State<TapGameOverlay>
    with SingleTickerProviderStateMixin {
  int _tapCount = 0;
  static const int _target = 15;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 150),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _pulseController.reverse();
          }
        });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _tapCount++;
      _pulseController.forward(from: 0);
    });
    if (_tapCount >= _target) {
      widget.game.stressLevel = 60;
      widget.game.overlays.remove('TapGame');
      widget.game.isFrozen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_tapCount / _target).clamp(0.0, 1.0);
    final isNearingEnd = _tapCount > _target * 0.7;

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.6),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: Align(
          alignment: const Alignment(0, 0.6),
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.1).animate(
              CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 250,
                  height: 250,
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 200),
                    tween: Tween<double>(begin: 0, end: progress),
                    builder: (context, value, child) {
                      return CircularProgressIndicator(
                        value: value,
                        strokeWidth: 26,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isNearingEnd
                              ? Colors.orangeAccent
                              : Colors.cyanAccent,
                        ),
                      );
                    },
                  ),
                ),

                Text(
                  '$_tapCount/$_target',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: (isNearingEnd ? Colors.orange : Colors.cyan)
                            .withValues(alpha: 0.5),
                        blurRadius: 20,
                      ),
                    ],
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
