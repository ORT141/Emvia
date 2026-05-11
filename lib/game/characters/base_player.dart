import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../utils/game_config.dart';
import '../emvia_game.dart';
import '../emvia_types.dart';
import '../utils/pos_util.dart';
import 'character_data.dart';

enum PlayerState { standing, walking }

abstract class BasePlayer extends SpriteAnimationGroupComponent<PlayerState>
    with HasGameReference<EmviaGame>, KeyboardHandler, TapCallbacks {
  final CharacterData characterData;

  BasePlayer({required this.characterData}) : super(anchor: Anchor.center);

  @override
  int priority = 15;

  Future<SpriteAnimation> loadWalkingAnimation({
    String? prefix,
    int? frames,
    double stepTime = 0.1,
  }) async {
    final frameCount = frames ?? characterData.walkingFrames;
    final pathPrefix = prefix ?? "walking";
    return SpriteAnimation.spriteList([
      for (int i = 1; i <= frameCount; i++)
        await game.loadSprite(
          "${characterData.assetPath}/${pathPrefix}_$i.png",
        ),
    ], stepTime: stepTime);
  }

  Future<SpriteAnimation> loadWalkingAnimationAuto({
    String prefix = 'walking',
    int maxFrames = 30,
    double stepTime = 0.1,
  }) async {
    final frames = <Sprite>[];
    for (int i = 1; i <= maxFrames; i++) {
      try {
        final sprite = await game.loadSprite(
          "${characterData.assetPath}/${prefix}_$i.png",
        );
        frames.add(sprite);
      } catch (_) {
        break;
      }
    }

    if (frames.isEmpty) {
      try {
        final sprite = await game.loadSprite(
          "${characterData.assetPath}/standing.png",
        );
        frames.add(sprite);
      } catch (_) {}
    }

    return SpriteAnimation.spriteList(frames, stepTime: stepTime);
  }

  Future<SpriteAnimation> loadSingleFrameAnimation(String fileName) async {
    return SpriteAnimation.spriteList([
      await game.loadSprite("${characterData.assetPath}/$fileName"),
    ], stepTime: 1);
  }

  bool isInteracting = false;

  Future<void> onStartGame();

  Future<void> interactWithItem(String itemId);

  void endInteraction() {
    isInteracting = false;
  }

  bool hasReachedRightSceneEdge() {
    final scene = game.currentScene;
    if (scene != null && scene.background.size.x > 0) {
      final uvTarget = getWorldPosFromUV(
        Vector2(0.9, 0.5),
        scene.background.position,
        scene.background.size,
      );
      final thresholdX = uvTarget.x - size.x / 2;
      return position.x >= thresholdX;
    }

    return false;
  }

  bool hasReachedLeftSceneEdge() {
    final scene = game.currentScene;
    if (scene != null && scene.background.size.x > 0) {
      final uvTarget = getWorldPosFromUV(
        Vector2(0.1, 0.5),
        scene.background.position,
        scene.background.size,
      );
      final thresholdX = uvTarget.x + size.x / 2;
      return position.x <= thresholdX;
    }

    return false;
  }

  final Vector2 velocity = Vector2.zero();
  final Vector2 keyboardVelocity = Vector2.zero();
  final Vector2 mobileVelocity = Vector2.zero();

  AudioPlayer? _footstepPlayer;
  bool _wasWalking = false;

  double get speed => game.size.y * (300.0 / 1080.0);

  void updatePlayerSize() {
    if (game.worldRoot.size.y <= 0) return;
    final height = game.worldRoot.size.y * GameConfig.playerHeightFactor;
    size = Vector2(height * characterData.widthFactor, height);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      updatePlayerSize();
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    return false;
  }

  @override
  void update(double dt) {
    super.update(dt);
    updatePlayerSize();

    if (game.gameState.isFrozen) {
      velocity.setZero();
      keyboardVelocity.setZero();
      mobileVelocity.setZero();
    }

    velocity
      ..x = keyboardVelocity.x + mobileVelocity.x
      ..y = keyboardVelocity.y + mobileVelocity.y;
    if (!velocity.isZero()) {
      velocity.normalize();
    }

    position += velocity * speed * dt;

    if (velocity.isZero()) {
      current = PlayerState.standing;
      if (_wasWalking) {
        _wasWalking = false;
        _footstepPlayer?.stop();
        _footstepPlayer?.dispose();
        _footstepPlayer = null;
      }
      if (characterData.resetScaleOnIdle) {
        scale.x = 1;
      }
    } else {
      current = PlayerState.walking;
      if (!_wasWalking) {
        _wasWalking = true;
        _startFootsteps();
      }
      if (velocity.x < 0) {
        scale.x = -1;
      } else if (velocity.x > 0) {
        scale.x = 1;
      }
    }

    position.x = position.x.clamp(
      size.x / 2,
      game.worldRoot.size.x - size.x / 2,
    );

    if (!isInteracting) {
      final scene = game.currentScene;
      final baseY = scene != null
          ? game.sceneSpawnPoint(scene, game.size, game.worldRoot).y
          : game.worldRoot.size.y * GameConfig.playerSpawnYFactor;
      final yOffset = scene?.playerYOffsetForX(position.x) ?? 0;
      position.y = baseY - yOffset;
    }
  }

  void onRemove() {
    _footstepPlayer?.stop();
    _footstepPlayer?.dispose();
    _footstepPlayer = null;
    super.onRemove();
  }

  Future<void> _startFootsteps() async {
    if (!game.soundEnabled) return;
    try {
      _footstepPlayer = await FlameAudio.loop(
        'other/кроки.mp3',
        volume: game.volume * 0.45,
      );
    } catch (_) {}
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.tab) {
        if (game.selectedCharacter != PlayableCharacter.liam) {
          game.toggleBackpack();
        }
        return true;
      }
    }

    if (game.gameState.isFrozen) {
      keyboardVelocity.setZero();
      return false;
    }

    keyboardVelocity
      ..x = 0
      ..y = 0;

    if (keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      keyboardVelocity.x -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      keyboardVelocity.x += 1;
    }

    if (!keyboardVelocity.isZero()) {
      keyboardVelocity.normalize();
    }

    return super.onKeyEvent(event, keysPressed);
  }

  void setMobileDirection(double xDirection) {
    mobileVelocity
      ..x = xDirection.clamp(-1.0, 1.0)
      ..y = 0;
  }
}
