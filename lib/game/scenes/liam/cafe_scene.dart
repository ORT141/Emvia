import 'package:emvia/game/scenes/game_scene.dart';
import 'package:flame/components.dart';

class CafeScene extends GameScene {
  CafeScene()
    : super(
        backgroundPath: 'misc/liam-cafe-entrance/near.png',
        scalingMode: SceneScalingMode.stretch,
        showControls: false,
        showPlayer: false,
      ) {
    GameScene.register(() => CafeScene());
  }

  @override
  int get sceneIndex => 11;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    layoutToWorld();
  }

  @override
  Future<void> onMount() async {
    super.onMount();
    game.freezePlayer();
  }

  @override
  void onRemove() {
    game.overlays.remove('LiamCafeNear');
    game.overlays.remove('LiamCafeGrab');
    super.onRemove();
  }

  @override
  Vector2 spawnPoint(Vector2 viewportSize, Vector2 worldSize) =>
      Vector2(worldSize.x * 0.5, worldSize.y * 0.68);
}
