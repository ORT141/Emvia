import 'dart:math' as math;
import 'package:flame/components.dart';
import '../emvia_game.dart';
import '../components/player.dart';

class CameraManager {
  final EmviaGame game;

  final Vector2 _cameraPos = Vector2.zero();
  double zoom = 1.1;
  static const double _defaultZoom = 1.1;
  static const double _followSharpness = 5.0;
  static const double _deadZonePx = 10.0;
  double _time = 0.0;
  bool liveEnabled = true;
  final double _bobAmplitude = 2.0;
  final double _bobFrequency = 1.4;
  final double _breathAmplitude = 0.008;
  final double _breathFrequency = 0.2;
  double _bobAmount = 0.0;

  CameraManager(this.game);

  void resetZoom() {
    zoom = _defaultZoom;
  }

  void update(double dt) {
    if (game.freezeForPathChoice && game.overlays.isActive('PathChoice')) {
      final sceneCenter = Vector2(
        game.worldRoot.size.x / 2,
        game.worldRoot.size.y / 2,
      );
      _cameraPos.setFrom(sceneCenter);
      final effectiveZoom = zoom;
      _applyToWorld(effectiveZoom, 0.0);
      return;
    }

    final target = Vector2(game.olya.position.x, game.olya.position.y);
    final isWalking = game.olya.current == PlayerState.walking;

    if (isWalking) {
      final deadZoneWorld = _deadZonePx / zoom;

      final distX = (target.x - _cameraPos.x).abs();
      final distY = (target.y - _cameraPos.y).abs();

      final resolvedTargetX = (distX > deadZoneWorld) ? target.x : _cameraPos.x;
      final resolvedTargetY = (distY > deadZoneWorld) ? target.y : _cameraPos.y;

      final rawTarget = Vector2(resolvedTargetX, resolvedTargetY);
      final clampedTarget = _clampTargetToWorldBounds(rawTarget);

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
    if (game.freezeForPathChoice && !force) return;

    final rawTarget = Vector2(game.olya.position.x, game.olya.position.y);
    final clamped = _clampTargetToWorldBounds(rawTarget);
    _cameraPos.setFrom(clamped);
    _applyToWorld(zoom, 0.0);
  }

  void _applyToWorld(double effectiveZoom, double bobWorld) {
    game.worldRoot.scale = Vector2.all(effectiveZoom);

    final screenCenter = Vector2(game.size.x / 2, game.size.y / 2);

    final cameraWithBob = _clampTargetToWorldBounds(
      _cameraPos + Vector2(0, bobWorld),
      effectiveZoom,
    );
    final worldPos = screenCenter - (cameraWithBob * effectiveZoom);
    game.worldRoot.position = Vector2(
      worldPos.x.roundToDouble(),
      worldPos.y.roundToDouble(),
    );
  }

  Vector2 _clampTargetToWorldBounds(Vector2 target, [double? zoomOverride]) {
    final usedZoom = zoomOverride ?? zoom;
    final worldWidth = game.worldRoot.size.x;
    final worldHeight = game.worldRoot.size.y;

    final scaledWorldWidth = worldWidth * usedZoom;
    final scaledWorldHeight = worldHeight * usedZoom;

    double minX, maxX, minY, maxY;

    if (scaledWorldWidth <= game.size.x) {
      minX = maxX = worldWidth / 2;
    } else {
      final halfVisibleWidth = (game.size.x / 2) / usedZoom;
      minX = halfVisibleWidth;
      maxX = worldWidth - halfVisibleWidth;
    }

    if (scaledWorldHeight <= game.size.y) {
      minY = maxY = worldHeight / 2;
    } else {
      final halfVisibleHeight = (game.size.y / 2) / usedZoom;
      minY = halfVisibleHeight;
      maxY = worldHeight - halfVisibleHeight;
    }

    return Vector2(target.x.clamp(minX, maxX), target.y.clamp(minY, maxY));
  }
}
