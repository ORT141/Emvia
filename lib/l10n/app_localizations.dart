// Deprecated compatibility shim: prefer using generated `AppLocalizationsGen`.
// This file re-exports the generated public API so older imports keep working.

export 'app_localizations_gen.dart';

import 'package:flutter/widgets.dart';
import 'app_localizations_gen.dart';

abstract class AppLocalizations {
  static AppLocalizationsGen? of(BuildContext context) =>
      AppLocalizationsGen.of(context);
}
