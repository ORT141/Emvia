# Emvia

A competitive Flutter & Flame game project focusing on narrative exploration and emotional resilience.

## Overview

Emvia is a story-driven game where players navigate social environments, manage stress, and make impactful decisions. Built with the **Flame** engine, it features:

- **Character Selection**: Choose between multiple playable characters (Olya, Liam, Olenka, Anton).
- **Narrative Scenes**: Explore different environments like classrooms and corridors.
- **Dynamic Dialogs**: Complex conversation systems with branching paths.
- **Inventory System**: Manage a backpack with items that affect gameplay.
- **Stress Management**: UI and gameplay mechanics centered around psychological well-being.
- **Survey System**: In-game assessments to track player progress or states.

## Getting Started

1. **Prerequisites**: Ensure you have Flutter installed.
2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```
3. **Run the Project**:
   ```bash
   flutter run
   ```

## Project Structure

- `lib/game/`: Core game logic, including the `EmviaGame` class.
- `lib/game/components/`: Reusable game components (Player, NPC, UI buttons).
- `lib/game/scenes/`: Different game environments (Classroom, Corridor).
- `lib/overlays/`: Game UI overlays (Main Menu, Inventory, Settings, Survey).
- `lib/l10n/`: Localization files for multi-language support.

## Localization (i18n)

Emvia supports **English** and **Ukrainian**.

To generate localization classes:

1. `flutter pub get`
2. `flutter gen-l10n`

This uses `l10n.yaml` and the ARB files in `lib/l10n/` to generate `app_localizations.dart`.
