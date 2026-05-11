import 'package:emvia/game/characters/liam/liam_journey.dart';
import 'package:emvia/game/scenes/game_scene.dart';
import 'package:flame/components.dart';

class GraffitiScene extends GameScene {
  GraffitiScene()
    : super(
        backgroundPath: 'scenes/liam/graffiti/background.png',
        showControls: true,
        showPlayer: true,
      ) {
    GameScene.register(() => GraffitiScene());
  }

  @override
  int get sceneIndex => 9;

  @override
  String get ambientSoundPath => 'other/легкий біт.mp3';

  @override
  void onPlayerReachedRightEdge() => game.navigationManager.goToLiamOutside();

  @override
  void onPlayerReachedLeftEdge() => game.navigationManager.goToLiamElevator();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    layoutToWorld();
  }

  @override
  Future<void> onMount() async {
    super.onMount();
    LiamJourney.maybeShowCurrentNarrative(game);
  }

  @override
  double worldWidthForViewport(Vector2 viewportSize) {
    if (background.sprite?.srcSize != null &&
        background.sprite!.srcSize.y > 0) {
      final aspect =
          background.sprite!.srcSize.x / background.sprite!.srcSize.y;
      return viewportSize.y * aspect;
    }
    return viewportSize.x * 2;
  }

  @override
  Vector2 spawnPoint(Vector2 viewportSize, Vector2 worldSize) =>
      Vector2(worldSize.x * 0.1, worldSize.y * 0.68);
}
