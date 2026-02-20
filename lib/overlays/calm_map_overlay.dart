import 'package:flutter/material.dart';

import '../game/emvia_game.dart';

class CalmMapOverlay extends StatelessWidget {
  final EmviaGame game;

  const CalmMapOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = game.surveyProfile;

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
                        ? 'Персональний артефакт'
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
                          'Твоя Мапа спокою',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('• Патерн: ${profile.calmingPatternLabel}'),
                        Text('• Предмет опори: ${profile.calmingItemLabel}'),
                        Text(
                          '• Фраза підтримки: ${profile.supportMessageLabel}',
                        ),
                        Text('• Символ опори: ${profile.supportSymbolEmoji}'),
                        if (game.selectedTools.isNotEmpty)
                          Text(
                            '• Обрані ресурси: ${game.selectedTools.join(', ')}',
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
                        label: const Text('У головне меню'),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: () {
                          game.startGame();
                          game.overlays.remove('CalmMap');
                        },
                        icon: const Icon(Icons.replay_rounded),
                        label: const Text('Зіграти ще раз'),
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
