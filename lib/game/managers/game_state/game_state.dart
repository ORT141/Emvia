import '../../scenes/olya/classroom_scene.dart';

abstract class GameState {
  bool isFrozen = false;
  double mobileMoveX = 0;
}

class OlyaGameState extends GameState {
  bool hasTriggeredStressScene = false;
  bool hasShownCorridorStressIntro = false;
  bool isCorridorStressIntroActive = false;
  ClassroomScene? classroomScene;
}

class LiamGameState extends GameState {
  bool isCameraMode = false;
}
