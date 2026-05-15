import 'package:emvia/game/scenes/game_scene.dart';
import 'package:emvia/game/utils/color_util.dart';
import 'package:emvia/game/utils/pos_util.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HouseScene extends GameScene {
  final List<_HouseClutterItem> _clutterItems = [];
  final ValueNotifier<int> remainingClutterNotifier = ValueNotifier<int>(0);

  HouseScene()
    : super(
        backgroundPath: 'scenes/liam/house/background.png',
        foregroundPath: 'scenes/liam/house/foreground.png',
        showControls: true,
      ) {
    GameScene.register(() => HouseScene());
  }

  @override
  int get sceneIndex => 7;

  @override
  String get ambientSoundPath => 'other/легке піано.mp3';

  @override
  bool get isPhotoCaptureAllowed {
    final state = game.liamState;
    if (state == null || state.currentMissionIndex != 5) return true;
    return _clutterItems.isEmpty;
  }

  @override
  void onPlayerReachedLeftEdge() => game.navigationManager.goToLiamOutside();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    ColorUtil.colorWalls(background.decorator, game.surveyProfile);

    await _syncClutterItems();

    if (game.liamState?.currentMissionIndex == 5) {
      game.overlays.add('LiamHouseObjective');
    }

    layoutToWorld();
  }

  @override
  void onRemove() {
    game.overlays.remove('LiamHouseObjective');
    _clearClutterItems();
    remainingClutterNotifier.dispose();
    super.onRemove();
  }

  @override
  void layoutToWorld() {
    super.layoutToWorld();
    for (final item in _clutterItems) {
      item.updatePosition(background.position, background.size, game.size.y);
    }
  }

  Future<void> _syncClutterItems() async {
    if (game.liamState?.currentMissionIndex != 5) {
      _clearClutterItems();
      remainingClutterNotifier.value = 0;
      return;
    }

    if (_clutterItems.isNotEmpty) return;

    final items = [
      _HouseClutterItem(
        sprite: await game.loadSprite('scenes/liam/house/boxes.png'),
        uv: Vector2(0.24, 0.67),
        heightFactor: 0.28,
        priorityValue: 24,
        onRemoved: _handleClutterRemoved,
      ),
      _HouseClutterItem(
        sprite: await game.loadSprite('scenes/liam/house/crocs.png'),
        uv: Vector2(0.46, 0.75),
        heightFactor: 0.14,
        priorityValue: 26,
        onRemoved: _handleClutterRemoved,
      ),
      _HouseClutterItem(
        sprite: await game.loadSprite('scenes/liam/house/umbrella.png'),
        uv: Vector2(0.68, 0.64),
        heightFactor: 0.22,
        priorityValue: 25,
        onRemoved: _handleClutterRemoved,
      ),
      _HouseClutterItem(
        sprite: await game.loadSprite('scenes/liam/house/boxes.png'),
        uv: Vector2(0.79, 0.72),
        heightFactor: 0.19,
        priorityValue: 23,
        onRemoved: _handleClutterRemoved,
      ),
    ];

    _clutterItems.addAll(items);
    remainingClutterNotifier.value = _clutterItems.length;
    for (final item in _clutterItems) {
      add(item);
      item.updatePosition(background.position, background.size, game.size.y);
    }
  }

  void _handleClutterRemoved(_HouseClutterItem item) {
    _clutterItems.remove(item);
    remainingClutterNotifier.value = _clutterItems.length;
  }

  void _clearClutterItems() {
    for (final item in _clutterItems) {
      item.removeFromParent();
    }
    _clutterItems.clear();
    remainingClutterNotifier.value = 0;
  }

  @override
  double worldWidthForViewport(Vector2 viewportSize) {
    if (background.sprite?.srcSize != null &&
        background.sprite!.srcSize.y > 0) {
      final aspect =
          background.sprite!.srcSize.x / background.sprite!.srcSize.y;
      return viewportSize.y * aspect;
    }
    return viewportSize.x * 2;
  }

  @override
  Vector2 spawnPoint(Vector2 viewportSize, Vector2 worldSize) =>
      Vector2(worldSize.x * 0.2, worldSize.y * 0.68);
}

class _HouseClutterItem extends SpriteComponent with TapCallbacks {
  final Sprite spriteSource;
  final Vector2 uv;
  final double heightFactor;
  final int priorityValue;
  final void Function(_HouseClutterItem item) onRemoved;

  _HouseClutterItem({
    required Sprite sprite,
    required this.uv,
    required this.heightFactor,
    required this.priorityValue,
    required this.onRemoved,
  }) : spriteSource = sprite {
    sprite = spriteSource;
    anchor = Anchor.topLeft;
    priority = priorityValue;
    paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high;
  }

  @override
  void onTapDown(TapDownEvent event) {
    onRemoved(this);
    removeFromParent();
  }

  void updatePosition(Vector2 bgPos, Vector2 bgSize, double viewportHeight) {
    final srcSize = sprite?.srcSize;
    if (srcSize != null && srcSize.y > 0) {
      final targetHeight = viewportHeight * heightFactor;
      final aspect = srcSize.x / srcSize.y;
      size = Vector2(targetHeight * aspect, targetHeight);
    }

    position = getWorldPosFromUV(uv, bgPos, bgSize);
  }
}
