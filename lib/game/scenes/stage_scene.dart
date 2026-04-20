import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'dart:ui' show FilterQuality, Paint, Rect;

import '../scenes/game_scene.dart';
import '../survey_service.dart';
import '../stage_item_card_data.dart';
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

  static final List<StageItemCardData> _itemDefinitions = [
    StageItemCardData(
      id: 'rocking_chair',
      normalSpritePath: 'scenes/stage/rocking_chair.png',
      selectedSpritePath: 'scenes/stage/rocking_chair_selected.png',
      uv: Vector2(0.5104, 0.4),
      heightFactor: _rockingChairHeightFactor,
      soundAssetEn: 'items/stage/rocking chair.mp3',
      soundAssetUk: 'items/stage/крісло гойдалка.mp3',
      title: (l) => l.stage_item_rocking_chair_title,
      description: (l) => l.stage_item_rocking_chair_description,
    ),
    StageItemCardData(
      id: 'book',
      normalSpritePath: 'scenes/stage/books.png',
      selectedSpritePath: 'scenes/stage/books_selected.png',
      uv: Vector2(0.7355, 0.6),
      heightFactor: _booksHeightFactor,
      soundAssetEn: 'items/stage/thick book.mp3',
      soundAssetUk: 'items/stage/товста книжка.mp3',
      title: (l) => l.stage_item_book_title,
      description: (l) => l.stage_item_book_description,
    ),
    StageItemCardData(
      id: 'bag_of_rocks',
      normalSpritePath: 'scenes/stage/bag_of_rocks.png',
      selectedSpritePath: 'scenes/stage/bag_of_rocks_selected.png',
      uv: Vector2(0.7450, 0.6195),
      heightFactor: _bagOfRocksHeightFactor,
      soundAssetEn: 'items/stage/pouch with smooth pebbles.mp3',
      soundAssetUk: 'items/stage/мішечок з камінчиками.mp3',
      title: (l) => l.stage_item_bag_of_rocks_title,
      description: (l) => l.stage_item_bag_of_rocks_description,
    ),
    StageItemCardData(
      id: 'hibuki',
      normalSpritePath: 'scenes/stage/hibuki.png',
      selectedSpritePath: 'scenes/stage/hibuki_selected.png',
      uv: Vector2(0.775, 0.4975),
      heightFactor: _hibukiHeightFactor,
      soundAssetEn: 'items/stage/hug-dog.mp3',
      soundAssetUk: 'items/stage/собака обіймака.mp3',
      title: (l) => l.stage_item_hibuki_title,
      description: (l) => l.stage_item_hibuki_description,
    ),
  ];

  final List<_StageItem> _items = [];
  _StageItem? _selectedItem;
  bool _hasShownCalmingPrompt = false;

  @override
  Vector2 spawnPoint(Vector2 viewportSize, Vector2 worldSize) {
    return Vector2(viewportSize.x * 0.25, worldSize.y * 0.65);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final surveyService = SurveyService();
    final profile = await surveyService.getProfile();

    final rockingChair = _itemDefinitions.firstWhere(
      (item) => item.id == 'rocking_chair',
    );
    await _addItem(rockingChair);

    final selectedItemId = profile.calmingItem;
    final selectedItem = _itemDefinitions.firstWhere(
      (item) =>
          item.id == selectedItemId ||
          (selectedItemId == 'stones' && item.id == 'bag_of_rocks') ||
          (selectedItemId == 'toy' && item.id == 'hibuki'),
      orElse: () => rockingChair,
    );
    if (selectedItem != rockingChair) {
      await _addItem(selectedItem);
    }
  }

  @override
  void layoutToWorld() {
    super.layoutToWorld();
    for (final item in _items) {
      item.updatePosition(background.position, background.size, game.size.y);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_hasShownCalmingPrompt) {
      return;
    }

    if (!game.isPlayerInitialized) {
      return;
    }

    final sceneEdgeX = game.worldRoot.size.x - game.player.size.x - 50;
    if (game.player.position.x >= sceneEdgeX) {
      _hasShownCalmingPrompt = true;

      clearSelectedItem();
      try {
        game.player.endInteraction();
      } catch (_) {}

      game.playRightSideScene();
    }
  }

  @override
  void onRemove() {
    _selectedItem = null;
    _items.clear();
    super.onRemove();
  }

  void clearSelectedItem() {
    _selectedItem?.setSelected(false);
    _selectedItem = null;
  }

  Vector2? get chairWorldPosition {
    try {
      final chair = _items.firstWhere(
        (item) => item.data.id == 'rocking_chair',
      );

      final pos = chair.position.clone()..y += chair.size.y * 0.05;

      return pos;
    } catch (_) {
      return null;
    }
  }

  Future<void> _addItem(StageItemCardData data) async {
    try {
      final normalSprite = await game.loadSprite(data.normalSpritePath);
      final selectedSprite = await game.loadSprite(data.selectedSpritePath);
      final item = _StageItem(
        data: data,
        normalSprite: normalSprite,
        selectedSprite: selectedSprite,
        onTap: (item) {
          _selectItem(item);
          game.showStageItemCard(item.data);
        },
      );
      _items.add(item);
      add(item);
      item.updatePosition(background.position, background.size, game.size.y);
    } catch (_) {}
  }

  void _selectItem(_StageItem item) {
    if (_selectedItem == item) return;
    _selectedItem?.setSelected(false);
    _selectedItem = item;
    _selectedItem?.setSelected(true);
  }
}

class _StageItem extends SpriteComponent with TapCallbacks {
  final StageItemCardData data;
  final Sprite normalSprite;
  final Sprite selectedSprite;
  final void Function(_StageItem) onTap;
  bool _isSelected = false;

  _StageItem({
    required this.data,
    required this.normalSprite,
    required this.selectedSprite,
    required this.onTap,
  }) : super(sprite: normalSprite) {
    anchor = Anchor.center;
    priority = 30;
    paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high;
  }

  void setSelected(bool value) {
    if (_isSelected == value) return;
    _isSelected = value;
    sprite = value ? selectedSprite : normalSprite;
    priority = value ? 50 : 30;
    scale = value ? Vector2.all(1.05) : Vector2.all(1.0);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap(this);
  }

  @override
  bool containsPoint(Vector2 point) {
    final rect = Rect.fromCenter(
      center: absolutePosition.toOffset(),
      width: size.x,
      height: size.y,
    );
    return rect.contains(point.toOffset());
  }

  void updatePosition(Vector2 bgPos, Vector2 bgSize, double viewportHeight) {
    if (normalSprite.srcSize.y > 0) {
      final height = viewportHeight * data.heightFactor;
      final width = normalSprite.srcSize.x / normalSprite.srcSize.y * height;
      size = Vector2(width, height);
    }
    position = getWorldPosFromUV(data.uv, bgPos, bgSize);
  }
}
