import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import '../utils/pos_util.dart';
import 'game_scene.dart';

class OutsideScene extends GameScene {
  OutsideScene()
    : super(
        backgroundPath: 'scenes/outside/background.png',
        showControls: true,
        frozenPlayer: false,
      );

  SpriteComponent? _peopleBackgroundOverlay;
  SpriteComponent? _peopleForegroundOverlay;

  bool _stressTriggered = false;

  static const _stressTriggerUVx = 0.7;

  @override
  double worldWidthForViewport(Vector2 viewportSize) {
    if (background.sprite?.srcSize != null &&
        background.sprite!.srcSize.y > 0) {
      final aspect =
          background.sprite!.srcSize.x / background.sprite!.srcSize.y;
      return viewportSize.y * aspect;
    }
    return viewportSize.x * 2;
  }

  @override
  Vector2 spawnPoint(Vector2 viewportSize, Vector2 worldSize) =>
      Vector2(180, viewportSize.y * 0.75);

  @override
  @protected
  void layoutToWorld() {
    super.layoutToWorld();

    for (final overlay in [
      _peopleBackgroundOverlay,
      _peopleForegroundOverlay,
    ]) {
      final src = overlay?.sprite?.srcSize;
      if (overlay == null || src == null || src.y <= 0) continue;
      final viewportH = game.size.y;
      final scale = viewportH / src.y;
      overlay
        ..size = Vector2(src.x * scale, viewportH)
        ..position = Vector2.zero();
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      _peopleBackgroundOverlay = SpriteComponent()
        ..anchor = Anchor.topLeft
        ..priority = 10;
      _peopleBackgroundOverlay!.sprite = await game.loadSprite(
        'scenes/outside/people_background.png',
      );
      add(_peopleBackgroundOverlay!);
    } catch (_) {
      _peopleBackgroundOverlay = null;
    }

    try {
      _peopleForegroundOverlay = SpriteComponent()
        ..anchor = Anchor.topLeft
        ..priority = 50;
      _peopleForegroundOverlay!.sprite = await game.loadSprite(
        'scenes/outside/people_foreground.png',
      );
      game.worldRoot.add(_peopleForegroundOverlay!);
    } catch (_) {
      _peopleForegroundOverlay = null;
    }

    layoutToWorld();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_stressTriggered) return;
    if (game.transitionManager.isTransitioning) return;

    final playerX = game.player.position.x;
    final triggerX = getWorldPosFromUV(
      Vector2(_stressTriggerUVx, 0),
      background.position,
      background.size,
    ).x;

    if (playerX >= triggerX) {
      _stressTriggered = true;
      game.showBreathingExercise();
    }

    if (game.stressLevel >= 30 && !game.overlays.isActive('Stress')) {
      game.overlays.add('Stress');
    }
  }

  @override
  @mustCallSuper
  void redrawScene() {
    _stressTriggered = false;
    _peopleBackgroundOverlay?.removeFromParent();
    _peopleBackgroundOverlay = null;
    _peopleForegroundOverlay?.removeFromParent();
    _peopleForegroundOverlay = null;

    layoutToWorld();
    super.redrawScene();
  }

  @override
  void onRemove() {
    if (_peopleForegroundOverlay != null) {
      game.worldRoot.remove(_peopleForegroundOverlay!);
    }

    _peopleBackgroundOverlay?.removeFromParent();
    _peopleBackgroundOverlay = null;
    _peopleForegroundOverlay?.removeFromParent();
    _peopleForegroundOverlay = null;

    super.onRemove();
  }
}
