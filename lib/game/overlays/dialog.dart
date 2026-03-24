import 'package:emvia/game/dialog/dialog_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../emvia_game.dart';
import '../../l10n/app_localizations_gen.dart';

class DialogOverlay extends StatelessWidget {
  final EmviaGame game;

  const DialogOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<DialogNode?>(
      valueListenable: game.currentNodeNotifier,
      builder: (context, node, child) {
        if (node == null) {
          return const SizedBox.shrink();
        }

        final loc = AppLocalizationsGen.of(context)!;

        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Localizations.override(
                context: context,
                locale: const Locale('uk'),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (node.choices != null && node.choices!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: node.choices!.map((choice) {
                              return ElevatedButton(
                                onPressed: () => game.selectChoice(choice),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      theme.colorScheme.primaryContainer,
                                  foregroundColor:
                                      theme.colorScheme.onPrimaryContainer,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 4,
                                  shadowColor: Colors.black.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                                child: Text(
                                  choice.label(loc),
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                  style: GoogleFonts.baloo2(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    height: 1.3,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(
                            alpha: 0.95,
                          ),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.30 : 0.12,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.28,
                            ),
                            width: 2.5,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withValues(
                                  alpha: 0.18,
                                ),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (node.speakerName != null)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Text(
                                        node.speakerName!(loc),
                                        style: GoogleFonts.baloo2(
                                          color: theme.colorScheme.primary,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                  Text(
                                    node.text(loc),
                                    softWrap: true,
                                    textWidthBasis: TextWidthBasis.longestLine,
                                    style: GoogleFonts.baloo2(
                                      color: theme.colorScheme.onSurface,
                                      fontSize: 18.5,
                                      fontWeight: FontWeight.w600,
                                      height: 1.38,
                                    ),
                                  ),
                                ],
                              ),
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
        );
      },
    );
  }
}
