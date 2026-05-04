import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:emvia/game/emvia_game.dart';
import '../base_player.dart';
import '../character_data.dart';

class LiamPlayer extends BasePlayer {
  static const CharacterData liamData = CharacterData(
    name: 'Liam',
    assetPath: 'player/liam',
    walkingFrames: 1,
    widthFactor: 1.0,
    resetScaleOnIdle: false,
  );

  LiamPlayer() : super(characterData: liamData);

  late final SpriteAnimation _standingAnimation;
  late final SpriteAnimation _walkingAnimation;

  @override
  Future<void> onLoad() async {
    updatePlayerSize();

    _standingAnimation = await loadSingleFrameAnimation('standing.png');
    _walkingAnimation = await loadWalkingAnimationAuto(
      prefix: 'walking',
      maxFrames: 30,
      stepTime: 0.08,
    );

    animations = {
      PlayerState.standing: _standingAnimation,
      PlayerState.walking: _walkingAnimation,
    };

    current = PlayerState.standing;
  }

  @override
  Future<void> onStartGame() async {
    await game.navigationManager.goToLiamHouse();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (hasReachedLeftSceneEdge()) {
      game.currentScene?.onPlayerReachedLeftEdge();
    }

    if (hasReachedRightSceneEdge()) {
      game.currentScene?.onPlayerReachedRightEdge();
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyC) {
        game.toggleCameraMode();
        return true;
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  Future<void> interactWithItem(String itemId) async {}
}
