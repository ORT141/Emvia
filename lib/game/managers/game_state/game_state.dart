import '../../scenes/olya/classroom_scene.dart';
import '../../models/captured_photo.dart';

abstract class GameState {
  bool isFrozen = false;
  double mobileMoveX = 0;

  void reset() {}
}

enum LiamBoundaryResponse { explain, joke, respondSharply }

enum LiamPhotoStyle { street, minimalism, lightShadow, portrait }

enum LiamNavColor { cyan, orange, red, green }

enum LiamSupportSymbol { heart, cat, star, wings }

enum LiamIrritation { blocksPath, intrusiveHelp, inconvenientLayout, othersDecide }

enum LiamCopingStyle { findWay, askHelp, tryMyself, avoid }

class OlyaGameState extends GameState {
  bool hasTriggeredStressScene = false;
  bool hasShownCorridorStressIntro = false;
  bool isCorridorStressIntroActive = false;
  ClassroomScene? classroomScene;
  bool hasUsedItemInStage = false;

  @override
  void reset() {
    hasTriggeredStressScene = false;
    hasShownCorridorStressIntro = false;
    isCorridorStressIntroActive = false;
    hasUsedItemInStage = false;
    classroomScene = null;
  }
}

class LiamGameState extends GameState {
  bool isCameraMode = false;

  static const int maxPhotos = 6;

  final List<CapturedPhoto> capturedPhotos = [];
  final Set<int> shownBriefings = <int>{};

  bool hasShownSilentIntro = false;
  bool hasShownCompletionDialog = false;
  LiamBoundaryResponse? boundaryResponse;

  // Graffiti scene survey answers
  bool hasCompletedGraffitiSurvey = false;
  LiamPhotoStyle? photoStyle;
  LiamNavColor? navColor;
  LiamSupportSymbol? supportSymbol;
  LiamIrritation? irritation;
  LiamCopingStyle? copingStyle;

  int get currentMissionIndex => capturedPhotos.length.clamp(0, maxPhotos);

  bool get isJourneyComplete => currentMissionIndex >= maxPhotos;

  bool get canCaptureMore => !isJourneyComplete;

  bool addPhoto(CapturedPhoto photo) {
    if (!canCaptureMore) return false;
    capturedPhotos.add(photo);
    return true;
  }

  bool markCurrentBriefingShown() => shownBriefings.add(currentMissionIndex);

  @override
  void reset() {
    isCameraMode = false;
    capturedPhotos.clear();
    shownBriefings.clear();
    hasShownSilentIntro = false;
    hasShownCompletionDialog = false;
    boundaryResponse = null;
    hasCompletedGraffitiSurvey = false;
    photoStyle = null;
    navColor = null;
    supportSymbol = null;
    irritation = null;
    copingStyle = null;
  }
}
