import 'package:emvia/game/characters/liam/liam_journey.dart';
import 'package:emvia/game/scenes/game_scene.dart';
import 'package:flame/components.dart';

class ElevatorScene extends GameScene {
  ElevatorScene()
    : super(
        backgroundPath: 'scenes/liam/elevator/background.png',
        showControls: true,
        showPlayer: true,
      ) {
    GameScene.register(() => ElevatorScene());
  }

  @override
  int get sceneIndex => 10;

  @override
  void onPlayerReachedRightEdge() => game.navigationManager.goToLiamGraffiti();

  @override
  void onPlayerReachedLeftEdge() => game.navigationManager.goToLiamHouse();

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
      Vector2(worldSize.x * 0.8, worldSize.y * 0.68);
}