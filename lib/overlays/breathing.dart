import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../game/emvia_game.dart';
import '../l10n/app_localizations_gen.dart';

class BreathingOverlay extends StatefulWidget {
  final EmviaGame game;

  const BreathingOverlay({super.key, required this.game});

  @override
  State<BreathingOverlay> createState() => _BreathingOverlayState();
}

class _BreathingOverlayState extends State<BreathingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizationsGen.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: (isDark ? Colors.black : Colors.white).withOpacity(0.6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final isExpanding =
                    _controller.status == AnimationStatus.forward;
                return Container(
                  width: 150 + _controller.value * 120,
                  height: 150 + _controller.value * 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withOpacity(0.6),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 15 * _controller.value,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      isExpanding ? loc.inhale : loc.exhale,
                      style: GoogleFonts.baloo2(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 60),
            FilledButton(
              onPressed: widget.game.calmDown,
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.tertiary,
                foregroundColor: isDark ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: Text(
                loc.i_calm_down,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
