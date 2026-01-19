import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_gen_en.dart';
import 'app_localizations_gen_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizationsGen
/// returned by `AppLocalizationsGen.of(context)`.
///
/// Applications need to include `AppLocalizationsGen.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations_gen.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizationsGen.localizationsDelegates,
///   supportedLocales: AppLocalizationsGen.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizationsGen.supportedLocales
/// property.
abstract class AppLocalizationsGen {
  AppLocalizationsGen(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizationsGen? of(BuildContext context) {
    return Localizations.of<AppLocalizationsGen>(context, AppLocalizationsGen);
  }

  static const LocalizationsDelegate<AppLocalizationsGen> delegate =
      _AppLocalizationsGenDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('uk'),
  ];

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Emvia'**
  String get title;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @teacher_intro.
  ///
  /// In en, this message translates to:
  /// **'Teacher: Olya, your turn is in 15 minutes'**
  String get teacher_intro;

  /// No description provided for @too_loud.
  ///
  /// In en, this message translates to:
  /// **'It\'s too loud... need to calm down'**
  String get too_loud;

  /// No description provided for @calmed.
  ///
  /// In en, this message translates to:
  /// **'Phew... it\'s quieter now. moving on'**
  String get calmed;

  /// No description provided for @inhale.
  ///
  /// In en, this message translates to:
  /// **'inhale'**
  String get inhale;

  /// No description provided for @exhale.
  ///
  /// In en, this message translates to:
  /// **'exhale'**
  String get exhale;

  /// No description provided for @i_calm_down.
  ///
  /// In en, this message translates to:
  /// **'I calmed down'**
  String get i_calm_down;

  /// No description provided for @subtitle.
  ///
  /// In en, this message translates to:
  /// **'Find calm. Find courage.'**
  String get subtitle;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @headphones.
  ///
  /// In en, this message translates to:
  /// **'Headphones'**
  String get headphones;

  /// No description provided for @headphonesOff.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get headphonesOff;

  /// No description provided for @breathing.
  ///
  /// In en, this message translates to:
  /// **'Breathing'**
  String get breathing;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// No description provided for @exitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to quit?'**
  String get exitConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @backToMenu.
  ///
  /// In en, this message translates to:
  /// **'Main Menu'**
  String get backToMenu;

  /// No description provided for @thanksForPlaying.
  ///
  /// In en, this message translates to:
  /// **'Thank you for playing'**
  String get thanksForPlaying;

  /// No description provided for @leadDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Lead Developer'**
  String get leadDeveloper;

  /// No description provided for @artistAndDesigner.
  ///
  /// In en, this message translates to:
  /// **'Artist & Designer'**
  String get artistAndDesigner;

  /// No description provided for @breathingGuide.
  ///
  /// In en, this message translates to:
  /// **'Gentle guide for calming'**
  String get breathingGuide;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;
}

class _AppLocalizationsGenDelegate
    extends LocalizationsDelegate<AppLocalizationsGen> {
  const _AppLocalizationsGenDelegate();

  @override
  Future<AppLocalizationsGen> load(Locale locale) {
    return SynchronousFuture<AppLocalizationsGen>(
      lookupAppLocalizationsGen(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsGenDelegate old) => false;
}

AppLocalizationsGen lookupAppLocalizationsGen(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsGenEn();
    case 'uk':
      return AppLocalizationsGenUk();
  }

  throw FlutterError(
    'AppLocalizationsGen.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
