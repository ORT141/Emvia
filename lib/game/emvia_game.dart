import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'utils/game_config.dart';
import 'utils/survey_service.dart';
import 'components/fade_overlay.dart';
import 'characters/base_player.dart';
import 'characters/character_factory.dart';
import 'characters/liam/liam_journey.dart';
import 'scenes/game_scene.dart';
import 'scenes/olya/stage_scene.dart';
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
  OlyaGameState? get olyaState {
    final state = gameState;
    return state is OlyaGameState ? state : null;
  }

  LiamGameState? get liamState {
    final state = gameState;
    return state is LiamGameState ? state : null;
  }

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

  DialogTree? pendingCafeDialog;

  String educationalCardText = '';

  VoidCallback? educationalCardOnDismiss;

  String? educationalCardSoundFile;

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
    final scene = currentScene;
    if (scene is StageScene) await scene.useItem(item);
  }

  void freezePlayer() {
    gameState.isFrozen = true;
    overlayManager.hideMobileControls();
  }

  void unfreezePlayer() {
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

  void _reinitializePlayer() {
    _player?.removeFromParent();
    _initializePlayer();
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
    await navigationManager.continueFromSavedScene();
    overlayManager.closeMainMenu();
  }

  double currentSceneWorldWidth() {
    final scene = currentScene;
    return scene?.worldWidthForViewport(size) ?? GameConfig.worldWidth;
  }

  void setDebugTapEnabled(bool enabled) {
    debugTapEnabled = enabled;
  }

  bool consumeStartGameAfterSurvey() => session.consumeStartGameAfterSurvey();

  bool isCharacterUnlocked(PlayableCharacter character) {
    return character == PlayableCharacter.liam ||
        character == PlayableCharacter.olya;
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
    if (scene != null && scene.isLoaded) {
      scene.onWorldResize(size);
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

extension EmviaGameFlow on EmviaGame {
  Future<void> reloadCurrentScene() => navigationManager.reloadCurrentScene();
  Future<void> goToCorridor() => navigationManager.goToCorridor();
  Future<void> transitionToCorridor() => navigationManager.goToCorridor();
  Future<void> playRightSideScene() => navigationManager.playRightSideScene();
  Future<void> startGame() => navigationManager.startGameFlow();
  Future<void> startGameSkippingSurvey() => navigationManager.startGameFlow();

  Future<void> skipToScene(GameScene scene) =>
      navigationManager.skipToScene(scene);
  void showPathDetail(PathDetailInfo info) =>
      navigationManager.showPathDetail(info);
  void hidePathDetail() => navigationManager.hidePathDetail();
  void clearPathSelection() => navigationManager.clearPathSelection();

  Future<void> finishBreathingExercise() =>
      navigationManager.finishBreathingExercise();
  void showEducationalCard(
    String text, {
    VoidCallback? onDismiss,
    String? soundFile,
  }) => navigationManager.showEducationalCard(
    text,
    onDismiss: onDismiss,
    soundFile: soundFile,
  );
  void dismissEducationalCard() => navigationManager.dismissEducationalCard();
  Future<void> transitionToStressScene() =>
      navigationManager.transitionToStressScene();
  Future<void> transitionToStageScene() =>
      navigationManager.transitionToStageScene();
  void completeCorridorStressIntro() =>
      navigationManager.completeCorridorStressIntro();

  void selectCharacter(PlayableCharacter character) {
    if (isCharacterUnlocked(character)) {
      selectedCharacter = character;
    }
  }

  void startNewGameSurveyFlow() async {
    session.markStartGameAfterSurvey();
    closeMainMenu();
    _reinitializePlayer();

    if (selectedCharacter == PlayableCharacter.liam) {
      await loadScene(
        SurveyScene(),
        onFullOpacity: () {
          overlays.add('LiamGraffitiSurvey');
        },
      );
    } else {
      await surveyService.clearAiResults();
      await loadScene(
        SurveyScene(),
        onFullOpacity: () {
          overlays.add('Survey');
        },
      );
    }
  }

  Future<void> returnToMainMenu() async {
    await fadeOverlay.fadeIn(GameConfig.defaultFadeDuration);
    resumeEngine();
    overlays.remove('PauseMenu');
    navigationManager.prepareReturnToMainMenu();
    await loadMenuScene();
    openMainMenu();
    await fadeOverlay.fadeOut(GameConfig.defaultFadeDuration);
  }

  Future<void> returnToMainMenuAfterJourney() =>
      navigationManager.returnToMainMenuAfterJourney();
  Future<void> returnToMainMenuAfterSurvey() =>
      navigationManager.returnToMainMenuAfterSurvey();

  void finishJourney() {
    if (session.journeyCompleted) return;
    session.journeyCompleted = true;
    overlayManager.hideMobileControls();
    pauseEngine();
    overlays.add('LiamExhibition');
  }
}

extension EmviaGameUI on EmviaGame {
  void toggleBackpack() => overlayManager.toggleBackpack();
  void toggleDebug() => overlayManager.toggleDebug();
  void openMainMenu() => overlayManager.openMainMenu();
  void closeMainMenu() => overlayManager.closeMainMenu();
  void showMobileControls() => overlayManager.showMobileControls();
  void hideMobileControls() => overlayManager.hideMobileControls();

  void toggleCameraMode() {
    if (selectedCharacter != PlayableCharacter.liam) return;
    final state = liamState;
    if (state == null) return;

    if (state.isJourneyComplete) {
      LiamJourney.maybeShowCurrentNarrative(this);
      return;
    }

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
}

extension EmviaGameInventory on EmviaGame {
  void equipTool(String toolId) => session.toggleSelectedTool(toolId);
  void unequipTool(String toolId) => session.removeSelectedTool(toolId);

  void initializeInventory(BuildContext context) {
    if (backpack.items.isNotEmpty) return;
    for (final item in BackpackItem.initialItems(context)) {
      backpack.addItem(item);
    }
  }
}
