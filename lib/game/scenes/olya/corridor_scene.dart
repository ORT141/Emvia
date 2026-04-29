import 'dart:math' as math;
import 'package:emvia/game/emvia_game.dart';
import 'package:emvia/game/utils/color_util.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

import '../../utils/pos_util.dart';
import '../game_scene.dart';
import 'stress/stress_scene.dart';

import 'package:emvia/l10n/app_localizations_gen.dart';
import '../../dialog/dialog_model.dart';

class CorridorScene extends GameScene {
  CorridorScene()
    : super(
        backgroundPath: 'scenes/olya/corridor/background.png',
        foregroundPath: 'scenes/olya/corridor/foreground.png',
        showControls: true,
        frozenPlayer: false,
      ) {
    GameScene.register(() => CorridorScene());
  }

  bool _lockerPromptShown = false;
  bool _educationalCardShown = false;
  bool _hudShown = false;

  SpriteComponent? _peopleBackgroundOverlay;
  SpriteComponent? _peopleForegroundOverlay;

  final List<PatternSymbol> _patternSprites = [];
  int _collectedPatterns = 0;
  final ValueNotifier<int> collectedPatternsNotifier = ValueNotifier<int>(0);

  int get collectedPatterns => _collectedPatterns;
  int get totalPatterns => _patternSprites.length;

  List<Vector2> get patternPositions =>
      _patternSprites.map((sp) => sp.position.clone()).toList();

  Vector2 get backpackWorldMin =>
      _backpackMinUV.toWorldPos(background.position, background.size);
  Vector2 get backpackWorldMax =>
      _backpackMaxUV.toWorldPos(background.position, background.size);
  double get patternWorldStartX => Vector2(
    _patternStartUVx,
    0,
  ).toWorldPos(background.position, background.size).x;
  double get patternWorldEndX => Vector2(
    _patternEndUVx,
    0,
  ).toWorldPos(background.position, background.size).x;

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
      Vector2(180, worldSize.y * 0.6);

  static const _stressTriggerUVx = 0.1591;
  static const _lockerPromptUVx = 0.2688;
  static final _backpackMinUV = Vector2(0.2743, 0.6113);
  static final _backpackMaxUV = Vector2(0.2919, 0.7063);
  static const _patternStartUVx = 0.47;
  static const _patternStartUVy = 0.0909;
  static const _patternEndUVx = 0.8648;
  static const _patternEndUVy = 0.50;

  @override
  void onTapDown(TapDownEvent event) {
    if (game.overlays.isActive('TapGame')) {
      return;
    }

    final screenPos = event.localPosition;
    final worldOffset = game.worldRoot.position;
    final zoom = game.worldRoot.scale.x;
    final worldPos = (screenPos - worldOffset) / zoom;

    final minPos = _backpackMinUV.toWorldPos(
      background.position,
      background.size,
    );
    final maxPos = _backpackMaxUV.toWorldPos(
      background.position,
      background.size,
    );

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

    if (game.player.parent != game.worldRoot) {
      game.worldRoot.add(game.player);
    }

    if (game.stressLevel >= 30 &&
        !(game.olyaState?.hasShownCorridorStressIntro ?? true)) {
      game.olyaState?.hasShownCorridorStressIntro = true;
      game.olyaState?.isCorridorStressIntroActive = true;
    }

    try {
      _peopleBackgroundOverlay = SpriteComponent()
        ..anchor = Anchor.topLeft
        ..priority = 10;
      _peopleBackgroundOverlay!.sprite = await game.loadSprite(
        'scenes/olya/corridor/people_background.png',
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
        'scenes/olya/corridor/people_foreground.png',
      );

      game.worldRoot.add(_peopleForegroundOverlay!);
    } catch (_) {
      _peopleForegroundOverlay = null;
    }

    if (game.olyaState?.isCorridorStressIntroActive ?? false) {
      game.gameState.isFrozen = true;
      game.overlayManager.hideMobileControls();
    } else {
      game.overlayManager.showMobileControls();
    }

    if (game.stressLevel >= 30 && !game.overlays.isActive('Stress')) {
      game.overlays.add('Stress');
    }

    _restorePosition();

    ColorUtil.colorWalls(background.decorator, game.surveyProfile);

    await _loadWallPattern();
  }

  void _restorePosition() {
    final savedX = game.session.savedCorridorReturnX;
    game.session.savedCorridorReturnX = null;
    game.session.save();

    if (savedX == null) {
      game.player.position.x = game.player.size.x / 2 + 10;
    } else {
      final minX = game.player.size.x / 2;
      final maxX = game.worldRoot.size.x - game.player.size.x / 2;
      game.player.position.x = savedX.clamp(minX, maxX).toDouble();
    }

    game.player.position.y = game
        .sceneSpawnPoint(this, game.size, game.worldRoot)
        .y;
    game.cameraManager.snapToPlayer(force: true);
  }

