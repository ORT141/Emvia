import 'dart:math' as math;
import 'dart:ui' show Paint;

import 'package:flame/components.dart';

import 'game_scene.dart';

class StressScene extends GameScene {
  StressScene()
    : super(
        backgroundPath: 'stress/stress-scene/panic_background.png',
        foregroundPath: 'stress/stress-scene/panic_foreground.png',
        scalingMode: SceneScalingMode.stretch,
      );

  RectangleComponent? _ambientOverlay;
  SpriteComponent? _olyaComponent;
  SpriteComponent? _silhouettesComponent;

  @override
  double worldWidthForViewport(Vector2 viewportSize) => viewportSize.x;

  @override
  Vector2 spawnPoint(Vector2 viewportSize, Vector2 worldSize) =>
      Vector2(viewportSize.x / 2, viewportSize.y / 2);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    game.isFrozen = true;

    _ambientOverlay = RectangleComponent(
      anchor: Anchor.topLeft,
      priority: 1,
      paint: Paint()..color = game.surveyProfile.safeColorValue.withAlpha(32),
    );
    add(_ambientOverlay!);

    foreground?.priority = 2;

    _silhouettesComponent = SpriteComponent()
      ..sprite = await game.loadSprite(
        'stress/stress-scene/panic_silhouettes.png',
      )
      ..anchor = Anchor.topLeft
      ..priority = 5;
    add(_silhouettesComponent!);

    _olyaComponent = SpriteComponent()
      ..sprite = await game.loadSprite('stress/stress-scene/panic_olya.png')
      ..anchor = Anchor.topLeft
      ..priority = 10;
    add(_olyaComponent!);

    game.stressLevel = 100;

    game.overlays.add('TapGame');

    game.overlays.add('Stress');

    layoutToWorld();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (game.stressLevel <= 60 && !game.overlays.isActive('TapGame')) {
      _startTransitionToCorridor();
    }
  }

  bool _transitioning = false;

  void _startTransitionToCorridor() {
    if (_transitioning) return;
    _transitioning = true;
    game.transitionToCorridor();
  }

  @override
  void layoutToWorld() {
    super.layoutToWorld();

    final viewportW = game.size.x;
    final viewportH = game.size.y;

    _ambientOverlay
      ?..size = Vector2(viewportW, viewportH)
      ..position = Vector2.zero();

    if (background.sprite?.srcSize != null) {
      final src = background.sprite!.srcSize;
      final scale = math.max(viewportW / src.x, viewportH / src.y);
      final size = Vector2(src.x * scale, src.y * scale);

      for (final comp in [_silhouettesComponent, _olyaComponent]) {
        comp
          ?..size = size
          ..position = Vector2(
            (viewportW - size.x) / 2,
            (viewportH - size.y) / 2,
          );
      }
    }
  }
}
