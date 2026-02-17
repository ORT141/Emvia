import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import 'components/player.dart';
import 'scenes/game_scene.dart';
import 'scenes/blank_room.dart';
import 'dialog_model.dart';
import 'dialog_data.dart';

class EmviaGame extends FlameGame
    with TapCallbacks, HasKeyboardHandlerComponents {
  static const double worldWidth = 2000.0;

  static const double _cameraFollowSharpness = 5.0;
  static const double _cameraDeadZonePx = 10.0;

  late final OlyaPlayer olya = OlyaPlayer();
  late SpriteComponent noiseEffect;

  final PositionComponent worldRoot = PositionComponent();

  final Vector2 _cameraPos = Vector2.zero();
  double _zoom = _defaultZoom;

  static const double _defaultZoom = 1.4;

  GameScene? currentScene;

  int sceneIndex = 0;
  bool isStressMode = false;

  final currentNodeNotifier = ValueNotifier<DialogNode?>(null);
  DialogNode? get currentNode => currentNodeNotifier.value;
  set currentNode(DialogNode? value) => currentNodeNotifier.value = value;

  DialogTree? currentTree;

  @override
  Future<void> onLoad() async {
    noiseEffect = SpriteComponent()
      ..sprite = await loadSprite('noise.jpg')
      ..size = size
      ..opacity = 0.0;

    _zoom = _defaultZoom;
    worldRoot.scale = Vector2.all(_zoom);
    worldRoot.anchor = Anchor.topLeft;

    add(worldRoot);

    await loadScene(BlankRoom());

    add(noiseEffect);

    overlays.add('MainMenu');
  }

  Future<void> loadScene(GameScene scene) async {
    if (currentScene != null) {
      currentScene!.removeFromParent();
    }
    currentScene = scene;
    await worldRoot.add(scene);

    if (olya.parent == null) {
      await worldRoot.add(olya);
    }
    olya.priority = 10;

    worldRoot.size = Vector2(worldWidth, size.y);

    olya.position = Vector2(worldRoot.size.x / 2, worldRoot.size.y / 2);
    _snapCameraToPlayer();
  }

  void startGame() {
    sceneIndex = 0;
    startDialog(DialogData.getTeacherDialog());
  }

  void calmDown() {
    isStressMode = false;
    noiseEffect.opacity = 0.0;
    overlays.remove('Breathing');
    startDialog(
      DialogTree(
        startNodeId: 'calmed',
        nodes: {
          'calmed': DialogNode(
            id: 'calmed',
            text: (l) => l.dialog_calmed_you_feel_better,
          ),
        },
      ),
    );
  }

  void startDialog(DialogTree tree) {
    currentTree = tree;
    currentNode = tree.getNode(tree.startNodeId);
    currentNode?.onSelect?.call(this);
    overlays.add('Dialog');
  }

  void selectChoice(DialogChoice choice) {
    choice.onSelect?.call(this);
    if (choice.nextNodeId != null) {
      currentNode = currentTree?.getNode(choice.nextNodeId);
      currentNode?.onSelect?.call(this);
      if (currentNode == null) {
        overlays.remove('Dialog');
      }
    } else {
      overlays.remove('Dialog');
      currentNode = null;
    }
  }

  void nextDialog() {
    if (currentNode?.choices != null && currentNode!.choices!.isNotEmpty) {
      return;
    }

    if (currentNode?.nextNodeId != null) {
      currentNode = currentTree?.getNode(currentNode!.nextNodeId);
      currentNode?.onSelect?.call(this);
      if (currentNode == null) {
        overlays.remove('Dialog');
      }
    } else {
      overlays.remove('Dialog');
      currentNode = null;
    }
  }

  void pauseGame() {
    pauseEngine();
    overlays.add('Pause');
  }

  void resumeGame() {
    resumeEngine();
    overlays.remove('Pause');
  }

  @override
  void update(double dt) {
    dt = dt.clamp(0, 0.05);
    super.update(dt);

    if (olya.parent == null) return;

    final target = Vector2(olya.position.x, olya.position.y);

    final deadZoneWorld = _cameraDeadZonePx / _zoom;
    final distX = (target.x - _cameraPos.x).abs();
    final distY = (target.y - _cameraPos.y).abs();

    final resolvedTargetX = (distX > deadZoneWorld) ? target.x : _cameraPos.x;
    final resolvedTargetY = (distY > deadZoneWorld) ? target.y : _cameraPos.y;

    final rawTarget = Vector2(resolvedTargetX, resolvedTargetY);

    final clampedTarget = _clampTargetToWorldBounds(rawTarget);

    final alpha = 1 - math.exp(-_cameraFollowSharpness * dt);

    _cameraPos.x = _cameraPos.x + (clampedTarget.x - _cameraPos.x) * alpha;
    _cameraPos.y = _cameraPos.y + (clampedTarget.y - _cameraPos.y) * alpha;

    final screenCenter = Vector2(size.x / 2, size.y / 2);
    worldRoot.position = screenCenter - (_cameraPos * _zoom);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    worldRoot.size.y = size.y;

    if (olya.parent != null) {
      olya.position.y = size.y / 2;
    }

    _snapCameraToPlayer();
  }

  void _snapCameraToPlayer() {
    final rawTarget = Vector2(olya.position.x, olya.position.y);
    final clamped = _clampTargetToWorldBounds(rawTarget);

    _cameraPos.setFrom(clamped);

    final screenCenter = Vector2(size.x / 2, size.y / 2);
    worldRoot.position = screenCenter - (_cameraPos * _zoom);
  }

  Vector2 _clampTargetToWorldBounds(Vector2 target) {
    final zoom = _zoom;

    final visibleWidthWorld = size.x / zoom;
    final visibleHeightWorld = size.y / zoom;

    final halfVisibleWidth = visibleWidthWorld / 2;
    final halfVisibleHeight = visibleHeightWorld / 2;

    final worldWidthLocal = worldRoot.size.x;
    final worldHeightLocal = worldRoot.size.y;

    final minX = halfVisibleWidth;
    final maxX = worldWidthLocal - halfVisibleWidth;
    final minY = halfVisibleHeight;
    final maxY = worldHeightLocal - halfVisibleHeight;

    double clampedX = target.x;
    double clampedY = target.y;

    if (minX <= maxX) {
      clampedX = target.x.clamp(minX, maxX).toDouble();
    } else {
      clampedX = worldWidthLocal / 2;
    }

    if (minY <= maxY) {
      clampedY = target.y.clamp(minY, maxY).toDouble();
    } else {
      clampedY = worldHeightLocal / 2;
    }

    return Vector2(clampedX, clampedY);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isStressMode && overlays.isActive('Dialog')) {
      nextDialog();
      return;
    }

    if (!overlays.isActive('Pause') && !overlays.isActive('MainMenu')) {
      final pos = event.localPosition;
      if (pos.x > size.x - 60 && pos.y < 60) {
        pauseGame();
      }
    }
  }
}
