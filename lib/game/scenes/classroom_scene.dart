import 'dart:math' as math;

import 'package:flame/components.dart';
import 'game_scene.dart';

class ClassroomScene extends GameScene {
  ClassroomScene()
    : super(
        backgroundPath: 'scenes/classroom/classroom.png',
        foregroundPath: 'scenes/classroom/classmates.png',
      );

  SpriteComponent? _pathOverlay;
  Vector2? _pathBgSrcSize;

  double _bgHeight = 0;

  double get bgHeight => _bgHeight > 0 ? _bgHeight : game.size.y;

  Vector2 _coverSize(Vector2 src, Vector2 target) {
    final scale = math.max(target.x / src.x, target.y / src.y);
    return Vector2(src.x * scale, src.y * scale);
  }

  Vector2 _coverPosition(Vector2 covered, Vector2 target) =>
      Vector2((target.x - covered.x) / 2, (target.y - covered.y) / 2);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final src = background.sprite?.srcSize;
    if (src != null && src.x > 0 && src.y > 0) {
      _bgHeight = game.worldRoot.size.x * src.y / src.x;
    }
    background.size = Vector2(game.worldRoot.size.x, bgHeight);
    foreground?.size = Vector2(game.worldRoot.size.x, bgHeight);
  }

  Future<void> showPathImage() async {
    final sprite = await game.loadSprite('scenes/classroom/path.png');
    background.sprite = sprite;
    _pathBgSrcSize = sprite.srcSize.clone();
    final covered = _coverSize(_pathBgSrcSize!, game.size);
    background.size = covered;
    background.position = _coverPosition(covered, game.size);
    foreground?.opacity = 0.0;
    await clearPathOverlay();
  }

  Future<void> showClassroomImage() async {
    background.sprite = await game.loadSprite(backgroundPath);
    _pathBgSrcSize = null;
    background.size = Vector2(game.worldRoot.size.x, bgHeight);
    background.position = Vector2.zero();
    foreground?.size = Vector2(game.worldRoot.size.x, bgHeight);
    foreground?.opacity = 1.0;
    await clearPathOverlay();
  }

  Future<void> showPathOverlay(String asset) async {
    final sprite = await game.loadSprite(asset);
    final covered = _coverSize(sprite.srcSize, game.size);
    final pos = _coverPosition(covered, game.size);
    if (_pathOverlay == null) {
      _pathOverlay = SpriteComponent(
        sprite: sprite,
        size: covered,
        anchor: Anchor.topLeft,
        position: pos,
      );
      add(_pathOverlay!);
    } else {
      _pathOverlay!.sprite = sprite;
      _pathOverlay!.size = covered;
      _pathOverlay!.position = pos;
    }
  }

  Future<void> clearPathOverlay() async {
    if (_pathOverlay != null) {
      _pathOverlay!.removeFromParent();
      _pathOverlay = null;
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      final overlaySprite = _pathOverlay?.sprite;
      if (overlaySprite != null) {
        final covered = _coverSize(overlaySprite.srcSize, size);
        _pathOverlay!.size = covered;
        _pathOverlay!.position = _coverPosition(covered, size);
      }
      if (foreground?.opacity == 0 && _pathBgSrcSize != null) {
        final covered = _coverSize(_pathBgSrcSize!, size);
        background.size = covered;
        background.position = _coverPosition(covered, size);
      } else {
        background.size = Vector2(game.worldRoot.size.x, bgHeight);
        background.position = Vector2.zero();
        foreground?.size = Vector2(game.worldRoot.size.x, bgHeight);
      }
    }
  }
}
