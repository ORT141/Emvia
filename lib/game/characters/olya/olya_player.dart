import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../../scenes/classroom_scene.dart';
import '../../scenes/corridor_scene.dart';
import '../../scenes/stage_scene.dart';
import '../base_player.dart';
import '../character_data.dart';

class OlyaPlayer extends BasePlayer {
  static const CharacterData olyaData = CharacterData(
    name: 'olya',
    assetPath: 'player/olya',
    walkingFrames: 26,
    extraAssets: {
      'stressPanic': 'stress/stress-scene/panic_olya.png',
    },
    widthFactor: 0.5,
    resetScaleOnIdle: true,
  );

  OlyaPlayer() : super(characterData: olyaData);

  late final SpriteAnimation _standingAnimation;
  late final SpriteAnimation _walkingAnimation;
  late final SpriteAnimation _standingHeadphonesAnimation;
  late final SpriteAnimation _walkingHeadphonesAnimation;
  late final SpriteAnimation _wearingHeadphonesAnimation;

  late SpriteAnimation _chosenBooksAnimation;
  late SpriteAnimation _chosenHibukiAnimation;
  late SpriteAnimation _chosenBagOfRocksAnimation;
  late SpriteAnimation _chosenSittingInChairAnimation;

  @override
  Future<void> onLoad() async {
    updatePlayerSize();

    _standingAnimation = await loadSingleFrameAnimation('standing.png');
    _walkingAnimation = await loadWalkingAnimation();

    try {
      _standingHeadphonesAnimation =
          await loadSingleFrameAnimation('standing_headphones.png');
      _walkingHeadphonesAnimation = await loadWalkingAnimation(
        prefix: 'walking_headphones',
        frames: 29,
      );

      try {
        final wearingSprite = await game.loadSprite(
          '${characterData.assetPath}/headphones_wearing.png',
        );
        final wearedSprite = await game.loadSprite(
          '${characterData.assetPath}/headphones_weared.png',
        );
        _wearingHeadphonesAnimation = SpriteAnimation.spriteList(
          [wearingSprite, wearedSprite],
          stepTime: 0.12,
          loop: false,
        );
      } catch (_) {
        _wearingHeadphonesAnimation = _standingHeadphonesAnimation;
      }
    } catch (_) {
      _standingHeadphonesAnimation = _standingAnimation;
      _walkingHeadphonesAnimation = _walkingAnimation;
      _wearingHeadphonesAnimation = _standingAnimation;
    }

    _chosenBooksAnimation = await loadSingleFrameAnimation('chosen_books.png');
    _chosenHibukiAnimation = await loadSingleFrameAnimation('chosen_hibuki.png');
    _chosenBagOfRocksAnimation =
        await loadSingleFrameAnimation('chosen_bag_of_rocks.png');
    _chosenSittingInChairAnimation =
        await loadSingleFrameAnimation('chosen_sitting_in_chair.png');

    _updateAnimations();
    current = PlayerState.standing;
  }

  @override
  Future<void> onStartGame() async {
    await game.loadScene(
      ClassroomScene(),
      onFullOpacity: () {
        opacity = 0;
      },
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (game.currentScene is ClassroomScene) {
      return;
    }
  }

  @override
  void update(double dt) {
    _updateAnimations();
    super.update(dt);

    if (game.currentScene is ClassroomScene && hasReachedRightSceneEdge()) {
      game.transitionToStressScene();
    }

    if (game.currentScene is CorridorScene && hasReachedRightSceneEdge()) {
      game.transitionToStageScene();
    }
  }

  bool _hasHeadphones = false;

  @override
  Future<void> interactWithItem(String itemId) async {
    isInteracting = true;

    if (itemId == 'rocking_chair' && game.currentScene is StageScene) {
      var chairPos = (game.currentScene as StageScene).chairWorldPosition;
      chairPos = chairPos?.clone()?..y += size.y * 0.3;
      if (chairPos != null) {
        position.setFrom(chairPos);
      }
    }

    final SpriteAnimation interactionAnim;
    switch (itemId) {
      case 'rocking_chair':
        interactionAnim = _chosenSittingInChairAnimation;
        break;
      case 'book':
        interactionAnim = _chosenBooksAnimation;
        break;
      case 'bag_of_rocks':
        interactionAnim = _chosenBagOfRocksAnimation;
        break;
      case 'hibuki':
        interactionAnim = _chosenHibukiAnimation;
        break;
      default:
        isInteracting = false;
        return;
    }
    animations = {
      PlayerState.standing: interactionAnim,
      PlayerState.walking: interactionAnim,
    };
    current = PlayerState.standing;
    if (current != null) current = current;
    await Future.delayed(const Duration(milliseconds: 2500));
    endInteraction();
  }

  @override
  void endInteraction() {
    isInteracting = false;
    animations = null;
    _hasHeadphones = game.selectedTools.contains('headphones');
    _updateAnimations();
    if (current != null) current = current;
  }

  void _updateAnimations() {
    if (isInteracting) return;
    final prev = _hasHeadphones;
    final hasHeadphones = game.selectedTools.contains('headphones');
    if (hasHeadphones == prev && animations != null) {
      return;
    }
    _hasHeadphones = hasHeadphones;

    if (hasHeadphones && !prev) {
      animations = {
        PlayerState.standing: _wearingHeadphonesAnimation,
        PlayerState.walking: _walkingHeadphonesAnimation,
      };
      if (current != null) current = current;

      try {
        final frameCount = _wearingHeadphonesAnimation.frames.length;
        const stepMs = 320;
        Future.delayed(
          Duration(milliseconds: (frameCount * stepMs).toInt()),
          () {
            if (!game.selectedTools.contains('headphones')) return;
            animations = {
              PlayerState.standing: _standingHeadphonesAnimation,
              PlayerState.walking: _walkingHeadphonesAnimation,
            };
            if (current != null) current = current;
          },
        );
      } catch (_) {
        animations = {
          PlayerState.standing: _standingHeadphonesAnimation,
          PlayerState.walking: _walkingHeadphonesAnimation,
        };
        if (current != null) current = current;
      }

      return;
    }

    animations = {
      PlayerState.standing: hasHeadphones
          ? _standingHeadphonesAnimation
          : _standingAnimation,
      PlayerState.walking: hasHeadphones
          ? _walkingHeadphonesAnimation
          : _walkingAnimation,
    };
    if (current != null) {
      current = current;
    }
  }
}
