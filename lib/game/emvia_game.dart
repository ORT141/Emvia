import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:emvia/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'survey_service.dart';
import 'components/fade_overlay.dart';
import 'components/player.dart';
import 'scenes/game_scene.dart';
import 'scenes/classroom_scene.dart';
import 'scenes/corridor_scene.dart';
import 'scenes/path_choice_scene.dart';
import 'dialog_model.dart';
import 'inventory/backpack_inventory.dart';
import 'inventory/backpack_item.dart';

import 'mixins/dialog_handler.dart';
import 'emvia_types.dart';

import 'managers/camera_manager.dart';
import 'managers/transition_manager.dart';

enum PlayableCharacter { olya, liam, olenka, anton }

class EmviaGame extends FlameGame
    with TapCallbacks, HasKeyboardHandlerComponents, DialogHandler {
  static const double worldWidth = 2000.0;

  EmviaGame() {
    cameraManager = CameraManager(this);
    transitionManager = TransitionManager(this);
  }

  late final OlyaPlayer olya = OlyaPlayer();
  late FadeOverlay fadeOverlay;

  final PositionComponent worldRoot = PositionComponent();

  late final CameraManager cameraManager;
  late final TransitionManager transitionManager;

  GameScene? currentScene;
  ClassroomScene? classroomScene;

  bool freezeForPathChoice = false;

  int sceneIndex = 0;
  int _stressLevel = 0;
  final ValueNotifier<int> stressNotifier = ValueNotifier<int>(0);

  int get stressLevel => _stressLevel;
  set stressLevel(int value) {
    _stressLevel = value.clamp(0, 100);
    stressNotifier.value = _stressLevel;
  }

  int _sessionToken = 0;

  PlayableCharacter selectedCharacter = PlayableCharacter.olya;
  bool _startGameAfterSurvey = false;

  static const String _volumeKey = 'volume';
  static const String _soundEnabledKey = 'sound_enabled';

  double _volume = 0.6;
  bool _soundEnabled = true;

  double get volume => _soundEnabled ? _volume : 0.0;
  set volume(double value) {
    _volume = value.clamp(0.0, 1.0);
    _saveVolume();
  }

  bool get soundEnabled => _soundEnabled;
  set soundEnabled(bool value) {
    _soundEnabled = value;
    _saveSoundEnabled();
  }

  Future<void> _saveVolume() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_volumeKey, _volume);
    } catch (_) {}
  }

  Future<void> _saveSoundEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_soundEnabledKey, _soundEnabled);
    } catch (_) {}
  }

  final SurveyService _surveyService = SurveyService();
  SurveyProfile surveyProfile = SurveyProfile(const {});
  late final BackpackInventory backpack = BackpackInventory();

  double _mobileMoveX = 0;

  final List<String> _selectedTools = [];

  List<String> get selectedTools => List.unmodifiable(_selectedTools);

  final currentNodeNotifier = ValueNotifier<DialogNode?>(null);
  final pathDetailNotifier = ValueNotifier<PathDetailInfo?>(null);
  DialogNode? get currentNode => currentNodeNotifier.value;
  set currentNode(DialogNode? value) => currentNodeNotifier.value = value;

  DialogTree? currentTree;

  @override
  Future<void> onLoad() async {
    await _loadVolume();

    worldRoot.scale = Vector2.all(cameraManager.zoom);
    worldRoot.anchor = Anchor.topLeft;

    add(worldRoot);
    fadeOverlay = FadeOverlay();
    add(fadeOverlay);

    await loadScene(ClassroomScene());
    olya.opacity = 0;

    overlays.add('MainMenu');
  }

  void initializeInventory(BuildContext context) {
    if (backpack.items.isNotEmpty) return;
    for (final item in BackpackItem.initialItems(context)) {
      backpack.addItem(item);
    }
  }

  Future<void> loadScene(GameScene scene) async {
    await transitionManager.loadScene(scene);
    currentScene = scene;
    if (scene is ClassroomScene) {
      classroomScene = scene;
    }
  }

  void goToCorridor() async {
    await loadScene(CorridorScene());
    sceneIndex = 3;
    olya.opacity = 1;
    showMobileControls();
    overlays.add('Stress');
  }

  void _updateClassroomZoom() {
    transitionManager.updateClassroomZoom();
  }

  double sceneWorldWidth(double baseWidth) {
    final scene = currentScene;
    if (scene == null) return baseWidth;
    return scene.worldWidthForViewport(size);
  }

  void startGame() {
    if (selectedCharacter != PlayableCharacter.olya) return;
    _startGameFlow();
  }

  bool get isMobilePlatform {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  bool get isBackpackOpen => overlays.isActive('Backpack');
  bool get isDebugOpen => overlays.isActive('Debug');

  void toggleBackpack() {
    if (!_canToggleBackpack()) return;
    if (isBackpackOpen) {
      overlays.remove('Backpack');
    } else {
      overlays.add('Backpack');
    }
  }

  void equipTool(String toolId) {
    if (!_selectedTools.contains(toolId)) {
      _selectedTools.add(toolId);
    } else {
      _selectedTools.remove(toolId);
    }
  }

  void toggleDebug() {
    if (isDebugOpen) {
      overlays.remove('Debug');
    } else {
      overlays.add('Debug');
    }
  }

  bool _canToggleBackpack() {
    if (sceneIndex == 0) return false;
    if (transitionManager.isTransitioning) return false;
    if (overlays.isActive('MainMenu') || overlays.isActive('Pause')) {
      return false;
    }
    if (overlays.isActive('Survey') || overlays.isActive('Dialog')) {
      return false;
    }
    return true;
  }

  void setMobileMoveX(double direction) {
    if (freezeForPathChoice) return;
    _mobileMoveX = direction.clamp(-1.0, 1.0);
    olya.setMobileDirection(_mobileMoveX);
  }

  void showMobileControls() {
    if (!isMobilePlatform) return;
    if (!overlays.isActive('MobileControls')) {
      overlays.add('MobileControls');
    }
  }

  void hideMobileControls() {
    overlays.remove('MobileControls');
    setMobileMoveX(0);
  }

  void startNewGameSurveyFlow() {
    _startGameAfterSurvey = true;
    closeMainMenu();
    overlays.add('Survey');
  }

  Future<void> _loadVolume() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _volume = prefs.getDouble(_volumeKey) ?? _volume;
      _soundEnabled = prefs.getBool(_soundEnabledKey) ?? _soundEnabled;
    } catch (_) {}
  }

  void closeMainMenu() {
    overlays.remove('MainMenu');
    if (sceneIndex == 0 && currentScene is CorridorScene) {
      olya.opacity = 1;
    }
    if (!paused && sceneIndex > 0) {
      showMobileControls();
    }
  }

  void openMainMenu() {
    overlays.remove('Backpack');
    hideMobileControls();
    overlays.add('MainMenu');
  }

  bool consumeStartGameAfterSurvey() {
    final shouldStart = _startGameAfterSurvey;
    _startGameAfterSurvey = false;
    return shouldStart;
  }

  bool isCharacterUnlocked(PlayableCharacter character) {
    return character == PlayableCharacter.olya;
  }

  void selectCharacter(PlayableCharacter character) {
    if (!isCharacterUnlocked(character)) return;
    selectedCharacter = character;
  }

  Future<void> _startGameFlow() async {
    final token = ++_sessionToken;

    surveyProfile = await _surveyService.getProfile();
    sceneIndex = 1;
    stressLevel = 0;
    _selectedTools.clear();
    backpack.clear();

    overlays.remove('Dialog');
    overlays.remove('CalmMap');
    overlays.remove('PathChoice');
    overlays.remove('Backpack');

    await loadScene(ClassroomScene());

    if (token != _sessionToken) return;

    olya.opacity = 0;
    freezeForPathChoice = true;
    showMobileControls();
  }

  void showPathDetail(PathDetailInfo info) {
    pathDetailNotifier.value = info;
    overlays.add('PathDetail');
  }

  void hidePathDetail() {
    overlays.remove('PathDetail');
    pathDetailNotifier.value = null;
  }

  void clearPathSelection() {
    if (currentScene is PathChoiceScene) {
      (currentScene as PathChoiceScene).clearSelection();
    }
  }

  void showPathBackground() {
    classroomScene?.showPathImage();
  }

  void clearPathOverlay() {
    classroomScene?.clearPathOverlay();
  }

  void restoreClassroomBackground() {
    classroomScene?.showClassroomImage();
  }

  void chooseFirstPath(BuildContext context) {
    if (!context.mounted) return;
    final l = AppLocalizations.of(context)!;
    _selectedTools.add(l.classroom);
    _selectedTools.add(l.path_first);
    _finishPathChoice(l.map_of_calm_olya, l.first_path_description);
  }

  void chooseSecondPath(BuildContext context) {
    if (!context.mounted) return;
    final l = AppLocalizations.of(context)!;
    _selectedTools.add(l.classroom);
    _selectedTools.add(l.path_second);
    _finishPathChoice(l.map_of_calm_olya, l.second_path_description);
  }

  void chooseThirdPath(BuildContext context) {
    if (!context.mounted) return;
    final l = AppLocalizations.of(context)!;
    _selectedTools.add(l.classroom);
    _selectedTools.add(l.path_third);
    _finishPathChoice(l.map_of_calm_olya, l.third_path_description);
  }

  void _finishPathChoice(String title, String description) {
    sceneIndex = 2;
    olya.opacity = 1;
    freezeForPathChoice = false;
    classroomScene?.showClassroomImage();
    classroomScene?.clearMarks();
    _updateClassroomZoom();
    cameraManager.snapToPlayer(force: true);

    Future.delayed(const Duration(seconds: 1), () {
      goToCorridor();
    });
  }

  Future<void> applyPathChoice(int index, BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    _selectedTools.add(l.classroom);
    if (index == 0) {
      _selectedTools.add(l.path_first);
    } else if (index == 1) {
      _selectedTools.add(l.path_second);
    } else {
      _selectedTools.add(l.path_third);
    }

    freezeForPathChoice = false;
    await _transitionToCorridor();
  }

  Future<void> _transitionToCorridor() async {
    if (transitionManager.isTransitioning) return;
    sceneIndex = 3;
    await loadScene(CorridorScene());
    playerToCorridorEntrance();
  }

  void playerToCorridorEntrance() {
    olya.position.x = olya.size.x / 2 + 10;
    cameraManager.snapToPlayer(force: true);
  }

  void pauseGame() {
    overlays.remove('Backpack');
    hideMobileControls();
    pauseEngine();
    overlays.add('Pause');
  }

  void resumeGame() {
    resumeEngine();
    overlays.remove('Pause');
    showMobileControls();
  }

  void returnToMainMenuFromPause() {
    resumeEngine();
    overlays.remove('Pause');
    openMainMenu();
  }

  @override
  void update(double dt) {
    dt = dt.clamp(0, 0.05);
    super.update(dt);

    if (olya.parent == null) return;

    if (currentScene is ClassroomScene) {
      if (olya.position.x >= worldRoot.size.x - olya.size.x / 2 - 10) {
        _transitionToCorridor();
      }
    }

    cameraManager.update(dt);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    final scene = currentScene;
    if (scene is ClassroomScene && scene.isLoaded) {
      _updateClassroomZoom();
    } else {
      worldRoot.size = Vector2(
        scene != null ? sceneWorldWidth(worldWidth) : worldWidth,
        size.y,
      );
    }

    if (olya.parent != null) {
      final minX = olya.size.x / 2;
      final maxX = worldRoot.size.x - olya.size.x / 2;
      if (minX <= maxX) {
        olya.position.x = olya.position.x.clamp(minX, maxX).toDouble();
      } else {
        olya.position.x = worldRoot.size.x / 2;
      }
      olya.position.y = worldRoot.size.y * 0.75;
    }

    cameraManager.snapToPlayer();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!overlays.isActive('Pause') && !overlays.isActive('MainMenu')) {
      final pos = event.localPosition;
      if (pos.x > size.x - 60 && pos.y < 60) {
        pauseGame();
      }
    }
    currentScene?.onTapDown(event);
  }

  Vector2 sceneSpawnPoint(
    GameScene scene,
    Vector2 screenSize,
    PositionComponent root,
  ) {
    return scene.spawnPoint(screenSize, root.size);
  }
}
