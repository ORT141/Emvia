import 'package:flutter/material.dart';
import 'package:emvia/l10n/app_localizations.dart';

import '../../emvia_game.dart';

class CafeSceneOverlay extends StatefulWidget {
  final EmviaGame game;
  final String imagePath;
  final VoidCallback onDismiss;
  final String? text;
  final String? speakerName;

  const CafeSceneOverlay({
    super.key,
    required this.game,
    required this.imagePath,
    required this.onDismiss,
    this.text,
    this.speakerName,
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
  bool _isDismissing = false;

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
        if (_isDismissing) return;
        _isDismissing = true;
        _dismissController.forward().then((_) => widget.onDismiss()).whenComplete(
          () {
            _isDismissing = false;
          },
        );
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
            if (widget.text != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: MediaQuery.of(context).padding.bottom + 72,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.speakerName != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                widget.speakerName!,
                                style: const TextStyle(
                                  color: Color(0xFFFFD54F),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          Text(
                            widget.text!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
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
