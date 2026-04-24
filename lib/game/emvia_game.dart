import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'utils/survey_service.dart';
import 'components/fade_overlay.dart';
import 'characters/base_player.dart';
import 'characters/character_factory.dart';
import 'scenes/game_scene.dart';
import 'scenes/olya/classroom_scene.dart';
import 'scenes/olya/stress/stress_scene.dart';
import 'scenes/olya/path/path_choice_scene.dart';
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
import 'managers/overlay_manager.dart';
import 'managers/navigation_manager.dart';
import 'managers/game_state/game_state.dart';

class EmviaGame extends FlameGame
    with TapCallbacks, HasKeyboardHandlerComponents, DialogHandler {
  static const double worldWidth = 2000.0;

  final SurveyService surveyService = SurveyService();
  final GamePreferencesManager preferences = GamePreferencesManager();
  final GameSessionManager session = GameSessionManager();
  late GameState gameState;
  OlyaGameState? get olyaState => gameState is OlyaGameState ? gameState as OlyaGameState : null;
  LiamGameState? get liamState => gameState is LiamGameState ? gameState as LiamGameState : null;

  late final CameraManager cameraManager;
  late final TransitionManager transitionManager;
  late final OverlayManager overlayManager;
  late final NavigationManager navigationManager;

  BasePlayer? _player;
  BasePlayer get player => _player!;
  bool get isPlayerInitialized => _player != null;

  late FadeOverlay fadeOverlay;
  final PositionComponent worldRoot = PositionComponent();

  GameScene? currentScene;

  late final BackpackInventory backpack = BackpackInventory();

  DialogTree? currentTree;

  EmviaGame() {
    cameraManager = CameraManager(this);
    transitionManager = TransitionManager(this);
    overlayManager = OverlayManager(this);
    navigationManager = NavigationManager(this);
  }

  int get sceneIndex => session.sceneIndex;
  set sceneIndex(int value) {
    session.sceneIndex = value;
    session.save();
  }

  int get stressLevel => session.stressLevel;
  set stressLevel(int value) {
    session.stressLevel = value;
    session.save();
  }

  ValueNotifier<int> get stressNotifier => session.stressNotifier;

  PlayableCharacter get selectedCharacter => session.selectedCharacter;
  set selectedCharacter(PlayableCharacter value) {
    session.selectedCharacter = value;
    session.save();
  }

  SurveyProfile get surveyProfile => session.surveyProfile;
  set surveyProfile(SurveyProfile value) {
    session.surveyProfile = value;
    session.save();
  }

  double get volume => preferences.volume;
  set volume(double value) => preferences.volume = value;

  bool get soundEnabled => preferences.soundEnabled;
  set soundEnabled(bool value) => preferences.soundEnabled = value;

  bool get soundQuestionAnswered => preferences.soundQuestionAnswered;
  set soundQuestionAnswered(bool value) =>
      preferences.soundQuestionAnswered = value;

  List<String> get selectedTools => session.selectedTools;

  ValueNotifier<DialogNode?> get currentNodeNotifier =>
      session.currentNodeNotifier;
  ValueNotifier<PathDetailInfo?> get pathDetailNotifier =>
      session.pathDetailNotifier;

  DialogNode? get currentNode => session.currentNode;
  set currentNode(DialogNode? value) => session.currentNode = value;

  ValueNotifier<StageItemCardData?> get selectedStageItemNotifier =>
      overlayManager.selectedStageItemNotifier;

  bool get isBackpackOpen => overlayManager.isBackpackOpen;
  bool get isDebugOpen => overlayManager.isDebugOpen;
  bool get isStageItemCardOpen => overlayManager.isStageItemCardOpen;

  void showStageItemCard(StageItemCardData item) =>
      overlayManager.showStageItemCard(item);

  void hideStageItemCard() => overlayManager.hideStageItemCard();

  Future<void> useStageItem(StageItemCardData item) async {
    if (!isPlayerInitialized) return;

    gameState.isFrozen = true;
    overlayManager.hideMobileControls();
    overlays.add('CalmingEffect');
    overlayManager.hideStageItemCard();

    cameraManager.animateZoomTo(1.45);
    cameraManager.beginFocusOnPlayer();

    await player.interactWithItem(item.id);

    stressLevel = (stressLevel - 10).clamp(0, 100);

    overlays.remove('CalmingEffect');
    cameraManager.animateZoomTo(1.1);
    cameraManager.endFocusOnPlayer();
    gameState.isFrozen = false;
    overlayManager.showMobileControls();
  }

  bool debugTapEnabled = false;
  bool _spoofMobile = false;

  bool get isMobilePlatform {
    if (_spoofMobile) return true;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  bool get isMobileSpoofed => _spoofMobile;

  void toggleMobileSpoof() {
    _spoofMobile = !_spoofMobile;
    if (_spoofMobile) {
      overlayManager.showMobileControls();
    } else {
      overlayManager.hideMobileControls();
    }
  }

  @override
  Future<void> onLoad() async {
    await preferences.load();
    await session.load();

    _initializePlayer();
    _configureWorldRoot();

    add(worldRoot);
    fadeOverlay = FadeOverlay();
    add(fadeOverlay);

    await loadMenuScene();

    overlays.add('MainMenu');
  }

  void _initializePlayer() {
    _player = CharacterFactory.createPlayer(selectedCharacter);
    if (selectedCharacter == PlayableCharacter.liam) {
      gameState = LiamGameState();
    } else {
      gameState = OlyaGameState();
    }
  }

  void _configureWorldRoot() {
    worldRoot
      ..scale = Vector2.all(cameraManager.zoom)
      ..anchor = Anchor.topLeft;
  }

  Future<void> loadMenuScene() async {
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

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.f3 ||
          (event.logicalKey == LogicalKeyboardKey.keyD &&
              keysPressed.contains(LogicalKeyboardKey.controlLeft))) {
        overlayManager.toggleDebug();
        return KeyEventResult.handled;
      }

      if (event.logicalKey == LogicalKeyboardKey.escape ||
          event.logicalKey == LogicalKeyboardKey.keyP) {
        if (sceneIndex > 0 && !overlays.isActive('MainMenu')) {
          if (paused) {
            resumeGame();
          } else {
            pauseGame();
          }
          return KeyEventResult.handled;
        }
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }

  void pauseGame() {
    if (paused) return;
    pauseEngine();
    overlays.add('PauseMenu');
    overlayManager.hideMobileControls();
  }

  void resumeGame() {
    if (!paused) return;
    resumeEngine();
    overlays.remove('PauseMenu');
    if (sceneIndex > 0) {
      overlayManager.showMobileControls();
    }
  }

  Future<void> continueGame() async {
    overlayManager.clearGameplayOverlays();
    _initializePlayer();

    switch (sceneIndex) {
      case 1:
        await loadScene(
          ClassroomScene(),
          onFullOpacity: () {
            player.opacity = 0;
          },
        );
        break;
      case 2:
        await loadScene(PathChoiceScene(), onFullOpacity: () {});
        break;
      case 3:
        await loadScene(StressScene(), onFullOpacity: () {});
        break;
      case 4:
        await navigationManager.transitionToCorridor();
        break;
      case 6:
        await navigationManager.loadStageScene();
        break;
      default:
        await navigationManager.startGameFlow();
    }
    overlayManager.closeMainMenu();
  }

  Future<void> reloadCurrentScene() => navigationManager.reloadCurrentScene();

  Future<void> goToCorridor() => navigationManager.goToCorridor();

  Future<void> transitionToCorridor() =>
      navigationManager.transitionToCorridor();

  Future<void> playRightSideScene() => navigationManager.playRightSideScene();

  Future<void> loadStageScene() => navigationManager.loadStageScene();

  double currentSceneWorldWidth() {
    final scene = currentScene;
    return scene?.worldWidthForViewport(size) ?? worldWidth;
  }

  void startGame() {
    navigationManager.startGameFlow();
  }

  void finishJourney() {
    if (session.journeyCompleted) return;
    session.journeyCompleted = true;
    overlayManager.hideMobileControls();
    pauseEngine();
    overlays.add('CalmMap');
  }

  Future<void> returnToMainMenuAfterJourney() =>
      navigationManager.returnToMainMenuAfterJourney();

  Future<void> returnToMainMenuAfterSurvey() =>
      navigationManager.returnToMainMenuAfterSurvey();

  void initializeInventory(BuildContext context) {
    if (backpack.items.isNotEmpty) return;
    for (final item in BackpackItem.initialItems(context)) {
      backpack.addItem(item);
    }
  }

  void setDebugTapEnabled(bool enabled) {
    debugTapEnabled = enabled;
  }

  void toggleBackpack() => overlayManager.toggleBackpack();

  void equipTool(String toolId) {
    session.toggleSelectedTool(toolId);
  }

  void unequipTool(String toolId) {
    session.removeSelectedTool(toolId);
  }

  void toggleDebug() => overlayManager.toggleDebug();

  void toggleCameraMode() {
    if (selectedCharacter != PlayableCharacter.liam) return;
    final state = liamState;
    if (state == null) return;
    
    if (state.isCameraMode) {
      state.isCameraMode = false;
      overlays.remove('Camera');
      gameState.isFrozen = false;
    } else {
      state.isCameraMode = true;
      overlays.add('Camera');
      gameState.isFrozen = true;
    }
  }

  void setMobileMoveX(double direction) {
    if (gameState.isFrozen) return;
    gameState.mobileMoveX = direction.clamp(-1.0, 1.0);
    player.setMobileDirection(gameState.mobileMoveX);
  }

  void showMobileControls() => overlayManager.showMobileControls();

  void hideMobileControls() => overlayManager.hideMobileControls();

  void openMainMenu() => overlayManager.openMainMenu();

  Future<void> returnToMainMenu() async {
    await fadeOverlay.fadeIn(0.4);
    resumeEngine();
    overlays.remove('PauseMenu');
    navigationManager.prepareReturnToMainMenu();
    await loadMenuScene();
    openMainMenu();
    await fadeOverlay.fadeOut(0.4);
  }

  void closeMainMenu() => overlayManager.closeMainMenu();

  bool consumeStartGameAfterSurvey() => session.consumeStartGameAfterSurvey();

  bool isCharacterUnlocked(PlayableCharacter character) {
    return character == PlayableCharacter.olya ||
        character == PlayableCharacter.liam;
  }

  void selectCharacter(PlayableCharacter character) {
    if (!isCharacterUnlocked(character)) return;
    selectedCharacter = character;
  }

  void startNewGameSurveyFlow() async {
    await surveyService.clearAiResults();
    session.markStartGameAfterSurvey();
    closeMainMenu();
    await loadScene(
      SurveyScene(),
      onFullOpacity: () {
        overlays.add('Survey');
      },
    );
  }

  void startGameSkippingSurvey() {
    navigationManager.startGameFlow();
  }

  Future<void> skipToScene(GameScene scene) =>
      navigationManager.skipToScene(scene);

  void showPathDetail(PathDetailInfo info) =>
      navigationManager.showPathDetail(info);

  void hidePathDetail() => navigationManager.hidePathDetail();

  void clearPathSelection() => navigationManager.clearPathSelection();

  void clearPathOverlay() => olyaState?.classroomScene?.clearPathOverlay();

  void restoreClassroomBackground() =>
      olyaState?.classroomScene?.showClassroomImage();

  void chooseFirstPath(BuildContext context) =>
      navigationManager.chooseFirstPath(context);

  void chooseSecondPath(BuildContext context) =>
      navigationManager.chooseSecondPath(context);

  void chooseThirdPath(BuildContext context) =>
      navigationManager.chooseThirdPath(context);

  Future<void> applyPathChoice(int index, BuildContext context) =>
      navigationManager.applyPathChoice(index, context);

  Future<void> goToSecondCorridor() => navigationManager.goToSecondCorridor();

  Future<void> goToOutside() => navigationManager.goToOutside();

  void showBreathingExercise() => navigationManager.showBreathingExercise();

  Future<void> finishBreathingExercise() =>
      navigationManager.finishBreathingExercise();

  Future<void> transitionToStressScene() =>
      navigationManager.transitionToStressScene();

  Future<void> transitionToStageScene() =>
      navigationManager.transitionToStageScene();

  void completeCorridorStressIntro() =>
      navigationManager.completeCorridorStressIntro();

  void playerToCorridorEntrance() {
    player.position.x = player.size.x / 2 + 10;
    cameraManager.snapToPlayer(force: true);
  }

  void saveCorridorReturnPosition(double x) {
    session.savedCorridorReturnX = x;
    session.save();
  }

  void restoreCorridorPosition() {
    final savedX = session.savedCorridorReturnX;
    session.savedCorridorReturnX = null;
    session.save();

    if (savedX == null) {
      playerToCorridorEntrance();
      return;
    }

    final minX = player.size.x / 2;
    final maxX = worldRoot.size.x - player.size.x / 2;
    player.position.x = savedX.clamp(minX, maxX).toDouble();
    if (currentScene != null) {
      player.position.y = sceneSpawnPoint(currentScene!, size, worldRoot).y;
    }
    cameraManager.snapToPlayer(force: true);
  }

  @override
  void update(double dt) {
    dt = dt.clamp(0, 0.05);
    super.update(dt);

    if (_player == null || _player!.parent == null) return;

    cameraManager.update(dt);
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

    if (scene != null && !player.isInteracting) {
      player.position.y = sceneSpawnPoint(scene, size, worldRoot).y;
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
    final p = scene.spawnPoint(screenSize, root.size);
    return Vector2(p.x, p.y);
  }
}
