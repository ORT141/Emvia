import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:emvia/game/emvia_game.dart';
import 'package:emvia/l10n/app_localizations_gen.dart';

class PatternProgressOverlay extends StatelessWidget {
  final EmviaGame game;
  final int collected;
  final int total;

  const PatternProgressOverlay({
    super.key,
    required this.game,
    required this.collected,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizationsGen.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return IgnorePointer(
      child: TweenAnimationBuilder<Offset>(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutBack,
        tween: Tween<Offset>(begin: const Offset(0, 1.5), end: Offset.zero),
        builder: (context, offset, child) {
          return Transform.translate(
            offset: Offset(0, offset.dy * 100),
            child: child,
          );
        },
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha((0.35 * 255).round()),
                        border: Border.all(
                          color: Colors.white.withAlpha((0.2 * 255).round()),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l.corridor_pattern_instruction,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l.corridor_pattern_progress(
                              collected.toString(),
                              total.toString(),
                            ),
                            style: TextStyle(
                              fontSize: 15,
                              color: colorScheme.primary.withAlpha(
                                (0.95 * 255).round(),
                              ),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              shadows: const [
                                Shadow(
                                  color: Colors.black38,
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
