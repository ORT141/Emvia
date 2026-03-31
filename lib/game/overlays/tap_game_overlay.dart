import 'dart:async';
import 'dart:math' as math;
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:emvia/game/emvia_game.dart';

class TapGameOverlay extends StatefulWidget {
  final EmviaGame game;

  const TapGameOverlay({super.key, required this.game});

  @override
  State<TapGameOverlay> createState() => _TapGameOverlayState();
}

class _TapGameOverlayState extends State<TapGameOverlay>
    with TickerProviderStateMixin {
  int _tapCount = 0;
  static const int _target = 15;
  late AnimationController _pulseController;
  final List<_FloatingWord> _words = [];
  final math.Random _random = math.Random();

  static const double _initialVolume = 2.0;

  AudioPlayer? _voicePlayer;
  Timer? _voiceFadeTimer;
  double _voiceVolume = 0.0;

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
    _startVoiceLoop();
  }

  @override
  void dispose() {
    _stopVoiceLoop();
    _pulseController.dispose();
    for (final word in _words) {
      word.controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fadeVoiceVolume(double from, double to, Duration duration) {
    _voiceFadeTimer?.cancel();
    final steps = 15;
    final stepDuration = Duration(
      milliseconds: (duration.inMilliseconds / steps).round(),
    );
    final delta = (to - from) / steps;
    var currentStep = 0;
    _voiceVolume = from;

    final completer = Completer<void>();

    _voiceFadeTimer = Timer.periodic(stepDuration, (timer) {
      currentStep++;
      _voiceVolume = (from + delta * currentStep).clamp(0.0, _initialVolume);
      _voicePlayer?.setVolume(_voiceVolume);

      if (currentStep >= steps) {
        timer.cancel();
        _voiceFadeTimer = null;
        if (to <= 0.0) {
          _voicePlayer?.stop();
          _voicePlayer = null;
        }
        completer.complete();
      }
    });

    return completer.future;
  }

  Future<void> _startVoiceLoop() async {
    try {
      _voicePlayer = await FlameAudio.loop(
        'other/people-talking.mp3',
        volume: 0.0,
      );
      _voicePlayer?.setReleaseMode(ReleaseMode.loop);
      await _fadeVoiceVolume(
        0.0,
        widget.game.volume,
        const Duration(milliseconds: 700),
      );
      _voiceVolume = widget.game.volume;
    } catch (_) {
      _voicePlayer = null;
    }
  }

  Future<void> _stopVoiceLoop() async {
    _voiceFadeTimer?.cancel();
    if (_voicePlayer != null) {
      await _fadeVoiceVolume(
        _voiceVolume,
        0.0,
        const Duration(milliseconds: 400),
      );
    }
  }

  void _handleTap() {
    setState(() {
      _tapCount++;
      _pulseController.forward(from: 0);

      final progress = (_tapCount / _target).clamp(0.0, 1.0);
      final targetVolume = (widget.game.volume * (1.0 - progress)).clamp(
        0.0,
        _initialVolume,
      );
      _voiceVolume = targetVolume;
      _voicePlayer?.setVolume(_voiceVolume);

      final aiWords = widget.game.surveyProfile.aiWords;
      if (aiWords.isNotEmpty) {
        final wordText = aiWords[_random.nextInt(aiWords.length)];
        final controller = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1000),
        );

        final size = MediaQuery.of(context).size;
        final position = Offset(
          _random.nextDouble() * (size.width - 80) + 40,
          _random.nextDouble() * (size.height - 200) + 80,
        );

        final word = _FloatingWord(
          text: wordText,
          position: position,
          controller: controller,
          offset: Offset(
            (_random.nextDouble() - 0.5) * 40,
            -20 - _random.nextDouble() * 40,
          ),
        );

        _words.add(word);
        controller.forward().then((_) {
          if (mounted) {
            setState(() {
              _words.remove(word);
              word.controller.dispose();
            });
          }
        });
      }
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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: Stack(
        children: [
          ..._words.map(
            (word) => Positioned(
              left: word.position.dx + (word.offset.dx * word.controller.value),
              top: word.position.dy + (word.offset.dy * word.controller.value),
              child: AnimatedBuilder(
                animation: word.controller,
                builder: (context, child) {
                  final scale = 1.0 + (word.controller.value * 0.5);
                  final opacity = (1.0 - word.controller.value).clamp(0.0, 1.0);

                  return Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: Text(
                        word.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, 0.6),
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.1).animate(
                CurvedAnimation(
                  parent: _pulseController,
                  curve: Curves.easeOut,
                ),
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
                      decoration: TextDecoration.none,
                      decorationColor: Colors.transparent,
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
        ],
      ),
    );
  }
}

class _FloatingWord {
  final String text;
  final Offset position;
  final AnimationController controller;
  final Offset offset;

  _FloatingWord({
    required this.text,
    required this.position,
    required this.controller,
    required this.offset,
  });
}
