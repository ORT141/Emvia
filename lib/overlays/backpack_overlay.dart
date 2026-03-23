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
  Future<void> Function()? _stopItemAudio;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.game.initializeInventory(context);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _selectItem(BackpackItem item) {
    _doSelect(item);
  }

  Future<void> _doSelect(BackpackItem item) async {
    setState(() => _selectedItem = item);
    if (!widget.game.soundEnabled) return;

    final soundPath = item.localizedSoundAsset(context);

    await _stopItemAudio?.call();
    try {
      final player = await FlameAudio.play(
        soundPath,
        volume: widget.game.volume,
      );
      _stopItemAudio = player.stop;
    } catch (_) {}
  }

  void _selectPrevItem() {
    final items = widget.game.backpack.items;
    if (items.isEmpty) return;
    if (_selectedItem == null) {
      _selectItem(items.first);
      return;
    }
    final idx = items.indexWhere((it) => it.id == _selectedItem!.id);
    final prev = (idx - 1) < 0 ? items.length - 1 : idx - 1;
    _selectItem(items[prev]);
  }

  void _selectNextItem() {
    final items = widget.game.backpack.items;
    if (items.isEmpty) return;
    if (_selectedItem == null) {
      _selectItem(items.first);
      return;
    }
    final idx = items.indexWhere((it) => it.id == _selectedItem!.id);
    final next = (idx + 1) % items.length;
    _selectItem(items[next]);
  }

  @override
  void dispose() {
    _stopItemAudio?.call();
    super.dispose();
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
    return ListenableBuilder(
      listenable: widget.game.backpack.itemsListenable,
      builder: (context, _) {
        final items = widget.game.backpack.items;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.basic,
              child: Hero(
                tag: 'backpack_main',
                child: SizedBox.square(
                  dimension: (MediaQuery.of(context).size.height * 0.5).clamp(
                    0.0,
                    360.0,
                  ),
                  child: GestureDetector(
                    onTap: () => _selectItem(items.first),
                    child: Image.asset(
                      'assets/images/backpack/backpack.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.backpack_title,
              style: GoogleFonts.baloo2(
                fontSize: (MediaQuery.of(context).size.height * 0.065).clamp(
                  28.0,
                  48.0,
                ),
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
      },
    );
  }

  Widget _buildItemCard(BackpackItem item) {
    final theme = Theme.of(context);
    final items = widget.game.backpack.items;
    final currentIndex = items.indexWhere((it) => it.id == item.id);
    final total = items.length;
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.baloo2(
                        fontSize: (MediaQuery.of(context).size.height * 0.05)
                            .clamp(22.0, 36.0),
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.game.selectedTools.contains(item.id)
                          ? item.status
                          : item.status,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isBlocked
                            ? theme.colorScheme.error
                            : (widget.game.selectedTools.contains(item.id)
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
                    const SizedBox(height: 32),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: SizedBox(
                          width: 160,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: _selectPrevItem,
                                icon: const Icon(Icons.chevron_left_rounded),
                                tooltip: 'Previous item',
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Text(
                                  total > 0
                                      ? '${currentIndex + 1} / $total'
                                      : '0 / 0',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _selectNextItem,
                                icon: const Icon(Icons.chevron_right_rounded),
                                tooltip: AppLocalizations.of(context)!.next_item,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: isBlocked
                            ? null
                            : () async {
                                if (item.id == 'headphones') {
                                  widget.game.equipTool(item.id);
                                  widget.game.stressLevel = 10;
                                  widget.game.overlays.remove('Backpack');
                                  return;
                                }

                                if (!widget.game.soundEnabled) return;

                                final soundPath = item.localizedSoundAsset(
                                  context,
                                );

                                await _stopItemAudio?.call();
                                if (!mounted) return;
                                try {
                                  final player = await FlameAudio.play(
                                    soundPath,
                                    volume: widget.game.volume,
                                  );
                                  _stopItemAudio = player.stop;
                                } catch (_) {}
                              },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          backgroundColor: isBlocked
                              ? theme.colorScheme.errorContainer
                              : null,
                        ),
                        child: Text(
                          isBlocked
                              ? (item.id == 'blanket'
                                    ? AppLocalizations.of(
                                        context,
                                      )!.item_blanket_status
                                    : AppLocalizations.of(
                                        context,
                                      )!.item_lunchbox_status)
                              : (widget.game.selectedTools.contains(item.id)
                                    ? 'Unequip'
                                    : AppLocalizations.of(context)!.use_item),
                        ),
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
