import 'package:flame/components.dart';
import 'scenes/game_scene.dart';
import 'scenes/classroom_scene.dart';
import 'scenes/corridor_scene.dart';

double sceneWorldWidth(double worldWidth) {
  return worldWidth;
}

typedef SceneSpawnPoint =
    Vector2 Function(
      GameScene scene,
      Vector2 size,
      PositionComponent worldRoot,
    );

Vector2 sceneSpawnPoint(
  GameScene scene,
  Vector2 size,
  PositionComponent worldRoot,
) {
  if (scene is ClassroomScene) {
    return Vector2(size.x * 0.2, worldRoot.size.y * 0.75);
  }
  if (scene is CorridorScene) {
    return Vector2(80, worldRoot.size.y * 0.75);
  }
  return Vector2(worldRoot.size.x / 2, worldRoot.size.y * 0.75);
}

Vector2 clampTargetToWorldBounds(
  Vector2 target,
  double zoom,
  Vector2 size,
  PositionComponent worldRoot,
) {
  final visibleWidthWorld = size.x / zoom;
  final visibleHeightWorld = size.y / zoom;

  final halfVisibleWidth = visibleWidthWorld / 2;
  final halfVisibleHeight = visibleHeightWorld / 2;

  final worldWidthLocal = worldRoot.size.x;
  final worldHeightLocal = worldRoot.size.y;

  final minX = halfVisibleWidth;
  final maxX = worldWidthLocal - halfVisibleWidth;
  final minY = halfVisibleHeight;
  final maxY = worldHeightLocal - halfVisibleHeight;

  double clampedX = target.x;
  double clampedY = target.y;

  if (minX <= maxX) {
    clampedX = target.x.clamp(minX, maxX).toDouble();
  } else {
    clampedX = worldWidthLocal / 2;
  }

  if (minY <= maxY) {
    clampedY = target.y.clamp(minY, maxY).toDouble();
  } else {
    clampedY = worldHeightLocal / 2;
  }

  return Vector2(clampedX, clampedY);
}
