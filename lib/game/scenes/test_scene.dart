import 'package:flame/components.dart';
import 'game_scene.dart';

class TestScene extends GameScene {
  TestScene()
    : super(backgroundPath: 'scenes/corridor/wall.png', showControls: true);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      TextComponent(
        text: 'TEST SCENE',
        position: Vector2(100, 100),
        anchor: Anchor.center,
      ),
    );
  }

  @override
  Vector2 spawnPoint(Vector2 viewportSize, Vector2 worldSize) {
    return Vector2(viewportSize.x / 2, worldSize.y * 0.6);
  }
}
