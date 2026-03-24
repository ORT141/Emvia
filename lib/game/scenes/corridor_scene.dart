import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/rendering.dart';
import 'package:flutter/material.dart';

import '../utils/pos_util.dart';
import 'game_scene.dart';
import 'stress/stress_scene.dart';

import 'package:emvia/l10n/app_localizations_gen.dart';
import '../dialog/dialog_model.dart';

class CorridorScene extends GameScene {
  CorridorScene()
    : super(
        backgroundPath: 'scenes/corridor/wall.png',
        foregroundPath: 'scenes/corridor/background.png',
        showControls: true,
        frozenPlayer: false,
      );

  bool _lockerPromptShown = false;

  SpriteComponent? _peopleBackgroundOverlay;
  SpriteComponent? _peopleForegroundOverlay;

  final List<SpriteComponent> _patternSprites = [];

  List<Vector2> get patternPositions =>
      _patternSprites.map((sp) => sp.position.clone()).toList();

  Vector2 get backpackWorldMin =>
      getWorldPosFromUV(_backpackMinUV, background.position, background.size);
  Vector2 get backpackWorldMax =>
      getWorldPosFromUV(_backpackMaxUV, background.position, background.size);
  double get patternWorldStartX =>
      getWorldPosFromUV(Vector2(_patternStartUVx, 0), background.position, background.size).x;
  double get patternWorldEndX =>
      getWorldPosFromUV(Vector2(_patternEndUVx, 0), background.position, background.size).x;

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

  static const _stressTriggerUVx = 0.1591;
  static const _lockerPromptUVx = 0.2688;
  static final _backpackMinUV = Vector2(0.2743, 0.6113);
  static final _backpackMaxUV = Vector2(0.2919, 0.7063);
  static const _patternStartUVx = 0.4545;
  static const _patternEndUVx = 0.8648;
  static const _patternStartUVy = 0.0909;
  static const _patternEndUVy = 0.5261;

  @override
  void onTapDown(TapDownEvent event) {
    if (game.overlays.isActive('TapGame')) {
      return;
    }

    final screenPos = event.localPosition;
    final worldOffset = game.worldRoot.position;
    final zoom = game.worldRoot.scale.x;
    final worldPos = (screenPos - worldOffset) / zoom;

    final minPos = getWorldPosFromUV(_backpackMinUV, background.position, background.size);
    final maxPos = getWorldPosFromUV(_backpackMaxUV, background.position, background.size);

    if (worldPos.x >= minPos.x &&
        worldPos.x <= maxPos.x &&
        worldPos.y >= minPos.y &&
        worldPos.y <= maxPos.y) {
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

  @override
  void update(double dt) {
    super.update(dt);

    final playerX = game.olya.position.x;
    final stressTriggerX = getWorldPosFromUV(Vector2(_stressTriggerUVx, 0), background.position, background.size).x;

    if (!_stressSceneTriggered &&
        !game.transitionManager.isTransitioning &&
        !game.hasTriggeredStressScene &&
        playerX >= stressTriggerX) {
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

    final lockerX = getWorldPosFromUV(Vector2(_lockerPromptUVx, 0), background.position, background.size).x;
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
      final minY = getWorldPosFromUV(Vector2(0, _patternStartUVy), background.position, background.size).y;
      final maxY = getWorldPosFromUV(Vector2(0, _patternEndUVy), background.position, background.size).y;

      final startX = getWorldPosFromUV(Vector2(_patternStartUVx, 0), background.position, background.size).x;
      final endX = getWorldPosFromUV(Vector2(_patternEndUVx, 0), background.position, background.size).x;
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
