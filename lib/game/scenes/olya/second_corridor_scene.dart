import 'package:emvia/game/utils/color_util.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import '../../utils/pos_util.dart';
import '../game_scene.dart';
import '../people_overlay_mixin.dart';

class SecondCorridorScene extends GameScene with PeopleOverlayMixin {
  SecondCorridorScene()
    : super(
        backgroundPath: 'scenes/olya/second-corridor/background.png',
        foregroundPath: 'scenes/olya/second-corridor/foreground.png',
        showControls: true,
        frozenPlayer: false,
      ) {
    GameScene.register(() => SecondCorridorScene());
  }

  bool _stressTriggered = false;

  static const _stressTriggerUVx = 0.7;

  @override
  String get peopleBackgroundOverlayPath =>
      'scenes/olya/second-corridor/people_background.png';
  @override
  String get peopleForegroundOverlayPath =>
      'scenes/olya/second-corridor/people_foreground.png';

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
      Vector2(180, worldSize.y / 1.65);

  @override
  @protected
  void layoutToWorld() {
    super.layoutToWorld();
    layoutPeopleOverlays();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await loadPeopleOverlays();

    ColorUtil.colorWalls(background.decorator, game.surveyProfile);

    layoutToWorld();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_stressTriggered) return;
    if (game.transitionManager.isTransitioning) return;

    final playerX = game.player.position.x;
    final triggerX = Vector2(
      _stressTriggerUVx,
      0,
    ).toWorldPos(background.position, background.size).x;

    if (playerX >= triggerX) {
      _stressTriggered = true;
      game.navigationManager.showBreathingExercise();
    }

    if (game.stressLevel >= 30 && !game.overlays.isActive('Stress')) {
      game.overlays.add('Stress');
    }
  }

  @override
  @mustCallSuper
  void redrawScene() {
    _stressTriggered = false;
    removePeopleOverlays();

    try {
      background.decorator.removeLast();
    } catch (_) {}
    ColorUtil.colorWalls(background.decorator, game.surveyProfile);

    layoutToWorld();
    super.redrawScene();
  }

  @override
  void onRemove() {
    removePeopleOverlays();
    super.onRemove();
  }
}
