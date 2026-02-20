import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SurveyQuestion {
  final String id;
  final String title;
  final List<SurveyOption> options;

  const SurveyQuestion({
    required this.id,
    required this.title,
    required this.options,
  });
}

class SurveyOption {
  final String id;
  final String label;

  const SurveyOption({required this.id, required this.label});
}

class SurveyProfile {
  final Map<String, String> answers;

  SurveyProfile(this.answers);

  String get safeColor => answers[SurveyService.safeColorKey] ?? 'mint';
  String get calmingPattern =>
      answers[SurveyService.calmingPatternKey] ?? 'geometry';
  String get calmingItem => answers[SurveyService.calmingItemKey] ?? 'book';
  String get soundTrigger => answers[SurveyService.soundTriggerKey] ?? 'crowd';
  String get calmingAction =>
      answers[SurveyService.calmingActionKey] ?? 'breathing';
  String get panicStyle => answers[SurveyService.panicStyleKey] ?? 'shake';
  String get supportMessage =>
      answers[SurveyService.supportMessageKey] ?? 'safe_breathe';
  String get supportSymbol =>
      answers[SurveyService.supportSymbolKey] ?? 'anchor';

  Color get safeColorValue {
    switch (safeColor) {
      case 'lavender':
        return const Color(0xFFDCC6FF);
      case 'deep_ocean':
        return const Color(0xFF2F5A9E);
      case 'sand':
        return const Color(0xFFE9D4A5);
      case 'mint':
      default:
        return const Color(0xFFA7E9D3);
    }
  }

  String get supportMessageLabel {
    switch (supportMessage) {
      case 'not_alone':
        return 'Ти не одна, ми пройдемо це разом';
      case 'your_world_strength':
        return 'Твій світ — це твоя сила, покажи його';
      case 'all_good_time':
        return 'Все гаразд. Дай собі час на відновлення';
      case 'safe_breathe':
      default:
        return 'Ти в безпеці, просто дихай';
    }
  }

  String get supportSymbolEmoji {
    switch (supportSymbol) {
      case 'shield':
        return '🛡️';
      case 'cat':
        return '🐱';
      case 'battery':
        return '🔋';
      case 'anchor':
      default:
        return '⚓';
    }
  }

  String get calmingPatternLabel {
    switch (calmingPattern) {
      case 'nature':
        return 'Природні мотиви';
      case 'stars':
        return 'Зоряне небо';
      case 'clouds':
        return 'М’які хмари';
      case 'geometry':
      default:
        return 'Чітка геометрія';
    }
  }

  String get calmingItemLabel {
    switch (calmingItem) {
      case 'stones':
        return 'Мішечок з камінчиками';
      case 'toy':
        return 'Заспокоююча іграшка';
      case 'book':
      default:
        return 'Книжка';
    }
  }

  String get calmingActionLabel {
    switch (calmingAction) {
      case 'squeeze':
        return 'Стискання м’якого предмета';
      case 'counting':
        return 'Рахунок предметів навколо';
      case 'eyes_closed':
        return 'Коротко закрити очі';
      case 'breathing':
      default:
        return 'Глибоке повільне дихання';
    }
  }

  String get soundTriggerLabel {
    switch (soundTrigger) {
      case 'mechanical':
        return 'різкі механічні звуки';
      case 'high_pitch':
        return 'високий писк';
      case 'chaotic_music':
        return 'хаотична гучна музика';
      case 'crowd':
      default:
        return 'гучний натовп';
    }
  }
}

class SurveyService {
  static const String _surveyCompletedKey = 'survey_completed';

  static const String safeColorKey = 'safe_color';
  static const String calmingPatternKey = 'calming_pattern';
  static const String calmingItemKey = 'calming_item';
  static const String soundTriggerKey = 'sound_trigger';
  static const String calmingActionKey = 'calming_action';
  static const String panicStyleKey = 'panic_style';
  static const String supportMessageKey = 'support_message';
  static const String supportSymbolKey = 'support_symbol';

