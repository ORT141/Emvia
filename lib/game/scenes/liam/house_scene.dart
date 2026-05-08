import 'package:emvia/game/scenes/game_scene.dart';
import 'package:emvia/game/utils/color_util.dart';
import 'package:flame/components.dart';

class HouseScene extends GameScene {
  HouseScene()
    : super(
        backgroundPath: 'scenes/liam/house/background.png',
        foregroundPath: 'scenes/liam/house/foreground.png',
      ) {
    GameScene.register(() => HouseScene());
  }

  @override
  int get sceneIndex => 7;

  @override
  void onPlayerReachedLeftEdge() => game.navigationManager.goToLiamOutside();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    game.overlayManager.showMobileControls();

    ColorUtil.colorWalls(background.decorator, game.surveyProfile);

    layoutToWorld();
  }

  @override
  double worldWidthForViewport(Vector2 viewportSize) {
    if (background.sprite?.srcSize != null &&
        background.sprite!.srcSize.y > 0) {
      final aspect =
          background.sprite!.srcSize.x / background.sprite!.srcSize.y;
      return viewportSize.y * aspect;
    }
    return viewportSize.x * 2;
  }

  @override
  Vector2 spawnPoint(Vector2 viewportSize, Vector2 worldSize) =>
      Vector2(worldSize.x * 0.2, worldSize.y * 0.68);
}
