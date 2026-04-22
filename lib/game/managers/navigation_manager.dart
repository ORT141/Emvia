import 'package:flutter/material.dart';
import '../emvia_game.dart';
import '../scenes/game_scene.dart';
import '../scenes/classroom_scene.dart';
import '../scenes/corridor_scene.dart';
import '../scenes/stage_scene.dart';
import '../scenes/stress/stress_scene.dart';
import '../scenes/path/path_choice_scene.dart';
import '../scenes/second_corridor_scene.dart';
import '../scenes/outside_scene.dart';
import '../scenes/scene_scene.dart';
import '../emvia_types.dart';
import 'package:emvia/l10n/app_localizations_gen.dart';

class NavigationManager {
  final EmviaGame game;

  NavigationManager(this.game);

  Future<void> reloadCurrentScene() async {
    final scene = game.currentScene;
    if (scene == null) return;

    final savedSceneIndex = game.sceneIndex;
    game.overlayManager.hideStageItemCard();
    game.overlays.remove('Debug');

    final sceneType = scene.runtimeType;
    final sceneFactory = _sceneFactories[sceneType];

    if (sceneFactory != null) {
      await game.loadScene(
        sceneFactory(),
        onFullOpacity: () {
          game.sceneIndex = savedSceneIndex;
          if (scene is StageScene) {
            game.player.opacity = 1;
          }
        },
      );
    } else {
      game.currentScene?.redrawScene();
    }
  }

  static final Map<Type, GameScene Function()> _sceneFactories = {
    for (final factory in GameScene.registry) factory().runtimeType: factory,
  };

  Future<void> _loadSceneWithDefaults(
    GameScene scene, {
    int? sceneIndex,
    VoidCallback? onFullOpacity,
    bool showMobileControls = true,
    bool resetPlayerOpacity = true,
  }) async {
    await game.loadScene(
      scene,
      onFullOpacity: () {
        if (sceneIndex != null) game.sceneIndex = sceneIndex;
        if (resetPlayerOpacity) game.player.opacity = 1;
        if (showMobileControls) {
          game.overlayManager.showMobileControls();
        }
        onFullOpacity?.call();
      },
    );
  }

  Future<void> goToCorridor() async {
    if (game.stressLevel >= 30 && !game.olyaState.hasShownCorridorStressIntro) {
      game.olyaState.hasShownCorridorStressIntro = true;
      game.olyaState.isCorridorStressIntroActive = true;
    }

    await _loadSceneWithDefaults(
      CorridorScene(),
      sceneIndex: 4,
      showMobileControls: !game.olyaState.isCorridorStressIntroActive,
      onFullOpacity: () => game.overlays.remove('TapGame'),
    );
  }

  Future<void> transitionToCorridor() async {
    await _loadSceneWithDefaults(
      CorridorScene(),
      sceneIndex: 4,
      onFullOpacity: () {
        game.overlays.remove('TapGame');
        game.restoreCorridorPosition();
      },
    );
  }

  Future<void> playRightSideScene() async {
    await game.loadScene(SceneScene(), onFullOpacity: () {});
  }

  Future<void> loadStageScene() async {
    game.unequipTool('headphones');
    await _loadSceneWithDefaults(StageScene(), sceneIndex: 6);
  }

  Future<void> goToSecondCorridor() async {
    await _loadSceneWithDefaults(SecondCorridorScene(), sceneIndex: 4);
  }

  Future<void> goToOutside() async {
    await _loadSceneWithDefaults(OutsideScene(), sceneIndex: 4);
  }

  Future<void> startGameFlow() async {
    final token = game.session.beginSession();
    final profile = await game.surveyService.getProfile();

    _resetJourneyState(profile: profile);
    game.overlayManager.clearGameplayOverlays();

    await game.player.onStartGame();

    if (!game.session.isCurrentSession(token)) return;
  }

  Future<void> skipToScene(GameScene scene) async {
    final token = game.session.beginSession();
    final profile = await game.surveyService.getProfile();

    _resetJourneyState(profile: profile);
    _clearGameplayOverlays();

    await _loadSceneWithDefaults(
      scene,
      sceneIndex: _sceneIndexForScene(scene),
      resetPlayerOpacity: scene is CorridorScene || scene is StageScene,
    );

    if (!game.session.isCurrentSession(token)) return;
  }

  void _resetJourneyState({required dynamic profile}) {
    game.session.resetForNewJourney(profile: profile);
    game.backpack.clear();
    game.olyaState.hasTriggeredStressScene = false;
  }

  void _clearGameplayOverlays() {
    final overlaysToRemove = [
      'MainMenu',
      'Survey',
      'CalmMap',
      'TapGame',
      'Backpack',
      'Stress',
    ];
    for (final overlay in overlaysToRemove) {
      game.overlays.remove(overlay);
    }
    game.overlayManager.clearGameplayOverlays();
  }

