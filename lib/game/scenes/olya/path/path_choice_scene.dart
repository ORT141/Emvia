import 'package:emvia/game/emvia_types.dart';
import 'package:emvia/game/utils/ui_utils.dart';
import 'package:emvia/game/emvia_game.dart';
import 'package:flame/components.dart';
import 'package:emvia/l10n/app_localizations.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import '../../../utils/cover_scaling.dart';
import 'path_mark.dart';
import '../../game_scene.dart';

class PathChoiceScene extends GameScene with CoverScaling {
  PathChoiceScene()
    : super(
        backgroundPath: 'scenes/olya/classroom/path.png',
        showPlayer: false,
      ) {
    GameScene.register(() => PathChoiceScene());
  }

  @override
  double worldWidthForViewport(Vector2 viewportSize) => viewportSize.x;

  @override
  int get sceneIndex => 2;

  @override
  Vector2 spawnPoint(Vector2 viewportSize, Vector2 worldSize) =>
      Vector2(viewportSize.x / 2, worldSize.y / 2);

  final List<Vector2> _marks = <Vector2>[];
  final List<PathMark> _markCircles = <PathMark>[];
  int? _selectedMarkIndex;

  Future<void> Function()? _stopPathAudio;

  static const _pathSoundFiles = {
    'en': [
      'through the library.mp3',
      'main corridor.mp3',
      'through the schoolyard.mp3',
    ],
    'uk': [
      'через бібліотеку.mp3',
      'головний коридор.mp3',
      'через шкільний двір.mp3',
    ],
  };

  final double _bgHeight = 0;

  double get bgHeight => _bgHeight > 0 ? _bgHeight : game.size.y;

  @override
  void layoutToWorld() {
    setupCoverWorld();

    applyCoverScaling(background);

    if (foreground != null) {
      applyCoverScaling(foreground!);
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    foreground?.opacity = 0.0;

    background.opacity = 1.0;

    try {
      final allFiles = <String>[];
      allFiles.addAll(_pathSoundFiles['en']!);
      allFiles.addAll(_pathSoundFiles['uk']!);
      await FlameAudio.audioCache.loadAll(
        allFiles.map((f) => 'paths/$f').toList(),
      );
    } catch (_) {}

    await showMarks([
      Vector2(0.4346, 0.3160),
      Vector2(0.4865, 0.3793),
      Vector2(0.5225, 0.4526),
    ]);
  }

  Future<void> showMarks(List<Vector2> marksNormalized) async {
    await clearMarks();
    _marks.addAll(marksNormalized);

    for (var i = 0; i < _marks.length; i++) {
      final pos =
          background.position +
          Vector2(
            _marks[i].x * background.size.x,
            _marks[i].y * background.size.y,
          );
      final mark = PathMark(
        index: i,
        position: pos,
        onSelected: _onMarkSelected,
      );
      _markCircles.add(mark);
      add(mark);
    }
  }

  void _onMarkSelected(int index) {
    _selectedMarkIndex = index;
    for (var i = 0; i < _markCircles.length; i++) {
      _markCircles[i].isSelected = (i == _selectedMarkIndex);
    }
    _playPathSound(index);
    _showDetailForIndex(index);
  }

  void _playPathSound(int index) async {
    try {
      String lang;
      if (game.buildContext != null) {
        final locale = Localizations.localeOf(game.buildContext!);
        lang = locale.languageCode == 'uk' ? 'uk' : 'en';
      } else {
        final plat = WidgetsBinding.instance.platformDispatcher.locale;
        lang = plat.languageCode == 'uk' ? 'uk' : 'en';
      }
      final files = _pathSoundFiles[lang]!;
      if (index < 0 || index >= files.length) return;
      await _stopPathAudio?.call();

      final player = await FlameAudio.play(
        'paths/${files[index]}',
        volume: game.volume,
      );
      _stopPathAudio = player.stop;
    } catch (_) {}
  }

  void _showDetailForIndex(int index) {
    final l = AppLocalizations.of(game.buildContext!);
    final info = PathDetailInfo(
      index: index,
      name: index == 0
          ? (l?.path_second ?? 'Second Path')
          : index == 1
          ? (l?.path_first ?? 'First Path')
          : (l?.path_third ?? 'Third Path'),
      title: l?.map_of_calm_olya ?? 'Map of Calm: Olya',
      description: index == 0
          ? (l?.second_path_description ?? '')
          : index == 1
          ? (l?.first_path_description ?? '')
          : (l?.third_path_description ?? ''),
      confirmLabel: l?.confirm ?? 'Confirm',
      cancelLabel: l?.cancel ?? 'Cancel',
    );

    game.showPathDetail(info);
  }

  Future<void> clearMarks() async {
    for (final c in _markCircles) {
      c.removeFromParent();
    }
    _markCircles.clear();
    _marks.clear();
    _selectedMarkIndex = null;
    _stopPathAudio?.call();
  }

  void clearSelection() {
    _selectedMarkIndex = null;
    for (var i = 0; i < _markCircles.length; i++) {
      _markCircles[i].isSelected = false;
    }
    _stopPathAudio?.call();
    _stopPathAudio = null;
  }

  Future<void> confirmSelectedPath(int index) async {
    final context = game.buildContext;
    if (context == null || !context.mounted) return;
    final l = AppLocalizationsGen.of(context)!;
    _recordPathChoice(l, index);

    if (index == 1 || index == 2) {
      await UIUtils.showWarningDialog(context, l.too_dangerous);
    }
    await _applyPathChoice(index, l);
  }

  Future<void> _applyPathChoice(int index, AppLocalizationsGen l) async {
    _recordPathChoice(l, index);

    if (index == 1 || index == 2) {
      game.stressLevel = 100;
    }

    if (index == 0) {
      await game.navigationManager.goToCorridor();
    } else if (index == 1) {
      await game.navigationManager.goToSecondCorridor();
    } else {
      await game.navigationManager.goToOutside();
    }
  }

  void _recordPathChoice(AppLocalizationsGen l, int index) {
    game.session.addSelectedTool(l.classroom);
    game.session.addSelectedTool(_pathLabelForIndex(l, index));
  }

  String _pathLabelForIndex(AppLocalizationsGen l, int index) {
    switch (index) {
      case 0:
        return l.path_first;
      case 1:
        return l.path_second;
      default:
        return l.path_third;
    }
  }

  @override
  void onRemove() {
    _stopPathAudio?.call();
    _stopPathAudio = null;
    super.onRemove();
  }
}
