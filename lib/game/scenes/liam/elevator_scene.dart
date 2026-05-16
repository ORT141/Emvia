import 'package:emvia/game/characters/liam/liam_journey.dart';
import 'package:emvia/game/managers/game_state/game_state.dart';
import 'package:emvia/game/scenes/game_scene.dart';
import 'package:emvia/game/utils/pos_util.dart';
import 'package:flame/components.dart';
import 'dart:ui' show Offset, Rect;

class ElevatorScene extends GameScene {
  static final Vector2 _buttonUv = Vector2(0.205, 0.40);

  RectangleComponent? _buttonHighlight;
  bool _cameraTriggered = false;
  bool _openCameraWhenReady = false;

  ElevatorScene()
    : super(
        backgroundPath: 'scenes/liam/elevator/background.png',
        showControls: true,
        showPlayer: true,
      ) {
    GameScene.register(() => ElevatorScene());
  }

  @override
  int get sceneIndex => 10;

  @override
  Future<void> onMount() async {
    super.onMount();
    LiamJourney.maybeShowCurrentNarrative(game);
  }

  @override
  void onRemove() {
    _buttonHighlight?.removeFromParent();
    _buttonHighlight = null;
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);

    final bounds = _buttonBounds();
    if (bounds == null || game.transitionManager.isTransitioning) return;

    final player = game.player;
    final triggerBounds = bounds.inflate(player.size.x * 0.45);
    final playerCenter = Offset(player.position.x, player.position.y);
    final inTriggerZone = triggerBounds.contains(playerCenter);

    final state = game.liamState;
    final dialogActive = game.overlays.isActive('Dialog') ||
        game.overlays.isActive('EducationalCard');

    if (inTriggerZone) {
      if (!_cameraTriggered) {
        _cameraTriggered = true;
      }

      if (state == null) return;

      final isAlmostThereMission = state.currentMissionIndex == 4;
      final briefingNotShown = !state.shownBriefings.contains(
        state.currentMissionIndex,
      );

      if (isAlmostThereMission && briefingNotShown) {
        _openCameraWhenReady = true;
        if (!dialogActive) {
          LiamJourney.maybeShowCurrentNarrative(game);
        }
        return;
      }

      if (_openCameraWhenReady && !dialogActive && !state.isCameraMode) {
        _enterCameraMode(state);
        _openCameraWhenReady = false;
        return;
      }

      if (!state.isCameraMode) {
        _enterCameraMode(state);
      }
      return;
    }

    _cameraTriggered = false;
  }

  void _enterCameraMode(LiamGameState state) {
    state.isCameraMode = true;
    game.overlays.add('Camera');
    game.gameState.isFrozen = true;
  }


  @override
  Vector2 spawnPoint(Vector2 viewportSize, Vector2 worldSize) =>
      Vector2(worldSize.x * 0.1, worldSize.y * 0.68);

  Rect? _buttonBounds() {
    if (background.size.x <= 0 || background.size.y <= 0) return null;

    final size = Vector2(background.size.x * 0.025, background.size.y * 0.12);
    final topLeft = getWorldPosFromUV(
      _buttonUv,
      background.position,
      background.size,
    );
    return Rect.fromLTWH(topLeft.x, topLeft.y, size.x, size.y);
  }

}
