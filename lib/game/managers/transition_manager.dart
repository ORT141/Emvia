import 'package:flame/components.dart';
import '../emvia_game.dart';
import '../scenes/game_scene.dart';
import '../scenes/classroom_scene.dart';
import '../scenes/path_choice_scene.dart';

class TransitionManager {
  final EmviaGame game;
  bool isTransitioning = false;

  TransitionManager(this.game);

  Future<void> loadScene(GameScene scene) async {
    isTransitioning = true;

    await game.fadeOverlay.fadeIn(0.4);

    if (game.currentScene != null) {
      game.currentScene!.removeFromParent();
    }

    game.worldRoot.size = Vector2(
      game.sceneWorldWidth(EmviaGame.worldWidth),
      game.size.y,
    );

    game.currentScene = scene;

    if (scene is ClassroomScene) {
      game.classroomScene = scene;
      updateClassroomZoom();
    } else {
      game.classroomScene = null;
      game.cameraManager.resetZoom();
      game.worldRoot.scale = Vector2.all(game.cameraManager.zoom);
    }

    await game.worldRoot.add(scene);

    if (game.olya.parent == null) {
      await game.worldRoot.add(game.olya);
    }
    game.olya.priority = 10;

    if (scene is PathChoiceScene) {
      game.olya.opacity = 0;
    } else {
      game.olya.opacity = 1.0;
    }

    game.olya.position = game.sceneSpawnPoint(scene, game.size, game.worldRoot);
    game.cameraManager.snapToPlayer(force: true);

    await game.fadeOverlay.fadeOut(0.4);

    isTransitioning = false;
  }

  void updateClassroomZoom() {
    final scene = game.classroomScene;
    if (scene == null || !scene.isLoaded) return;

    final h = scene.bgHeight;
    if (h <= 0) return;

    final widthFit = game.size.x / game.worldRoot.size.x;
    final heightFit = game.size.y / h;

    game.cameraManager.zoom = (widthFit > heightFit) ? widthFit : heightFit;
    game.worldRoot.size = Vector2(game.worldRoot.size.x, h);
    game.worldRoot.scale = Vector2.all(game.cameraManager.zoom);
  }
}
