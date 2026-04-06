import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show HSVColor;
import '../../emvia_game.dart';

import '../game_scene.dart';

class StressScene extends GameScene {
  StressScene()
    : super(
        backgroundPath: 'stress/stress-scene/panic_background.png',
        foregroundPath: 'stress/stress-scene/panic_foreground.png',
        scalingMode: SceneScalingMode.stretch,
        frozenPlayer: true,
      );

  RectangleComponent? _ambientOverlay;
  SpriteComponent? _playerComponent;
  SpriteComponent? _silhouettesComponent;
  NoiseOverlay? _noiseOverlay;

  final math.Random _random = math.Random();
  double _time = 0;
  Vector2 _basePosition = Vector2.zero();

  double get _stressFactor => (game.stressLevel / 100.0).clamp(0.0, 1.0);

  @override
  double worldWidthForViewport(Vector2 viewportSize) => viewportSize.x;

  @override
  Vector2 spawnPoint(Vector2 viewportSize, Vector2 worldSize) =>
      Vector2(viewportSize.x / 2, viewportSize.y / 2);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _applyBackgroundTint();

    foreground?.priority = 2;

    _silhouettesComponent = SpriteComponent()
      ..sprite = await game.loadSprite(
        'stress/stress-scene/panic_silhouettes.png',
      )
      ..anchor = Anchor.topLeft
      ..priority = 5;
    add(_silhouettesComponent!);

    _playerComponent = SpriteComponent()
      ..sprite = await game.loadSprite(game.player.stressPanicSprite)
      ..anchor = Anchor.topLeft
      ..priority = 10;
    add(_playerComponent!);

    final style = game.surveyProfile.panicStyle;
    if (style == 'noise') {
      _noiseOverlay = NoiseOverlay()..priority = 100;
      add(_noiseOverlay!);
    } else if (style == 'blur') {
      _updateBlur();
    }

    game.stressLevel = 100;

    game.overlays.add('TapGame');
    game.overlays.add('Stress');

    layoutToWorld();
  }

  void _updateBlur() {
    final sigma = _stressFactor * 10.0;
    if (sigma <= 0.2) {
      background.paint.imageFilter = null;
      for (final fg in foregrounds) {
        fg.paint.imageFilter = null;
      }
      _silhouettesComponent?.paint.imageFilter = null;
      _playerComponent?.paint.imageFilter = null;
    } else {
      final blur = ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);
      background.paint.imageFilter = blur;
      for (final fg in foregrounds) {
        fg.paint.imageFilter = blur;
      }
      _silhouettesComponent?.paint.imageFilter = blur;
      _playerComponent?.paint.imageFilter = blur;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    if (game.stressLevel <= 60 && !game.overlays.isActive('TapGame')) {
      _startTransitionToCorridor();
    }

    _noiseOverlay?.intensity = _stressFactor;

    final style = game.surveyProfile.panicStyle;
    if (style == 'shake') {
      _handleShake();
    } else if (style == 'acid') {
      _handleAcid(dt);
    } else if (style == 'blur') {
      _updateBlur();
    }
  }

  void _handleShake() {
    final intensity = math.max(1.0, 12.0 * _stressFactor);
    final offsetX = (_random.nextDouble() - 0.5) * intensity;
    final offsetY = (_random.nextDouble() - 0.5) * intensity;

    final pos = _basePosition + Vector2(offsetX, offsetY);
    background.position = pos;
    for (final fg in foregrounds) {
      fg.position = pos;
    }
    _silhouettesComponent?.position = pos;
    _playerComponent?.position = pos;
  }

  void _handleAcid(double dt) {
    final hue = (_time * 360 * 0.2) % 360;
    final alpha = (0.4 * _stressFactor).clamp(0.0, 0.4);
    final color = HSVColor.fromAHSV(1.0, hue, 0.7, 0.7).toColor();

    try {
      background.decorator.removeLast();
    } catch (_) {}
    try {
      background.decorator.addLast(
        PaintDecorator.tint(color.withValues(alpha: alpha)),
      );
    } catch (_) {}
  }

  bool _transitioning = false;

  void _startTransitionToCorridor() {
    if (_transitioning) return;
    _transitioning = true;
    game.transitionToCorridor();
  }

  @override
  void layoutToWorld() {
    final viewportW = game.size.x;
    final viewportH = game.size.y;

    game.worldRoot.size = Vector2(viewportW, viewportH);

    _ambientOverlay
      ?..size = Vector2(viewportW, viewportH)
      ..position = Vector2.zero();

    if (background.sprite?.srcSize != null) {
      final src = background.sprite!.srcSize;
      final scale = viewportW / src.x;
      final size = Vector2(src.x * scale, src.y * scale);
      _basePosition = Vector2(0, (viewportH - size.y) / 2);

      background
        ..size = size
        ..position = _basePosition;

      for (final foreground in foregrounds) {
        foreground
          ..size = size
          ..position = _basePosition;
      }

      for (final comp in [_silhouettesComponent, _playerComponent]) {
        comp
          ?..size = size
          ..position = _basePosition;
      }

      _noiseOverlay?.size = Vector2(viewportW, viewportH);
    }
  }

  @override
  @mustCallSuper
  void redrawScene() {
    _applyBackgroundTint();
    super.redrawScene();
  }

  void _applyBackgroundTint() {
    final color = game.surveyProfile.safeColorValue;
    try {
      background.decorator.removeLast();
    } catch (_) {}
    try {
      background.decorator.addLast(PaintDecorator.tint(color));
    } catch (_) {}
  }
}

class NoiseOverlay extends Component with HasGameReference<EmviaGame> {
  final math.Random _random = math.Random();
  Vector2 size = Vector2.zero();
  double intensity = 1.0;

  @override
  void render(ui.Canvas canvas) {
    final w = size.x;
    final h = size.y;
    if (w <= 0 || h <= 0) return;

    final alpha = (0x66 * intensity).round().clamp(0, 255);
    final paint = ui.Paint()..color = ui.Color.fromARGB(alpha, 255, 255, 255);

    for (var i = 0; i < 1000; i++) {
      final x = _random.nextDouble() * w;
      final y = _random.nextDouble() * h;
      final size = _random.nextDouble() * 3 + 1;
      canvas.drawRect(ui.Rect.fromLTWH(x, y, size, size), paint);
    }
  }
}
