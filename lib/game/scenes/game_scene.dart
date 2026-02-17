import 'package:flame/components.dart';
import '../emvia_game.dart';

abstract class GameScene extends Component with HasGameReference<EmviaGame> {
  final String backgroundPath;

  GameScene({required this.backgroundPath});

  late SpriteComponent background;

  @override
  Future<void> onLoad() async {
    background = SpriteComponent()
      ..sprite = await game.loadSprite(backgroundPath)
      ..size = game.size;
    add(background);
  }

  void onPlayerInteract(PositionComponent other) {}
}
