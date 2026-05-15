import 'package:emvia/game/characters/liam/liam_journey.dart';
import 'package:emvia/game/scenes/game_scene.dart';
import 'package:emvia/game/utils/pos_util.dart';
import 'package:flame/components.dart';
import 'package:emvia/l10n/app_localizations_gen.dart';
import '../../models/captured_photo.dart';

class LiamOutsideScene extends GameScene {
  static const double _bumpStartUvX = 0.3462;
  static const double _bumpEndUvX = 0.3961;
  static const double _bumpHeightRatio = 0.035;

  static const double _cafeTriggerUvX = 0.6379;

  final double? returnPlayerX;

  bool _cafeTriggered = false;

  LiamOutsideScene({this.returnPlayerX})
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
  String get ambientSoundPath => 'other/шум міста.mp3';

  @override
  void onPlayerReachedRightEdge() => game.navigationManager.goToLiamGraffiti();

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
  Future<void> onMount() async {
    super.onMount();

    if (game.liamState?.cafeBoundaryCompleted == true) {
      _cafeTriggered = true;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_cafeTriggered) return;
    if (game.transitionManager.isTransitioning) return;
    if (background.size.x <= 0) return;

    final playerX = game.player.position.x;
    final triggerX = Vector2(
      _cafeTriggerUvX,
      0,
    ).toWorldPos(background.position, background.size).x;

    if (playerX >= triggerX) {
      _cafeTriggered = true;

      final liamState = game.liamState;

      if (liamState != null) {
        while (liamState.currentMissionIndex < 2) {
          liamState.addPhoto(
            CapturedPhoto(
              path: '',
              tagKey: 'tag_placeholder',
              sceneIndex: game.sceneIndex,
            ),
          );
        }

        final ctx = game.buildContext;
        final loc = ctx != null ? AppLocalizationsGen.of(ctx) : null;
        if (loc != null) {
          try {
            game.pendingCafeDialog = LiamJourney.buildBoundaryDialog(
              game,
              loc,
              liamState,
            );
          } catch (_) {
            game.pendingCafeDialog = null;
          }
        }

        liamState.savedOutsidePlayerX = game.player.position.x;
      }

      game.navigationManager.goToLiamCafe();
    }
  }

  @override
  void redrawScene() {
    if (game.liamState?.cafeBoundaryCompleted != true) {
      _cafeTriggered = false;
    }
    super.redrawScene();
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
  Vector2 spawnPoint(Vector2 viewportSize, Vector2 worldSize) {
    if (returnPlayerX != null) {
      return Vector2(returnPlayerX!, worldSize.y * 0.68);
    }
    return Vector2(worldSize.x * 0.1, worldSize.y * 0.68);
  }
}