  int _sceneIndexForScene(GameScene scene) {
    if (scene is ClassroomScene) return 1;
    if (scene is PathChoiceScene) return 2;
    if (scene is StressScene) return 3;
    if (scene is CorridorScene) return 4;
    if (scene is StageScene) return 6;
    return 0;
  }

  Future<void> returnToMainMenuAfterJourney() async {
    game.overlays.remove('CalmMap');
    if (game.paused) game.resumeEngine();
    await _returnToMainMenu();
  }

  Future<void> returnToMainMenuAfterSurvey() async {
    game.overlays.remove('Survey');
    await _returnToMainMenu();
  }

  Future<void> _returnToMainMenu() async {
    prepareReturnToMainMenu();
    await game.loadMenuScene();
    game.overlayManager.openMainMenu();
  }

  void prepareReturnToMainMenu() {
    game.stressLevel = 100;
    game.sceneIndex = 0;
    game.olyaState.hasTriggeredStressScene = false;
    game.olyaState.hasShownCorridorStressIntro = false;
    game.olyaState.isCorridorStressIntroActive = false;
    game.overlayManager.hideMobileControls();
    game.overlays.remove('Stress');
    game.overlays.remove('TapGame');
  }

  void showPathDetail(PathDetailInfo info) {
    game.session.pathDetail = info;
    game.overlays.add('PathDetail');
  }

  void hidePathDetail() {
    game.overlays.remove('PathDetail');
    game.session.pathDetail = null;
  }

  void clearPathSelection() {
    if (game.currentScene is PathChoiceScene) {
      (game.currentScene as PathChoiceScene).clearSelection();
    }
  }

  void clearPathOverlay() {
    game.olyaState.classroomScene?.clearPathOverlay();
  }

  void restoreClassroomBackground() {
    game.olyaState.classroomScene?.showClassroomImage();
  }

  void chooseFirstPath(BuildContext context) {
    confirmSelectedPath(context, 0);
  }

  void chooseSecondPath(BuildContext context) {
    confirmSelectedPath(context, 1);
  }

  void chooseThirdPath(BuildContext context) {
    confirmSelectedPath(context, 2);
  }

  void confirmSelectedPath(BuildContext context, int index) {
    if (!context.mounted) return;
    final l = AppLocalizationsGen.of(context)!;
    recordPathChoice(l, index);
    finishPathChoice();
  }

  void finishPathChoice() {
    game.sceneIndex = 2;
    game.player.opacity = 1;
    game.olyaState.classroomScene?.showClassroomImage();
    game.olyaState.classroomScene?.clearMarks();
    game.transitionManager.updateClassroomZoom();
    game.cameraManager.snapToPlayer(force: true);

    Future.delayed(const Duration(seconds: 1), () {
      goToCorridor();
    });
  }

  Future<void> applyPathChoice(int index, BuildContext context) async {
    final l = AppLocalizationsGen.of(context)!;
    recordPathChoice(l, index);

    if (index == 1 || index == 2) {
      game.stressLevel = 100;
    }

    if (index == 0) {
      await goToCorridor();
    } else if (index == 1) {
      await goToSecondCorridor();
    } else {
      await goToOutside();
    }
  }

  void showBreathingExercise() {
    game.gameState.isFrozen = true;
    game.overlayManager.hideMobileControls();
    game.overlays.add('BreathingExercise');
  }

  Future<void> finishBreathingExercise() async {
    game.overlays.remove('BreathingExercise');
    game.gameState.isFrozen = false;
    await game.loadScene(
      PathChoiceScene(),
      onFullOpacity: () {
        game.sceneIndex = 2;
        game.player.opacity = 0;
      },
    );
  }

  Future<void> transitionToStressScene() async {
    if (game.transitionManager.isTransitioning) return;
    await game.loadScene(
      StressScene(),
      onFullOpacity: () {
        game.sceneIndex = 3;
        game.player.opacity = 0;
      },
    );
  }

  Future<void> transitionToStageScene() async {
    if (game.transitionManager.isTransitioning) return;
    game.unequipTool('headphones');
    await game.loadScene(
      StageScene(),
      onFullOpacity: () {
        game.sceneIndex = 6;
        game.player.opacity = 1;
        game.overlayManager.showMobileControls();
      },
    );
  }

  void completeCorridorStressIntro() {
    if (!game.olyaState.isCorridorStressIntroActive) return;
    game.olyaState.isCorridorStressIntroActive = false;
    game.gameState.isFrozen = false;
    game.overlayManager.showMobileControls();
  }

  void recordPathChoice(AppLocalizationsGen l, int index) {
    game.session.addSelectedTool(l.classroom);
    game.session.addSelectedTool(_pathLabelForIndex(l, index));
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
}
