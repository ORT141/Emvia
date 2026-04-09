import 'dart:async';
import 'package:emvia/game/scenes/game_scene.dart';
import 'package:emvia/game/scenes/stress/stress_scene.dart';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_audio/flame_audio.dart';

class SceneScene extends GameScene {
  SceneScene()
    : super(
        backgroundPath: 'scenes/scene/scene_stress.png',
        scalingMode: SceneScalingMode.stretch,
        frozenPlayer: true,
      );

  SpriteComponent? _winImage;
  NoiseOverlay? _noiseOverlay;
  SpriteComponent? _bgFill;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (background.sprite != null) {
      _bgFill = SpriteComponent()
        ..sprite = background.sprite
        ..anchor = Anchor.topLeft
        ..priority = -1;
      add(_bgFill!);
    }

    _winImage = SpriteComponent()
      ..sprite = await game.loadSprite('scenes/scene/scene_win.png')
      ..priority = 20
      ..opacity = 0.0;
    add(_winImage!);

    _noiseOverlay = NoiseOverlay()
      ..priority = 100
      ..size = game.size
      ..position = Vector2.zero();
    add(_noiseOverlay!);

    try {
      await FlameAudio.play('other/people-talking.mp3', volume: game.volume);
    } catch (_) {}

    Future.delayed(const Duration(seconds: 5), () {
      _fadeToWin();
    });
  }

  void _fadeToWin() {
    if (_winImage == null || background.sprite == null) return;

    final src = background.sprite!.srcSize;
    final viewportW = game.size.x;
    final viewportH = game.size.y;
    final coverScale = math.max(viewportW / src.x, viewportH / src.y);
    final coverSize = Vector2(src.x * coverScale, src.y * coverScale);

    _winImage!
      ..size = coverSize
      ..position = Vector2(viewportW / 2, viewportH / 2)
      ..anchor = Anchor.center;

    _winImage!.add(OpacityEffect.to(1.0, EffectController(duration: 0.8)));
    background.add(OpacityEffect.to(0.0, EffectController(duration: 0.8)));

    Future.delayed(const Duration(milliseconds: 1100), () {
      _noiseOverlay?.fadeOut(const Duration(milliseconds: 600));

      Future.delayed(const Duration(seconds: 1), () async {
        game.finishJourney();
      });
    });
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_winImage != null && background.sprite != null) {
      final bgSize = background.size;
      _winImage!
        ..size = bgSize
        ..position = Vector2(bgSize.x / 2, bgSize.y / 2);
    }
    _noiseOverlay?.size = game.size;
  }

  @override
  void layoutToWorld() {
    final viewportW = game.size.x;
    final viewportH = game.size.y;

    if (background.sprite?.srcSize == null) {
      game.worldRoot.size = Vector2(viewportW, viewportH);
      return;
    }

    final src = background.sprite!.srcSize;
    final containScale = math.min(viewportW / src.x, viewportH / src.y);
    final containSize = Vector2(src.x * containScale, src.y * containScale);

    final coverScale = math.max(viewportW / src.x, viewportH / src.y);
    final coverSize = Vector2(src.x * coverScale, src.y * coverScale);

    background
      ..size = containSize
      ..position = Vector2(
        (viewportW - containSize.x) / 2,
        (viewportH - containSize.y) / 2,
      );

    if (_bgFill != null) {
      _bgFill!
        ..size = coverSize
        ..position = Vector2(
          (viewportW - coverSize.x) / 2,
          (viewportH - coverSize.y) / 2,
        );
    }

    if (_winImage != null) {
      _winImage!
        ..size = coverSize
        ..position = Vector2(viewportW / 2, viewportH / 2)
        ..anchor = Anchor.center;
    }

    game.worldRoot.size = Vector2(viewportW, viewportH);
    _noiseOverlay?.size = Vector2(viewportW, viewportH);
    _noiseOverlay?.position = Vector2.zero();
  }
}
