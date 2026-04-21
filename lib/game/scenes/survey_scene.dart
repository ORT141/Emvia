import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Gradient;

import 'game_scene.dart';

class SurveyScene extends GameScene {
  SurveyScene() : super();

  late final RectangleComponent _bg;
  double _time = 0;

  @override
  double worldWidthForViewport(Vector2 viewportSize) => viewportSize.x;

  @override
  Vector2 spawnPoint(Vector2 viewportSize, Vector2 worldSize) =>
      Vector2(worldSize.x / 2, worldSize.y / 2);

  @override
  Future<void> onLoad() async {
    _bg = RectangleComponent(paint: Paint(), priority: -100);
    add(_bg);

    await super.onLoad();

    game.player.opacity = 0;

    layoutToWorld();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    final viewportSize = game.size;
    if (viewportSize.x == 0 || viewportSize.y == 0) return;

    final angle = _time * 0.2;
    final begin = Offset(
      viewportSize.x * (0.5 + 0.8 * math.cos(angle)),
      viewportSize.y * (0.5 + 0.8 * math.sin(angle)),
    );
    final end = Offset(
      viewportSize.x * (0.5 - 0.8 * math.cos(angle)),
      viewportSize.y * (0.5 - 0.8 * math.sin(angle)),
    );

    _bg.paint.shader = ui.Gradient.linear(
      begin,
      end,
      [
        const Color(0xFF020205),
        const Color(0xFF0A0A15),
        const Color(0xFF101020),
        const Color(0xFF05050A),
      ],
      [0.0, 0.3, 0.7, 1.0],
      TileMode.clamp,
    );
  }

  @override
  void layoutToWorld() {
    super.layoutToWorld();

    final viewportSize = game.size;
    _bg.size = viewportSize.clone();

    game.worldRoot.size = viewportSize.clone();
  }
}
