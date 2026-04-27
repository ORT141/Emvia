import 'package:emvia/game/emvia_game.dart';
import 'package:emvia/l10n/app_localizations_gen.dart';
import 'package:flutter/material.dart';
import '../glass_ui.dart';

class EducationalCardOverlay extends StatefulWidget {
  const EducationalCardOverlay({super.key, required this.game});

  final EmviaGame game;

  @override
  State<EducationalCardOverlay> createState() => _EducationalCardOverlayState();
}

class _EducationalCardOverlayState extends State<EducationalCardOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizationsGen.of(context)!;
    final size = MediaQuery.of(context).size;
    final isSmall = size.shortestSide < 600;

    return Container(
      color: Colors.black.withValues(alpha: 0.55),
      alignment: Alignment.center,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: FractionallySizedBox(
            widthFactor: isSmall ? 0.9 : 0.55,
            child: GlassPanel(
              padding: EdgeInsets.all(isSmall ? 20 : 32),
              borderRadius: BorderRadius.circular(isSmall ? 24 : 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmall ? 10 : 14,
                          vertical: isSmall ? 4 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(isSmall ? 8 : 12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lightbulb_outline_rounded,
                              color: Colors.white.withValues(alpha: 0.9),
                              size: isSmall ? 14 : 16,
                            ),
                            SizedBox(width: isSmall ? 4 : 6),
                            Text(
                              l.educational_card_label,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: isSmall ? 11 : 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmall ? 16 : 22),
                  Text(
                    widget.game.educationalCardText,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontSize: isSmall ? 15 : 18,
                      height: 1.55,
                    ),
                  ),
                  SizedBox(height: isSmall ? 20 : 28),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: widget.game.dismissEducationalCard,
                      child: Text(l.educational_card_got_it),
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
