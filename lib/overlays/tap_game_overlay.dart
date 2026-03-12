import 'package:flutter/material.dart';
import 'package:emvia/game/emvia_game.dart';
import 'package:emvia/l10n/app_localizations_gen.dart';

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
      widget.game.freezeForPathChoice = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizationsGen.of(context)!;
    final progress = (_tapCount / _target).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.45),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [Colors.white.withValues(alpha: 0.1), Colors.transparent],
              radius: 0.8,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 1.1).animate(
                    CurvedAnimation(
                      parent: _pulseController,
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: Text(
                    loc.tap_game_title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 250,
                  height: 12,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.cyanAccent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${(_tapCount)} / $_target',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
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
