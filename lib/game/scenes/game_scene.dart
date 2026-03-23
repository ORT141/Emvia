import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' show FilterQuality, Paint;
import 'dart:math' as math;
import '../emvia_game.dart';

enum SceneScalingMode { stretch, scrolling }

abstract class GameScene extends Component with HasGameReference<EmviaGame> {
  final String backgroundPath;
  final List<String> foregroundPaths;
  final SceneScalingMode scalingMode;

  GameScene({
    required this.backgroundPath,
    String? foregroundPath,
    List<String>? foregroundPaths,
    this.scalingMode = SceneScalingMode.scrolling,
  }) : foregroundPaths = [?foregroundPath, ...?foregroundPaths];

  final SpriteComponent background = SpriteComponent()
    ..anchor = Anchor.topLeft
    ..priority = 0;

  final List<SpriteComponent> foregrounds = <SpriteComponent>[];

  SpriteComponent? get foreground =>
      foregrounds.isNotEmpty ? foregrounds.first : null;

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
    final viewportSize = game.size;

    if (scalingMode == SceneScalingMode.stretch) {
      _layoutStretch(viewportSize.x, viewportSize.y);
    } else {
      _layoutScrolling(viewportSize.x, viewportSize.y);
    }
  }

  void _layoutStretch(double viewportW, double viewportH) {
    if (background.sprite?.srcSize == null) return;

    final src = background.sprite!.srcSize;
    final scaleX = viewportW / src.x;
    final scaleY = viewportH / src.y;
    final scale = math.max(scaleX, scaleY);

    final size = Vector2(src.x * scale, src.y * scale);

    background
      ..size = size
      ..position = Vector2((viewportW - size.x) / 2, (viewportH - size.y) / 2);

    for (final foreground in foregrounds) {
      if (foreground.sprite?.srcSize == null) continue;
      foreground
        ..size = size
        ..position = background.position;
    }

    game.worldRoot.size = Vector2(viewportW, viewportH);
  }

  void _layoutScrolling(double viewportW, double viewportH) {
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

    for (final foreground in foregrounds) {
      if (foreground.sprite?.srcSize != null &&
          foreground.sprite!.srcSize.x > 0 &&
          foreground.sprite!.srcSize.y > 0) {
        final src = foreground.sprite!.srcSize;
        final scale = viewportH / src.y;
        final contentW = src.x * scale;
        foreground
          ..size = Vector2(contentW, viewportH)
          ..position = Vector2.zero();
      } else {
        final w = worldWidthForViewport(game.size);
        foreground
          ..size = Vector2(w, viewportH)
          ..position = Vector2.zero();
      }
    }
  }

  @override
  Future<void> onLoad() async {
    background.sprite = await game.loadSprite(backgroundPath);
    background.paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high;
    if (!children.contains(background)) {
      add(background);
    }

    for (var i = 0; i < foregroundPaths.length; i++) {
      final foreground = SpriteComponent()
        ..anchor = Anchor.topLeft
        ..priority = 10 + i;

      foreground.sprite = await game.loadSprite(foregroundPaths[i]);

      foreground.paint = Paint()
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.high;

      foregrounds.add(foreground);
      add(foreground);
    }

    layoutToWorld();
  }

  @mustCallSuper
  void redrawScene() {
    layoutToWorld();
  }

  @override
  void onRemove() {
    for (final foreground in foregrounds) {
      foreground.removeFromParent();
    }
    foregrounds.clear();
    super.onRemove();
  }

  void onPlayerInteract(PositionComponent other) {}

  void onTapDown(TapDownEvent event) {}
}
