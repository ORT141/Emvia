import 'dart:math' as math;
import 'package:flame/components.dart';

Vector2 calculateCoverSize(Vector2 src, Vector2 target) {
  final scale = math.max(target.x / src.x, target.y / src.y);
  return Vector2(src.x * scale, src.y * scale);
}

Vector2 calculateCoverPosition(Vector2 covered, Vector2 target) {
  return Vector2((target.x - covered.x) / 2, (target.y - covered.y) / 2);
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

Vector2 getWorldPosFromUV(Vector2 uv, Vector2 bgPos, Vector2 bgSize) {
  return bgPos + Vector2(uv.x * bgSize.x, uv.y * bgSize.y);
}

extension Vector2Extension on Vector2 {
  Vector2 toWorldPos(Vector2 bgPos, Vector2 bgSize) =>
      bgPos + Vector2(x * bgSize.x, y * bgSize.y);
}
