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

  /// Label for returning to the main menu from a pause screen.
  ///
  /// In en, this message translates to:
  /// **'Return to menu'**
  String get return_to_menu;

  /// Warning message when a path is locked.
  ///
  /// In en, this message translates to:
  /// **'This way are too dangerous'**
  String get too_dangerous;

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

  /// Status label shown while the calming effect is active.
  ///
  /// In en, this message translates to:
  /// **'Calming...'**
  String get calming;

  /// Caption shown under the stress meter when it first appears in the corridor.
  ///
  /// In en, this message translates to:
  /// **'Olya\'s stress level.'**
  String get stress_intro_caption;

  /// Short reminder to monitor the stress meter.
  ///
  /// In en, this message translates to:
  /// **'Keep an eye on it'**
  String get stress_intro_watch;

  /// Tip shown when the tap stress mini-game starts.
  ///
  /// In en, this message translates to:
  /// **'Tap fast to calm down'**
  String get tap_game_tip;

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

  /// Title shown at the start of the breathing exercise overlay.
  ///
  /// In en, this message translates to:
  /// **'Breathing Exercise'**
  String get breathing_title;

  /// Label for the current breathing cycle count.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get breathing_cycle;

  /// Instruction shown on the breathing overlay to tap the screen.
  ///
  /// In en, this message translates to:
  /// **'Tap to advance to the next step'**
  String get breathing_tap_to_advance;

  /// Text shown when the breathing exercise is complete.
  ///
  /// In en, this message translates to:
  /// **'Well done!'**
  String get breathing_done;

  /// Button label for returning to the path choice map.
  ///
  /// In en, this message translates to:
  /// **'Back to map'**
  String get breathing_back_to_map;

  /// Label for the inhale phase of the breathing exercise.
  ///
  /// In en, this message translates to:
  /// **'inhale'**
  String get breathing_inhale;

  /// Label for the exhale phase of the breathing exercise.
  ///
  /// In en, this message translates to:
  /// **'exhale'**
  String get breathing_exhale;

  /// Instruction or label for holding the breath.
  ///
  /// In en, this message translates to:
  /// **'hold'**
  String get breathing_hold;

  /// Guidance text for the inhale phase.
  ///
  /// In en, this message translates to:
  /// **'Slowly inhale through your nose.'**
  String get breathing_inhale_instruction;

  /// Guidance text for the hold phase.
  ///
  /// In en, this message translates to:
  /// **'Hold your breath.'**
  String get breathing_hold_instruction;

  /// Guidance text for the exhale phase.
  ///
  /// In en, this message translates to:
  /// **'Slowly exhale through your mouth like a straw.'**
  String get breathing_exhale_instruction;

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

  /// Label for using an item from the stage item card.
  ///
  /// In en, this message translates to:
  /// **'Use Item'**
  String get useItem;

  /// Tooltip title prompting the player to use the calming item.
  ///
  /// In en, this message translates to:
  /// **'Calming item ahead'**
  String get calmingItemTooltipTitle;

  /// Tooltip text explaining that the player should tap the calming item.
  ///
  /// In en, this message translates to:
  /// **'Tap the calming item on the screen to relax and lower your stress.'**
  String get calmingItemTooltipBody;

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

  /// Question asked at the start of the game about sound preference.
  ///
  /// In en, this message translates to:
  /// **'Before we start, do you want to play with sound?'**
  String get sound_question_title;

  /// Option to enable sound.
  ///
  /// In en, this message translates to:
  /// **'Sound On'**
  String get sound_on;

  /// Option to disable sound.
  ///
  /// In en, this message translates to:
  /// **'Sound Off'**
  String get sound_off;

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

  /// No description provided for @item_headphones_name.
  ///
  /// In en, this message translates to:
  /// **'Sensory headphones'**
  String get item_headphones_name;

  /// No description provided for @item_headphones_status.
  ///
  /// In en, this message translates to:
  /// **'Exactly what\'s needed! (Click to equip)'**
  String get item_headphones_status;

  /// No description provided for @item_headphones_desc.
  ///
  /// In en, this message translates to:
  /// **'A reliable shield against chaos. They instantly block out excess stimuli and harsh sounds, helping to create a personal safe zone even in the noisiest corridor.'**
  String get item_headphones_desc;

  /// No description provided for @item_blanket_name.
  ///
  /// In en, this message translates to:
  /// **'Weighted blanket'**
  String get item_blanket_name;

  /// No description provided for @item_blanket_status.
  ///
  /// In en, this message translates to:
  /// **'Unavailable right now'**
  String get item_blanket_status;

  /// No description provided for @item_blanket_desc.
  ///
  /// In en, this message translates to:
  /// **'The sensation of deep pressure perfectly relieves overload and provides a feeling of a safety \"cocoon\". But it is impossible to take it with you into a noisy corridor. Look for something more mobile!'**
  String get item_blanket_desc;

  /// No description provided for @item_lunchbox_name.
  ///
  /// In en, this message translates to:
  /// **'Lunch box'**
  String get item_lunchbox_name;

  /// No description provided for @item_lunchbox_status.
  ///
  /// In en, this message translates to:
  /// **'Access restricted'**
  String get item_lunchbox_status;

  /// No description provided for @item_lunchbox_desc.
  ///
  /// In en, this message translates to:
  /// **'Familiar and safe food in your own box is important for comfort away from home. But right now the problem isn\'t hunger, it\'s the noise level! This item won\'t help here.'**
  String get item_lunchbox_desc;

  /// No description provided for @stage_item_not_chosen_status.
  ///
  /// In en, this message translates to:
  /// **'You did not select this item'**
  String get stage_item_not_chosen_status;

  /// No description provided for @stage_item_book_title.
  ///
  /// In en, this message translates to:
  /// **'Thick book'**
  String get stage_item_book_title;

  /// No description provided for @stage_item_book_description.
  ///
  /// In en, this message translates to:
  /// **'Page turning can be very soothing. Repeated motions create a sense of control. Tactile sensations like paper rustle and texture help regulate the nervous system. A good calming resource.'**
  String get stage_item_book_description;

  /// No description provided for @stage_item_bag_of_rocks_title.
  ///
  /// In en, this message translates to:
  /// **'Pouch with smooth pebbles'**
  String get stage_item_bag_of_rocks_title;

  /// No description provided for @stage_item_bag_of_rocks_description.
  ///
  /// In en, this message translates to:
  /// **'Works as a self-regulation tool through tactile sensation and repetitive motion. Touching smooth pebbles reduces tension. A good calming resource.'**
  String get stage_item_bag_of_rocks_description;

  /// No description provided for @stage_item_hibuki_title.
  ///
  /// In en, this message translates to:
  /// **'Hibuki'**
  String get stage_item_hibuki_title;

  /// No description provided for @stage_item_hibuki_description.
  ///
  /// In en, this message translates to:
  /// **'A soft therapy toy dog used for emotional support, especially for children recovering from stress or trauma. Anxiety goes down with hugs because deep pressure soothes the nervous system. A good calming resource.'**
  String get stage_item_hibuki_description;

  /// No description provided for @stage_item_rocking_chair_title.
  ///
  /// In en, this message translates to:
  /// **'Rocking chair'**
  String get stage_item_rocking_chair_title;

  /// No description provided for @stage_item_rocking_chair_description.
  ///
  /// In en, this message translates to:
  /// **'Helps calm, release tension, and regulate movement through rocking. Swaying lets the nervous system switch gears and lower anxiety. A good calming resource.'**
  String get stage_item_rocking_chair_description;

  /// Label for using an item from the backpack.
  ///
  /// In en, this message translates to:
  /// **'Use Item'**
  String get use_item;

  /// No description provided for @backpack_title.
  ///
  /// In en, this message translates to:
  /// **'Backpack'**
  String get backpack_title;

  /// No description provided for @no_items.
  ///
  /// In en, this message translates to:
  /// **'No items yet. Explore to collect more.'**
  String get no_items;

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

  /// Title for the onboarding survey
  ///
  /// In en, this message translates to:
  /// **'Little Questionnaire'**
  String get survey_title;

  /// Question about color preference
  ///
  /// In en, this message translates to:
  /// **'What colors do you like more?'**
  String get survey_question_color;

  /// Question about atmosphere preference
  ///
  /// In en, this message translates to:
  /// **'What atmosphere do you prefer?'**
  String get survey_question_atmosphere;

  /// Question about brightness preference
  ///
  /// In en, this message translates to:
  /// **'What kind of room lighting do you like?'**
  String get survey_question_brightness;

  /// Option for blue color
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get survey_option_blue;

  /// Option for green color
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get survey_option_green;

  /// Option for warm color
  ///
  /// In en, this message translates to:
  /// **'Warm'**
  String get survey_option_warm;

  /// Option for calm atmosphere
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get survey_option_calm;

  /// Option for energetic atmosphere
  ///
  /// In en, this message translates to:
  /// **'Energetic'**
  String get survey_option_energetic;

  /// Option for bright lighting
  ///
  /// In en, this message translates to:
  /// **'Bright'**
  String get survey_option_bright;

  /// Option for dim lighting
  ///
  /// In en, this message translates to:
  /// **'Dim'**
  String get survey_option_dim;

  /// Olya name + age
  ///
  /// In en, this message translates to:
  /// **'Olya, 14 years'**
  String get character_olya_title;

  /// Olya short quote
  ///
  /// In en, this message translates to:
  /// **'\"I won\'t speak - I will show\"'**
  String get character_olya_quote;

  /// Olya trait description
  ///
  /// In en, this message translates to:
  /// **'Autistic spectrum (ASD), hypersensitivity to loud sounds, bright light and chaos.'**
  String get character_olya_trait;

  /// Olya super power
  ///
  /// In en, this message translates to:
  /// **'Remembers and structures space through visual patterns, drawings and geometry.'**
  String get character_olya_superPower;

  /// Olya long description
  ///
  /// In en, this message translates to:
  /// **'For Olya the world often feels like a crowded highway without signs. She creates her own \"Map of Calm\" and turns sensory noise into art.'**
  String get character_olya_description;

  /// Liam name + age
  ///
  /// In en, this message translates to:
  /// **'Liam, 15 years'**
  String get character_liam_title;

  /// Liam short quote
  ///
  /// In en, this message translates to:
  /// **'\"It\'s not about style. It\'s about level\"'**
  String get character_liam_quote;

  /// Liam trait description
  ///
  /// In en, this message translates to:
  /// **'Uses a wheelchair; the city often becomes an obstacle course.'**
  String get character_liam_trait;

  /// Liam super power
  ///
  /// In en, this message translates to:
  /// **'Photography, wit and activism.'**
  String get character_liam_superPower;

  /// Liam long description
  ///
  /// In en, this message translates to:
  /// **'Fights for accessibility and shows that access is freedom to choose your route.'**
  String get character_liam_description;

  /// Olenka name + age
  ///
  /// In en, this message translates to:
  /// **'Olenka, 15 years'**
  String get character_olenka_title;

  /// Olenka short quote
  ///
  /// In en, this message translates to:
  /// **'\"Sometimes to see you just need to learn to hear\"'**
  String get character_olenka_quote;

  /// Olenka trait description
  ///
  /// In en, this message translates to:
  /// **'Visually impaired, orients through hearing, touch, imagination and logic.'**
  String get character_olenka_trait;

  /// Olenka super power
  ///
  /// In en, this message translates to:
  /// **'Echolocation and the ability to \"see\" space through a soundscape.'**
  String get character_olenka_superPower;

  /// Olenka long description
  ///
  /// In en, this message translates to:
  /// **'Navigates complex urban environments and teaches respect for the independence of visually impaired people.'**
  String get character_olenka_description;

  /// Anton name + age
  ///
  /// In en, this message translates to:
  /// **'Anton, 14 years'**
  String get character_anton_title;

  /// Anton short quote
  ///
  /// In en, this message translates to:
  /// **'\"Silence isn\'t empty. It speaks loudly if you listen with your heart\"'**
  String get character_anton_quote;

  /// Anton trait description
  ///
  /// In en, this message translates to:
  /// **'Has a severe hearing impairment. Communicates using sign language, reads lips, and actively uses gadgets.'**
  String get character_anton_trait;

  /// Anton super power
  ///
  /// In en, this message translates to:
  /// **'Graphic design and observation skills. Knows how to \"hear with his eyes\" - flawlessly reads the most subtle emotions from a face (even sarcasm or confusion).'**
  String get character_anton_superPower;

  /// Anton long description
  ///
  /// In en, this message translates to:
  /// **'A confident, creative teenager with a subtle sense of humor who dreams of creating his own manga. Anton proves that communication is not limited to voice. His story teaches that sign language is a complete language, and art and emojis can explain what words cannot.'**
  String get character_anton_description;

  /// No description provided for @survey_calibration_title.
  ///
  /// In en, this message translates to:
  /// **'Sensory Profile Calibration'**
  String get survey_calibration_title;

  /// No description provided for @survey_calibration_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Answers will personalize character story and the final \"Map of Calm\".'**
  String get survey_calibration_subtitle;

  /// No description provided for @survey_save_continue.
  ///
  /// In en, this message translates to:
  /// **'Save and Continue'**
  String get survey_save_continue;

  /// No description provided for @survey_post_modal_title.
  ///
  /// In en, this message translates to:
  /// **'Your Mission'**
  String get survey_post_modal_title;

  /// No description provided for @survey_post_modal_text.
  ///
  /// In en, this message translates to:
  /// **'Your mission: Today is a very important day. Olya must present her project on the school stage in the assembly hall. Her motto: \"I won\'t speak - I will show\". But to get to the stage and show her drawing, she needs to leave the quiet classroom and traverse the whole school. The road to the assembly hall is full of stressors: sudden bells, bright lights, and noisy crowds. Help Olya not get lost in this noisy world, build her own safe route, successfully reach the stage and create your own \"Map of Calm\"!'**
  String get survey_post_modal_text;

  /// No description provided for @survey_post_modal_button.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get survey_post_modal_button;

  /// No description provided for @path_choice_title.
  ///
  /// In en, this message translates to:
  /// **'Choose Route'**
  String get path_choice_title;

  /// No description provided for @path_first.
  ///
  /// In en, this message translates to:
  /// **'Main corridor'**
  String get path_first;

  /// No description provided for @path_second.
  ///
  /// In en, this message translates to:
  /// **'Through the library'**
  String get path_second;

  /// No description provided for @path_third.
  ///
  /// In en, this message translates to:
  /// **'Through the schoolyard'**
  String get path_third;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @calm_map_personal_artifact.
  ///
  /// In en, this message translates to:
  /// **'Personal Artifact'**
  String get calm_map_personal_artifact;

  /// No description provided for @calm_map_title.
  ///
  /// In en, this message translates to:
  /// **'Your Map of Calm'**
  String get calm_map_title;

  /// No description provided for @calm_map_pattern.
  ///
  /// In en, this message translates to:
  /// **'Pattern: {value}'**
  String calm_map_pattern(String value);

  /// No description provided for @calm_map_item.
  ///
  /// In en, this message translates to:
  /// **'Safe Object: {value}'**
  String calm_map_item(String value);

  /// No description provided for @calm_map_support_message.
  ///
  /// In en, this message translates to:
  /// **'Support Phrase: {value}'**
  String calm_map_support_message(String value);

  /// No description provided for @calm_map_support_symbol.
  ///
  /// In en, this message translates to:
  /// **'Support Symbol: {value}'**
  String calm_map_support_symbol(String value);

  /// No description provided for @calm_map_selected_path.
  ///
  /// In en, this message translates to:
  /// **'Selected path: {value}'**
  String calm_map_selected_path(String value);

  /// No description provided for @play_again.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get play_again;

  /// No description provided for @survey_safe_color_title.
  ///
  /// In en, this message translates to:
  /// **'1. What color feels safe for you?'**
  String get survey_safe_color_title;

  /// No description provided for @survey_mint.
  ///
  /// In en, this message translates to:
  /// **'Mint'**
  String get survey_mint;

  /// No description provided for @survey_lavender.
  ///
  /// In en, this message translates to:
  /// **'Lavender'**
  String get survey_lavender;

  /// No description provided for @survey_deep_ocean.
  ///
  /// In en, this message translates to:
  /// **'Deep Blue'**
  String get survey_deep_ocean;

  /// No description provided for @survey_sand.
  ///
  /// In en, this message translates to:
  /// **'Warm Sand'**
  String get survey_sand;

  /// No description provided for @survey_calming_pattern_title.
  ///
  /// In en, this message translates to:
  /// **'2. Which pattern is calming?'**
  String get survey_calming_pattern_title;

  /// No description provided for @survey_geometry.
  ///
  /// In en, this message translates to:
  /// **'Clear Geometry'**
  String get survey_geometry;

  /// No description provided for @survey_nature.
  ///
  /// In en, this message translates to:
  /// **'Nature Motifs'**
  String get survey_nature;

  /// No description provided for @survey_stars.
  ///
  /// In en, this message translates to:
  /// **'Starry Sky'**
  String get survey_stars;

  /// Title for the character selection section.
  ///
  /// In en, this message translates to:
  /// **'Heroes'**
  String get heroes_title;

  /// Instruction text for character selection.
  ///
  /// In en, this message translates to:
  /// **'Choose a hero to see the description'**
  String get select_hero_description;

  /// Name of the character Olya.
  ///
  /// In en, this message translates to:
  /// **'Olya'**
  String get character_olya;

  /// Name of the character Liam.
  ///
  /// In en, this message translates to:
  /// **'Liam'**
  String get character_liam;

  /// Name of the character Olenka.
  ///
  /// In en, this message translates to:
  /// **'Olenka'**
  String get character_olenka;

  /// Name of the character Anton.
  ///
  /// In en, this message translates to:
  /// **'Anton'**
  String get character_anton;

  /// Label for character trait.
  ///
  /// In en, this message translates to:
  /// **'Trait:'**
  String get character_trait_label;

  /// Label for character superpower.
  ///
  /// In en, this message translates to:
  /// **'Superpower:'**
  String get character_superpower_label;

  /// No description provided for @survey_clouds.
  ///
  /// In en, this message translates to:
  /// **'Soft Clouds'**
  String get survey_clouds;

  /// No description provided for @survey_calming_item_title.
  ///
  /// In en, this message translates to:
  /// **'3. Which object gives a sense of calm?'**
  String get survey_calming_item_title;

  /// No description provided for @survey_book.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get survey_book;

  /// No description provided for @survey_stones.
  ///
  /// In en, this message translates to:
  /// **'Pouch with Stones'**
  String get survey_stones;

  /// No description provided for @survey_toy.
  ///
  /// In en, this message translates to:
  /// **'Calming Toy'**
  String get survey_toy;

  /// No description provided for @survey_sound_trigger_title.
  ///
  /// In en, this message translates to:
  /// **'4. Which sounds annoy you?'**
  String get survey_sound_trigger_title;

  /// No description provided for @survey_crowd.
  ///
  /// In en, this message translates to:
  /// **'Loud Crowd'**
  String get survey_crowd;

  /// No description provided for @survey_mechanical.
  ///
  /// In en, this message translates to:
  /// **'Sharp Mechanical Sounds'**
  String get survey_mechanical;

  /// No description provided for @survey_high_pitch.
  ///
  /// In en, this message translates to:
  /// **'High Pitch'**
  String get survey_high_pitch;

  /// No description provided for @survey_chaotic_music.
  ///
  /// In en, this message translates to:
  /// **'Chaotic Loud Music'**
  String get survey_chaotic_music;

  /// No description provided for @survey_calming_action_title.
  ///
  /// In en, this message translates to:
  /// **'5. Which movements calm you down?'**
  String get survey_calming_action_title;

  /// No description provided for @survey_squeeze.
  ///
  /// In en, this message translates to:
  /// **'Squeezing a soft object'**
  String get survey_squeeze;

  /// No description provided for @survey_breathing.
  ///
  /// In en, this message translates to:
  /// **'Deep slow breathing'**
  String get survey_breathing;

  /// No description provided for @survey_counting.
  ///
  /// In en, this message translates to:
  /// **'Counting objects'**
  String get survey_counting;

  /// No description provided for @survey_eyes_closed.
  ///
  /// In en, this message translates to:
  /// **'Closing eyes briefly'**
  String get survey_eyes_closed;

  /// No description provided for @survey_panic_style_title.
  ///
  /// In en, this message translates to:
  /// **'6. What does your \"panic\" look like?'**
  String get survey_panic_style_title;

  /// No description provided for @survey_shake.
  ///
  /// In en, this message translates to:
  /// **'Screen shakes and pulses'**
  String get survey_shake;

  /// No description provided for @survey_blur.
  ///
  /// In en, this message translates to:
  /// **'Image is blurred like in fog'**
  String get survey_blur;

  /// No description provided for @survey_acid.
  ///
  /// In en, this message translates to:
  /// **'Bright \"acid\" colors'**
  String get survey_acid;

  /// No description provided for @survey_noise.
  ///
  /// In en, this message translates to:
  /// **'Image is noisy and doubled'**
  String get survey_noise;

  /// Survey question 7: What form of support.
  ///
  /// In en, this message translates to:
  /// **'7. What message would support you?'**
  String get survey_support_form_title;

  /// Survey option: safe phrase and breathing.
  ///
  /// In en, this message translates to:
  /// **'You are safe, just breathe'**
  String get survey_support_safe_breathe;

  /// Survey option: positive affirmation.
  ///
  /// In en, this message translates to:
  /// **'You are not alone, we\'ll get through this together'**
  String get survey_support_affirmation;

  /// Survey option: grounding technique.
  ///
  /// In en, this message translates to:
  /// **'Your world is your strength, show it'**
  String get survey_support_grounding;

  /// Survey option: calm visualization.
  ///
  /// In en, this message translates to:
  /// **'It\'s okay. Give yourself time to recover'**
  String get survey_support_visualization;

  /// No description provided for @survey_support_symbol_title.
  ///
  /// In en, this message translates to:
  /// **'8. Which form of support would you choose?'**
  String get survey_support_symbol_title;

  /// No description provided for @survey_shield.
  ///
  /// In en, this message translates to:
  /// **'Shield'**
  String get survey_shield;

  /// No description provided for @survey_cat.
  ///
  /// In en, this message translates to:
  /// **'Cat'**
  String get survey_cat;

  /// No description provided for @survey_battery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get survey_battery;

  /// No description provided for @survey_anchor.
  ///
  /// In en, this message translates to:
  /// **'Anchor'**
  String get survey_anchor;

  /// No description provided for @calm_map_safe_color.
  ///
  /// In en, this message translates to:
  /// **'Safe Color: {value}'**
  String calm_map_safe_color(String value);

  /// Label for the button or tooltip to go to the next item in a list or carousel.
  ///
  /// In en, this message translates to:
  /// **'Next item'**
  String get next_item;

  /// No description provided for @calm_map_calming_action.
  ///
  /// In en, this message translates to:
  /// **'Calming Action: {value}'**
  String calm_map_calming_action(String value);

  /// No description provided for @calm_map_sound_trigger.
  ///
  /// In en, this message translates to:
  /// **'Sound Trigger: {value}'**
  String calm_map_sound_trigger(String value);

  /// No description provided for @calm_map_export_png.
  ///
  /// In en, this message translates to:
  /// **'Export PNG'**
  String get calm_map_export_png;

  /// No description provided for @calm_map_export_hint.
  ///
  /// In en, this message translates to:
  /// **'Press P to export the PNG and open it.'**
  String get calm_map_export_hint;

  /// No description provided for @calm_map_export_success.
  ///
  /// In en, this message translates to:
  /// **'PNG saved. Opening file...'**
  String get calm_map_export_success;

  /// No description provided for @calm_map_export_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not export the calm map PNG.'**
  String get calm_map_export_failed;

  /// No description provided for @classroom.
  ///
  /// In en, this message translates to:
  /// **'Classroom'**
  String get classroom;

  /// No description provided for @first_path_description.
  ///
  /// In en, this message translates to:
  /// **'The shortest route. Crowded, noisy, many students. You will have to quickly make your way through the crowd.'**
  String get first_path_description;

  /// No description provided for @second_path_description.
  ///
  /// In en, this message translates to:
  /// **'Quiet corridors near the library. School lockers are located here - Olya can stop and take something from her belongings. The route is a bit longer, but calmer.'**
  String get second_path_description;

  /// No description provided for @third_path_description.
  ///
  /// In en, this message translates to:
  /// **'A detour through the inner courtyard and the back entrance. There are almost no people, but the path is longer and less safe - older students or other unpredictable situations might be encountered in the yard.'**
  String get third_path_description;

  /// No description provided for @map_of_calm_olya.
  ///
  /// In en, this message translates to:
  /// **'Map of Calm: Olya'**
  String get map_of_calm_olya;

  /// No description provided for @tap_game_title.
  ///
  /// In en, this message translates to:
  /// **'Tap the screen repeatedly to calm down'**
  String get tap_game_title;

  /// No description provided for @locker_prompt.
  ///
  /// In en, this message translates to:
  /// **'You\'re at your locker, open your backpack to continue.'**
  String get locker_prompt;

  /// No description provided for @corridor_pattern_instruction.
  ///
  /// In en, this message translates to:
  /// **'Tap the patterns on the wall to collect them'**
  String get corridor_pattern_instruction;

  /// No description provided for @corridor_pattern_progress.
  ///
  /// In en, this message translates to:
  /// **'Collected: {current} / {total}'**
  String corridor_pattern_progress(Object current, Object total);

  /// No description provided for @camera_liam_title.
  ///
  /// In en, this message translates to:
  /// **'Liam\'s Camera'**
  String get camera_liam_title;

  /// No description provided for @camera_liam_instructions.
  ///
  /// In en, this message translates to:
  /// **'Press C to toggle camera. Tap shutter to take photo.'**
  String get camera_liam_instructions;
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
