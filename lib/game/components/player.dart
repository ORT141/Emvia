import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import '../emvia_game.dart';

enum PlayerState { standing, walking }

class OlyaPlayer extends SpriteAnimationGroupComponent<PlayerState>
    with HasGameReference<EmviaGame>, KeyboardHandler {
  OlyaPlayer() : super(size: Vector2(130, 260), anchor: Anchor.center);

  late final SpriteAnimation _standingAnimation;
  late final SpriteAnimation _walkingAnimation;

  final Vector2 _velocity = Vector2.zero();
  final Vector2 _keyboardVelocity = Vector2.zero();
  final Vector2 _mobileVelocity = Vector2.zero();
  final double _speed = 200.0;

  @override
  Future<void> onLoad() async {
    _standingAnimation = SpriteAnimation.spriteList([
      await game.loadSprite('player/standing.png'),
    ], stepTime: 1);

    _walkingAnimation = SpriteAnimation.spriteList([
      await game.loadSprite('player/walking1.png'),
      await game.loadSprite('player/walking2.png'),
      await game.loadSprite('player/walking3.png'),
      await game.loadSprite('player/walking4.png'),
      await game.loadSprite('player/walking5.png'),
    ], stepTime: 0.1);

    animations = {
      PlayerState.standing: _standingAnimation,
      PlayerState.walking: _walkingAnimation,
    };

    current = PlayerState.standing;
    position = game.worldRoot.size / 2;
  }

  @override
  void update(double dt) {
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
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.tab) {
      game.toggleBackpack();
      return true;
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
}
