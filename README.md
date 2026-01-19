# emvia

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## Localization (i18n)

I added initial support for Ukrainian and ARB files in `lib/l10n/`.
To generate Flutter's localization classes run:

1. `flutter pub get`
2. `flutter gen-l10n`

This will create a generated localization class according to `l10n.yaml` (file: `lib/l10n/app_localizations_gen.dart`).
You can then replace the temporary `AppLocalizations` with the generated one for a fully standard workflow.
