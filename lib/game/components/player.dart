import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import '../emvia_game.dart';
import '../scenes/classroom_scene.dart';

enum PlayerState { standing, walking }

class OlyaPlayer extends SpriteAnimationGroupComponent<PlayerState>
    with HasGameReference<EmviaGame>, KeyboardHandler, TapCallbacks {
  OlyaPlayer() : super(size: Vector2(130, 280), anchor: Anchor.center);

  late final SpriteAnimation _standingAnimation;
  late final SpriteAnimation _walkingAnimation;
  late final SpriteAnimation _standingHeadphonesAnimation;
  late final SpriteAnimation _walkingHeadphonesAnimation;

  final Vector2 _velocity = Vector2.zero();
  final Vector2 _keyboardVelocity = Vector2.zero();
  final Vector2 _mobileVelocity = Vector2.zero();
  final double _speed = 220.0;

  @override
  Future<void> onLoad() async {
    _standingAnimation = SpriteAnimation.spriteList([
      await game.loadSprite('player/standing.png'),
    ], stepTime: 1);

    _walkingAnimation = SpriteAnimation.spriteList([
      for (int i = 1; i <= 26; i++)
        await game.loadSprite('player/walking_$i.png'),
    ], stepTime: 0.1);

    try {
      _standingHeadphonesAnimation = SpriteAnimation.spriteList([
        await game.loadSprite('player/standing_headphones.png'),
      ], stepTime: 1);
      _walkingHeadphonesAnimation = SpriteAnimation.spriteList([
        for (int i = 1; i <= 26; i++)
          await game.loadSprite('player/walking_headphones_$i.png'),
      ], stepTime: 0.1);
    } catch (_) {
      _standingHeadphonesAnimation = _standingAnimation;
      _walkingHeadphonesAnimation = _walkingAnimation;
    }

    _updateAnimations();
    current = PlayerState.standing;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (game.currentScene is ClassroomScene) {
      return;
    }
  }

  @override
  void update(double dt) {
    _updateAnimations();
    super.update(dt);
    if (game.freezeForPathChoice) {
      _velocity.setZero();
      _keyboardVelocity.setZero();
      _mobileVelocity.setZero();
    }

    _velocity
      ..x = _keyboardVelocity.x + _mobileVelocity.x
      ..y = _keyboardVelocity.y + _mobileVelocity.y;
    if (!_velocity.isZero()) {
      _velocity.normalize();
    }

    position += _velocity * _speed * dt;

    if (_velocity.isZero()) {
      current = PlayerState.standing;
    } else {
      current = PlayerState.walking;
      if (_velocity.x < 0) {
        scale.x = -1;
      } else if (_velocity.x > 0) {
        scale.x = 1;
      }
    }

    position.x = position.x.clamp(
      size.x / 2,
      game.worldRoot.size.x - size.x / 2,
    );
    position.y = game.worldRoot.size.y * 0.75;
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.tab) {
        game.toggleBackpack();

        return true;
      }
      if (event.logicalKey == LogicalKeyboardKey.f3) {
        game.toggleDebug();
        return true;
      }
    }

    if (game.freezeForPathChoice) {
      _keyboardVelocity.setZero();
      return false;
    }

    _keyboardVelocity
      ..x = 0
      ..y = 0;

    if (keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      _keyboardVelocity.x -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      _keyboardVelocity.x += 1;
    }

    if (!_keyboardVelocity.isZero()) {
      _keyboardVelocity.normalize();
    }

    return super.onKeyEvent(event, keysPressed);
  }

  void setMobileDirection(double xDirection) {
    _mobileVelocity
      ..x = xDirection.clamp(-1.0, 1.0)
      ..y = 0;
  }

  void _updateAnimations() {
    final hasHeadphones = game.selectedTools.contains('headphones');
    animations = {
      PlayerState.standing: hasHeadphones
          ? _standingHeadphonesAnimation
          : _standingAnimation,
      PlayerState.walking: hasHeadphones
          ? _walkingHeadphonesAnimation
          : _walkingAnimation,
    };
    final cur = current;
    if (cur != null) {
      current = cur;
    }
  }
}
