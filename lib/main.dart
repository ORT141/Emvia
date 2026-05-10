import 'package:emvia/game/characters/liam/liam_journey.dart';
import 'package:emvia/game/emvia_game.dart';
import 'package:emvia/game/scenes/olya/path/path_detail_component.dart';
import 'package:emvia/game/overlays/olya/calm_map_overlay.dart';
import 'package:emvia/game/overlays/olya/calm_effect_overlay.dart';
import 'package:emvia/game/overlays/olya/calm_item_prompt_overlay.dart';
import 'package:emvia/game/overlays/dialog.dart';
import 'package:emvia/game/overlays/main_menu.dart';
import 'package:emvia/game/overlays/pause_menu.dart';
import 'package:emvia/game/overlays/mobile_controls_overlay.dart';
import 'package:emvia/game/backpack/backpack_overlay.dart';
import 'package:emvia/game/overlays/settings_overlay.dart';
import 'package:emvia/game/overlays/survey_overlay.dart';
import 'package:emvia/game/overlays/olya/stage_item_card_overlay.dart';
import 'package:emvia/game/overlays/debug_overlay.dart';
import 'package:emvia/game/overlays/liam/camera_overlay.dart';
import 'package:emvia/game/overlays/liam/cafe_scene_overlay.dart';
import 'package:emvia/game/overlays/liam_graffiti_survey_overlay.dart';
import 'package:emvia/game/scenes/olya/stress/stress_overlay.dart';
import 'package:emvia/game/overlays/olya/tap_game_overlay.dart';
import 'package:emvia/game/overlays/olya/pattern_progress_overlay.dart';
import 'package:emvia/game/overlays/olya/breathing_exercise_overlay.dart';
import 'package:emvia/game/overlays/olya/educational_card_overlay.dart';
import 'package:emvia/game/scenes/olya/corridor_scene.dart';
import 'package:emvia/game/scenes/olya/path/path_choice_scene.dart';
import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

import 'l10n/app_localizations_gen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SchedulerBinding.instance.addPersistentFrameCallback((_) {
    SchedulerBinding.instance.scheduleFrame();
  });

  FlameAudio.audioCache.prefix = 'assets/sounds/';

  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.dark;

  void _setLocale(Locale locale) => setState(() => _locale = locale);

  void _toggleTheme() => setState(
    () => _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark,
  );

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF88D4D0);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizationsGen.localizationsDelegates,
      supportedLocales: AppLocalizationsGen.supportedLocales,
      locale: _locale,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          primary: seedColor,
          secondary: const Color(0xFFA2D2FF),
          tertiary: const Color(0xFFFFC8DD),
          surface: const Color(0xFFF9F7F2),
        ),
        textTheme: GoogleFonts.baloo2TextTheme(ThemeData.light().textTheme),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
          primary: seedColor,
          secondary: const Color(0xFFA2D2FF),
          tertiary: const Color(0xFFFFC8DD),
          surface: const Color(0xFF1C1B1F),
        ),
        textTheme: GoogleFonts.baloo2TextTheme(ThemeData.dark().textTheme),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
      ),
      themeMode: _themeMode,
      home: GameWidget<EmviaGame>.controlled(
        gameFactory: EmviaGame.new,
        overlayBuilderMap: {
          'Dialog': (_, game) => DialogOverlay(game: game),
          'MainMenu': (_, game) => MainMenuOverlay(
            game: game,
            onLocaleChanged: _setLocale,
            onThemeToggled: _toggleTheme,
            isDarkMode: _themeMode == ThemeMode.dark,
          ),
          'PauseMenu': (_, game) => PauseMenuOverlay(game: game),
          'Settings': (_, game) => SettingsOverlay(
            game: game,
            onLocaleChanged: _setLocale,
            onThemeToggled: _toggleTheme,
            isDarkMode: _themeMode == ThemeMode.dark,
          ),
          'Survey': (_, game) => SurveyOverlay(game: game),
          'LiamGraffitiSurvey': (_, game) =>
              LiamGraffitiSurveyOverlay(game: game),
          'Backpack': (_, game) => BackpackOverlay(game: game),
          'StageItemCard': (_, game) => StageItemCardOverlay(game: game),
          'CalmingItemPrompt': (_, game) =>
              CalmingItemPromptOverlay(game: game),
          'CalmingEffect': (_, game) => CalmEffectOverlay(game: game),
          'MobileControls': (_, game) => MobileControlsOverlay(game: game),
          'Debug': (_, game) => DebugOverlay(
            game: game,
            onThemeToggled: _toggleTheme,
            isDarkMode: _themeMode == ThemeMode.dark,
          ),
          'Stress': (_, game) => StressOverlay(game: game),
          'Camera': (_, game) => CameraOverlay(game: game),
          'LiamCafeNear': (_, game) => CafeSceneOverlay(
            game: game,
            imagePath: 'assets/images/misc/liam-cafe-entrance/near.png',
            onDismiss: () {
              game.overlays.remove('LiamCafeNear');
              game.overlays.add('LiamCafeGrab');
            },
          ),
          'LiamCafeGrab': (_, game) => CafeSceneOverlay(
            game: game,
            imagePath:
                'assets/images/misc/liam-cafe-entrance/someone-holding-wheelchair.png',
            onDismiss: () {
              game.overlays.remove('LiamCafeGrab');
              LiamJourney.maybeShowCurrentNarrative(game);
            },
          ),
          'TapGame': (_, game) => TapGameOverlay(game: game),
          'BreathingExercise': (_, game) =>
              BreathingExerciseOverlay(game: game),
          'EducationalCard': (_, game) => EducationalCardOverlay(game: game),
          'CalmMap': (_, game) => CalmMapOverlay(game: game),
          'PatternProgress': (_, game) {
            final scene = game.currentScene;
            if (scene is CorridorScene) {
              return ValueListenableBuilder<int>(
                valueListenable: scene.collectedPatternsNotifier,
                builder: (context, value, _) {
                  return PatternProgressOverlay(
                    game: game,
                    collected: value,
                    total: scene.totalPatterns,
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
          'PathDetail': (_, game) => ValueListenableBuilder(
            valueListenable: game.pathDetailNotifier,
            builder: (context, value, child) {
              final info = value;
              if (info == null) return const SizedBox.shrink();
              return PathDetailComponent(
                index: info.index,
                title: info.title,
                name: info.name,
                description: info.description,
                confirmLabel: info.confirmLabel,
                cancelLabel: info.cancelLabel,
                onConfirm: () {
                  final scene = game.currentScene;
                  game.hidePathDetail();
                  game.clearPathSelection();
                  if (scene is PathChoiceScene) {
                    scene.confirmSelectedPath(info.index);
                  }
                },
                onCancel: () {
                  game.hidePathDetail();
                  game.clearPathSelection();
                },
              );
            },
          ),
        },
      ),
    );
  }
}
