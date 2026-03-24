import 'package:flame/components.dart';
import '../emvia_game.dart';
import '../scenes/game_scene.dart';
import '../scenes/classroom_scene.dart';
import '../scenes/corridor_scene.dart';

class TransitionManager {
  final EmviaGame game;
  bool isTransitioning = false;

  TransitionManager(this.game);

  Future<void> loadScene(
    GameScene scene, {
    void Function()? onFullOpacity,
  }) async {
    isTransitioning = true;

    await game.fadeOverlay.fadeIn(0.4);

    if (game.currentScene != null) {
      game.currentScene!.removeFromParent();
    }

    game.currentScene = scene;

    game.worldRoot.size = Vector2(
      scene.worldWidthForViewport(game.size),
      game.size.y,
    );

//    if (scene is ClassroomScene) {
//      game.isFrozen = true;
//      game.classroomScene = scene;
//    } else {
//      game.classroomScene = null;
//      game.cameraManager.resetZoom();
//    }

    await game.worldRoot.add(scene);

    scene.onGameResize(game.size);

    if (scene is ClassroomScene) {
      updateClassroomZoom();
    } else {
      game.worldRoot.scale = Vector2.all(game.cameraManager.zoom);
    }

    if (game.olya.parent != game.worldRoot) {
      await game.worldRoot.add(game.olya);
    }

    if (scene is CorridorScene) {
      game.olya.opacity = 1.0;
    } else {
      game.olya.opacity = 0.0;
    }

    game.olya.position = game.sceneSpawnPoint(scene, game.size, game.worldRoot);

    if (onFullOpacity != null) {
      onFullOpacity();
    }

    game.cameraManager.snapToPlayer(force: true);

    scene.onGameResize(game.size);
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

    game.cameraManager.zoom =
        ((widthFit > heightFit) ? widthFit : heightFit) + 0.001;
    game.worldRoot.size = Vector2(game.worldRoot.size.x, h);
    game.worldRoot.scale = Vector2.all(game.cameraManager.zoom);
  }
}
