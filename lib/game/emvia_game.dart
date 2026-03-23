import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:emvia/l10n/app_localizations_gen.dart';

import 'survey_service.dart';
import 'components/fade_overlay.dart';
import 'components/player.dart';
import 'scenes/game_scene.dart';
import 'scenes/classroom_scene.dart';
import 'scenes/corridor_scene.dart';
import 'scenes/stress_scene.dart';
import 'scenes/path_choice_scene.dart';
import 'scenes/survey_scene.dart';
import 'dialog_model.dart';
import 'inventory/backpack_inventory.dart';
import 'inventory/backpack_item.dart';

import 'mixins/dialog_handler.dart';
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

  EmviaGame() {
    cameraManager = CameraManager(this);
    transitionManager = TransitionManager(this);
  }

  late final OlyaPlayer olya = OlyaPlayer();
  late FadeOverlay fadeOverlay;

  final PositionComponent worldRoot = PositionComponent();

  late final CameraManager cameraManager;
  late final TransitionManager transitionManager;

  GameScene? currentScene;
  ClassroomScene? classroomScene;

  bool _isFrozen = false;
  bool get isFrozen => _isFrozen;
  set isFrozen(bool value) {
    if (_isFrozen == value) return;
    _isFrozen = value;
    if (olya.isMounted) {
      olya.isFrozen = value;
    }
  }

  bool hasTriggeredStressScene = false;
  double? _savedCorridorReturnX;
  bool _hasShownCorridorStressIntro = false;
  bool _isCorridorStressIntroActive = false;

  int get sceneIndex => _session.sceneIndex;
  set sceneIndex(int value) => _session.sceneIndex = value;

  int get stressLevel => _session.stressLevel;
  set stressLevel(int value) => _session.stressLevel = value;

  ValueNotifier<int> get stressNotifier => _session.stressNotifier;

  bool get isCorridorStressIntroActive => _isCorridorStressIntroActive;

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

  late final BackpackInventory backpack = BackpackInventory();

  double _mobileMoveX = 0;

  List<String> get selectedTools => _session.selectedTools;

  ValueNotifier<DialogNode?> get currentNodeNotifier =>
      _session.currentNodeNotifier;
  ValueNotifier<PathDetailInfo?> get pathDetailNotifier =>
      _session.pathDetailNotifier;

  DialogNode? get currentNode => _session.currentNode;
  set currentNode(DialogNode? value) => _session.currentNode = value;

  DialogTree? currentTree;

  @override
  Future<void> onLoad() async {
    await _preferences.load();

    _configureWorldRoot();

    add(worldRoot);
    fadeOverlay = FadeOverlay();
    add(fadeOverlay);

    await _loadMenuScene();

    overlays.add('MainMenu');
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
        olya.opacity = 0;
      },
    );
  }

  void initializeInventory(BuildContext context) {
    if (backpack.items.isNotEmpty) return;
    for (final item in BackpackItem.initialItems(context)) {
      backpack.addItem(item);
    }
  }

  Future<void> loadScene(
    GameScene scene, {
    void Function()? onFullOpacity,
  }) async {
    await transitionManager.loadScene(scene, onFullOpacity: onFullOpacity);
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
      isFrozen = true;
      hideMobileControls();
    } else {
      isFrozen = false;
      showMobileControls();
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
    olya.opacity = 1;
    showMobileControls();
    isFrozen = false;
  }

  void _updateClassroomZoom() {
    transitionManager.updateClassroomZoom();
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

  bool get isMobilePlatform {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  bool get isBackpackOpen => overlays.isActive('Backpack');
  bool get isDebugOpen => overlays.isActive('Debug');

  bool debugTapEnabled = false;

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
    if (overlays.isActive('MainMenu') || overlays.isActive('Pause')) {
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

  Future<void> startNewGameSurveyFlow() async {
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

  void closeMainMenu() {
    overlays.remove('MainMenu');
    if (sceneIndex == 0 && currentScene is CorridorScene) {
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

  bool consumeStartGameAfterSurvey() => _session.consumeStartGameAfterSurvey();

  bool isCharacterUnlocked(PlayableCharacter character) {
    return character == PlayableCharacter.olya;
  }

  void selectCharacter(PlayableCharacter character) {
    if (!isCharacterUnlocked(character)) return;
    selectedCharacter = character;
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
        olya.opacity = 0;
        isFrozen = true;
        showMobileControls();
      },
    );

    if (!_session.isCurrentSession(token)) return;
  }

  void _clearGameplayOverlays() {
    overlays.remove('Dialog');
    overlays.remove('CalmMap');
    overlays.remove('PathChoice');
    overlays.remove('Backpack');
    currentNode = null;
    hidePathDetail();
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
    olya.opacity = 1;
    isFrozen = false;
    classroomScene?.showClassroomImage();
    classroomScene?.clearMarks();
    _updateClassroomZoom();
    cameraManager.snapToPlayer(force: true);

    Future.delayed(const Duration(seconds: 1), () {
      goToCorridor();
    });
  }

  Future<void> applyPathChoice(int index, BuildContext context) async {
    final l = AppLocalizationsGen.of(context)!;
    _recordPathChoice(l, index);

    isFrozen = false;
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
        olya.opacity = 0;
      },
    );
  }

  void finishOlyaJourney() {
    if (_session.journeyCompleted) return;
    _session.journeyCompleted = true;
    isFrozen = true;
    hideMobileControls();
    pauseEngine();
    overlays.add('CalmMap');
  }

  Future<void> returnToMainMenuAfterJourney() async {
    overlays.remove('CalmMap');
    if (paused) {
      resumeEngine();
    }
    isFrozen = false;
    _prepareReturnToMainMenu();
    await _loadMenuScene();
    openMainMenu();
  }

  Future<void> returnToMainMenuAfterSurvey() async {
    overlays.remove('Survey');
    isFrozen = true;
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

  void completeCorridorStressIntro() {
    if (!_isCorridorStressIntroActive) return;
    _isCorridorStressIntroActive = false;
    isFrozen = false;
    showMobileControls();
  }

  void playerToCorridorEntrance() {
    olya.position.x = olya.size.x / 2 + 10;
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

    final minX = olya.size.x / 2;
    final maxX = worldRoot.size.x - olya.size.x / 2;
    olya.position.x = savedX.clamp(minX, maxX).toDouble();
    if (currentScene != null) {
      olya.position.y = currentScene!.spawnPoint(size, worldRoot.size).y;
    }
    cameraManager.snapToPlayer(force: true);
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

    if (currentScene is ClassroomScene && _hasReachedRightSceneEdge()) {
      _transitionToStressScene();
    }

    if (currentScene is CorridorScene &&
        !_session.journeyCompleted &&
        _hasReachedRightSceneEdge()) {
      finishOlyaJourney();
    }

    cameraManager.update(dt);
  }

  bool _hasReachedRightSceneEdge() {
    return olya.position.x >= worldRoot.size.x - olya.size.x / 2 - 10;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    final scene = currentScene;
    if (scene is ClassroomScene && scene.isLoaded) {
      _updateClassroomZoom();
    } else {
      worldRoot.size = Vector2(currentSceneWorldWidth(), size.y);
    }

    if (olya.parent != null) {
      _clampPlayerToWorld(scene);
    }

    cameraManager.snapToPlayer();
  }

  void _clampPlayerToWorld(GameScene? scene) {
    final minX = olya.size.x / 2;
    final maxX = worldRoot.size.x - olya.size.x / 2;

    if (minX <= maxX) {
      olya.position.x = olya.position.x.clamp(minX, maxX).toDouble();
    } else {
      olya.position.x = worldRoot.size.x / 2;
    }

    if (scene != null) {
      olya.position.y = scene.spawnPoint(size, worldRoot.size).y;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    final pos = event.localPosition;
    if (!overlays.isActive('Pause') && !overlays.isActive('MainMenu')) {
      if (pos.x > size.x - 60 && pos.y < 60) {
        pauseGame();
      }
    }

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
