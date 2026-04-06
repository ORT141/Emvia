import 'package:flame/components.dart';
import 'dart:ui' show FilterQuality, Paint;

import '../scenes/game_scene.dart';
import '../utils/pos_util.dart';

class StageScene extends GameScene {
  StageScene()
    : super(
        backgroundPath: 'scenes/stage/background_stage.png',
        foregroundPath: 'scenes/stage/foreground_stage.png',
        scalingMode: SceneScalingMode.scrolling,
        showControls: true,
        frozenPlayer: false,
      );

  static const double _rockingChairHeightFactor = 0.8;
  static const double _booksHeightFactor = 0.1;
  static const double _bagOfRocksHeightFactor = 0.07;
  static const double _hibukiHeightFactor = 0.25;

  final List<_StageItem> _items = [];

  @override
  double worldWidthForViewport(Vector2 viewportSize) {
    if (background.sprite?.srcSize != null &&
        background.sprite!.srcSize.y > 0) {
      final src = background.sprite!.srcSize;
      final scale = viewportSize.y / src.y;
      return src.x * scale;
    }
    return viewportSize.x * 2;
  }

  @override
  Vector2 spawnPoint(Vector2 viewportSize, Vector2 worldSize) =>
      Vector2(2000, worldSize.y * 0.58);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await _addItem(
      'scenes/stage/rocking_chair.png',
      Vector2(0.5104, 0.4),
      _rockingChairHeightFactor,
    );

    await _addItem(
      'scenes/stage/books.png',
      Vector2(0.7978, 0.61),
      _booksHeightFactor,
    );

    await _addItem(
      'scenes/stage/bag_of_rocks.png',
      Vector2(0.8109, 0.6222),
      _bagOfRocksHeightFactor,
    );

    await _addItem(
      'scenes/stage/hibuki.png',
      Vector2(0.835, 0.49),
      _hibukiHeightFactor,
    );
  }

  @override
  void layoutToWorld() {
    super.layoutToWorld();
    for (final item in _items) {
      item.updatePosition(background.position, background.size, game.size.y);
    }
  }

  Future<void> _addItem(String path, Vector2 uv, double heightFactor) async {
    try {
      final sprite = await game.loadSprite(path);
      final item = _StageItem(
        sprite: sprite,
        uv: uv,
        heightFactor: heightFactor,
      );
      _items.add(item);
      add(item);
      item.updatePosition(background.position, background.size, game.size.y);
    } catch (_) {}
  }
}

class _StageItem extends SpriteComponent {
  final Vector2 uv;
  final double heightFactor;

  _StageItem({
    required Sprite sprite,
    required this.uv,
    required this.heightFactor,
  }) : super(sprite: sprite) {
    anchor = Anchor.center;
    priority = 30;
    paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high;
  }

  void updatePosition(Vector2 bgPos, Vector2 bgSize, double viewportHeight) {
    if (sprite!.srcSize.y > 0) {
      final height = viewportHeight * heightFactor;
      final width = sprite!.srcSize.x / sprite!.srcSize.y * height;
      size = Vector2(width, height);
    }
    position = getWorldPosFromUV(uv, bgPos, bgSize);
  }
}
