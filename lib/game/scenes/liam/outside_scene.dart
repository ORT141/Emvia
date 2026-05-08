import 'package:emvia/game/scenes/game_scene.dart';
import 'package:emvia/game/utils/pos_util.dart';
import 'package:flame/components.dart';

class LiamOutsideScene extends GameScene {
  static const double _bumpStartUvX = 0.3462;
  static const double _bumpEndUvX = 0.3961;
  static const double _bumpHeightRatio = 0.035;

  LiamOutsideScene()
    : super(
        backgroundPath: 'scenes/liam/outside/background.png',
        showControls: true,
        showPlayer: true,
      ) {
    GameScene.register(() => LiamOutsideScene());
  }

  @override
  int get sceneIndex => 8;

  @override
  void onPlayerReachedRightEdge() => game.navigationManager.goToLiamHouse();

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
  Future<void> onLoad() async {
    await super.onLoad();
    layoutToWorld();
  }

  @override
  double playerYOffsetForX(double playerX) {
    if (background.size.x <= 0) return 0;

    final startX = Vector2(
      _bumpStartUvX,
      0,
    ).toWorldPos(background.position, background.size).x;
    final endX = Vector2(
      _bumpEndUvX,
      0,
    ).toWorldPos(background.position, background.size).x;
    final centerX = (startX + endX) / 2;

    if (playerX <= startX || playerX >= endX) return 0;

    final halfWidth = (endX - startX) / 2;
    if (halfWidth <= 0) return 0;

    final normalized = (playerX - centerX).abs() / halfWidth;
    final height = game.worldRoot.size.y * _bumpHeightRatio;
    return (1 - normalized * normalized) * height;
  }

  @override
  Vector2 spawnPoint(Vector2 viewportSize, Vector2 worldSize) =>
      Vector2(worldSize.x * 0.8, worldSize.y * 0.68);
}
