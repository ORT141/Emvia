import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import 'game_scene.dart';

mixin PeopleOverlayMixin on GameScene {
  String get peopleBackgroundOverlayPath;
  String get peopleForegroundOverlayPath;

  SpriteComponent? _peopleBackgroundOverlay;
  SpriteComponent? _peopleForegroundOverlay;

  Future<void> loadPeopleOverlays() async {
    try {
      _peopleBackgroundOverlay = SpriteComponent()
        ..anchor = Anchor.topLeft
        ..priority = 10;
      _peopleBackgroundOverlay!.sprite = await game.loadSprite(
        peopleBackgroundOverlayPath,
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
        peopleForegroundOverlayPath,
      );
      game.worldRoot.add(_peopleForegroundOverlay!);
    } catch (_) {
      _peopleForegroundOverlay = null;
    }
  }

  @protected
  void layoutPeopleOverlays() {
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

  void removePeopleOverlays() {
    if (_peopleForegroundOverlay != null) {
      game.worldRoot.remove(_peopleForegroundOverlay!);
    }
    _peopleBackgroundOverlay?.removeFromParent();
    _peopleBackgroundOverlay = null;
    _peopleForegroundOverlay?.removeFromParent();
    _peopleForegroundOverlay = null;
  }
}
