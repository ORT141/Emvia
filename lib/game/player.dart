import 'package:flame/components.dart';

import 'emvia_game.dart';

class OlyaPlayer extends SpriteComponent with HasGameReference<EmviaGame> {
  OlyaPlayer() : super(size: Vector2(100, 150));

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('olya.png');
    anchor = Anchor.center;
    position = game.size / 2;
    y += 50;
  }
}
