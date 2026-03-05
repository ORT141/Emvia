import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:emvia/l10n/app_localizations.dart';

import 'survey_service.dart';
import 'components/fade_overlay.dart';
import 'components/player.dart';
import 'scenes/game_scene.dart';
import 'scenes/classroom_scene.dart';
import 'scenes/corridor_scene.dart';
import 'scenes/path_choice_scene.dart';
import 'dialog_model.dart';
import 'inventory/backpack_inventory.dart';
import 'inventory/backpack_item.dart';

import 'mixins/dialog_handler.dart';

class PathDetailInfo {
  final int index;
  final String title;
  final String name;
  final String description;
  final String confirmLabel;
  final String cancelLabel;

  PathDetailInfo({
    required this.index,
    required this.title,
    required this.name,
    required this.description,
    required this.confirmLabel,
    required this.cancelLabel,
  });
}

enum PlayableCharacter { olya, liam, olenka }

class EmviaGame extends FlameGame
    with TapCallbacks, HasKeyboardHandlerComponents, DialogHandler {
  static const double worldWidth = 2000.0;

  static const double _cameraFollowSharpness = 5.0;
  static const double _cameraDeadZonePx = 10.0;

  late final OlyaPlayer olya = OlyaPlayer();
  late SpriteComponent noiseEffect;
  late FadeOverlay fadeOverlay;

  final PositionComponent worldRoot = PositionComponent();

  final Vector2 _cameraPos = Vector2.zero();
  double _zoom = _defaultZoom;

  static const double _defaultZoom = 1.1;

  GameScene? currentScene;
  ClassroomScene? _classroomScene;
  bool _isSceneTransitioning = false;

  bool freezeForPathChoice = false;

  int sceneIndex = 0;
  bool isStressMode = false;
  int stressLevel = 0;

  int _sessionToken = 0;

  PlayableCharacter selectedCharacter = PlayableCharacter.olya;
  bool _startGameAfterSurvey = false;

  final SurveyService _surveyService = SurveyService();
  SurveyProfile surveyProfile = SurveyProfile(const {});
  final BackpackInventory backpack = BackpackInventory(
    initialItems: BackpackItem.placeholderItems(),
  );

  double _mobileMoveX = 0;

  final List<String> _selectedTools = [];

  List<String> get selectedTools => List.unmodifiable(_selectedTools);

  final currentNodeNotifier = ValueNotifier<DialogNode?>(null);
  final pathDetailNotifier = ValueNotifier<PathDetailInfo?>(null);
  DialogNode? get currentNode => currentNodeNotifier.value;
  set currentNode(DialogNode? value) => currentNodeNotifier.value = value;

  DialogTree? currentTree;

  @override
  Future<void> onLoad() async {
    noiseEffect = SpriteComponent()
      ..sprite = await loadSprite('overlays/noise.jpg')
      ..size = size
      ..opacity = 0.0;

    _zoom = _defaultZoom;
    worldRoot.scale = Vector2.all(_zoom);
    worldRoot.anchor = Anchor.topLeft;

    add(worldRoot);
    fadeOverlay = FadeOverlay();
    add(fadeOverlay);

    await loadScene(ClassroomScene());
    olya.opacity = 0;

    add(noiseEffect);

    overlays.add('MainMenu');
  }

  Future<void> loadScene(GameScene scene) async {
    _isSceneTransitioning = true;

    await fadeOverlay.fadeIn(0.4);

    if (currentScene != null) {
      currentScene!.removeFromParent();
    }

    worldRoot.size = Vector2(_sceneWorldWidth(scene), size.y);

    currentScene = scene;
    await worldRoot.add(scene);
    if (scene is ClassroomScene) {
      _classroomScene = scene;
      _updateClassroomZoom();
    } else {
      _classroomScene = null;
      _zoom = _defaultZoom;
      worldRoot.scale = Vector2.all(_zoom);
    }

    if (olya.parent == null) {
      await worldRoot.add(olya);
    }
    olya.priority = 10;

    if (scene is PathChoiceScene) {
      olya.opacity = 0;
    }

    olya.position = _sceneSpawnPoint(scene);
    _snapCameraToPlayer();

    await fadeOverlay.fadeOut(0.4);

    _isSceneTransitioning = false;
  }

  void _updateClassroomZoom() {
    final scene = _classroomScene;
    if (scene == null || !scene.isLoaded) return;
    final h = scene.bgHeight;
    if (h <= 0) return;
    final widthFit = size.x / worldRoot.size.x;
    final heightFit = size.y / h;
    _zoom = math.max(widthFit, heightFit);
    worldRoot.size = Vector2(worldRoot.size.x, h);
    worldRoot.scale = Vector2.all(_zoom);
  }

  double _sceneWorldWidth(GameScene scene) {
    return worldWidth;
  }

  Vector2 _sceneSpawnPoint(GameScene scene) {
    if (scene is ClassroomScene) {
      return Vector2(size.x * 0.2, worldRoot.size.y * 0.75);
    }
    if (scene is CorridorScene) {
      return Vector2(80, worldRoot.size.y * 0.75);
    }
    return Vector2(worldRoot.size.x / 2, worldRoot.size.y * 0.75);
  }

  void startGame() {
    if (selectedCharacter != PlayableCharacter.olya) return;
    _startGameFlow();
  }

  bool get isMobilePlatform {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  bool get isBackpackOpen => overlays.isActive('Backpack');

  void toggleBackpack() {
    if (!_canToggleBackpack()) return;
    if (isBackpackOpen) {
      overlays.remove('Backpack');
    } else {
      overlays.add('Backpack');
    }
  }

  bool _canToggleBackpack() {
    if (sceneIndex == 0) return false;
    if (_isSceneTransitioning) return false;
    if (overlays.isActive('MainMenu') || overlays.isActive('Pause')) {
      return false;
    }
    if (overlays.isActive('Survey') || overlays.isActive('Dialog')) {
      return false;
    }
    return true;
  }

  void setMobileMoveX(double direction) {
    _mobileMoveX = direction.clamp(-1.0, 1.0);
    olya.setMobileDirection(_mobileMoveX);
  }

  void showMobileControls() {
    if (!isMobilePlatform) return;
    if (!overlays.isActive('MobileControls')) {
      overlays.add('MobileControls');
    }
  }

  void hideMobileControls() {
    overlays.remove('MobileControls');
    setMobileMoveX(0);
  }

  void startNewGameSurveyFlow() {
    _startGameAfterSurvey = true;
    closeMainMenu();
    overlays.add('Survey');
  }

  void closeMainMenu() {
    overlays.remove('MainMenu');
    if (sceneIndex == 0) {
      olya.opacity = 1;
    }
    if (!paused && sceneIndex > 0) {
      showMobileControls();
    }
  }

  void openMainMenu() {
    overlays.remove('Backpack');
    hideMobileControls();
    overlays.add('MainMenu');
  }

  bool consumeStartGameAfterSurvey() {
    final shouldStart = _startGameAfterSurvey;
    _startGameAfterSurvey = false;
    return shouldStart;
  }

  bool isCharacterUnlocked(PlayableCharacter character) {
    return character == PlayableCharacter.olya;
  }

  void selectCharacter(PlayableCharacter character) {
    if (!isCharacterUnlocked(character)) return;
    selectedCharacter = character;
  }

  Future<void> _startGameFlow() async {
    final token = ++_sessionToken;

    surveyProfile = await _surveyService.getProfile();
    sceneIndex = 1;
    stressLevel = 0;
    isStressMode = false;
    noiseEffect.opacity = 0.0;
    _selectedTools.clear();
    backpack.clear();
    for (final item in BackpackItem.placeholderItems()) {
      backpack.addItem(item);
    }

    overlays.remove('Dialog');
    overlays.remove('CalmMap');
    overlays.remove('PathChoice');
    overlays.remove('Backpack');

    await fadeOverlay.fadeIn(0.4);

    await loadScene(PathChoiceScene());

    if (token != _sessionToken) return;

    freezeForPathChoice = true;
    worldRoot.scale = Vector2.all(1.0);
    olya.opacity = 0;

    await fadeOverlay.fadeOut(0.4);

    showMobileControls();
  }

  void showPathDetail(PathDetailInfo info) {
    pathDetailNotifier.value = info;
    overlays.add('PathDetail');
  }

  void hidePathDetail() {
    overlays.remove('PathDetail');
    pathDetailNotifier.value = null;
  }

  void clearPathSelection() {
    if (currentScene is PathChoiceScene) {
      (currentScene as PathChoiceScene).clearSelection();
    }
  }

  void showPathBackground() {
    _classroomScene?.showPathImage();
  }

  void clearPathOverlay() {
    _classroomScene?.clearPathOverlay();
  }

  void restoreClassroomBackground() {
    _classroomScene?.showClassroomImage();
  }

  void chooseFirstPath(BuildContext context) {
    if (!context.mounted) return;
    final l = AppLocalizations.of(context)!;
    _selectedTools.add(l.classroom);
    _selectedTools.add(l.path_first);
    _finishPathChoice(l.map_of_calm_olya, l.first_path_description);
  }

  void chooseSecondPath(BuildContext context) {
    if (!context.mounted) return;
    final l = AppLocalizations.of(context)!;
    _selectedTools.add(l.classroom);
    _selectedTools.add(l.path_second);
    _finishPathChoice(l.map_of_calm_olya, l.second_path_description);
  }

  void chooseThirdPath(BuildContext context) {
    if (!context.mounted) return;
    final l = AppLocalizations.of(context)!;
    _selectedTools.add(l.classroom);
    _selectedTools.add(l.path_third);
    _finishPathChoice(l.map_of_calm_olya, l.third_path_description);
  }

  void _finishPathChoice(String title, String description) {
    sceneIndex = 2;
    olya.opacity = 1;
    _classroomScene?.showClassroomImage();
    _classroomScene?.clearMarks();
    freezeForPathChoice = false;
    _updateClassroomZoom();
    olya.position = _sceneSpawnPoint(currentScene!);
    _snapCameraToPlayer();
  }

  Future<void> applyPathChoice(int index, BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    _selectedTools.add(l.classroom);
    if (index == 0) {
      _selectedTools.add(l.path_first);
    } else if (index == 1) {
      _selectedTools.add(l.path_second);
    } else {
      _selectedTools.add(l.path_third);
    }

    await loadScene(ClassroomScene());
    _finishPathChoice(
      l.map_of_calm_olya,
      index == 0
          ? l.first_path_description
          : index == 1
          ? l.second_path_description
          : l.third_path_description,
    );
  }

  Future<void> _transitionToCorridor() async {
    if (_isSceneTransitioning) return;
    sceneIndex = 3;
    await loadScene(CorridorScene());
    olya.position.x = olya.size.x / 2 + 10;
    _snapCameraToPlayer();
  }

  void calmDown() {
    isStressMode = false;
    noiseEffect.opacity = 0.0;
    startDialog(
      DialogTree(
        startNodeId: 'calmed',
        nodes: {
          'calmed': DialogNode(
            id: 'calmed',
            text: (_) => surveyProfile.supportMessageLabel(buildContext!),
          ),
        },
      ),
    );
  }

  void pauseGame() {
    overlays.remove('Backpack');
    hideMobileControls();
    pauseEngine();
    overlays.add('Pause');
  }

  void resumeGame() {
    resumeEngine();
    overlays.remove('Pause');
    showMobileControls();
  }

  void returnToMainMenuFromPause() {
    resumeEngine();
    overlays.remove('Pause');
    openMainMenu();
  }

  @override
  void update(double dt) {
    dt = dt.clamp(0, 0.05);
    super.update(dt);

    if (olya.parent == null) return;

    if (freezeForPathChoice) {
      worldRoot.scale = Vector2.all(1.0);
      worldRoot.position = Vector2.zero();
      return;
    }

    if (currentScene is ClassroomScene) {
      if (olya.position.x >= worldRoot.size.x - olya.size.x / 2 - 10) {
        _transitionToCorridor();
      }
    }

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

    final scene = currentScene;
    if (scene is ClassroomScene && !freezeForPathChoice && scene.isLoaded) {
      _updateClassroomZoom();
    } else {
      worldRoot.size = Vector2(
        scene != null ? _sceneWorldWidth(scene) : worldWidth,
        size.y,
      );
    }

    if (olya.parent != null) {
      final minX = olya.size.x / 2;
      final maxX = worldRoot.size.x - olya.size.x / 2;
      if (minX <= maxX) {
        olya.position.x = olya.position.x.clamp(minX, maxX).toDouble();
      } else {
        olya.position.x = worldRoot.size.x / 2;
      }
      olya.position.y = worldRoot.size.y * 0.75;
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
    if (!overlays.isActive('Pause') && !overlays.isActive('MainMenu')) {
      final pos = event.localPosition;
      if (pos.x > size.x - 60 && pos.y < 60) {
        pauseGame();
      }
    }
    currentScene?.onTapDown(event);
  }
}