  static const List<SurveyQuestion> questions = [
    SurveyQuestion(
      id: safeColorKey,
      title: '1. Який колір для тебе — безпечний?',
      options: [
        SurveyOption(id: 'mint', label: 'М’ятний'),
        SurveyOption(id: 'lavender', label: 'Лавандовий'),
        SurveyOption(id: 'deep_ocean', label: 'Глибокий синій'),
        SurveyOption(id: 'sand', label: 'Теплий пісочний'),
      ],
    ),
    SurveyQuestion(
      id: calmingPatternKey,
      title: '2. Який візерунок заспокоює?',
      options: [
        SurveyOption(id: 'geometry', label: 'Чітка геометрія'),
        SurveyOption(id: 'nature', label: 'Природні мотиви'),
        SurveyOption(id: 'stars', label: 'Зоряне небо'),
        SurveyOption(id: 'clouds', label: 'М’які хмари'),
      ],
    ),
    SurveyQuestion(
      id: calmingItemKey,
      title: '3. Який предмет дає відчуття спокою?',
      options: [
        SurveyOption(id: 'book', label: 'Книжка'),
        SurveyOption(id: 'stones', label: 'Мішечок з камінчиками'),
        SurveyOption(id: 'toy', label: 'Заспокоююча іграшка'),
      ],
    ),
    SurveyQuestion(
      id: soundTriggerKey,
      title: '4. Які звуки тебе дратують?',
      options: [
        SurveyOption(id: 'crowd', label: 'Гучний натовп'),
        SurveyOption(id: 'mechanical', label: 'Різкі механічні звуки'),
        SurveyOption(id: 'high_pitch', label: 'Високий писк'),
        SurveyOption(id: 'chaotic_music', label: 'Хаотична гучна музика'),
      ],
    ),
    SurveyQuestion(
      id: calmingActionKey,
      title: '5. Які рухи тебе заспокоюють?',
      options: [
        SurveyOption(id: 'squeeze', label: 'Стискання м’якого предмета'),
        SurveyOption(id: 'breathing', label: 'Глибоке повільне дихання'),
        SurveyOption(id: 'counting', label: 'Рахунок предметів'),
        SurveyOption(id: 'eyes_closed', label: 'Коротко закрити очі'),
      ],
    ),
    SurveyQuestion(
      id: panicStyleKey,
      title: '6. Як виглядає твоя “паніка”?',
      options: [
        SurveyOption(id: 'shake', label: 'Екран тремтить і пульсує'),
        SurveyOption(id: 'blur', label: 'Картинка розмита, як у тумані'),
        SurveyOption(id: 'acid', label: 'Яскраві “кислотні” кольори'),
        SurveyOption(id: 'noise', label: 'Зображення шумить і двоїться'),
      ],
    ),
    SurveyQuestion(
      id: supportMessageKey,
      title: '7. Яке повідомлення тебе б підтримало?',
      options: [
        SurveyOption(id: 'safe_breathe', label: 'Ти в безпеці, просто дихай'),
        SurveyOption(
          id: 'not_alone',
          label: 'Ти не одна, ми пройдемо це разом',
        ),
        SurveyOption(
          id: 'your_world_strength',
          label: 'Твій світ — це твоя сила, покажи його',
        ),
        SurveyOption(
          id: 'all_good_time',
          label: 'Все гаразд. Дай собі час на відновлення',
        ),
      ],
    ),
    SurveyQuestion(
      id: supportSymbolKey,
      title: '8. Яку форму підтримки обереш?',
      options: [
        SurveyOption(id: 'shield', label: 'Щит'),
        SurveyOption(id: 'cat', label: 'Котик'),
        SurveyOption(id: 'battery', label: 'Батарейка'),
        SurveyOption(id: 'anchor', label: 'Якір'),
      ],
    ),
  ];

  Future<bool> isSurveyCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_surveyCompletedKey) ?? false;
  }

  Future<void> saveSurvey(Map<String, String> answers) async {
    final prefs = await SharedPreferences.getInstance();

    for (final question in questions) {
      final answer = answers[question.id];
      if (answer != null) {
        await prefs.setString(question.id, answer);
      }
    }

    await prefs.setBool(_surveyCompletedKey, true);
  }

  Future<Map<String, String>> getSurveyResults() async {
    final prefs = await SharedPreferences.getInstance();

    final result = <String, String>{};
    for (final question in questions) {
      final value = prefs.getString(question.id);
      if (value != null) {
        result[question.id] = value;
      }
    }

    return result;
  }

  Future<SurveyProfile> getProfile() async {
    final answers = await getSurveyResults();
    return SurveyProfile(answers);
  }
}
