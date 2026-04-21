import 'package:emvia/game/stage_item_card_data.dart';
import 'package:emvia/game/emvia_game.dart';
import 'package:emvia/l10n/app_localizations.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'glass_ui.dart';

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

        final size = MediaQuery.of(context).size;
        final isSmall = size.shortestSide < 600;
        final isShort = size.height < 500;

        final profile = widget.game.surveyProfile;
        final selectedItemId = profile.calmingItem;
        final isChosenItem = item.id == selectedItemId ||
            (selectedItemId == 'stones' && item.id == 'bag_of_rocks') ||
            (selectedItemId == 'toy' && item.id == 'hibuki') ||
            (item.id == 'rocking_chair');

        return GestureDetector(
          onTap: widget.game.hideStageItemCard,
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: Colors.black54,
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {},
              child: GlassPanel(
                constraints: BoxConstraints(
                  maxWidth: isSmall ? size.width * 0.9 : 900,
                  maxHeight: isSmall ? size.height * 0.9 : 700,
                ),
                padding: EdgeInsets.all(isSmall ? 16 : 28),
                borderRadius: BorderRadius.circular(isSmall ? 24 : 32),
                child: SingleChildScrollView(
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
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    fontSize: isSmall ? 18 : null,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                          IconButton(
                            onPressed: widget.game.hideStageItemCard,
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                            ),
                            tooltip: AppLocalizations.of(context)!.cancel,
                            iconSize: isSmall ? 20 : 24,
                          ),
                        ],
                      ),
                      SizedBox(height: isSmall ? 8 : 16),
                      Column(
                        children: [
                          SizedBox(
                            height: isShort ? 140 : (isSmall ? 180 : 240),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                  bottom: isSmall ? 5 : 10,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      isSmall ? 16 : 24,
                                    ),
                                    child: Image.asset(
                                      'assets/images/${item.selectedSpritePath}',
                                      fit: BoxFit.contain,
                                      height: isShort
                                          ? 120
                                          : (isSmall ? 160 : 220),
                                    ),
                                  ),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    isSmall ? 16 : 24,
                                  ),
                                  child: Image.asset(
                                    'assets/images/${item.normalSpritePath}',
                                    fit: BoxFit.contain,
                                    height: isShort
                                        ? 120
                                        : (isSmall ? 160 : 220),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmall ? 12 : 24),
                      if (isChosenItem)
                        GlassButton(
                          onPressed: () => widget.game.useStageItem(item),
                          label: l.useItem,
                        )
                      else
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: isSmall ? 12 : 16,
                          ),
                          child: Text(
                            l.item_lunchbox_status,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white70,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ),
                      SizedBox(height: isSmall ? 12 : 16),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          fontSize: isSmall ? 14 : 16,
                          color: Colors.white.withValues(alpha: 0.9),
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
