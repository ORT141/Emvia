import 'dart:async';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:emvia/game/emvia_game.dart';
import 'package:emvia/l10n/app_localizations_gen.dart';

enum _BreathingPhase { inhale, hold, exhale, done }

class BreathingExerciseOverlay extends StatefulWidget {
  final EmviaGame game;

  const BreathingExerciseOverlay({super.key, required this.game});

  @override
  State<BreathingExerciseOverlay> createState() =>
      _BreathingExerciseOverlayState();
}

class _BreathingExerciseOverlayState extends State<BreathingExerciseOverlay>
    with TickerProviderStateMixin {
  static const _totalCycles = 4;
  static const _phaseDurations = {
    _BreathingPhase.inhale: 4,
    _BreathingPhase.hold: 7,
    _BreathingPhase.exhale: 8,
  };

  int _cycle = 0;
  _BreathingPhase _phase = _BreathingPhase.inhale;
  int _countdown = _phaseDurations[_BreathingPhase.inhale]!;
  Timer? _timer;
  AudioPlayer? _breathingAudio;

  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();

    _startTimer();
    _startBreathingAudio();
  }

  Future<void> _startBreathingAudio() async {
    if (!widget.game.soundEnabled) return;
    try {
      _breathingAudio = await FlameAudio.loop(
        'other/супровід на дихання.mp3',
        volume: widget.game.volume * 0.7,
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathingAudio?.stop();
    _breathingAudio?.dispose();
    _breathingAudio = null;
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          _advancePhase();
        }
      });
    });
  }

  void _advancePhase() {
    if (_phase == _BreathingPhase.inhale) {
      _phase = _BreathingPhase.hold;
      _countdown = _phaseDurations[_BreathingPhase.hold]!;
      _scaleController.stop();
    } else if (_phase == _BreathingPhase.hold) {
      _phase = _BreathingPhase.exhale;
      _countdown = _phaseDurations[_BreathingPhase.exhale]!;
      _scaleController.duration = const Duration(seconds: 8);
      _scaleController.forward(from: 1.0);
    } else if (_phase == _BreathingPhase.exhale) {
      _cycle++;
      if (_cycle >= _totalCycles) {
        _phase = _BreathingPhase.done;
        _timer?.cancel();
      } else {
        _phase = _BreathingPhase.inhale;
        _countdown = _phaseDurations[_BreathingPhase.inhale]!;
        _scaleController.duration = const Duration(seconds: 4);
        _scaleController.repeat(reverse: true);
      }
    }
  }

  void _onTap() {
    if (_phase == _BreathingPhase.done) return;
    setState(() {
      _advancePhase();
    });
  }

  void _finish() {
    widget.game.finishBreathingExercise();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizationsGen.of(context);
    final isSmall = MediaQuery.of(context).size.shortestSide < 600;

    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: _phase != _BreathingPhase.done ? _onTap : null,
        child: AnimatedBuilder(
          animation: _fadeAnim,
          builder: (context, child) {
            return Container(
              color: const Color(0xFF1A1A2E).withValues(alpha: _fadeAnim.value),
              child: child,
            );
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l?.breathing_title ?? 'Дихальна вправа',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmall ? 20 : 26,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${l?.breathing_cycle ?? 'Цикл'} ${_cycle + (_phase == _BreathingPhase.done ? 0 : 1)} / $_totalCycles',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isSmall ? 14 : 16,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_phase != _BreathingPhase.done) ...[
                    AnimatedBuilder(
                      animation: _scaleAnim,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _phase == _BreathingPhase.hold
                              ? 1.0
                              : _scaleAnim.value,
                          child: child,
                        );
                      },
                      child: Container(
                        width: isSmall ? 140 : 180,
                        height: isSmall ? 140 : 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _phaseColor().withValues(alpha: 0.3),
                          border: Border.all(color: _phaseColor(), width: 3),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _phaseLabel(l),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmall ? 16 : 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$_countdown',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmall ? 28 : 36,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _phaseInstruction(l),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isSmall ? 13 : 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l?.breathing_tap_to_advance ??
                          'Торкніться, щоб перейти до наступного кроку',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: isSmall ? 11 : 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.greenAccent,
                      size: isSmall ? 64 : 80,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l?.breathing_done ?? 'Чудово! Ти впорався.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmall ? 18 : 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90D9),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmall ? 24 : 32,
                          vertical: isSmall ? 12 : 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _finish,
                      child: Text(
                        l?.breathing_back_to_map ?? 'Повернутися до мапи',
                        style: TextStyle(fontSize: isSmall ? 14 : 16),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _phaseColor() {
    switch (_phase) {
      case _BreathingPhase.inhale:
        return const Color(0xFF64B5F6);
      case _BreathingPhase.hold:
        return const Color(0xFFFFD54F);
      case _BreathingPhase.exhale:
        return const Color(0xFF80CBC4);
      case _BreathingPhase.done:
        return Colors.greenAccent;
    }
  }

  String _phaseLabel(AppLocalizationsGen? l) {
    switch (_phase) {
      case _BreathingPhase.inhale:
        return l?.breathing_inhale ?? 'Вдих';
      case _BreathingPhase.hold:
        return l?.breathing_hold ?? 'Затримка';
      case _BreathingPhase.exhale:
        return l?.breathing_exhale ?? 'Видих';
      case _BreathingPhase.done:
        return '';
    }
  }

  String _phaseInstruction(AppLocalizationsGen? l) {
    switch (_phase) {
      case _BreathingPhase.inhale:
        return l?.breathing_inhale_instruction ?? 'Повільно вдихніть через ніс';
      case _BreathingPhase.hold:
        return l?.breathing_hold_instruction ?? 'Затримайте дихання';
      case _BreathingPhase.exhale:
        return l?.breathing_exhale_instruction ??
            'Повільно видихайте через рот, наче через соломинку';
      case _BreathingPhase.done:
        return '';
    }
  }
}
