import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../components/path_confirm_button.dart';
import '../components/path_mark.dart';
import 'game_scene.dart';
import 'path_choice_scene.dart';

class ClassroomScene extends GameScene with TapCallbacks {
  ClassroomScene()
    : super(
        backgroundPath: 'scenes/classroom/classroom.png',
        foregroundPath: 'scenes/classroom/classmates.png',
      );

  SpriteComponent? _pathOverlay;
  Vector2? _pathBgSrcSize;

  final List<Vector2> _marks = <Vector2>[];
  final List<PathMark> _markCircles = <PathMark>[];
  int? _selectedMarkIndex;
  PathConfirmButton? _confirmButton;

  double _bgHeight = 0;

  double get bgHeight => _bgHeight > 0 ? _bgHeight : game.size.y;

  @override
  void onTapDown(TapDownEvent event) {
    final centerX = game.worldRoot.size.x / 2;
    final centerY = game.worldRoot.size.y / 2;

    final clickScreen = event.localPosition;
    final worldRootPos = game.worldRoot.position;
    final worldRootScale = game.worldRoot.scale;
    final clickWorld = Vector2(
      (clickScreen.x - worldRootPos.x) / worldRootScale.x,
      (clickScreen.y - worldRootPos.y) / worldRootScale.y,
    );

    if ((clickWorld.x - centerX).abs() < 300 &&
        (clickWorld.y - centerY).abs() < 300) {
      game.loadScene(PathChoiceScene());
    }
  }

  Vector2 _coverSize(Vector2 src, Vector2 target) {
    final scale = math.max(target.x / src.x, target.y / src.y);
    return Vector2(src.x * scale, src.y * scale);
  }

  Vector2 _coverPosition(Vector2 covered, Vector2 target) =>
      Vector2((target.x - covered.x) / 2, (target.y - covered.y) / 2);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final src = background.sprite?.srcSize;
    if (src != null && src.x > 0 && src.y > 0) {
      _bgHeight = (game.worldRoot.size.x * src.y / src.x).ceilToDouble();
    }
    background.size = Vector2(game.worldRoot.size.x, bgHeight);
    background.position = Vector2.zero();
    foreground?.size = Vector2(game.worldRoot.size.x, bgHeight);
    foreground?.position = Vector2.zero();
  }

  Future<void> showPathImage() async {
    final sprite = await game.loadSprite('scenes/classroom/path.png');
    background.sprite = sprite;
    _pathBgSrcSize = sprite.srcSize.clone();
    background.size = Vector2(game.worldRoot.size.x, bgHeight);
    background.position = Vector2.zero();
    foreground?.opacity = 0.0;
    await clearPathOverlay();
  }

  Future<void> showClassroomImage() async {
    background.sprite = await game.loadSprite(backgroundPath);
    _pathBgSrcSize = null;
    background.size = Vector2(game.worldRoot.size.x, bgHeight);
    background.position = Vector2.zero();
    foreground?.size = Vector2(game.worldRoot.size.x, bgHeight);
    foreground?.opacity = 1.0;
    await clearPathOverlay();
  }

  Future<void> showPathOverlay(String asset) async {
    final sprite = await game.loadSprite(asset);
    final pos = Vector2.zero();
    final covered = Vector2(game.worldRoot.size.x, bgHeight);
    if (_pathOverlay == null) {
      _pathOverlay = SpriteComponent(
        sprite: sprite,
        size: covered,
        anchor: Anchor.topLeft,
        position: pos,
      );
      add(_pathOverlay!);
    } else {
      _pathOverlay!.sprite = sprite;
      _pathOverlay!.size = covered;
      _pathOverlay!.position = pos;
    }
  }

  Future<void> clearPathOverlay() async {
    if (_pathOverlay != null) {
      _pathOverlay!.removeFromParent();
      _pathOverlay = null;
    }
  }

  Future<void> showMarks(List<Vector2> marksNormalized) async {
    await clearMarks();
    _marks.addAll(marksNormalized);

    for (var i = 0; i < _marks.length; i++) {
      final bgPos = background.position.clone();
      final bgSize = background.size;
      final pos =
          bgPos + Vector2(_marks[i].x * bgSize.x, _marks[i].y * bgSize.y);
      final mark = PathMark(
        index: i,
        position: pos,
        onSelected: _onMarkSelected,
      );
      _markCircles.add(mark);
      add(mark);
    }

    _confirmButton = PathConfirmButton(
      onConfirm: _onConfirmChoice,
      position: Vector2(game.size.x / 2, game.size.y - 80),
    );
    add(_confirmButton!);
  }

  void _onMarkSelected(int index) {
    _selectedMarkIndex = index;
    for (var i = 0; i < _markCircles.length; i++) {
      _markCircles[i].isSelected = (i == _selectedMarkIndex);
    }
    _confirmButton?.setEnabled(true);
  }

  void _onConfirmChoice() {
    if (_selectedMarkIndex == null) return;
    if (_selectedMarkIndex == 0) {
      game.chooseFirstPath(game.buildContext!);
    } else if (_selectedMarkIndex == 1) {
      game.chooseSecondPath(game.buildContext!);
    } else if (_selectedMarkIndex == 2) {
      game.chooseSecondPath(game.buildContext!);
    }
  }

  Future<void> clearMarks() async {
    for (final c in _markCircles) {
      c.removeFromParent();
    }
    _markCircles.clear();
    _marks.clear();
    _selectedMarkIndex = null;
    _confirmButton?.removeFromParent();
    _confirmButton = null;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      final overlaySprite = _pathOverlay?.sprite;
      if (overlaySprite != null) {
        final covered = _coverSize(overlaySprite.srcSize, size);
        _pathOverlay!.size = covered;
        _pathOverlay!.position = _coverPosition(covered, size);
      }
      if (foreground?.opacity == 0 && _pathBgSrcSize != null) {
        final covered = _coverSize(_pathBgSrcSize!, size);
        background.size = covered;
        background.position = _coverPosition(covered, size);
      } else {
        background.size = Vector2(game.worldRoot.size.x, bgHeight);
        background.position = Vector2.zero();
        foreground?.size = Vector2(game.worldRoot.size.x, bgHeight);
        foreground?.position = Vector2.zero();
      }
      for (var i = 0; i < _marks.length; i++) {
        final m = _marks[i];
        final bgPos = background.position.clone();
        final bgSize = background.size;
        final screenPos = bgPos + Vector2(m.x * bgSize.x, m.y * bgSize.y);
        final mark = _markCircles.length > i ? _markCircles[i] : null;
        if (mark != null) {
          mark.position = screenPos;
        }
      }
      _confirmButton?.position = Vector2(size.x / 2, size.y - 80);
    }
  }
}
