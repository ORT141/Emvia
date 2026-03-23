import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/rendering.dart';
import 'package:flutter/material.dart';

import 'game_scene.dart';
import 'stress_scene.dart';

import 'package:emvia/l10n/app_localizations_gen.dart';
import '../dialog_model.dart';

class CorridorScene extends GameScene {
  CorridorScene()
    : super(
        backgroundPath: 'scenes/corridor/wall.png',
        foregroundPath: 'scenes/corridor/background.png',
      );

  bool _lockerPromptShown = false;

  SpriteComponent? _peopleBackgroundOverlay;
  SpriteComponent? _peopleForegroundOverlay;

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
  @protected
  void layoutToWorld() {
    super.layoutToWorld();

    for (final overlay in [
      _peopleBackgroundOverlay,
      _peopleForegroundOverlay,
    ]) {
      final src = overlay?.sprite?.srcSize;
      if (overlay == null || src == null || src.y <= 0) continue;
      final viewportH = game.size.y;
      final scale = viewportH / src.y;
      overlay
        ..size = Vector2(src.x * scale, viewportH)
        ..position = Vector2.zero();
    }
  }

  @override
  Vector2 spawnPoint(Vector2 viewportSize, Vector2 worldSize) =>
      Vector2(180, viewportSize.y * 0.78);

  @override
  void onTapDown(TapDownEvent event) {
    if (game.overlays.isActive('TapGame')) {
      return;
    }

    final screenPos = event.localPosition;
    final worldOffset = game.worldRoot.position;
    final zoom = game.worldRoot.scale.x;
    final worldPos = (screenPos - worldOffset) / zoom;

    const minX = 1210.0;
    const minY = 397.3;
    const maxX = 1369.1;
    const maxY = 494.5;

    if (worldPos.x >= minX &&
        worldPos.x <= maxX &&
        worldPos.y >= minY &&
        worldPos.y <= maxY) {
      game.toggleBackpack();
      return;
    }

    super.onTapDown(event);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      _peopleBackgroundOverlay = SpriteComponent()
        ..anchor = Anchor.topLeft
        ..priority = 10;
      _peopleBackgroundOverlay!.sprite = await game.loadSprite(
        'scenes/corridor/people_background.png',
      );
      add(_peopleBackgroundOverlay!);
    } catch (_) {
      _peopleBackgroundOverlay = null;
    }

    try {
      _peopleForegroundOverlay = SpriteComponent()
        ..anchor = Anchor.topLeft
        ..priority = 50;
      _peopleForegroundOverlay!.sprite = await game.loadSprite(
        'scenes/corridor/people_foreground.png',
      );

      game.worldRoot.add(_peopleForegroundOverlay!);
    } catch (_) {
      _peopleForegroundOverlay = null;
    }

    if (game.isCorridorStressIntroActive) {
      game.isFrozen = true;
    }

    if (game.stressLevel >= 30 && !game.overlays.isActive('Stress')) {
      game.overlays.add('Stress');
    }

    final color = game.surveyProfile.safeColorValue;
    background.decorator.addLast(PaintDecorator.tint(color));

    await _loadWallPattern();
  }

  bool _stressSceneTriggered = false;
  static const _stressTriggerX = 800.0;

  @override
  void update(double dt) {
    super.update(dt);

    final playerX = game.olya.position.x;

    if (!_stressSceneTriggered &&
        !game.transitionManager.isTransitioning &&
        !game.hasTriggeredStressScene &&
        playerX >= _stressTriggerX) {
      _stressSceneTriggered = true;
      game.hasTriggeredStressScene = true;
      game.saveCorridorReturnPosition(playerX);
      game.loadScene(
        StressScene(),
        onFullOpacity: () {
          game.sceneIndex = 3;
          game.olya.opacity = 0;
        },
      );
      return;
    }

    const lockerX = 1228.0;
    if (!_lockerPromptShown && playerX >= lockerX) {
      _lockerPromptShown = true;
      game.isFrozen = true;

      final l = AppLocalizationsGen.of(game.buildContext!)!;
      final tree = DialogTree(
        nodes: {'start': DialogNode(id: 'start', text: (_) => l.locker_prompt)},
        startNodeId: 'start',
      );
      game.startDialog(tree);
    }

    if (_lockerPromptShown && game.isBackpackOpen) {
      game.isFrozen = false;
    }
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

  @override
  void onRemove() {
    game.worldRoot.remove(_peopleForegroundOverlay!);

    _peopleBackgroundOverlay?.removeFromParent();
    _peopleBackgroundOverlay = null;
    _peopleForegroundOverlay?.removeFromParent();
    _peopleForegroundOverlay = null;

    super.onRemove();
  }
}
