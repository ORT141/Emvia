import '../../scenes/olya/classroom_scene.dart';
import '../../models/captured_photo.dart';

abstract class GameState {
  bool isFrozen = false;
  double mobileMoveX = 0;
}

class OlyaGameState extends GameState {
  bool hasTriggeredStressScene = false;
  bool hasShownCorridorStressIntro = false;
  bool isCorridorStressIntroActive = false;
  ClassroomScene? classroomScene;
  bool hasUsedItemInStage = false;
}

class LiamGameState extends GameState {
  bool isCameraMode = false;

  static const int maxPhotos = 6;

  final List<CapturedPhoto> capturedPhotos = [];

  bool get canCaptureMore => capturedPhotos.length < maxPhotos;

  void addPhoto(CapturedPhoto photo) {
    if (canCaptureMore) capturedPhotos.add(photo);
  }
}
