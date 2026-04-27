import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../utils/pos_util.dart';
import '../../utils/cover_scaling.dart';
import 'path/path_confirm_button.dart';
import 'path/path_mark.dart';
import '../game_scene.dart';
import 'path/path_choice_scene.dart';

class ClassroomScene extends GameScene with TapCallbacks, CoverScaling {
  ClassroomScene()
    : super(
        backgroundPath: 'scenes/olya/classroom/classroom.png',
        showControls: false,
        frozenPlayer: true,
        showPlayer: false,
      ) {
    GameScene.register(() => ClassroomScene());
  }

  @override
  double worldWidthForViewport(Vector2 viewportSize) => viewportSize.x;

  @override
  Vector2 spawnPoint(Vector2 viewportSize, Vector2 worldSize) =>
      Vector2(viewportSize.x / 2, worldSize.y / 2);

  SpriteComponent? _pathOverlay;

  final List<Vector2> _marks = <Vector2>[];
  final List<PathMark> _markCircles = <PathMark>[];
  int? _selectedMarkIndex;
  PathConfirmButton? _confirmButton;

  final double _bgHeight = 0;

  double get bgHeight => _bgHeight > 0 ? _bgHeight : game.size.y;

  @override
  void layoutToWorld() {
    setupCoverWorld();

    applyCoverScaling(background);

    if (foreground != null) {
      applyCoverScaling(foreground!);
    }
  }

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

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    game.olyaState?.classroomScene = this;

    background.priority = 0;

    if (foreground != null) {
      foreground!.priority = 1;
    }

    layoutToWorld();
  }

  Future<void> showClassroomImage() async {
    background.sprite = await game.loadSprite(backgroundPath);
    layoutToWorld();
    foreground?.opacity = 1.0;
    await clearPathOverlay();
  }

  Future<void> showPathOverlay(String asset) async {
    final sprite = await game.loadSprite(asset);
    if (_pathOverlay == null) {
      _pathOverlay = SpriteComponent(
        sprite: sprite,
        anchor: Anchor.topLeft,
        priority: 5,
      );
      add(_pathOverlay!);
    } else {
      _pathOverlay!.sprite = sprite;
    }
    applyCoverScaling(_pathOverlay!);
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
    completePathChoice();
  }

  void completePathChoice() {
    game.sceneIndex = 2;
    game.player.opacity = 1;
    showClassroomImage();
    clearMarks();
    game.transitionManager.updateClassroomZoom();
    game.cameraManager.snapToPlayer(force: true);

    Future.delayed(const Duration(seconds: 1), () {
      game.navigationManager.goToCorridor();
    });
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
      layoutToWorld();

      final overlaySprite = _pathOverlay?.sprite;
      if (overlaySprite != null) {
        final covered = calculateCoverSize(overlaySprite.srcSize, size);
        _pathOverlay!.size = covered;
        _pathOverlay!.position = calculateCoverPosition(covered, size);
      }

      for (var i = 0; i < _marks.length; i++) {
        final m = _marks[i];
        final mark = _markCircles.length > i ? _markCircles[i] : null;
        if (mark != null) {
          mark.position =
              background.position +
              Vector2(m.x * background.size.x, m.y * background.size.y);
        }
      }
      _confirmButton?.position = Vector2(size.x / 2, size.y - 80);
    }
  }
}
