import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'game_scene.dart';

class PlaceholderScene extends GameScene {
  PlaceholderScene() : super();

  @override
  void onRemove() {
    if (game.player.parent == game.worldRoot) {
      game.player.removeFromParent();
    }
    super.onRemove();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    add(RectangleComponent(
      size: game.size,
      paint: Paint()..color = Colors.black,
      priority: -100,
    ));

    game.player.opacity = 1;
    game.player.position = game.size / 2;
    add(game.player);

    game.worldRoot.
    add(TextComponent(
      text: 'Coming soon...',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: game.size / 2 + Vector2(0, 100),
    ));
  }
}