  void _onPatternCollected() {
    _collectedPatterns++;
    collectedPatternsNotifier.value = _collectedPatterns;
    if (_collectedPatterns >= _patternSprites.length) {
      game.overlays.remove('PatternProgress');
      // TODO: when background for notebook scene is ready, uncomment this
      //game.isFrozen = true;
      //game.loadScene(
      //  NotebookScene(),
      //  onFullOpacity: () {
      //    game.sceneIndex = 5;
      //  },
      //);
    }
  }

  void saveCorridorReturnPosition(double x) {
    game.session.savedCorridorReturnX = x;
    game.session.save();
  }

  bool _stressSceneTriggered = false;

  @override
  void update(double dt) {
    super.update(dt);

    final playerX = game.player.position.x;
    final stressTriggerX = Vector2(
      _stressTriggerUVx,
      0,
    ).toWorldPos(background.position, background.size).x;

    if (!_stressSceneTriggered &&
        !game.transitionManager.isTransitioning &&
        !(game.olyaState?.hasTriggeredStressScene ?? true) &&
        playerX >= stressTriggerX) {
      _stressSceneTriggered = true;
      if (game.olyaState != null) {
        game.olyaState!.hasTriggeredStressScene = true;
      }
      saveCorridorReturnPosition(playerX);
      game.loadScene(
        StressScene(),
        onFullOpacity: () {
          game.sceneIndex = 3;
          game.player.opacity = 0;
        },
      );
      return;
    }

    if (!_hudShown && _patternSprites.isNotEmpty) {
      final hudTriggerX = Vector2(
        _lockerPromptUVx + 0.15,
        0,
      ).toWorldPos(background.position, background.size).x;
      if (playerX >= hudTriggerX) {
        _hudShown = true;
        game.overlays.add('PatternProgress');
      }
    }

    final lockerX = Vector2(
      _lockerPromptUVx,
      0,
    ).toWorldPos(background.position, background.size).x;
    if (!_educationalCardShown && playerX >= lockerX) {
      _educationalCardShown = true;
      final l = AppLocalizationsGen.of(game.buildContext!)!;
      game.navigationManager.showEducationalCard(
        l.educational_card_counting_objects,
      );
    }

    if (_educationalCardShown &&
        !_lockerPromptShown &&
        !game.overlays.isActive('EducationalCard')) {
      _lockerPromptShown = true;
      game.gameState.isFrozen = true;

      final l = AppLocalizationsGen.of(game.buildContext!)!;
      final tree = DialogTree(
        nodes: {'start': DialogNode(id: 'start', text: (_) => l.locker_prompt)},
        startNodeId: 'start',
      );
      game.startDialog(tree);
    }

    if (_lockerPromptShown && game.isBackpackOpen) {
      game.gameState.isFrozen = false;
    }

    final blockX = patternWorldEndX;
    if (_collectedPatterns < _patternSprites.length && playerX >= blockX) {
      game.player.position.x = blockX - 5;
      game.navigationManager.showEducationalCard(
        'You need to collect all patterns before you can leave.',
      );
    }
  }

  Future<void> _loadWallPattern() async {
    final pattern = game.surveyProfile.aiPattern;
    if (pattern.isEmpty) return;

    _collectedPatterns = 0;
    const noRotatePatterns = {'cloud', 'tree', 'moon'};

    try {
      final sprite = await game.loadSprite('wall-patterns/$pattern.png');
      final worldH = game.size.y;
      final patternSize = worldH * 0.11;
      final spacing = patternSize * 2.5;
      final minY = Vector2(
        0,
        _patternStartUVy,
      ).toWorldPos(background.position, background.size).y;
      final maxY = Vector2(
        0,
        _patternEndUVy,
      ).toWorldPos(background.position, background.size).y;

      final startX = Vector2(
        _patternStartUVx,
        0,
      ).toWorldPos(background.position, background.size).x;
      final endX = Vector2(
        _patternEndUVx,
        0,
      ).toWorldPos(background.position, background.size).x;
      final areaWidth = endX - startX;
      final count = (areaWidth / spacing).floor().clamp(8, 12);

      final random = math.Random();
      for (int i = 0; i < count; i++) {
        final y = minY + random.nextDouble() * (maxY - minY);
        final angle = noRotatePatterns.contains(pattern)
            ? 0.0
            : random.nextDouble() * math.pi * 2;
        final sp = PatternSymbol(
          sprite: sprite,
          size: Vector2.all(patternSize),
          position: Vector2(startX + i * spacing + patternSize * 0.6, y),
          angle: angle,
          onCollected: _onPatternCollected,
        );
        _patternSprites.add(sp);
        add(sp);
      }
    } catch (_) {}
  }

