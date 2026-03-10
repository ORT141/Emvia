import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' show FilterQuality, Paint;
import '../emvia_game.dart';

abstract class GameScene extends Component with HasGameReference<EmviaGame> {
  final String backgroundPath;
  final String? foregroundPath;

  GameScene({required this.backgroundPath, this.foregroundPath});

  late SpriteComponent background;
  SpriteComponent? foreground;

  double worldWidthForViewport(Vector2 viewportSize) => EmviaGame.worldWidth;

  Vector2 spawnPoint(Vector2 viewportSize, Vector2 worldSize) =>
      Vector2(viewportSize.x / 2, worldSize.y * 0.75);

  @override
  @mustCallSuper
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      layoutToWorld();
    }
  }

  @protected
  void layoutToWorld() {
    final viewportH = game.size.y;

    if (background.sprite?.srcSize != null &&
        background.sprite!.srcSize.x > 0 &&
        background.sprite!.srcSize.y > 0) {
      final src = background.sprite!.srcSize;
      final scale = viewportH / src.y;
      final contentW = src.x * scale;
      final worldW = worldWidthForViewport(game.size);

      background
        ..size = Vector2(contentW, viewportH)
        ..position = Vector2.zero();

      game.worldRoot.size = Vector2(worldW, viewportH);
    } else {
      final w = worldWidthForViewport(game.size);
      background
        ..size = Vector2(w, viewportH)
        ..position = Vector2.zero();
    }

    if (foreground != null) {
      if (foreground!.sprite?.srcSize != null &&
          foreground!.sprite!.srcSize.x > 0 &&
          foreground!.sprite!.srcSize.y > 0) {
        final src = foreground!.sprite!.srcSize;
        final scale = viewportH / src.y;
        final contentW = src.x * scale;
        foreground!
          ..size = Vector2(contentW, viewportH)
          ..position = Vector2.zero();
      } else {
        final w = worldWidthForViewport(game.size);
        foreground!
          ..size = Vector2(w, viewportH)
          ..position = Vector2.zero();
      }
    }
  }

  @override
  Future<void> onLoad() async {
    background = SpriteComponent()
      ..sprite = await game.loadSprite(backgroundPath)
      ..anchor = Anchor.topLeft
      ..priority = 0;
    background.paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high;
    add(background);

    if (foregroundPath != null) {
      foreground = SpriteComponent()
        ..sprite = await game.loadSprite(foregroundPath!)
        ..anchor = Anchor.topLeft
        ..priority = 20;
      foreground!.paint = Paint()
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.high;
      add(foreground!);
    }

    layoutToWorld();
  }

  @mustCallSuper
  void redrawScene() {
    layoutToWorld();
  }

  @override
  void onRemove() {
    foreground?.removeFromParent();
    super.onRemove();
  }

  void onPlayerInteract(PositionComponent other) {}

  void onTapDown(TapDownEvent event) {}
}
