import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../dialog_model.dart';
import '../emvia_types.dart';
import '../survey_service.dart';

class GameSessionManager {
  int sceneIndex = 0;

  int _stressLevel = 100;
  final ValueNotifier<int> stressNotifier = ValueNotifier<int>(100);

  int get stressLevel => _stressLevel;
  set stressLevel(int value) {
    _stressLevel = value.clamp(0, 100);
    stressNotifier.value = _stressLevel;
  }

  int _sessionToken = 0;
  bool journeyCompleted = false;
  bool _startGameAfterSurvey = false;

  PlayableCharacter selectedCharacter = PlayableCharacter.olya;
  SurveyProfile surveyProfile = SurveyProfile(const {});

  final LinkedHashSet<String> _selectedTools = LinkedHashSet<String>();

  List<String> get selectedTools => List.unmodifiable(_selectedTools);

  final ValueNotifier<DialogNode?> currentNodeNotifier =
      ValueNotifier<DialogNode?>(null);
  DialogNode? get currentNode => currentNodeNotifier.value;
  set currentNode(DialogNode? value) => currentNodeNotifier.value = value;

  final ValueNotifier<PathDetailInfo?> pathDetailNotifier =
      ValueNotifier<PathDetailInfo?>(null);
  PathDetailInfo? get pathDetail => pathDetailNotifier.value;
  set pathDetail(PathDetailInfo? value) => pathDetailNotifier.value = value;

  int beginSession() => ++_sessionToken;

  bool isCurrentSession(int token) => token == _sessionToken;

  void markStartGameAfterSurvey() {
    _startGameAfterSurvey = true;
  }

  bool consumeStartGameAfterSurvey() {
    final shouldStart = _startGameAfterSurvey;
    _startGameAfterSurvey = false;
    return shouldStart;
  }

  void addSelectedTool(String toolId) {
    _selectedTools.add(toolId);
  }

  void toggleSelectedTool(String toolId) {
    if (!_selectedTools.remove(toolId)) {
      _selectedTools.add(toolId);
    }
  }

  void clearSelectedTools() {
    _selectedTools.clear();
  }

  void resetForNewJourney({required SurveyProfile profile}) {
    surveyProfile = profile;
    sceneIndex = 1;
    stressLevel = 100;
    journeyCompleted = false;
    clearSelectedTools();
    currentNode = null;
    pathDetail = null;
  }
}
