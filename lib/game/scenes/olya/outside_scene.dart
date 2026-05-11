import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import '../../utils/pos_util.dart';
import '../game_scene.dart';
import '../people_overlay_mixin.dart';

class OutsideScene extends GameScene with PeopleOverlayMixin {
  OutsideScene()
    : super(
        backgroundPath: 'scenes/olya/outside/background.png',
        showControls: true,
        frozenPlayer: false,
      ) {
    GameScene.register(() => OutsideScene());
  }

  bool _stressTriggered = false;

  @override
  String get ambientSoundPath => 'other/атмосферний ембіент.mp3';

  static const _stressTriggerUVx = 0.7;

  @override
  String get peopleBackgroundOverlayPath =>
      'scenes/olya/outside/people_background.png';
  @override
  String get peopleForegroundOverlayPath =>
      'scenes/olya/outside/people_foreground.png';

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
      Vector2(180, worldSize.y * 0.75);

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
    layoutToWorld();
    super.redrawScene();
  }

  @override
  void onRemove() {
    removePeopleOverlays();
    super.onRemove();
  }
}
