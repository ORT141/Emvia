import 'package:emvia/game/stage_item_card_data.dart';
import 'package:emvia/game/emvia_game.dart';
import 'package:emvia/l10n/app_localizations.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class StageItemCardOverlay extends StatefulWidget {
  const StageItemCardOverlay({super.key, required this.game});

  final EmviaGame game;

  @override
  State<StageItemCardOverlay> createState() => _StageItemCardOverlayState();
}

class _StageItemCardOverlayState extends State<StageItemCardOverlay> {
  Future<void> Function()? _stopAudio;
  String? _currentItemId;

  @override
  void dispose() {
    _stopAudio?.call();
    super.dispose();
  }

  Future<void> _playAudio(String asset) async {
    if (!widget.game.soundEnabled) return;
    await _stopAudio?.call();
    if (!mounted) return;

    try {
      final player = await FlameAudio.play(asset, volume: widget.game.volume);
      _stopAudio = player.stop;
    } catch (_) {
      _stopAudio = null;
    }
  }

  void _maybePlayAudio(String itemId, String soundPath) {
    if (_currentItemId != itemId) {
      _currentItemId = itemId;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _playAudio(soundPath);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<StageItemCardData?>(
      valueListenable: widget.game.selectedStageItemNotifier,
      builder: (context, item, child) {
        if (item == null) {
          return const SizedBox.shrink();
        }

        final l = AppLocalizationsGen.of(context)!;
        final title = item.title(l);
        final description = item.description(l);
        final soundPath = item.localizedSoundAsset(
          Localizations.localeOf(context).languageCode,
        );
        _maybePlayAudio(item.id, soundPath);

        return GestureDetector(
          onTap: widget.game.hideStageItemCard,
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: Colors.black54,
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {},
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 900,
                  maxHeight: 700,
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 34,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),
                          IconButton(
                            onPressed: widget.game.hideStageItemCard,
                            icon: const Icon(Icons.close_rounded),
                            tooltip: AppLocalizations.of(context)!.cancel,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          SizedBox(
                            height: 240,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.asset(
                                    'assets/images/${item.normalSpritePath}',
                                    fit: BoxFit.contain,
                                    height: 220,
                                  ),
                                ),
                                Positioned(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Image.asset(
                                      'assets/images/${item.selectedSpritePath}',
                                      fit: BoxFit.contain,
                                      height: 220,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        description,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(height: 1.6),
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
