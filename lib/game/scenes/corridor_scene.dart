import 'package:flame/components.dart';

import 'game_scene.dart';

class CorridorScene extends GameScene {
  CorridorScene()
    : super(
        backgroundPath: 'scenes/corridor/wall.png',
        foregroundPath: 'scenes/corridor/background.png',
      );

  final List<SpriteComponent> _patternSprites = [];

  @override
  double worldWidthForViewport(Vector2 viewportSize) => viewportSize.x;

  @override
  Vector2 spawnPoint(Vector2 viewportSize, Vector2 worldSize) =>
      Vector2(180, viewportSize.y * 0.78);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadWallPattern();
  }

  Future<void> _loadWallPattern() async {
    final pattern = game.surveyProfile.aiPattern;
    if (pattern.isEmpty) return;

    try {
      final sprite = await game.loadSprite('wall-patterns/$pattern.png');
      final worldH = game.size.y;
      final patternSize = worldH * 0.11;
      final worldW = game.worldRoot.size.x;
      final spacing = patternSize * 2.2;
      final count = (worldW / spacing).ceil() + 1;
      final y = worldH * 0.2;

      for (int i = 0; i < count; i++) {
        final sp = SpriteComponent()
          ..sprite = sprite
          ..size = Vector2.all(patternSize)
          ..position = Vector2(i * spacing + patternSize * 0.6, y)
          ..anchor = Anchor.center
          ..opacity = 0.50
          ..priority = 1;
        _patternSprites.add(sp);
        add(sp);
      }
    } catch (_) {}
  }
}
