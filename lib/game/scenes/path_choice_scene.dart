import 'dart:math' as math;

import 'package:emvia/game/emvia_types.dart';
import 'package:flame/components.dart';
import 'package:emvia/l10n/app_localizations.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/widgets.dart';

import '../components/path_mark.dart';
import 'game_scene.dart';

class PathChoiceScene extends GameScene {
  PathChoiceScene()
    : super(
        backgroundPath: 'scenes/classroom/classroom.png',
        foregroundPath: 'scenes/classroom/classmates.png',
      );

  @override
  double worldWidthForViewport(Vector2 viewportSize) => viewportSize.x;

  @override
  Vector2 spawnPoint(Vector2 viewportSize, Vector2 worldSize) =>
      Vector2(viewportSize.x / 2, viewportSize.y / 2);

  SpriteComponent? _pathOverlay;
  Vector2? _pathBgSrcSize;

  final List<Vector2> _marks = <Vector2>[];
  final List<PathMark> _markCircles = <PathMark>[];
  int? _selectedMarkIndex;

  Future<void> Function()? _stopPathAudio;

  static const _pathSoundFiles = {
    'en': [
      'main corridor.mp3',
      'through the library.mp3',
      'through the schoolyard.mp3',
    ],
    'uk': [
      'головний коридор.mp3',
      'через бібліотеку.mp3',
      'через шкільний двір.mp3',
    ],
  };

  final double _bgHeight = 0;

  double get bgHeight => _bgHeight > 0 ? _bgHeight : game.size.y;

  @override
  void layoutToWorld() {
    game.cameraManager.zoom = 1.0;
    game.worldRoot.scale = Vector2.all(1.0);
    game.worldRoot.size = game.size.clone();

    if (_pathBgSrcSize != null && foreground?.opacity == 0) {
      final covered = _coverSize(_pathBgSrcSize!, game.size);
      background.size = covered;
      background.position = _coverPosition(covered, game.size);
    }
  }

  Vector2 _coverSize(Vector2 src, Vector2 target) {
    final scale = math.max(target.x / src.x, target.y / src.y);
    return Vector2(src.x * scale, src.y * scale);
  }

  Vector2 _coverPosition(Vector2 covered, Vector2 target) =>
      Vector2((target.x - covered.x) / 2, (target.y - covered.y) / 2);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    game.isFrozen = true;

    final sprite = await game.loadSprite('scenes/classroom/path.png');
    background.sprite = sprite;
    _pathBgSrcSize = sprite.srcSize.clone();
    final covered = _coverSize(_pathBgSrcSize!, game.size);
    background.size = covered;
    background.position = _coverPosition(covered, game.size);
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

  Future<void> showPathOverlay(String asset) async {
    final sprite = await game.loadSprite(asset);
    final covered = _coverSize(sprite.srcSize, game.size);
    final pos = _coverPosition(covered, game.size);
    if (_pathOverlay == null) {
      _pathOverlay = SpriteComponent(
        sprite: sprite,
        size: covered,
        anchor: Anchor.topLeft,
        position: pos,
        priority: 5,
      );
      add(_pathOverlay!);
    } else {
      _pathOverlay!.sprite = sprite;
      _pathOverlay!.size = covered;
      _pathOverlay!.position = pos;
    }
  }

  Future<void> clearPathOverlay() async {
    if (_pathOverlay != null) {
      _pathOverlay!.removeFromParent();
      _pathOverlay = null;
    }
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
          ? (l?.path_first ?? 'First Path')
          : index == 1
          ? (l?.path_second ?? 'Second Path')
          : (l?.path_third ?? 'Third Path'),
      title: l?.map_of_calm_olya ?? 'Map of Calm: Olya',
      description: index == 0
          ? (l?.first_path_description ?? '')
          : index == 1
          ? (l?.second_path_description ?? '')
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
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      final overlaySprite = _pathOverlay?.sprite;
      if (overlaySprite != null) {
        final covered = _coverSize(overlaySprite.srcSize, size);
        _pathOverlay!.size = covered;
        _pathOverlay!.position = _coverPosition(covered, size);
      }
      for (var i = 0; i < _marks.length; i++) {
        final m = _marks[i];
        final mark = _markCircles.length > i ? _markCircles[i] : null;
        if (mark != null) {
          mark.position =
              background.position +
              Vector2(m.x * background.size.x, m.y * background.size.y);
        }
      }
    }
  }
}