  @override
  @mustCallSuper
  void redrawScene() {
    try {
      for (final sp in List<PatternSymbol>.from(_patternSprites)) {
        sp.removeFromParent();
      }
    } catch (_) {}
    _patternSprites.clear();
    _collectedPatterns = 0;

    try {
      background.decorator.removeLast();
    } catch (_) {}

    ColorUtil.colorWalls(background.decorator, game.surveyProfile);

    _loadWallPattern();
    _hudShown = false;
    _educationalCardShown = false;
    game.overlays.remove('PatternProgress');
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

    game.overlays.remove('PatternProgress');
    game.overlays.remove('EducationalCard');

    super.onRemove();
  }
}

class PatternSymbol extends SpriteComponent
    with TapCallbacks, HasGameReference<EmviaGame> {
  final VoidCallback onCollected;
  bool _isCollected = false;

  PatternSymbol({
    required Sprite sprite,
    required Vector2 size,
    required Vector2 position,
    required double angle,
    required this.onCollected,
  }) : super(
         sprite: sprite,
         size: size,
         position: position,
         anchor: Anchor.center,
         angle: angle,
         priority: 1,
       ) {
    opacity = 0.50;
    paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_isCollected) return;
    _isCollected = true;

    _spawnParticles();

    final player = game.player;
    final targetPos = player.position - Vector2(0, player.size.y / 4);

    add(
      MoveToEffect(
        targetPos,
        EffectController(duration: 0.6, curve: Curves.easeInQuad),
        onComplete: () {
          onCollected();
          removeFromParent();
        },
      ),
    );
    add(
      OpacityEffect.to(
        0.0,
        EffectController(duration: 0.6, curve: Curves.easeIn),
      ),
    );
    add(
      ScaleEffect.to(
        Vector2.all(0.1),
        EffectController(duration: 0.6, curve: Curves.easeIn),
      ),
    );
  }

  void _spawnParticles() {
    final random = math.Random();
    final baseColor = game.surveyProfile.safeColorValue;
    final baseHsv = HSVColor.fromColor(baseColor);

    final player = game.player;
    final targetPos = player.position - Vector2(0, player.size.y / 4);
    final relativeTarget = targetPos - position;

    const particleDuration = 0.6;
    final particleCurve = Curves.easeInQuad;

    final ps = ParticleSystemComponent(
      position: position.clone(),
      particle: Particle.generate(
        count: 18,
        lifespan: particleDuration,
        generator: (i) {
          final jitter = Vector2(
            random.nextDouble() * 128 - 64,
            random.nextDouble() * 128 - 64,
          );
          final endPosition = relativeTarget + jitter;

          final hue = (baseHsv.hue + 45 + random.nextDouble() * 20 - 30) % 360;
          final saturation =
              (baseHsv.saturation * 0.7 + random.nextDouble() * 0.5).clamp(
                0.0,
                1.0,
              );
          final value = (baseHsv.value * 0.7 + random.nextDouble() * 0.4).clamp(
            0.0,
            1.0,
          );
          final particleColor = HSVColor.fromAHSV(
            1.0,
            hue,
            saturation,
            value,
          ).toColor();

          return MovingParticle(
            from: Vector2.zero(),
            to: endPosition,
            lifespan: particleDuration,
            curve: particleCurve,
            child: FadingCircleParticle(
              radius: 5.5 + random.nextDouble() * 3.5,
              paint: Paint()
                ..color = particleColor.withAlpha((0.88 * 255).round()),
              lifespan: particleDuration,
            ),
          );
        },
      ),
    );

    try {
      ps.priority = game.player.priority + 1;
    } catch (_) {}
    (parent ?? game.worldRoot).add(ps);
  }
}

class FadingCircleParticle extends CircleParticle {
  FadingCircleParticle({required super.paint, super.radius, super.lifespan});

  @override
  void render(Canvas canvas) {
    final baseColor = paint.color;
    final alpha = (baseColor.a * (1.0 - progress) * 255).round().clamp(0, 255);
    final fadingPaint = Paint()
      ..color = baseColor.withAlpha(alpha)
      ..blendMode = paint.blendMode
      ..filterQuality = paint.filterQuality
      ..isAntiAlias = paint.isAntiAlias
      ..style = paint.style
      ..strokeCap = paint.strokeCap
      ..strokeJoin = paint.strokeJoin
      ..strokeWidth = paint.strokeWidth;

    canvas.drawCircle(Offset.zero, radius, fadingPaint);
  }
}
