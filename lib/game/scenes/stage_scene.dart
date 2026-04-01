import 'package:flame/components.dart';
import 'dart:ui' show FilterQuality, Paint;

import '../scenes/game_scene.dart';
import '../utils/pos_util.dart';

class StageScene extends GameScene {
  StageScene()
    : super(
        backgroundPath: 'scenes/stage/background_stage.png',
        foregroundPath: 'scenes/stage/foreground_stage.png',
        showControls: true,
        frozenPlayer: false,
      );

  static const double _rockingChairHeightFactor = 0.8;

  @override
  Vector2 spawnPoint(Vector2 viewportSize, Vector2 worldSize) =>
      Vector2(viewportSize.x / 2, worldSize.y * 0.85);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      final sprite = await game.loadSprite('scenes/stage/rocking_chair.png');

      final rc = SpriteComponent()
        ..anchor = Anchor.center
        ..priority = 5;

      rc.sprite = sprite;
      rc.paint = Paint()
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.high;

      if (sprite.srcSize.y > 0) {
        final height = game.size.y * _rockingChairHeightFactor;
        final width = sprite.srcSize.x / sprite.srcSize.y * height;
        rc.size = Vector2(width, height);
      } else {
        rc.size = Vector2.all(80);
      }

      rc.position = getWorldPosFromUV(
        Vector2(0.5104, 0.4),
        background.position,
        background.size,
      );
      add(rc);
    } catch (_) {}
  }
}
