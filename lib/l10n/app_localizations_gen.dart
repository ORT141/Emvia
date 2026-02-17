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

  /// The main title of the application or game.
  ///
  /// In en, this message translates to:
  /// **'Emvia'**
  String get title;

  /// Label for the action to start the game or experience.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// Label for the settings menu.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Label for the action to quit the application or game.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// Label for pausing the current activity.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// Label for resuming a paused activity.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// A line spoken by the teacher to Olya, indicating her turn time.
  ///
  /// In en, this message translates to:
  /// **'Teacher: Olya, your turn is in 15 minutes'**
  String get teacher_intro;

  /// Player's internal thought or statement indicating distress due to high volume and the need to calm down.
  ///
  /// In en, this message translates to:
  /// **'It\'s too loud... need to calm down'**
  String get too_loud;

  /// Player's statement after successfully calming down, noting the quieter environment.
  ///
  /// In en, this message translates to:
  /// **'Phew... it\'s quieter now. moving on'**
  String get calmed;

  /// Instruction or label for the breathing in action.
  ///
  /// In en, this message translates to:
  /// **'inhale'**
  String get inhale;

  /// Instruction or label for the breathing out action.
  ///
  /// In en, this message translates to:
  /// **'exhale'**
  String get exhale;

  /// Confirmation that the player has successfully managed to calm down.
  ///
  /// In en, this message translates to:
  /// **'I calmed down'**
  String get i_calm_down;

  /// A tagline or subtitle for the experience, emphasizing the themes of calm and courage.
  ///
  /// In en, this message translates to:
  /// **'Find calm. Find courage.'**
  String get subtitle;

  /// General label for proceeding to the next step or screen.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// Label related to headphone settings or an instruction to use them.
  ///
  /// In en, this message translates to:
  /// **'Headphones'**
  String get headphones;

  /// Potentially a state or alternative setting when headphones are off, linked to the 'Calm' theme.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get headphonesOff;

  /// Label for the breathing exercise section or setting.
  ///
  /// In en, this message translates to:
  /// **'Breathing'**
  String get breathing;

  /// Label for the credits screen.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// Confirmation prompt message before exiting.
  ///
  /// In en, this message translates to:
  /// **'Do you want to quit?'**
  String get exitConfirm;

  /// Label for canceling an action or closing a dialog.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Label to return to the main menu screen.
  ///
  /// In en, this message translates to:
  /// **'Main Menu'**
  String get backToMenu;

  /// Closing message after the game or session ends.
  ///
  /// In en, this message translates to:
  /// **'Thank you for playing'**
  String get thanksForPlaying;

  /// Title for the lead developer in the credits.
  ///
  /// In en, this message translates to:
  /// **'Lead Developer'**
  String get leadDeveloper;

  /// Title for the artist and designer in the credits.
  ///
  /// In en, this message translates to:
  /// **'Artist & Designer'**
  String get artistAndDesigner;

  /// Title or description for the breathing guidance feature.
  ///
  /// In en, this message translates to:
  /// **'Gentle guide for calming'**
  String get breathingGuide;

  /// Label for sound settings.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// Label for the language selection setting.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Label for confirming changes or completing a task.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Label for theme selection setting.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Option for the light theme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Option for the dark theme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Initial greeting from the Mysterious Stranger character to Olya.
  ///
  /// In en, this message translates to:
  /// **'Mysterious Stranger: Hello Olya! Welcome to this peaceful place.'**
  String get npc_greeting;

  /// Name label for the teacher speaker
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get speaker_teacher;

  /// Teacher opening line asking if the player is ready
  ///
  /// In en, this message translates to:
  /// **'Welcome to the class! Are you ready to begin?'**
  String get dialog_teacher_start;

  /// Affirmative response by player
  ///
  /// In en, this message translates to:
  /// **'Yes, professor'**
  String get dialog_teacher_choice_yes;

  /// Negative unsure response by player
  ///
  /// In en, this message translates to:
  /// **'Not really...'**
  String get dialog_teacher_choice_not_really;

  /// Teacher tells students to open books
  ///
  /// In en, this message translates to:
  /// **'Excellent. Let us start by opening your books to page 42.'**
  String get dialog_teacher_ready;

  /// Teacher tells player to take time
  ///
  /// In en, this message translates to:
  /// **'Oh? Take your time. Let me know when you are settled.'**
  String get dialog_teacher_not_ready;

  /// Teacher asks for questions
  ///
  /// In en, this message translates to:
  /// **'Any questions before we start?'**
  String get dialog_teacher_end;

  /// Player agrees to start
  ///
  /// In en, this message translates to:
  /// **'No, let\'s go!'**
  String get dialog_teacher_choice_no_lets_go;

  /// Player asks which book
  ///
  /// In en, this message translates to:
  /// **'What book?'**
  String get dialog_teacher_choice_what_book;

  /// Teacher answers which book
  ///
  /// In en, this message translates to:
  /// **'The history book, of course! Focus, please.'**
  String get dialog_teacher_what_book;

  /// Name label for the stranger speaker
  ///
  /// In en, this message translates to:
  /// **'Stranger'**
  String get speaker_stranger;

  /// Stranger initial greeting
  ///
  /// In en, this message translates to:
  /// **'Hey you. You look like you\'re from out of town.'**
  String get dialog_stranger_entry;

  /// Player confirms they're from out of town
  ///
  /// In en, this message translates to:
  /// **'I am.'**
  String get dialog_stranger_choice_i_am;

  /// Player responds rudely
  ///
  /// In en, this message translates to:
  /// **'Mind your business.'**
  String get dialog_stranger_choice_mind_your_business;

  /// Stranger warns player to be careful
  ///
  /// In en, this message translates to:
  /// **'Thought so. Be careful around here after dark.'**
  String get dialog_stranger_from_out;

  /// Stranger replies rudely and triggers effect
  ///
  /// In en, this message translates to:
  /// **'Suit yourself. Don\'t say I didn\'t warn you.'**
  String get dialog_stranger_rude;

  /// Line shown after calming down
  ///
  /// In en, this message translates to:
  /// **'You feel much better now.'**
  String get dialog_calmed_you_feel_better;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get lang_en;

  /// Ukrainian language name
  ///
  /// In en, this message translates to:
  /// **'Українська'**
  String get lang_uk;
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
