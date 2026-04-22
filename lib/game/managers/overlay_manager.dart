import 'package:flutter/foundation.dart';
import '../emvia_game.dart';
import '../stage_item_card_data.dart';
import '../scenes/stage_scene.dart';
import '../scenes/corridor_scene.dart';

class OverlayManager {
  final EmviaGame game;

  final ValueNotifier<StageItemCardData?> selectedStageItemNotifier =
      ValueNotifier<StageItemCardData?>(null);
  final ValueNotifier<bool> mobileControlsVisible = ValueNotifier<bool>(false);

  OverlayManager(this.game);

  bool get isBackpackOpen => game.overlays.isActive('Backpack');
  bool get isDebugOpen => game.overlays.isActive('Debug');
  bool get isStageItemCardOpen => game.overlays.isActive('StageItemCard');

  void showStageItemCard(StageItemCardData item) {
    game.overlays.remove('CalmingItemPrompt');
    selectedStageItemNotifier.value = item;
    game.overlays.add('StageItemCard');
    if (game.currentScene is StageScene) {
      (game.currentScene as StageScene).clearSelectedItem();
    }
  }

  void hideStageItemCard() {
    game.overlays.remove('StageItemCard');
    selectedStageItemNotifier.value = null;
    if (game.currentScene is StageScene) {
      (game.currentScene as StageScene).clearSelectedItem();
    }
  }

  void toggleBackpack() {
    if (!canToggleBackpack()) return;
    if (isBackpackOpen) {
      game.overlays.remove('Backpack');
    } else {
      game.overlays.remove('Dialog');
      game.currentNode = null;
      game.overlays.add('Backpack');
    }
  }

  void toggleDebug() {
    if (isDebugOpen) {
      game.overlays.remove('Debug');
    } else {
      game.overlays.add('Debug');
    }
  }

  bool canToggleBackpack() {
    if (game.sceneIndex == 0) return false;
    if (game.transitionManager.isTransitioning) return false;
    if (game.olyaState.isCorridorStressIntroActive) return false;
    if (game.overlays.isActive('MainMenu')) return false;
    if (game.overlays.isActive('Survey')) return false;
    return true;
  }

  void showMobileControls() {
    if (!game.isMobilePlatform) return;
    if (game.sceneIndex == 0) return;

    if (!game.overlays.isActive('MobileControls')) {
      game.overlays.add('MobileControls');
    }
    mobileControlsVisible.value = true;
  }

  void hideMobileControls() {
    if (!mobileControlsVisible.value) return;
    mobileControlsVisible.value = false;
    game.setMobileMoveX(0);
  }

  void clearGameplayOverlays() {
    game.overlays.remove('Dialog');
    game.overlays.remove('CalmMap');
    game.overlays.remove('PathChoice');
    game.overlays.remove('Backpack');
    game.currentNode = null;
    game.hidePathDetail();
  }

  void openMainMenu() {
    game.overlays.remove('Backpack');
    hideMobileControls();
    game.overlays.add('MainMenu');
  }

  void closeMainMenu() {
    game.overlays.remove('MainMenu');
    if (game.sceneIndex == 0 && game.currentScene is CorridorScene) {
      game.player.opacity = 1;
    }
    if (!game.paused && game.sceneIndex > 0) {
      showMobileControls();
    }
  }
}
