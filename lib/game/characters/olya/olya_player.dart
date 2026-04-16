import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../../scenes/classroom_scene.dart';
import '../base_player.dart';

class OlyaPlayer extends BasePlayer {
  OlyaPlayer() : super();

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

    _standingAnimation = SpriteAnimation.spriteList([
      await game.loadSprite('player/olya/standing.png'),
    ], stepTime: 1);

    _walkingAnimation = SpriteAnimation.spriteList([
      for (int i = 1; i <= 26; i++)
        await game.loadSprite('player/olya/walking_$i.png'),
    ], stepTime: 0.1);

    try {
      _standingHeadphonesAnimation = SpriteAnimation.spriteList([
        await game.loadSprite('player/olya/standing_headphones.png'),
      ], stepTime: 1);
      _walkingHeadphonesAnimation = SpriteAnimation.spriteList([
        for (int i = 1; i <= 29; i++)
          await game.loadSprite('player/olya/walking_headphones_$i.png'),
      ], stepTime: 0.1);

      try {
        final wearingSprite = await game.loadSprite(
          'player/olya/headphones_wearing.png',
        );
        final wearedSprite = await game.loadSprite(
          'player/olya/headphones_weared.png',
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

    _chosenBooksAnimation = SpriteAnimation.spriteList([
      await game.loadSprite('player/olya/chosen_books.png'),
    ], stepTime: 1);
    _chosenHibukiAnimation = SpriteAnimation.spriteList([
      await game.loadSprite('player/olya/chosen_hibuki.png'),
    ], stepTime: 1);
    _chosenBagOfRocksAnimation = SpriteAnimation.spriteList([
      await game.loadSprite('player/olya/chosen_bag_of_rocks.png'),
    ], stepTime: 1);
    _chosenSittingInChairAnimation = SpriteAnimation.spriteList([
      await game.loadSprite('player/olya/chosen_sitting_in_chair.png'),
    ], stepTime: 1);

    _updateAnimations();
    current = PlayerState.standing;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (game.currentScene is ClassroomScene) {
      return;
    }
  }

  @override
  String get stressPanicSprite => 'stress/stress-scene/panic_olya.png';

  @override
  void update(double dt) {
    _updateAnimations();
    super.update(dt);
  }

  bool _hasHeadphones = false;

  @override
  Future<void> interactWithItem(String itemId) async {
    isInteracting = true;
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
