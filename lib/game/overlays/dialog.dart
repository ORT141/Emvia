import 'package:emvia/game/dialog/dialog_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../emvia_game.dart';
import '../../l10n/app_localizations_gen.dart';

import 'glass_ui.dart';

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
        return Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: node == null
                  ? const SizedBox.shrink()
                  : _buildDialogContent(context, node, theme, isDark),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogContent(
    BuildContext context,
    DialogNode node,
    ThemeData theme,
    bool isDark,
  ) {
    final loc = AppLocalizationsGen.of(context)!;
    final size = MediaQuery.of(context).size;
    final isSmall = size.shortestSide < 600;
    final isVerySmall = size.width < 400;

    return Align(
      key: ValueKey(node.id),
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + (isSmall ? 8 : 16),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Localizations.override(
            context: context,
            locale: const Locale('uk'),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isSmall ? 600 : 800),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (node.choices != null && node.choices!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmall ? 8 : 16,
                        vertical: isSmall ? 4 : 8,
                      ),
                      child: Wrap(
                        spacing: isSmall ? 8 : 12,
                        runSpacing: isSmall ? 8 : 12,
                        alignment: WrapAlignment.center,
                        children: node.choices!.map((choice) {
                          return _buildChoiceButton(
                            context,
                            choice,
                            loc,
                            isSmall,
                            theme,
                          );
                        }).toList(),
                      ),
                    ),
                  GestureDetector(
                    onTap: () => game.nextDialog(),
                    child: GlassPanel(
                      borderRadius: BorderRadius.circular(isSmall ? 24 : 32),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmall ? 16 : 24,
                        vertical: isSmall ? 14 : 20,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isVerySmall) ...[
                            Container(
                              width: isSmall ? 44 : 56,
                              height: isSmall ? 44 : 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.face_retouching_natural_rounded,
                                color: Colors.white,
                                size: isSmall ? 24 : 32,
                              ),
                            ),
                            SizedBox(width: isSmall ? 12 : 20),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (node.speakerName != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      node.speakerName!(loc),
                                      style: GoogleFonts.baloo2(
                                        color: Colors.white,
                                        fontSize: isSmall ? 15 : 17,
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
                                    color: Colors.white,
                                    fontSize: isSmall ? 16 : 18.5,
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceButton(
    BuildContext context,
    DialogChoice choice,
    AppLocalizationsGen loc,
    bool isSmall,
    ThemeData theme,
  ) {
    return ElevatedButton(
      onPressed: () => game.selectChoice(choice),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.1),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 16 : 24,
          vertical: isSmall ? 12 : 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isSmall ? 16 : 20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        elevation: 0,
      ),
      child: Text(
        choice.label(loc),
        textAlign: TextAlign.center,
        softWrap: true,
        style: GoogleFonts.baloo2(
          fontWeight: FontWeight.w700,
          fontSize: isSmall ? 16 : 18,
          height: 1.3,
        ),
      ),
    );
  }
}
