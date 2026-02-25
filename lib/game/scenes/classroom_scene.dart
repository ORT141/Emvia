import 'package:flame/components.dart';
import 'game_scene.dart';

class ClassroomScene extends GameScene {
  ClassroomScene()
    : super(backgroundPath: 'scenes/classroom/classroom.png');

  SpriteComponent? _pathOverlay;

  Future<void> showPathImage() async {
    background.sprite = await game.loadSprite(
      'scenes/classroom/path.png',
    );
    await clearPathOverlay();
  }

  Future<void> showClassroomImage() async {
    background.sprite = await game.loadSprite(backgroundPath);
    await clearPathOverlay();
  }

  Future<void> showPathOverlay(String asset) async {
    final sprite = await game.loadSprite(asset);
    if (_pathOverlay == null) {
      _pathOverlay = SpriteComponent(
        sprite: sprite,
        size: game.size,
        anchor: Anchor.topLeft,
        position: Vector2.zero(),
      );
      add(_pathOverlay!);
    } else {
      _pathOverlay!.sprite = sprite;
    }
  }

  Future<void> clearPathOverlay() async {
    if (_pathOverlay != null) {
      _pathOverlay!.removeFromParent();
      _pathOverlay = null;
    }
  }
}
