import 'dart:math' as math;
import 'package:flame/components.dart';
import '../utils/pos_util.dart';
import '../emvia_game.dart';
import '../characters/base_player.dart';

class CameraManager {
  final EmviaGame game;

  final Vector2 _cameraPos = Vector2.zero();
  double zoom = 1.1;
  static const double _defaultZoom = 1.1;
  static const double _followSharpness = 5.0;
  static const double _deadZonePx = 10.0;
  double _time = 0.0;
  bool liveEnabled = true;
  final double _bobAmplitude = 1.0;
  final double _bobFrequency = 0.7;
  final double _breathAmplitude = 0.004;
  final double _breathFrequency = 0.1;
  double _bobAmount = 0.0;

  CameraManager(this.game);

  void resetZoom() {
    zoom = _defaultZoom;
  }

  void update(double dt) {
    if (!game.isPlayerInitialized) return;
    if (game.isFrozen && game.overlays.isActive('PathChoice')) {
      final sceneCenter = Vector2(
        game.worldRoot.size.x / 2,
        game.worldRoot.size.y / 2,
      );
      _cameraPos.setFrom(sceneCenter);
      final effectiveZoom = zoom;
      _applyToWorld(effectiveZoom, 0.0);
      return;
    }

    final target = Vector2(game.player.position.x, game.player.position.y);
    final isWalking = game.player.current == PlayerState.walking;

    if (isWalking) {
      final deadZoneWorld = _deadZonePx / zoom;

      final distX = (target.x - _cameraPos.x).abs();
      final distY = (target.y - _cameraPos.y).abs();

      final resolvedTargetX = (distX > deadZoneWorld) ? target.x : _cameraPos.x;
      final resolvedTargetY = (distY > deadZoneWorld) ? target.y : _cameraPos.y;

      final rawTarget = Vector2(resolvedTargetX, resolvedTargetY);
      final clampedTarget = clampTargetToWorldBounds(
        rawTarget,
        zoom,
        game.size,
        game.worldRoot,
      );

      final alpha = 1 - math.exp(-_followSharpness * dt);
      _cameraPos.x += (clampedTarget.x - _cameraPos.x) * alpha;
      _cameraPos.y += (clampedTarget.y - _cameraPos.y) * alpha;
    }

    _time += dt;

    final targetAmount = isWalking ? 1.0 : 0.0;
    _bobAmount += (targetAmount - _bobAmount) * (1 - math.exp(-3.0 * dt));

    final breath = (liveEnabled)
        ? math.sin(_time * (2 * math.pi) * _breathFrequency) *
              _breathAmplitude *
              _bobAmount
        : 0.0;
    final effectiveZoom = zoom * (1.0 + breath);

    final bobPixels = (liveEnabled)
        ? math.sin(_time * (2 * math.pi) * _bobFrequency) *
              _bobAmplitude *
              _bobAmount
        : 0.0;
    final bobWorld = bobPixels / effectiveZoom;

    _applyToWorld(effectiveZoom, bobWorld);
  }

  void snapToPlayer({bool force = false}) {
    if (!game.isPlayerInitialized) return;
    if (game.isFrozen && !force) return;

    final rawTarget = Vector2(game.player.position.x, game.player.position.y);
    final clamped = clampTargetToWorldBounds(
      rawTarget,
      zoom,
      game.size,
      game.worldRoot,
    );
    _cameraPos.setFrom(clamped);
    _applyToWorld(zoom, 0.0);
  }

  void _applyToWorld(double effectiveZoom, double bobWorld) {
    game.worldRoot.scale = Vector2.all(effectiveZoom);

    final screenCenter = Vector2(game.size.x / 2, game.size.y / 2);

    final cameraWithBob = clampTargetToWorldBounds(
      _cameraPos + Vector2(0, bobWorld),
      effectiveZoom,
      game.size,
      game.worldRoot,
    );

    final worldPos = screenCenter - (cameraWithBob * effectiveZoom);

    game.worldRoot.position = worldPos;
  }
}
