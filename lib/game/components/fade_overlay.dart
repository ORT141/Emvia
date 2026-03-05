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
    this.size = size;
  }

  Future<void> fadeIn(double duration) async {
    final completer = Completer<void>();
    add(
      OpacityEffect.to(
        1.0,
        EffectController(duration: duration),
        onComplete: () {
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );

    Future.delayed(Duration(milliseconds: (duration * 1000).toInt() + 250), () {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    return completer.future;
  }

  Future<void> fadeOut(double duration) async {
    final completer = Completer<void>();
    add(
      OpacityEffect.to(
        0.0,
        EffectController(duration: duration),
        onComplete: () {
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );

    Future.delayed(Duration(milliseconds: (duration * 1000).toInt() + 250), () {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    return completer.future;
  }
}
