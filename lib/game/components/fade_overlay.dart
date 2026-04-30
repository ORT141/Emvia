import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../emvia_game.dart';

class FadeOverlay extends RectangleComponent with HasGameReference<EmviaGame> {
  FadeOverlay() : super(paint: Paint()..color = Colors.black, priority: 9999);

  @override
  Future<void> onLoad() async {
    size = game.size;
    opacity = 0;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size + Vector2.all(2);
    position = Vector2.all(-1);
  }

  Future<void> fadeIn(double duration) => _fadeTo(1.0, duration);

  Future<void> fadeOut(double duration) => _fadeTo(0.0, duration);

  Future<void> _fadeTo(double target, double duration) async {
    removeAll(children.whereType<OpacityEffect>());

    final completer = Completer<void>();
    add(
      OpacityEffect.to(
        target,
        EffectController(duration: duration),
        onComplete: () {
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );

    Future.delayed(Duration(milliseconds: (duration * 1000).toInt() + 250), () {
      if (!completer.isCompleted) completer.complete();
    });

    return completer.future;
  }
}
