import 'package:emvia/game/emvia_game.dart';
import 'package:emvia/overlays/breathing.dart';
import 'package:emvia/overlays/credits_overlay.dart';
import 'package:emvia/overlays/dialog.dart';
import 'package:emvia/overlays/main_menu.dart';
import 'package:emvia/overlays/pause_overlay.dart';
import 'package:emvia/overlays/settings_overlay.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'l10n/app_localizations_gen.dart';

void main() {
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
          'Breathing': (_, game) => BreathingOverlay(game: game),
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
          'Pause': (_, game) => PauseOverlay(game: game),
        },
      ),
    );
  }
}
