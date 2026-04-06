import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:emvia/l10n/app_localizations_gen.dart';

import 'survey_service.dart';
import 'components/fade_overlay.dart';
import 'characters/base_player.dart';
import 'characters/olya/olya_player.dart';
import 'scenes/game_scene.dart';
import 'scenes/classroom_scene.dart';
import 'scenes/corridor_scene.dart';
import 'scenes/stress/stress_scene.dart';
import 'scenes/stage_scene.dart';
import 'utils/pos_util.dart';
import 'scenes/notebook_scene.dart';
import 'scenes/path/path_choice_scene.dart';
import 'scenes/survey_scene.dart';
import 'dialog/dialog_model.dart';
import 'backpack/backpack_inventory.dart';
import 'backpack/backpack_item.dart';

import 'dialog/dialog_handler.dart';
import 'emvia_types.dart';

import 'managers/camera_manager.dart';
import 'managers/game_preferences_manager.dart';
import 'managers/game_session_manager.dart';
import 'managers/transition_manager.dart';

class EmviaGame extends FlameGame
    with TapCallbacks, HasKeyboardHandlerComponents, DialogHandler {
  static const double worldWidth = 2000.0;

  final SurveyService _surveyService = SurveyService();
  final GamePreferencesManager _preferences = GamePreferencesManager();
  final GameSessionManager _session = GameSessionManager();

  late final CameraManager cameraManager;
  late final TransitionManager transitionManager;

  BasePlayer? _player;
  BasePlayer get player => _player!;
  bool get isPlayerInitialized => _player != null;

  late FadeOverlay fadeOverlay;
  final PositionComponent worldRoot = PositionComponent();

  GameScene? currentScene;
  ClassroomScene? classroomScene;

  bool isFrozen = false;
  bool hasTriggeredStressScene = false;
  double? _savedCorridorReturnX;
  bool _hasShownCorridorStressIntro = false;
  bool _isCorridorStressIntroActive = false;

  late final BackpackInventory backpack = BackpackInventory();

  double _mobileMoveX = 0;

  DialogTree? currentTree;
  ValueNotifier<bool> mobileControlsVisible = ValueNotifier<bool>(false);

  EmviaGame() {
    cameraManager = CameraManager(this);
    transitionManager = TransitionManager(this);
  }

  int get sceneIndex => _session.sceneIndex;
  set sceneIndex(int value) => _session.sceneIndex = value;

  int get stressLevel => _session.stressLevel;
  set stressLevel(int value) => _session.stressLevel = value;

  ValueNotifier<int> get stressNotifier => _session.stressNotifier;

  PlayableCharacter get selectedCharacter => _session.selectedCharacter;
  set selectedCharacter(PlayableCharacter value) =>
      _session.selectedCharacter = value;

  SurveyProfile get surveyProfile => _session.surveyProfile;
  set surveyProfile(SurveyProfile value) => _session.surveyProfile = value;

  double get volume => _preferences.volume;
  set volume(double value) => _preferences.volume = value;

  bool get soundEnabled => _preferences.soundEnabled;
  set soundEnabled(bool value) => _preferences.soundEnabled = value;

  bool get soundQuestionAnswered => _preferences.soundQuestionAnswered;
  set soundQuestionAnswered(bool value) =>
      _preferences.soundQuestionAnswered = value;

  List<String> get selectedTools => _session.selectedTools;

  ValueNotifier<DialogNode?> get currentNodeNotifier =>
      _session.currentNodeNotifier;
  ValueNotifier<PathDetailInfo?> get pathDetailNotifier =>
      _session.pathDetailNotifier;

  DialogNode? get currentNode => _session.currentNode;
  set currentNode(DialogNode? value) => _session.currentNode = value;

  bool get isBackpackOpen => overlays.isActive('Backpack');
  bool get isDebugOpen => overlays.isActive('Debug');

  bool debugTapEnabled = false;

  // bool get isMobilePlatform => true;

  bool get isMobilePlatform {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  bool get isCorridorStressIntroActive => _isCorridorStressIntroActive;

  @override
  Future<void> onLoad() async {
    await _preferences.load();

    _initializePlayer();
    _configureWorldRoot();

    add(worldRoot);
    fadeOverlay = FadeOverlay();
    add(fadeOverlay);

    await _loadMenuScene();

    overlays.add('MainMenu');
  }

  void _initializePlayer() {
    switch (selectedCharacter) {
      case PlayableCharacter.olya:
        _player = OlyaPlayer();
        break;
      default:
        _player = OlyaPlayer();
    }
  }

  void _configureWorldRoot() {
    worldRoot
      ..scale = Vector2.all(cameraManager.zoom)
      ..anchor = Anchor.topLeft;
  }

  Future<void> _loadMenuScene() async {
    await loadScene(
      SurveyScene(),
      onFullOpacity: () {
        player.opacity = 0;
      },
    );
  }

  Future<void> loadScene(
    GameScene scene, {
    void Function()? onFullOpacity,
  }) async {
    await transitionManager.loadScene(scene, onFullOpacity: onFullOpacity);
  }

  Future<void> reloadCurrentScene() async {
    final scene = currentScene;
    if (scene == null) return;

    final savedSceneIndex = sceneIndex;
    overlays.remove('Debug');

    if (scene is ClassroomScene) {
      await loadScene(
        ClassroomScene(),
        onFullOpacity: () {
          sceneIndex = savedSceneIndex;
        },
      );
      return;
    } else if (scene is CorridorScene) {
      await loadScene(
        CorridorScene(),
        onFullOpacity: () {
          sceneIndex = savedSceneIndex;
        },
      );
      return;
    } else if (scene is StageScene) {
      await loadScene(
        StageScene(),
        onFullOpacity: () {
          sceneIndex = savedSceneIndex;
          player.opacity = 1;
        },
      );
      return;
    } else if (scene is StressScene) {
      await loadScene(
        StressScene(),
        onFullOpacity: () {
          sceneIndex = savedSceneIndex;
        },
      );
      return;
    } else if (scene is PathChoiceScene) {
      await loadScene(
        PathChoiceScene(),
        onFullOpacity: () {
          sceneIndex = savedSceneIndex;
        },
      );
      return;
    } else if (scene is SurveyScene) {
      await loadScene(
        SurveyScene(),
        onFullOpacity: () {
          sceneIndex = savedSceneIndex;
        },
      );
      return;
    } else if (scene is NotebookScene) {
      await loadScene(
        NotebookScene(),
        onFullOpacity: () {
          sceneIndex = savedSceneIndex;
        },
      );
      return;
    }

    currentScene?.redrawScene();
  }

  Future<void> goToCorridor() async {
    if (stressLevel >= 30 && !_hasShownCorridorStressIntro) {
      _hasShownCorridorStressIntro = true;
      _isCorridorStressIntroActive = true;
    }

    await loadScene(
      CorridorScene(),
      onFullOpacity: () {
        sceneIndex = 4;
        overlays.remove('TapGame');
      },
    );

    if (_isCorridorStressIntroActive) {
      hideMobileControls();
    }
  }

  Future<void> transitionToCorridor() async {
    await loadScene(
      CorridorScene(),
      onFullOpacity: () {
        overlays.remove('TapGame');
        restoreCorridorPosition();
      },
    );
    sceneIndex = 4;
    player.opacity = 1;
  }

  double currentSceneWorldWidth() {
    final scene = currentScene;
    return scene?.worldWidthForViewport(size) ?? worldWidth;
  }

  void startGame() {
    if (selectedCharacter == PlayableCharacter.olya) {
      _startGameFlow();
    }
  }

  Future<void> _startGameFlow() async {
    final token = _session.beginSession();
    final profile = await _surveyService.getProfile();

    _session.resetForNewJourney(profile: profile);
    backpack.clear();
    hasTriggeredStressScene = false;

    _clearGameplayOverlays();

    await loadScene(
      ClassroomScene(),
      onFullOpacity: () {
        player.opacity = 0;
      },
    );

    if (!_session.isCurrentSession(token)) return;
  }

  void finishJourney() {
    if (_session.journeyCompleted) return;
    _session.journeyCompleted = true;
    hideMobileControls();
    pauseEngine();
    overlays.add('CalmMap');
  }

  Future<void> returnToMainMenuAfterJourney() async {
    overlays.remove('CalmMap');
    if (paused) {
      resumeEngine();
    }
    _prepareReturnToMainMenu();
    await _loadMenuScene();
    openMainMenu();
  }

  Future<void> returnToMainMenuAfterSurvey() async {
    overlays.remove('Survey');
    _prepareReturnToMainMenu();
    await _loadMenuScene();
    openMainMenu();
  }

  void _prepareReturnToMainMenu() {
    stressLevel = 100;
    sceneIndex = 0;
    hasTriggeredStressScene = false;
    _hasShownCorridorStressIntro = false;
    _isCorridorStressIntroActive = false;
    hideMobileControls();
    overlays.remove('Stress');
    overlays.remove('TapGame');
  }

  void initializeInventory(BuildContext context) {
    if (backpack.items.isNotEmpty) return;
    for (final item in BackpackItem.initialItems(context)) {
      backpack.addItem(item);
    }
  }

  void _clearGameplayOverlays() {
    overlays.remove('Dialog');
    overlays.remove('CalmMap');
    overlays.remove('PathChoice');
    overlays.remove('Backpack');
    currentNode = null;
    hidePathDetail();
  }

  void setDebugTapEnabled(bool enabled) {
    debugTapEnabled = enabled;
  }

  void toggleBackpack() {
    if (!_canToggleBackpack()) return;
    if (isBackpackOpen) {
      overlays.remove('Backpack');
    } else {
      overlays.remove('Dialog');
      currentNode = null;
      overlays.add('Backpack');
    }
  }

  void equipTool(String toolId) {
    _session.toggleSelectedTool(toolId);
  }

  void toggleDebug() {
    if (isDebugOpen) {
      overlays.remove('Debug');
    } else {
      overlays.add('Debug');
    }
  }

  bool _canToggleBackpack() {
    if (sceneIndex == 0) return false;
    if (transitionManager.isTransitioning) return false;
    if (_isCorridorStressIntroActive) return false;
    if (overlays.isActive('MainMenu')) {
      return false;
    }
    if (overlays.isActive('Survey')) {
      return false;
    }
    return true;
  }

  void setMobileMoveX(double direction) {
    if (isFrozen) return;
    _mobileMoveX = direction.clamp(-1.0, 1.0);
    player.setMobileDirection(_mobileMoveX);
  }

  void showMobileControls() {
    if (!isMobilePlatform) return;
    if (currentScene is! CorridorScene) return;
    if (!overlays.isActive('MobileControls')) {
      overlays.add('MobileControls');
    }
    mobileControlsVisible.value = true;
  }

  void hideMobileControls() {
    if (!mobileControlsVisible.value) return;
    mobileControlsVisible.value = false;
    setMobileMoveX(0);
  }

  void openMainMenu() {
    overlays.remove('Backpack');
    hideMobileControls();
    overlays.add('MainMenu');
  }

  void closeMainMenu() {
    overlays.remove('MainMenu');
    if (sceneIndex == 0 && currentScene is CorridorScene) {
      player.opacity = 1;
    }
    if (!paused && sceneIndex > 0) {
      showMobileControls();
    }
  }

  bool consumeStartGameAfterSurvey() => _session.consumeStartGameAfterSurvey();

  bool isCharacterUnlocked(PlayableCharacter character) {
    return character == PlayableCharacter.olya;
  }

  void selectCharacter(PlayableCharacter character) {
    if (!isCharacterUnlocked(character)) return;
    selectedCharacter = character;
  }

  void startNewGameSurveyFlow() async {
    await _surveyService.clearAiResults();
    _session.markStartGameAfterSurvey();
    closeMainMenu();
    await loadScene(
      SurveyScene(),
      onFullOpacity: () {
        overlays.add('Survey');
      },
    );
  }

  void startGameSkippingSurvey() {
    _startGameFlow();
  }

  Future<void> skipToCorridor() async {
    final token = _session.beginSession();
    final profile = await _surveyService.getProfile();

    _session.resetForNewJourney(profile: profile);
    backpack.clear();
    hasTriggeredStressScene = false;

    overlays.remove('MainMenu');
    overlays.remove('Survey');
    overlays.remove('CalmMap');
    overlays.remove('TapGame');
    overlays.remove('Backpack');
    overlays.remove('Stress');

    _clearGameplayOverlays();

    await loadScene(
      CorridorScene(),
      onFullOpacity: () {
        sceneIndex = 4;
        overlays.remove('TapGame');
        player.opacity = 1;
      },
    );

    if (!_session.isCurrentSession(token)) return;
  }

  void showPathDetail(PathDetailInfo info) {
    _session.pathDetail = info;
    overlays.add('PathDetail');
  }

  void hidePathDetail() {
    overlays.remove('PathDetail');
    _session.pathDetail = null;
  }

  void clearPathSelection() {
    if (currentScene is PathChoiceScene) {
      (currentScene as PathChoiceScene).clearSelection();
    }
  }

  void showPathBackground() {
    classroomScene?.showPathImage();
  }

  void clearPathOverlay() {
    classroomScene?.clearPathOverlay();
  }

  void restoreClassroomBackground() {
    classroomScene?.showClassroomImage();
  }

  void chooseFirstPath(BuildContext context) {
    _confirmSelectedPath(context, 0);
  }

  void chooseSecondPath(BuildContext context) {
    _confirmSelectedPath(context, 1);
  }

  void chooseThirdPath(BuildContext context) {
    _confirmSelectedPath(context, 2);
  }

  void _confirmSelectedPath(BuildContext context, int index) {
    if (!context.mounted) return;
    final l = AppLocalizationsGen.of(context)!;
    _recordPathChoice(l, index);
    _finishPathChoice();
  }

  void _finishPathChoice() {
    sceneIndex = 2;
    player.opacity = 1;
    classroomScene?.showClassroomImage();
    classroomScene?.clearMarks();
    transitionManager.updateClassroomZoom();
    cameraManager.snapToPlayer(force: true);

    Future.delayed(const Duration(seconds: 1), () {
      goToCorridor();
    });
  }

  Future<void> applyPathChoice(int index, BuildContext context) async {
    final l = AppLocalizationsGen.of(context)!;
    _recordPathChoice(l, index);

    await goToCorridor();
  }

  void _recordPathChoice(AppLocalizationsGen l, int index) {
    _session.addSelectedTool(l.classroom);
    _session.addSelectedTool(_pathLabelForIndex(l, index));
  }

  String _pathLabelForIndex(AppLocalizationsGen l, int index) {
    switch (index) {
      case 0:
        return l.path_first;
      case 1:
        return l.path_second;
      default:
        return l.path_third;
    }
  }

  Future<void> _transitionToStressScene() async {
    if (transitionManager.isTransitioning) return;
    await loadScene(
      StressScene(),
      onFullOpacity: () {
        sceneIndex = 3;
        player.opacity = 0;
      },
    );
  }

  Future<void> _transitionToStageScene() async {
    if (transitionManager.isTransitioning) return;
    await loadScene(
      StageScene(),
      onFullOpacity: () {
        sceneIndex = 6;
        player.opacity = 1;
      },
    );
  }

  void completeCorridorStressIntro() {
    if (!_isCorridorStressIntroActive) return;
    _isCorridorStressIntroActive = false;
    isFrozen = false;
    showMobileControls();
  }

  void playerToCorridorEntrance() {
    player.position.x = player.size.x / 2 + 10;
    cameraManager.snapToPlayer(force: true);
  }

  void saveCorridorReturnPosition(double x) {
    _savedCorridorReturnX = x;
  }

  void restoreCorridorPosition() {
    final savedX = _savedCorridorReturnX;
    _savedCorridorReturnX = null;

    if (savedX == null) {
      playerToCorridorEntrance();
      return;
    }

    final minX = player.size.x / 2;
    final maxX = worldRoot.size.x - player.size.x / 2;
    player.position.x = savedX.clamp(minX, maxX).toDouble();
    if (currentScene != null) {
      player.position.y = currentScene!.spawnPoint(size, worldRoot.size).y;
    }
    cameraManager.snapToPlayer(force: true);
  }

  @override
  void update(double dt) {
    dt = dt.clamp(0, 0.05);
    super.update(dt);

    if (_player == null || _player!.parent == null) return;

    if (currentScene is ClassroomScene && _hasReachedRightSceneEdge()) {
      _transitionToStressScene();
    }

    if (currentScene is CorridorScene &&
        !_session.journeyCompleted &&
        _hasReachedRightSceneEdge()) {
      _transitionToStageScene();
    }

    cameraManager.update(dt);
  }

  bool _hasReachedRightSceneEdge() {
    final scene = currentScene;
    if (scene != null && scene.background.size.x > 0) {
      final uvTarget = getWorldPosFromUV(
        Vector2(0.9, 0.5),
        scene.background.position,
        scene.background.size,
      );
      final thresholdX = uvTarget.x - player.size.x / 2;
      return player.position.x >= thresholdX;
    }
    
    return false;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    final scene = currentScene;
    if (scene is ClassroomScene && scene.isLoaded) {
      transitionManager.updateClassroomZoom();
    } else {
      worldRoot.size = Vector2(currentSceneWorldWidth(), size.y);
    }

    if (_player != null && _player!.parent != null) {
      _clampPlayerToWorld(scene);
    }

    cameraManager.snapToPlayer();
  }

  void _clampPlayerToWorld(GameScene? scene) {
    final minX = player.size.x / 2;
    final maxX = worldRoot.size.x - player.size.x / 2;

    if (minX <= maxX) {
      player.position.x = player.position.x.clamp(minX, maxX).toDouble();
    } else {
      player.position.x = worldRoot.size.x / 2;
    }

    if (scene != null) {
      player.position.y = scene.spawnPoint(size, worldRoot.size).y;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (debugTapEnabled) {
      final local = event.localPosition;
      final worldOffset = worldRoot.position;
      final zoom = worldRoot.scale.x;
      final worldPos = (local - worldOffset) / zoom;

      String bgInfo = 'background not ready';
      if (currentScene != null &&
          currentScene!.background.sprite != null &&
          currentScene!.background.size.x > 0 &&
          currentScene!.background.size.y > 0) {
        final bgPos = currentScene!.background.position;
        final bgSize = currentScene!.background.size;
        final u = (worldPos.x - bgPos.x) / bgSize.x;
        final v = (worldPos.y - bgPos.y) / bgSize.y;
        bgInfo = 'uv=(${u.toStringAsFixed(4)}, ${v.toStringAsFixed(4)})';
      }

      debugPrint(
        'TAP $bgInfo screen=(${local.x.toStringAsFixed(1)}, ${local.y.toStringAsFixed(1)}) world=(${worldPos.x.toStringAsFixed(1)}, ${worldPos.y.toStringAsFixed(1)})',
      );
    }

    currentScene?.onTapDown(event);
  }

  Vector2 sceneSpawnPoint(
    GameScene scene,
    Vector2 screenSize,
    PositionComponent root,
  ) {
    return scene.spawnPoint(screenSize, root.size);
  }
}
