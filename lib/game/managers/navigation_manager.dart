import 'package:flutter/material.dart';
import '../emvia_game.dart';
import '../scenes/game_scene.dart';
import '../scenes/olya/corridor_scene.dart';
import '../scenes/olya/stage_scene.dart';
import '../scenes/olya/stress/stress_scene.dart';
import '../scenes/olya/path/path_choice_scene.dart';
import '../scenes/olya/second_corridor_scene.dart';
import '../scenes/olya/outside_scene.dart';
import '../scenes/olya/scene_scene.dart';
import '../emvia_types.dart';
import 'package:emvia/l10n/app_localizations.dart';
import 'package:emvia/l10n/app_localizations_gen.dart';
import '../utils/ui_utils.dart';

class NavigationManager {
  final EmviaGame game;

  NavigationManager(this.game);

  Future<void> continueFromSavedScene() async {
    final savedIndex = game.sceneIndex;
    if (savedIndex <= 0) {
      await startGameFlow();
      return;
    }

    GameScene? targetScene;
    for (final factory in GameScene.registry) {
      final candidate = factory();
      if (candidate.sceneIndex == savedIndex) {
        targetScene = candidate;
        break;
      }
    }

    if (targetScene == null) {
      await startGameFlow();
      return;
    }

    await _loadSceneWithDefaults(
      targetScene,
      sceneIndex: savedIndex,
      showMobileControls: targetScene.showControls,
      resetPlayerOpacity: targetScene.showPlayer,
      onFullOpacity: () => game.overlays.remove('TapGame'),
    );
  }

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
    await _loadSceneWithDefaults(
      CorridorScene(),
      sceneIndex: 4,
      onFullOpacity: () => game.overlays.remove('TapGame'),
    );
  }

  Future<void> playRightSideScene() async {
    await game.loadScene(SceneScene(), onFullOpacity: () {});
  }

  Future<void> loadStageScene() async {
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
      sceneIndex: scene.sceneIndex,
      resetPlayerOpacity: scene.showPlayer,
    );

    if (!game.session.isCurrentSession(token)) return;
  }

  void _resetJourneyState({required dynamic profile}) {
    game.session.resetForNewJourney(profile: profile);
    game.backpack.clear();
    game.gameState.reset();
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
    game.gameState.reset();
    game.overlayManager.hideMobileControls();
    game.overlays.remove('Stress');
    game.overlays.remove('TapGame');
  }

  void showPathDetail(PathDetailInfo info) {
    game.session.pathDetail = info;
    game.overlays.add('PathDetail');
  }

  void clearPathSelection() {
    if (game.currentScene is PathChoiceScene) {
      (game.currentScene as PathChoiceScene).clearSelection();
    }
  }

  void hidePathDetail() {
    game.overlays.remove('PathDetail');
    game.session.pathDetail = null;
  }

  void showBreathingExercise() {
    game.freezePlayer();
    game.overlays.add('BreathingExercise');
  }

  void showEducationalCard(String text, {VoidCallback? onDismiss}) {
    game.educationalCardText = text;
    game.educationalCardOnDismiss = onDismiss;
    game.freezePlayer();
    game.overlays.add('EducationalCard');
  }

  void dismissEducationalCard() {
    game.overlays.remove('EducationalCard');
    final cb = game.educationalCardOnDismiss;
    game.educationalCardOnDismiss = null;
    if (cb != null) {
      cb();
    } else {
      game.unfreezePlayer();
    }
  }

  Future<void> finishBreathingExercise() async {
    game.overlays.remove('BreathingExercise');
    game.gameState.isFrozen = false;

    final context = game.buildContext;
    if (context != null && context.mounted) {
      final l = AppLocalizationsGen.of(context)!;
      await UIUtils.showWarningDialog(context, l.too_dangerous);
    }

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
    if (!(game.olyaState?.isCorridorStressIntroActive ?? false)) return;
    game.olyaState?.isCorridorStressIntroActive = false;
    game.unfreezePlayer();
  }
}
