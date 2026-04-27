import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' show FilterQuality, Paint;
import 'dart:math' as math;
import '../emvia_game.dart';

enum SceneScalingMode { stretch, scrolling }

abstract class GameScene extends Component with HasGameReference<EmviaGame> {
  static final List<GameScene Function()> registry = [];

  static void register(GameScene Function() builder) {
    registry.add(builder);
  }

  final String backgroundPath;
  final List<String> foregroundPaths;
  final SceneScalingMode scalingMode;

  final bool showControls;
  final bool frozenPlayer;

  GameScene({
    this.backgroundPath = '',
    String? foregroundPath,
    List<String>? foregroundPaths,
    this.scalingMode = SceneScalingMode.scrolling,
    this.showControls = false,
    this.frozenPlayer = false,
    this.showPlayer = true,
  }) : foregroundPaths = [
         if (foregroundPath != null && foregroundPath.isNotEmpty)
           foregroundPath,
         ...?foregroundPaths,
       ];

  final bool showPlayer;

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
    final worldW = worldWidthForViewport(game.size);

    if (background.sprite?.srcSize != null &&
        background.sprite!.srcSize.x > 0 &&
        background.sprite!.srcSize.y > 0) {
      final src = background.sprite!.srcSize;

      final scale = viewportH / src.y;
      final contentW = src.x * scale;

      final double bgW = math.max(contentW, worldW.toDouble());
      final double bgH = bgW > contentW
          ? math.max(viewportH, bgW * src.y / src.x)
          : viewportH;

      background
        ..size = Vector2(bgW, bgH)
        ..position = Vector2.zero();

      game.worldRoot.size = Vector2(worldW, math.max(viewportH, bgH));
    } else {
      background
        ..size = Vector2(worldW, viewportH)
        ..position = Vector2.zero();
      game.worldRoot.size = Vector2(worldW, viewportH);
    }

    for (final foreground in foregrounds) {
      if (foreground.sprite?.srcSize != null &&
          foreground.sprite!.srcSize.x > 0 &&
          foreground.sprite!.srcSize.y > 0) {
        final src = foreground.sprite!.srcSize;
        final scale = viewportH / src.y;
        final contentW = src.x * scale;
        final double fgW = math.max(contentW, worldW.toDouble());
        final double fgH = fgW > contentW
            ? math.max(viewportH, fgW * src.y / src.x)
            : viewportH;
        foreground
          ..size = Vector2(fgW, fgH)
          ..position = Vector2.zero();
      } else {
        foreground
          ..size = Vector2(worldW, viewportH)
          ..position = Vector2.zero();
      }
    }
  }

  @override
  Future<void> onLoad() async {
    if (backgroundPath.isNotEmpty) {
      background.sprite = await game.loadSprite(backgroundPath);
    }

    background.paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high;
    if (background.sprite != null && !children.contains(background)) {
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

    if (showControls) {
      game.showMobileControls();
    } else {
      game.hideMobileControls();
    }

    game.gameState.isFrozen = frozenPlayer;
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
