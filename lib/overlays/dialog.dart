import 'package:emvia/l10n/app_localizations_gen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../game/emvia_game.dart';

class DialogOverlay extends StatelessWidget {
  final EmviaGame game;

  const DialogOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizationsGen.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String dialogText = loc.teacher_intro;
    if (game.currentDialogKey == 'too_loud') dialogText = loc.too_loud;
    if (game.currentDialogKey == 'calmed') dialogText = loc.calmed;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
            width: 3,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.face_retouching_natural_rounded,
                color: theme.colorScheme.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                dialogText,
                style: GoogleFonts.baloo2(
                  color: theme.colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
