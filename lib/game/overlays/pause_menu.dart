import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations_gen.dart';
import '../emvia_game.dart';
import 'glass_ui.dart';

class PauseMenuOverlay extends StatefulWidget {
  final EmviaGame game;

  const PauseMenuOverlay({super.key, required this.game});

  @override
  State<PauseMenuOverlay> createState() => _PauseMenuOverlayState();
}

class _PauseMenuOverlayState extends State<PauseMenuOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleResume() async {
    await _controller.reverse();
    widget.game.resumeGame();
  }

  Future<void> _handleReturnToMenu() async {
    await _controller.reverse();
    widget.game.returnToMainMenu();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizationsGen.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(onTap: _handleResume),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: GlassPanel(
                  width: 320,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        loc.pause.toUpperCase(),
                        style: GoogleFonts.baloo2(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 40),
                      GlassButton(label: loc.resume, onPressed: _handleResume),
                      const SizedBox(height: 16),
                      GlassButton(
                        label: loc.return_to_menu,
                        onPressed: _handleReturnToMenu,
                        primary: false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
