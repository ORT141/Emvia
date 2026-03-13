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

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.45),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: Center(
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.1).animate(
              CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
            ),
            child: SizedBox(
              width: 300,
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.cyanAccent,
                    ),
                  ),
                  Text(
                    '$_tapCount/$_target',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
