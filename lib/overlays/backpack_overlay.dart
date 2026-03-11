import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:emvia/l10n/app_localizations.dart';

import '../game/emvia_game.dart';
import '../game/inventory/backpack_item.dart';
import '../game/scenes/corridor_scene.dart';

class BackpackOverlay extends StatefulWidget {
  const BackpackOverlay({super.key, required this.game});

  final EmviaGame game;

  @override
  State<BackpackOverlay> createState() => _BackpackOverlayState();
}

class _BackpackOverlayState extends State<BackpackOverlay> {
  BackpackItem? _selectedItem;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.game.initializeInventory(context);
      }
    });
  }

  void _selectItem(BackpackItem item) {
    setState(() => _selectedItem = item);
    if (widget.game.soundEnabled) {
      FlameAudio.play(item.soundAsset);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      child: Stack(
        children: [
          GestureDetector(
            onTap: widget.game.toggleBackpack,
            child: Container(color: Colors.transparent),
          ),

          Center(
            child: _selectedItem == null
                ? _buildBackpackIcon()
                : _buildItemCard(_selectedItem!),
          ),

          Positioned(
            top: 40,
            right: 40,
            child: IconButton.filledTonal(
              onPressed: widget.game.toggleBackpack,
              iconSize: 32,
              padding: const EdgeInsets.all(12),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackpackIcon() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            final items = widget.game.backpack.items;
            if (items.isNotEmpty) {
              _selectItem(items.first);
            }
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Hero(
              tag: 'backpack_main',
              child: Image.asset(
                'assets/images/backpack/backpack.png',
                width: 300,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.backpack_title,
          style: GoogleFonts.baloo2(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: [
              const Shadow(
                color: Colors.black45,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(BackpackItem item) {
    final theme = Theme.of(context);
    final isCorridor = widget.game.currentScene is CorridorScene;
    final isBlocked = isCorridor && item.id != 'headphones';

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 40,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Spacer(),
                IconButton.filledTonal(
                  onPressed: () => setState(() => _selectedItem = null),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ],
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Container(
                            height: 200,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Image.asset(
                              item.iconAsset,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 80,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.game.backpack.items.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, idx) {
                                final other = widget.game.backpack.items[idx];
                                return GestureDetector(
                                  onTap: () => _selectItem(other),
                                  child: Container(
                                    width: 80,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: other.id == item.id
                                          ? theme.colorScheme.primary
                                                .withValues(alpha: 0.2)
                                          : theme.colorScheme.surfaceContainer,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: other.id == item.id
                                            ? theme.colorScheme.primary
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Image.asset(
                                      other.iconAsset,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: GoogleFonts.baloo2(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.status,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isBlocked
                                  ? theme.colorScheme.error
                                  : (item.id == 'headphones'
                                        ? Colors.green.shade600
                                        : theme.colorScheme.secondary),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            item.description,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: isBlocked
                                  ? null
                                  : () {
                                      if (widget.game.soundEnabled) {
                                        FlameAudio.play(item.soundAsset);
                                      }
                                    },
                              icon: Icon(
                                isBlocked
                                    ? Icons.block_rounded
                                    : Icons.check_circle_outline_rounded,
                              ),
                              label: Text(
                                isBlocked
                                    ? (item.id == 'blanket'
                                          ? "Unavailable in corridor"
                                          : "Not the right time")
                                    : "Use Item",
                              ),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                backgroundColor: isBlocked
                                    ? theme.colorScheme.errorContainer
                                    : null,
                              ),
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
    );
  }
}
