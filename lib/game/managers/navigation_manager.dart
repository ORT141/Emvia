import 'package:flutter/material.dart';
import '../emvia_game.dart';
import '../scenes/game_scene.dart';
import '../scenes/classroom_scene.dart';
import '../scenes/corridor_scene.dart';
import '../scenes/stage_scene.dart';
import '../scenes/stress/stress_scene.dart';
import '../scenes/path/path_choice_scene.dart';
import '../scenes/survey_scene.dart';
import '../scenes/notebook_scene.dart';
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
    game.overlayManager.hideStageItemCard(); // Ensure it's hidden
    game.overlays.remove('Debug');

    if (scene is ClassroomScene) {
      await game.loadScene(ClassroomScene(), onFullOpacity: () {
        game.sceneIndex = savedSceneIndex;
      });
    } else if (scene is CorridorScene) {
      await game.loadScene(CorridorScene(), onFullOpacity: () {
        game.sceneIndex = savedSceneIndex;
      });
    } else if (scene is StageScene) {
      await game.loadScene(StageScene(), onFullOpacity: () {
        game.sceneIndex = savedSceneIndex;
        game.player.opacity = 1;
      });
    } else if (scene is StressScene) {
      await game.loadScene(StressScene(), onFullOpacity: () {
        game.sceneIndex = savedSceneIndex;
      });
    } else if (scene is PathChoiceScene) {
      await game.loadScene(PathChoiceScene(), onFullOpacity: () {
        game.sceneIndex = savedSceneIndex;
      });
    } else if (scene is SurveyScene) {
      await game.loadScene(SurveyScene(), onFullOpacity: () {
        game.sceneIndex = savedSceneIndex;
      });
    } else if (scene is NotebookScene) {
      await game.loadScene(NotebookScene(), onFullOpacity: () {
        game.sceneIndex = savedSceneIndex;
      });
    } else {
      game.currentScene?.redrawScene();
    }
  }

  Future<void> goToCorridor() async {
    if (game.stressLevel >= 30 && !game.hasShownCorridorStressIntro) {
      game.hasShownCorridorStressIntro = true;
      game.isCorridorStressIntroActive = true;
    }

    await game.loadScene(
      CorridorScene(),
      onFullOpacity: () {
        game.sceneIndex = 4;
        game.overlays.remove('TapGame');
      },
    );

    if (game.isCorridorStressIntroActive) {
      game.overlayManager.hideMobileControls();
    }
  }

  Future<void> transitionToCorridor() async {
    await game.loadScene(
      CorridorScene(),
      onFullOpacity: () {
        game.overlays.remove('TapGame');
        game.restoreCorridorPosition();
      },
    );
    game.sceneIndex = 4;
    game.player.opacity = 1;
  }

  Future<void> playRightSideScene() async {
    await game.loadScene(SceneScene(), onFullOpacity: () {});
  }

  Future<void> loadStageScene() async {
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

  Future<void> goToSecondCorridor() async {
    await game.loadScene(
      SecondCorridorScene(),
      onFullOpacity: () {
        game.sceneIndex = 4;
        game.player.opacity = 1;
        game.overlayManager.showMobileControls();
      },
    );
  }

  Future<void> goToOutside() async {
    await game.loadScene(
      OutsideScene(),
      onFullOpacity: () {
        game.sceneIndex = 4;
        game.player.opacity = 1;
        game.overlayManager.showMobileControls();
      },
    );
  }

  Future<void> startGameFlow() async {
    final token = game.session.beginSession();
    final profile = await game.surveyService.getProfile();

    game.session.resetForNewJourney(profile: profile);
    game.backpack.clear();
    game.hasTriggeredStressScene = false;

    game.overlayManager.clearGameplayOverlays();

    await game.player.onStartGame();

    if (!game.session.isCurrentSession(token)) return;
  }

  Future<void> skipToScene(GameScene scene) async {
    final token = game.session.beginSession();
    final profile = await game.surveyService.getProfile();

    game.session.resetForNewJourney(profile: profile);
    game.backpack.clear();
    game.hasTriggeredStressScene = false;

    game.overlays.remove('MainMenu');
    game.overlays.remove('Survey');
    game.overlays.remove('CalmMap');
    game.overlays.remove('TapGame');
    game.overlays.remove('Backpack');
    game.overlays.remove('Stress');

    game.overlayManager.clearGameplayOverlays();

    await game.loadScene(
      scene,
      onFullOpacity: () {
        game.sceneIndex = _sceneIndexForScene(scene);
        game.overlays.remove('TapGame');
        if (scene is CorridorScene || scene is StageScene) {
          game.player.opacity = 1;
        }
      },
    );

    if (!game.session.isCurrentSession(token)) return;
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
    if (game.paused) {
      game.resumeEngine();
    }
    prepareReturnToMainMenu();
    await game.loadMenuScene();
    game.overlayManager.openMainMenu();
  }

  Future<void> returnToMainMenuAfterSurvey() async {
    game.overlays.remove('Survey');
    prepareReturnToMainMenu();
    await game.loadMenuScene();
    game.overlayManager.openMainMenu();
  }

  void prepareReturnToMainMenu() {
    game.stressLevel = 100;
    game.sceneIndex = 0;
    game.hasTriggeredStressScene = false;
    game.hasShownCorridorStressIntro = false;
    game.isCorridorStressIntroActive = false;
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
    game.classroomScene?.clearPathOverlay();
  }

  void restoreClassroomBackground() {
    game.classroomScene?.showClassroomImage();
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
    game.classroomScene?.showClassroomImage();
    game.classroomScene?.clearMarks();
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
    game.isFrozen = true;
    game.overlayManager.hideMobileControls();
    game.overlays.add('BreathingExercise');
  }

  Future<void> finishBreathingExercise() async {
    game.overlays.remove('BreathingExercise');
    game.isFrozen = false;
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
    if (!game.isCorridorStressIntroActive) return;
    game.isCorridorStressIntroActive = false;
    game.isFrozen = false;
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

