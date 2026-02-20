import 'package:flutter/material.dart';

import '../game/emvia_game.dart';

class PathChoiceOverlay extends StatefulWidget {
  final EmviaGame game;

  const PathChoiceOverlay({super.key, required this.game});

  @override
  State<PathChoiceOverlay> createState() => _PathChoiceOverlayState();
}

class _PathChoiceOverlayState extends State<PathChoiceOverlay> {
  int? _selectedIndex;

  EmviaGame get game => widget.game;

  @override
  void initState() {
    super.initState();
    game.showPathBackground();
  }

  @override
  void dispose() {
    game.clearPathOverlay();
    game.restoreClassroomBackground();
    super.dispose();
  }

  void _onAccept() {
    if (_selectedIndex == 0) {
      game.chooseFirstPath();
    } else if (_selectedIndex == 1) {
      game.chooseSecondPath();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.12),
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Card(
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Обери маршрут',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _OptionChip(
                          label: 'Перший шлях',
                          selected: _selectedIndex == 0,
                          onTap: () {
                            setState(() => _selectedIndex = 0);
                            game.previewPathOverlay(0);
                          },
                        ),
                        const SizedBox(width: 12),
                        _OptionChip(
                          label: 'Другий шлях',
                          selected: _selectedIndex == 1,
                          onTap: () {
                            setState(() => _selectedIndex = 1);
                            game.previewPathOverlay(1);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            game.clearPathOverlay();
                            game.restoreClassroomBackground();
                            game.overlays.remove('PathChoice');
                          },
                          child: const Text('Скасувати'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _selectedIndex == null ? null : _onAccept,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(100, 36),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: const Text('Підтвердити'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.10)
              : null,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.map,
              size: 18,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(label, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
