import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

import 'player.dart';

class EmviaGame extends FlameGame with TapCallbacks {
  late SpriteComponent background;
  late OlyaPlayer olya;
  late SpriteComponent noiseEffect;

  int sceneIndex = 0;
  bool isStressMode = false;
  String currentDialogKey = ""; // keys for localization

  @override
  Future<void> onLoad() async {
    background = SpriteComponent()
      ..sprite = await loadSprite('bg_classroom.jpg')
      ..size = size;
    add(background);

    olya = OlyaPlayer();
    add(olya);

    noiseEffect = SpriteComponent()
      ..sprite = await loadSprite('noise.jpg')
      ..size = size
      ..opacity = 0.0;
    add(noiseEffect);

    // show main menu at startup
    overlays.add('MainMenu');
  }

  void startGame() {
    sceneIndex = 0;
    showDialog('teacher_intro');
  }

  void goToCorridor() async {
    sceneIndex = 1;
    background.sprite = await loadSprite('bg_corridor.jpg');
    triggerStress();
  }

  void triggerStress() {
    isStressMode = true;
    noiseEffect.opacity = 0.5;
    overlays.add('Breathing');
    showDialog('too_loud');
  }

  void calmDown() {
    isStressMode = false;
    noiseEffect.opacity = 0.0;
    overlays.remove('Breathing');
    showDialog('calmed');
  }

  void showDialog(String key) {
    currentDialogKey = key;
    overlays.add('Dialog');
  }

  void pauseGame() {
    pauseEngine();
    overlays.add('Pause');
  }

  void resumeGame() {
    resumeEngine();
    overlays.remove('Pause');
  }

  @override
  void update(double dt) {
    // clamp large dt to avoid visible hitches on resume or frame drops
    dt = dt.clamp(0, 0.05);
    super.update(dt);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isStressMode && overlays.isActive('Dialog')) {
      overlays.remove('Dialog');
      if (sceneIndex == 0) goToCorridor();
    }

    // allow tapping the screen to pause for debugging / UX
    if (!overlays.isActive('Pause') && !overlays.isActive('MainMenu')) {
      // if user taps near the top-right, open pause (simple heuristic)
      // Not perfect but works cross-platform
      final pos = event.localPosition;
      if (pos.x > size.x - 60 && pos.y < 60) {
        pauseGame();
      }
    }
  }
}
