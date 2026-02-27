import 'package:flutter/material.dart';
import 'package:emvia/l10n/app_localizations.dart';

import '../game/emvia_game.dart';

class CalmMapOverlay extends StatelessWidget {
  final EmviaGame game;

  const CalmMapOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = game.surveyProfile;
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.96),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Card(
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.storyResultTitle.isEmpty
                        ? l.calm_map_personal_artifact
                        : game.storyResultTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    game.storyResultDescription,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: profile.safeColorValue.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.calm_map_title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.calm_map_pattern(
                            profile.calmingPatternLabel(context),
                          ),
                        ),
                        Text(
                          l.calm_map_item(profile.calmingItemLabel(context)),
                        ),
                        Text(
                          l.calm_map_support_message(
                            profile.supportMessageLabel(context),
                          ),
                        ),
                        Text(
                          l.calm_map_support_symbol(profile.supportSymbolEmoji),
                        ),
                        if (game.selectedTools.isNotEmpty)
                          Text(
                            l.calm_map_selected_tools(
                              game.selectedTools.join(', '),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: () {
                          game.overlays.remove('CalmMap');
                          game.overlays.add('MainMenu');
                        },
                        icon: const Icon(Icons.home_rounded),
                        label: Text(l.backToMenu),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: () {
                          game.startGame();
                          game.overlays.remove('CalmMap');
                        },
                        icon: const Icon(Icons.replay_rounded),
                        label: Text(l.play_again),
                      ),
                    ],
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
