import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import '../emvia_game.dart';

enum PlayerState { standing, walking }

abstract class BasePlayer extends SpriteAnimationGroupComponent<PlayerState>
    with HasGameReference<EmviaGame>, KeyboardHandler, TapCallbacks {
  BasePlayer() : super(anchor: Anchor.center);

  @override
  int priority = 15;

  final Vector2 velocity = Vector2.zero();
  final Vector2 keyboardVelocity = Vector2.zero();
  final Vector2 mobileVelocity = Vector2.zero();
  final double speed = 230.0;
  double? interactionY;

  void updatePlayerSize() {
    final height = game.size.y * 0.42;
    size = Vector2(height * 0.5, height);
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
    if (game.isFrozen) {
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
    } else {
      current = PlayerState.walking;
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
    position.y = interactionY ?? game.worldRoot.size.y * 0.58;
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

    if (game.isFrozen) {
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

  Future<void> interactWithItem(String itemId);

  String get stressPanicSprite;

  void endInteraction() {}
}
