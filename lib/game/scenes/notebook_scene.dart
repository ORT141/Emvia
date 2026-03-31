import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'game_scene.dart';

class NotebookScene extends GameScene {
  NotebookScene()
      : super(
          backgroundPath: 'scenes/corridor/wall.png',
          showControls: false,
          frozenPlayer: true,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final text = TextComponent(
      text: 'Notebook Scene (Placeholder)',
      anchor: Anchor.center,
      position: game.size / 2,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(text);
  }
}
