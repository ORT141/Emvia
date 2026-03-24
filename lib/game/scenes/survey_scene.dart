import 'package:flame/components.dart';

import 'game_scene.dart';

class SurveyScene extends GameScene {
  SurveyScene()
    : super(
      );

  @override
  double worldWidthForViewport(Vector2 viewportSize) => viewportSize.x;

  @override
  Vector2 spawnPoint(Vector2 viewportSize, Vector2 worldSize) =>
      Vector2(worldSize.x / 2, worldSize.y / 2);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    background.opacity = 0;
    foreground?.opacity = 0;

    game.olya.opacity = 0;

    layoutToWorld();
  }

  @override
  void layoutToWorld() {
    super.layoutToWorld();

    final viewportSize = game.size;

    game.worldRoot.size = viewportSize.clone();
  }
}
