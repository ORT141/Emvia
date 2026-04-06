import 'package:flame/components.dart';
import '../emvia_game.dart';
import 'pos_util.dart';

mixin CoverScaling on HasGameReference<EmviaGame> {
  void setupCoverWorld() {
    game.cameraManager.zoom = 1.0;
    game.worldRoot.scale = Vector2.all(1.0);
    game.worldRoot.size = game.size.clone();
  }

  void applyCoverScaling(SpriteComponent component, {Vector2? srcSize}) {
    final src = srcSize ?? component.sprite?.srcSize;
    if (src != null) {
      final covered = calculateCoverSize(src, game.size);
      component.size = covered;
      component.position = calculateCoverPosition(covered, game.size);
    }
  }
}
