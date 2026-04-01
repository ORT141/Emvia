import 'dart:math' as math;
import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/material.dart';
import 'package:emvia/game/emvia_game.dart';
import 'package:emvia/l10n/app_localizations_gen.dart';

class StressOverlay extends StatefulWidget {
  final EmviaGame game;

  const StressOverlay({super.key, required this.game});

  @override
  State<StressOverlay> createState() => _StressOverlayState();
}

class _StressOverlayState extends State<StressOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;
  late final AnimationController _introController;
  late final Animation<double> _introAnimation;
  int _lastStress = 0;
  bool _isIntroAnimating = false;

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
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _introAnimation = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeInOutCubic,
    );
    _introController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.game.completeCorridorStressIntro();
        if (mounted) {
          setState(() {
            _isIntroAnimating = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _dismissIntro() {
    if (!widget.game.isCorridorStressIntroActive || _isIntroAnimating) return;
    setState(() {
      _isIntroAnimating = true;
    });
    _introController.forward(from: 0);
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
    final l = AppLocalizationsGen.of(context)!;

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
            final showIntro =
                widget.game.isCorridorStressIntroActive || _isIntroAnimating;

            return Stack(
              children: [
                if (!showIntro)
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
                      child: _buildStressMeter(
                        bgPath: bgPath,
                        fluidPath: fluidPath,
                        size: 120,
                      ),
                    ),
                  ),
                if (showIntro)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _dismissIntro,
                      child: AnimatedBuilder(
                        animation: _introAnimation,
                        builder: (context, child) {
                          final dimOpacity = (1 - _introAnimation.value) * 0.70;
                          return Stack(
                            children: [
                              IgnorePointer(
                                child: Container(
                                  color: Colors.black.withValues(
                                    alpha: dimOpacity,
                                  ),
                                ),
                              ),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final mediaPadding = MediaQuery.of(
                                    context,
                                  ).padding;
                                  final progress = _introAnimation.value;
                                  final startMeterSize = math
                                      .min(
                                        math.max(
                                          constraints.biggest.shortestSide *
                                              0.34,
                                          170,
                                        ),
                                        250,
                                      )
                                      .toDouble();
                                  final introMeterSize = lerpDouble(
                                    startMeterSize,
                                    120,
                                    progress,
                                  )!;
                                  final textWidth = math.min(
                                    constraints.maxWidth * 0.78,
                                    420.0,
                                  );
                                  final introWidth = lerpDouble(
                                    math.max(startMeterSize, textWidth),
                                    120,
                                    progress,
                                  )!;
                                  const textHeight = 78.0;
                                  final introHeight =
                                      introMeterSize + textHeight;

                                  final startLeft =
                                      (constraints.maxWidth -
                                          math.max(startMeterSize, textWidth)) /
                                      2;
                                  final endLeft =
                                      constraints.maxWidth -
                                      120 -
                                      mediaPadding.right -
                                      8;
                                  final left = lerpDouble(
                                    startLeft,
                                    endLeft,
                                    progress,
                                  )!;
                                  final top = lerpDouble(
                                    (constraints.maxHeight - introHeight) / 2,
                                    mediaPadding.top + 8,
                                    progress,
                                  )!;
                                  final textOpacity =
                                      1 -
                                      Curves.easeOut.transform(
                                        (progress * 1.6).clamp(0.0, 1.0),
                                      );

                                  return Stack(
                                    children: [
                                      Positioned(
                                        left: left,
                                        top: top,
                                        width: introWidth,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _buildStressMeter(
                                              bgPath: bgPath,
                                              fluidPath: fluidPath,
                                              size: introMeterSize,
                                            ),
                                            SizedBox(
                                              height: lerpDouble(
                                                18,
                                                0,
                                                progress,
                                              ),
                                            ),
                                            Opacity(
                                              opacity: textOpacity,
                                              child: IgnorePointer(
                                                child: Text(
                                                  l.stress_intro_caption,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withValues(
                                                          alpha: 0.96,
                                                        ),
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.15,
                                                    decoration:
                                                        TextDecoration.none,
                                                    shadows: const [
                                                      Shadow(
                                                        blurRadius: 12,
                                                        color: Colors.black54,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Opacity(
                                              opacity: textOpacity,
                                              child: IgnorePointer(
                                                child: Text(
                                                  l.stress_intro_watch,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withValues(
                                                          alpha: 0.86,
                                                        ),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.15,
                                                    decoration:
                                                        TextDecoration.none,
                                                    shadows: const [
                                                      Shadow(
                                                        blurRadius: 8,
                                                        color: Colors.black45,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          );
                        },
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

  Widget _buildStressMeter({
    required String bgPath,
    required String fluidPath,
    required double size,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(bgPath),
          Image.asset(fluidPath, gaplessPlayback: true),
        ],
      ),
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

        if (hasHeadphones || stress < 10) return const SizedBox.shrink();

        final panicStyle = widget.game.surveyProfile.panicStyle;
        final intensity = stress / 100.0;

        switch (panicStyle) {
          case 'blur':
            return IgnorePointer(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: intensity * 10,
                  sigmaY: intensity * 10,
                ),
                child: Container(color: Colors.transparent),
              ),
            );
          case 'acid':
            return IgnorePointer(child: _AcidOverlay(intensity: intensity));
          case 'noise':
            return IgnorePointer(child: _NoiseOverlay(intensity: intensity));
          case 'shake':
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}

class _AcidOverlay extends StatefulWidget {
  final double intensity;
  const _AcidOverlay({required this.intensity});

  @override
  State<_AcidOverlay> createState() => _AcidOverlayState();
}

class _AcidOverlayState extends State<_AcidOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final hue = _controller.value * 360;
        final color = HSVColor.fromAHSV(
          widget.intensity * 0.38,
          hue,
          1.0,
          1.0,
        ).toColor();
        return Container(color: color);
      },
    );
  }
}

class _NoiseOverlay extends StatefulWidget {
  final double intensity;
  const _NoiseOverlay({required this.intensity});

  @override
  State<_NoiseOverlay> createState() => _NoiseOverlayState();
}

class _NoiseOverlayState extends State<_NoiseOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _NoisePainter(
            intensity: widget.intensity,
            seed: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _NoisePainter extends CustomPainter {
  final double intensity;
  final double seed;

  const _NoisePainter({required this.intensity, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random((seed * 10000).toInt());
    final paint = Paint();
    final count = (intensity * 600).toInt();
    for (int i = 0; i < count; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final opacity = random.nextDouble() * intensity * 0.55;
      paint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawRect(Rect.fromLTWH(x, y, 2, 2), paint);
    }
  }

  @override
  bool shouldRepaint(_NoisePainter old) => true;
}
