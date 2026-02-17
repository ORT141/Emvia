import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import '../emvia_game.dart';

enum PlayerState { standing, walking }

class OlyaPlayer extends SpriteAnimationGroupComponent<PlayerState>
    with HasGameReference<EmviaGame>, KeyboardHandler {
  OlyaPlayer() : super(size: Vector2(100, 200), anchor: Anchor.center);

  late final SpriteAnimation _standingAnimation;
  late final SpriteAnimation _walkingAnimation;

  final Vector2 _velocity = Vector2.zero();
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
      EmviaGame.worldWidth - size.x / 2,
    );
    position.y = game.worldRoot.size.y / 2;
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _velocity.x = 0;
    _velocity.y = 0;

    if (keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      _velocity.x -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      _velocity.x += 1;
    }

    if (!_velocity.isZero()) {
      _velocity.normalize();
    }

    return super.onKeyEvent(event, keysPressed);
  }
}
