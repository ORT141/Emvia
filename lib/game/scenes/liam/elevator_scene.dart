import 'package:emvia/game/characters/liam/liam_journey.dart';
import 'package:emvia/game/emvia_game.dart';
import 'package:emvia/game/scenes/game_scene.dart';
import 'package:emvia/game/utils/pos_util.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class ElevatorScene extends GameScene {
  static final Vector2 _buttonUv = Vector2(0.205, 0.40);

  RectangleComponent? _buttonHighlight;

  ElevatorScene()
    : super(
        backgroundPath: 'scenes/liam/elevator/background.png',
        showControls: true,
        showPlayer: true,
      ) {
    GameScene.register(() => ElevatorScene());
  }

  @override
  int get sceneIndex => 10;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    layoutToWorld();
    _syncButtonHighlight();
  }

  @override
  Future<void> onMount() async {
    super.onMount();
    LiamJourney.maybeShowCurrentNarrative(game);
  }

  @override
  void onRemove() {
    _buttonHighlight?.removeFromParent();
    _buttonHighlight = null;
    super.onRemove();
  }

  @override
  void layoutToWorld() {
    super.layoutToWorld();
    _syncButtonHighlight();
  }

  Rect? _buttonBounds() {
    if (background.size.x <= 0 || background.size.y <= 0) return null;

    final size = Vector2(background.size.x * 0.025, background.size.y * 0.12);
    final topLeft = getWorldPosFromUV(
      _buttonUv,
      background.position,
      background.size,
    );
    return Rect.fromLTWH(topLeft.x, topLeft.y, size.x, size.y);
  }

  void _syncButtonHighlight() {
    final bounds = _buttonBounds();
    if (bounds == null) return;

    final highlightSize = Vector2(bounds.width, bounds.height);

    _buttonHighlight?.removeFromParent();
    _buttonHighlight = RectangleComponent(
      size: highlightSize,
      position: Vector2(bounds.left, bounds.top),
      anchor: Anchor.topLeft,
      priority: 18,
      paint: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = const Color(0xFFFFF59D).withValues(alpha: 0.95),
    );

    add(_buttonHighlight!);
  }

  @override
  void onTapDown(TapDownEvent event) {
    final bounds = _buttonBounds();
    if (bounds == null) return;

    if (game.liamState?.isCameraMode == true) return;

    final clickScreen = event.localPosition;
    final worldRootPos = game.worldRoot.position;
    final worldRootScale = game.worldRoot.scale;
    final clickWorld = Vector2(
      (clickScreen.x - worldRootPos.x) / worldRootScale.x,
      (clickScreen.y - worldRootPos.y) / worldRootScale.y,
    );

    if (bounds.contains(Offset(clickWorld.x, clickWorld.y))) {
      game.toggleCameraMode();
    }
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
      Vector2(worldSize.x * 0.1, worldSize.y * 0.68);
}
