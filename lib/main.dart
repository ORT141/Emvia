// import 'package:device_preview/device_preview.dart';
import 'package:emvia/game/emvia_game.dart';
import 'package:emvia/game/scenes/path/path_detail_component.dart';
import 'package:emvia/game/overlays/calm_map_overlay.dart';
import 'package:emvia/game/overlays/credits_overlay.dart';
import 'package:emvia/game/overlays/dialog.dart';
import 'package:emvia/game/overlays/main_menu.dart';
import 'package:emvia/game/overlays/mobile_controls_overlay.dart';
import 'package:emvia/game/backpack/backpack_overlay.dart';
import 'package:emvia/game/overlays/settings_overlay.dart';
import 'package:emvia/game/overlays/survey_overlay.dart';
import 'package:emvia/game/overlays/debug_overlay.dart';
import 'package:emvia/game/scenes/stress/stress_overlay.dart';
import 'package:emvia/game/overlays/tap_game_overlay.dart';
import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'l10n/app_localizations_gen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlameAudio.audioCache.prefix = 'assets/sounds/';

  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  //runApp(
  //  DevicePreview(
  //    builder: (context) => MyApp(),
  //  ),
  //);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale = const Locale('uk');
  ThemeMode _themeMode = ThemeMode.light;

  void _setLocale(Locale locale) => setState(() => _locale = locale);

  void _toggleTheme() => setState(
    () => _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light,
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
          'Settings': (_, game) => SettingsOverlay(
            game: game,
            onLocaleChanged: _setLocale,
            onThemeToggled: _toggleTheme,
            isDarkMode: _themeMode == ThemeMode.dark,
          ),
          'Credits': (_, game) => CreditsOverlay(game: game),
          'Survey': (_, game) => SurveyOverlay(game: game),
          'Backpack': (_, game) => BackpackOverlay(game: game),
          'MobileControls': (_, game) => MobileControlsOverlay(game: game),
          'Debug': (_, game) => DebugOverlay(game: game),
          'Stress': (_, game) => StressOverlay(game: game),
          'TapGame': (_, game) => TapGameOverlay(game: game),
          'CalmMap': (_, game) => CalmMapOverlay(game: game),
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
                  game.applyPathChoice(info.index, game.buildContext!);
                  game.hidePathDetail();
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
