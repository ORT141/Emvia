import 'package:flutter/material.dart';
import 'package:emvia/l10n/app_localizations.dart';

import '../../emvia_game.dart';

class CafeSceneOverlay extends StatefulWidget {
  final EmviaGame game;
  final String imagePath;
  final VoidCallback onDismiss;

  const CafeSceneOverlay({
    super.key,
    required this.game,
    required this.imagePath,
    required this.onDismiss,
  });

  @override
  State<CafeSceneOverlay> createState() => _CafeSceneOverlayState();
}

class _CafeSceneOverlayState extends State<CafeSceneOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final AnimationController _dismissController;
  late final Animation<double> _blackAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.value = 1.0;
    _dismissController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _blackAnim = CurvedAnimation(
      parent: _dismissController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _dismissController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        try {
          widget.game.pauseEngine();
        } catch (_) {}
        _dismissController.forward().then((_) => widget.onDismiss());
      },
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(widget.imagePath, fit: BoxFit.cover),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 120,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.65),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 28,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: Center(
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.overlay_tap_to_continue,
                    ),
                  ),
                ),
              ),
            ),
            IgnorePointer(
              ignoring: true,
              child: AnimatedBuilder(
                animation: _blackAnim,
                builder: (context, child) {
                  return Container(
                    color: Colors.black.withValues(alpha: _blackAnim.value),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
