import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dialog/dialog_model.dart';
import '../emvia_types.dart';
import '../utils/survey_service.dart';

class GameSessionManager {
  int sceneIndex = 0;
  double? savedCorridorReturnX;

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

  PlayableCharacter selectedCharacter = PlayableCharacter.liam;
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
    save();
  }

  void toggleSelectedTool(String toolId) {
    if (!_selectedTools.remove(toolId)) {
      _selectedTools.add(toolId);
    }
    save();
  }

  void removeSelectedTool(String toolId) {
    if (_selectedTools.remove(toolId)) {
      save();
    }
  }

  void clearSelectedTools() {
    _selectedTools.clear();
    save();
  }

  void resetForNewJourney({required SurveyProfile profile}) {
    surveyProfile = profile;
    sceneIndex = 1;
    stressLevel = 100;
    journeyCompleted = false;
    clearSelectedTools();
    currentNode = null;
    pathDetail = null;
    save();
  }

  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('sceneIndex', sceneIndex);
      if (savedCorridorReturnX != null) {
        await prefs.setDouble('savedCorridorReturnX', savedCorridorReturnX!);
      } else {
        await prefs.remove('savedCorridorReturnX');
      }
      await prefs.setInt('stressLevel', _stressLevel);
      await prefs.setString('selectedCharacter', selectedCharacter.name);
      await prefs.setString('surveyProfile', jsonEncode(surveyProfile.answers));
      await prefs.setStringList('selectedTools', _selectedTools.toList());
      await prefs.setBool('journeyCompleted', journeyCompleted);
    } catch (_) {}
  }

  Future<bool> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('sceneIndex')) return false;

      sceneIndex = prefs.getInt('sceneIndex') ?? 0;
      savedCorridorReturnX = prefs.getDouble('savedCorridorReturnX');
      _stressLevel = prefs.getInt('stressLevel') ?? 100;
      stressNotifier.value = _stressLevel;

      final charName = prefs.getString('selectedCharacter');
      if (charName != null) {
        selectedCharacter = PlayableCharacter.values.firstWhere(
          (e) => e.name == charName,
          orElse: () => PlayableCharacter.liam,
        );
      }

      final surveyJson = prefs.getString('surveyProfile');
      if (surveyJson != null) {
        surveyProfile = SurveyProfile(
          Map<String, String>.from(jsonDecode(surveyJson)),
        );
      }

      final tools = prefs.getStringList('selectedTools');
      if (tools != null) {
        _selectedTools.clear();
        _selectedTools.addAll(tools);
      }

      journeyCompleted = prefs.getBool('journeyCompleted') ?? false;
      return true;
    } catch (_) {
      return false;
    }
  }
}
