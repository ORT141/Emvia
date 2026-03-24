import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../emvia_game.dart';
import '../../l10n/app_localizations_gen.dart';

class CreditsOverlay extends StatelessWidget {
  final EmviaGame game;

  const CreditsOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizationsGen.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Stack(
          children: [
            Card(
              color: theme.colorScheme.surface,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            loc.credits,
                            style: GoogleFonts.baloo2(
                              fontSize: 22,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          visualDensity: VisualDensity.compact,
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Text(
                              'RD',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          title: Text(
                            'Remez Devid',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            loc.leadDeveloper,
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        ListTile(
                          visualDensity: VisualDensity.compact,
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor:
                                theme.colorScheme.secondaryContainer,
                            child: Text(
                              'AD',
                              style: TextStyle(
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                          title: Text(
                            'Alice Dudarok',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            loc.artistAndDesigner,
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      loc.thanksForPlaying,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),

                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => game.overlays.remove('Credits'),
                        child: Text(loc.cancel),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              right: 6,
              top: 6,
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => game.overlays.remove('Credits'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
