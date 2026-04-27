import 'package:flutter/material.dart';
import 'package:emvia/l10n/app_localizations_gen.dart';

extension ContextExtension on BuildContext {
  AppLocalizationsGen get l10n => AppLocalizationsGen.of(this)!;
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  Size get screenSize => MediaQuery.of(this).size;
}
