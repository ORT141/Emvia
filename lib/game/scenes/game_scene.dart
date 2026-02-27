import 'package:flame/components.dart';
import '../emvia_game.dart';

abstract class GameScene extends Component with HasGameReference<EmviaGame> {
  final String backgroundPath;
  final String? foregroundPath;

  GameScene({required this.backgroundPath, this.foregroundPath});

  late SpriteComponent background;
  SpriteComponent? foreground;

  @override
  Future<void> onLoad() async {
    background = SpriteComponent()
      ..sprite = await game.loadSprite(backgroundPath)
      ..size = Vector2(game.worldRoot.size.x, game.size.y);
    add(background);

    if (foregroundPath != null) {
      foreground = SpriteComponent()
        ..sprite = await game.loadSprite(foregroundPath!)
        ..size = Vector2(game.worldRoot.size.x, game.size.y)
        ..priority = 20;
      game.worldRoot.add(foreground!);
    }
  }

  @override
  void onRemove() {
    foreground?.removeFromParent();
    super.onRemove();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      background.size = Vector2(game.worldRoot.size.x, size.y);
      foreground?.size = Vector2(game.worldRoot.size.x, size.y);
    }
  }

  void onPlayerInteract(PositionComponent other) {}
}
