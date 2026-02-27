import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:emvia/l10n/app_localizations.dart';

import 'survey_service.dart';
import 'components/player.dart';
import 'scenes/game_scene.dart';
import 'scenes/classroom_scene.dart';
import 'scenes/corridor_scene.dart';
import 'dialog_model.dart';

import 'mixins/dialog_handler.dart';

enum PlayableCharacter { olya, liam, olenka }

class EmviaGame extends FlameGame
    with TapCallbacks, HasKeyboardHandlerComponents, DialogHandler {
  static const double worldWidth = 2000.0;

  static const double _cameraFollowSharpness = 5.0;
  static const double _cameraDeadZonePx = 10.0;

  late final OlyaPlayer olya = OlyaPlayer();
  late SpriteComponent noiseEffect;

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

  String _storyResultTitle = '';
  String _storyResultDescription = '';
  final List<String> _selectedTools = [];

  String get storyResultTitle => _storyResultTitle;
  String get storyResultDescription => _storyResultDescription;
  List<String> get selectedTools => List.unmodifiable(_selectedTools);

  final currentNodeNotifier = ValueNotifier<DialogNode?>(null);
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

    await loadScene(ClassroomScene());

    add(noiseEffect);

    overlays.add('MainMenu');
  }

  Future<void> loadScene(GameScene scene) async {
    _isSceneTransitioning = true;

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
      worldRoot.scale = Vector2.all(_zoom);
    }

    if (olya.parent == null) {
      await worldRoot.add(olya);
    }
    olya.priority = 10;

    olya.position = _sceneSpawnPoint(scene);
    _snapCameraToPlayer();

    _isSceneTransitioning = false;
  }

  void _updateClassroomZoom() {
    final scene = _classroomScene;
    if (scene == null || !scene.isLoaded) return;
    final h = scene.bgHeight;
    if (h <= 0) return;
    _zoom = size.y / h;
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

  void startNewGameSurveyFlow() {
    _startGameAfterSurvey = true;
    overlays.remove('MainMenu');
    overlays.add('Survey');
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

    overlays.remove('Dialog');
    overlays.remove('CalmMap');
    overlays.remove('PathChoice');

    await loadScene(ClassroomScene());

    if (token != _sessionToken) return;

    freezeForPathChoice = true;
    worldRoot.scale = Vector2.all(1.0);
    olya.opacity = 0;
    _classroomScene?.showPathImage();

    overlays.add('PathChoice');
  }

  void showPathBackground() {
    _classroomScene?.showPathImage();
  }

  void previewPathOverlay(int index) {
    final asset = index == 0
        ? 'scenes/classroom/first-path-overlay.png'
        : 'scenes/classroom/second-path-overlay.png';
    _classroomScene?.showPathOverlay(asset);
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
    _storyResultTitle = l.map_of_calm_olya;
    _storyResultDescription = l.first_path_description;
    _finishPathChoice();
  }

  void chooseSecondPath(BuildContext context) {
    if (!context.mounted) return;
    final l = AppLocalizations.of(context)!;
    _selectedTools.add(l.classroom);
    _selectedTools.add(l.path_second);
    _storyResultTitle = l.map_of_calm_olya;
    _storyResultDescription = l.second_path_description;
    _finishPathChoice();
  }

  void _finishPathChoice() {
    sceneIndex = 2;
    overlays.remove('PathChoice');
    olya.opacity = 1;
    _classroomScene?.showClassroomImage();
    freezeForPathChoice = false;
    _updateClassroomZoom();
    olya.position = _sceneSpawnPoint(currentScene!);
    _snapCameraToPlayer();
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
  }
}
