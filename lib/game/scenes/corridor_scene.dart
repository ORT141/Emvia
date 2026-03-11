import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/rendering.dart';
import 'package:flutter/material.dart';

import 'game_scene.dart';

class CorridorScene extends GameScene {
  CorridorScene()
    : super(
        backgroundPath: 'scenes/corridor/wall.png',
        foregroundPath: 'scenes/corridor/background.png',
      );

  final List<SpriteComponent> _patternSprites = [];

  @override
  double worldWidthForViewport(Vector2 viewportSize) {
    if (background.sprite?.srcSize != null &&
        background.sprite!.srcSize.y > 0) {
      final src = background.sprite!.srcSize;
      final scale = viewportSize.y / src.y;
      return src.x * scale;
    }
    return viewportSize.x * 2;
  }

  @override
  Vector2 spawnPoint(Vector2 viewportSize, Vector2 worldSize) =>
      Vector2(180, viewportSize.y * 0.78);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    game.overlays.add('Stress');

    final color = game.surveyProfile.safeColorValue;
    background.decorator.addLast(PaintDecorator.tint(color));

    await _loadWallPattern();
  }

  @override
  void update(double dt) {
    super.update(dt);

    final playerX = game.olya.position.x;
    final worldW = worldWidthForViewport(game.size);
    final centerX = worldW / 2;

    final distanceToCenter = (playerX - centerX).abs();

    final proximity = 1.0 - (distanceToCenter / centerX).clamp(0.0, 1.0);

    game.stressLevel = (math.pow(proximity, 2) * 100).toInt();
  }

  @override
  void onRemove() {
    game.overlays.remove('Stress');
    game.stressLevel = 0;
    super.onRemove();
  }

  Future<void> _loadWallPattern() async {
    final pattern = game.surveyProfile.aiPattern;
    if (pattern.isEmpty) return;

    const noRotatePatterns = {'cloud', 'tree', 'moon'};

    try {
      final sprite = await game.loadSprite('wall-patterns/$pattern.png');
      final worldH = game.size.y;
      final patternSize = worldH * 0.11;
      final spacing = patternSize * 1.1;
      final minY = worldH * 0.13;
      final maxY = worldH * 0.5;

      final startX = 2100.0;
      final endX = 3500.0;
      final areaWidth = endX - startX;
      final count = (areaWidth / spacing).floor();

      final random = math.Random();
      for (int i = 0; i < count; i++) {
        final y = minY + random.nextDouble() * (maxY - minY);
        final angle = noRotatePatterns.contains(pattern)
            ? 0.0
            : random.nextDouble() * math.pi * 2;
        final sp = SpriteComponent()
          ..sprite = sprite
          ..size = Vector2.all(patternSize)
          ..position = Vector2(startX + i * spacing + patternSize * 0.6, y)
          ..anchor = Anchor.center
          ..angle = angle
          ..opacity = 0.50
          ..priority = 1;
        sp.paint = Paint()
          ..isAntiAlias = true
          ..filterQuality = FilterQuality.high;
        _patternSprites.add(sp);
        add(sp);
      }
    } catch (_) {}
  }

  @override
  @mustCallSuper
  void redrawScene() {
    try {
      for (final sp in List<SpriteComponent>.from(_patternSprites)) {
        sp.removeFromParent();
      }
    } catch (_) {}
    _patternSprites.clear();

    final color = game.surveyProfile.safeColorValue;
    try {
      background.decorator.removeLast();
    } catch (_) {}
    try {
      background.decorator.addLast(PaintDecorator.tint(color));
    } catch (_) {}

    _loadWallPattern();
    layoutToWorld();
    super.redrawScene();
  }
}
