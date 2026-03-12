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

  @override
  void dispose() {
    _stopItemAudio?.call();
    super.dispose();
  }

  String _localizedAssetFor(String assetPath) {
    final locale = Localizations.localeOf(context);
    final lang = locale.languageCode == 'uk' ? 'uk' : 'en';
    final filename = assetPath.split('/').last;
    return 'assets/images/backpack/$lang/$filename';
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
                child: SizedBox(
                  width: 360,
                  height: 360,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/backpack/backpack.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          for (final it in items)
                            Positioned(
                              left: 5,
                              top: -17,
                              width: 350,
                              child: GestureDetector(
                                onTap: () => _selectItem(it),
                                behavior: HitTestBehavior.translucent,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: _selectedItem?.id == it.id
                                        ? Theme.of(context).colorScheme.primary
                                              .withValues(alpha: 0.15)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Image.asset(
                                    _localizedAssetFor(it.iconAsset),
                                    fit: BoxFit.contain,
                                    errorBuilder: (ctx, err, st) => Image.asset(
                                      it.iconAsset,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
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
      },
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
                            child: Center(
                              child: Icon(
                                Icons.inventory_2_outlined,
                                size: 48,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
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
                                      _localizedAssetFor(other.iconAsset),
                                      fit: BoxFit.contain,
                                      errorBuilder: (ctx, err, st) =>
                                          Image.asset(
                                            other.iconAsset,
                                            fit: BoxFit.contain,
                                          ),
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
                            widget.game.selectedTools.contains(item.id)
                                ? '${item.status} (equipped)'
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
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
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

                                      final soundPath = item
                                          .localizedSoundAsset(context);

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
                              icon: Icon(
                                isBlocked
                                    ? Icons.block_rounded
                                    : (widget.game.selectedTools.contains(
                                            item.id,
                                          )
                                          ? Icons.autorenew_rounded
                                          : Icons.check_circle_outline_rounded),
                              ),
                              label: Text(
                                isBlocked
                                    ? (item.id == 'blanket'
                                          ? AppLocalizations.of(
                                              context,
                                            )!.item_blanket_status
                                          : AppLocalizations.of(
                                              context,
                                            )!.item_lunchbox_status)
                                    : (widget.game.selectedTools.contains(
                                            item.id,
                                          )
                                          ? 'Unequip'
                                          : AppLocalizations.of(
                                              context,
                                            )!.use_item),
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
