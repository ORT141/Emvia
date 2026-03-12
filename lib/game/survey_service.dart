import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:emvia/l10n/app_localizations.dart';

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

  String get aiPattern => answers[SurveyService.aiPatternKey] ?? '';
  String get aiColor => answers[SurveyService.aiColorKey] ?? '';
  String get aiStressType =>
      answers[SurveyService.aiStressTypeKey] ?? 'battery';

  List<String> get aiWords {
    final raw = answers[SurveyService.aiWordsKey];
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = (jsonDecode(raw) as List).cast<String>();
      return list;
    } catch (_) {
      return [];
    }
  }

  Color get safeColorValue {
    if (aiColor.isNotEmpty) {
      try {
        final hex = aiColor.replaceAll('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
    }
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

  String calmingPatternLabel(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    switch (calmingPattern) {
      case 'nature':
        return l.survey_nature;
      case 'stars':
        return l.survey_stars;
      case 'clouds':
        return l.survey_clouds;
      case 'geometry':
      default:
        return l.survey_geometry;
    }
  }

  String calmingItemLabel(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    switch (calmingItem) {
      case 'stones':
        return l.survey_stones;
      case 'toy':
        return l.survey_toy;
      case 'book':
      default:
        return l.survey_book;
    }
  }

  String safeColorLabel(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    switch (safeColor) {
      case 'lavender':
        return l.survey_lavender;
      case 'deep_ocean':
        return l.survey_deep_ocean;
      case 'sand':
        return l.survey_sand;
      case 'mint':
      default:
        return l.survey_mint;
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

  String supportMessageLabel(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    switch (supportMessage) {
      case 'affirmation':
        return l.survey_support_affirmation;
      case 'grounding':
        return l.survey_support_grounding;
      case 'visualization':
        return l.survey_support_visualization;
      case 'safe_breathe':
      default:
        return l.survey_support_safe_breathe;
    }
  }

  String supportSymbolLabel(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    switch (supportSymbol) {
      case 'shield':
        return l.survey_shield;
      case 'cat':
        return l.survey_cat;
      case 'battery':
        return l.survey_battery;
      case 'anchor':
      default:
        return l.survey_anchor;
    }
  }

  String calmingActionLabel(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    switch (calmingAction) {
      case 'squeeze':
        return l.survey_squeeze;
      case 'counting':
        return l.survey_counting;
      case 'eyes_closed':
        return l.survey_eyes_closed;
      case 'breathing':
      default:
        return l.survey_breathing;
    }
  }

  String soundTriggerLabel(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    switch (soundTrigger) {
      case 'mechanical':
        return l.survey_mechanical;
      case 'high_pitch':
        return l.survey_high_pitch;
      case 'chaotic_music':
        return l.survey_chaotic_music;
      case 'crowd':
      default:
        return l.survey_crowd;
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
  static const String aiPatternKey = 'ai_pattern';
  static const String aiWordsKey = 'ai_words';
  static const String aiColorKey = 'ai_color';
  static const String aiStressTypeKey = 'ai_stress_type';

  static List<SurveyQuestion> localizedQuestions(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return [
      SurveyQuestion(
        id: safeColorKey,
        title: l.survey_safe_color_title,
        options: [
          SurveyOption(id: 'mint', label: l.survey_mint),
          SurveyOption(id: 'lavender', label: l.survey_lavender),
          SurveyOption(id: 'deep_ocean', label: l.survey_deep_ocean),
          SurveyOption(id: 'sand', label: l.survey_sand),
        ],
      ),
      SurveyQuestion(
        id: calmingPatternKey,
        title: l.survey_calming_pattern_title,
        options: [
          SurveyOption(id: 'geometry', label: l.survey_geometry),
          SurveyOption(id: 'nature', label: l.survey_nature),
          SurveyOption(id: 'stars', label: l.survey_stars),
          SurveyOption(id: 'clouds', label: l.survey_clouds),
        ],
      ),
      SurveyQuestion(
        id: calmingItemKey,
        title: l.survey_calming_item_title,
        options: [
          SurveyOption(id: 'book', label: l.survey_book),
          SurveyOption(id: 'stones', label: l.survey_stones),
          SurveyOption(id: 'toy', label: l.survey_toy),
        ],
      ),
      SurveyQuestion(
        id: soundTriggerKey,
        title: l.survey_sound_trigger_title,
        options: [
          SurveyOption(id: 'crowd', label: l.survey_crowd),
          SurveyOption(id: 'mechanical', label: l.survey_mechanical),
          SurveyOption(id: 'high_pitch', label: l.survey_high_pitch),
          SurveyOption(id: 'chaotic_music', label: l.survey_chaotic_music),
        ],
      ),
      SurveyQuestion(
        id: calmingActionKey,
        title: l.survey_calming_action_title,
        options: [
          SurveyOption(id: 'squeeze', label: l.survey_squeeze),
          SurveyOption(id: 'breathing', label: l.survey_breathing),
          SurveyOption(id: 'counting', label: l.survey_counting),
          SurveyOption(id: 'eyes_closed', label: l.survey_eyes_closed),
        ],
      ),
      SurveyQuestion(
        id: panicStyleKey,
        title: l.survey_panic_style_title,
        options: [
          SurveyOption(id: 'shake', label: l.survey_shake),
          SurveyOption(id: 'blur', label: l.survey_blur),
          SurveyOption(id: 'acid', label: l.survey_acid),
          SurveyOption(id: 'noise', label: l.survey_noise),
        ],
      ),
      SurveyQuestion(
        id: supportMessageKey,
        title: l.survey_support_form_title,
        options: [
          SurveyOption(
            id: 'safe_breathe',
            label: l.survey_support_safe_breathe,
          ),
          SurveyOption(id: 'affirmation', label: l.survey_support_affirmation),
          SurveyOption(id: 'grounding', label: l.survey_support_grounding),
          SurveyOption(
            id: 'visualization',
            label: l.survey_support_visualization,
          ),
        ],
      ),
    ];
  }

  Future<bool> isSurveyCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_surveyCompletedKey) ?? false;
  }

  Future<void> saveSurvey(Map<String, String> answers) async {
    final prefs = await SharedPreferences.getInstance();

    for (final entry in answers.entries) {
      await prefs.setString(entry.key, entry.value);
    }

    await prefs.setBool(_surveyCompletedKey, true);
  }

  Future<Map<String, String>> getSurveyResults() async {
    final prefs = await SharedPreferences.getInstance();

    final result = <String, String>{};
    final keys = [
      safeColorKey,
      calmingPatternKey,
      calmingItemKey,
      soundTriggerKey,
      calmingActionKey,
      panicStyleKey,
      supportMessageKey,
      supportSymbolKey,
      aiPatternKey,
      aiWordsKey,
      aiColorKey,
      aiStressTypeKey,
    ];

    for (final key in keys) {
      final value = prefs.getString(key);
      if (value != null) {
        result[key] = value;
      }
    }

    return result;
  }

  Future<SurveyProfile> getProfile() async {
    final answers = await getSurveyResults();
    return SurveyProfile(answers);
  }

  Future<void> callAiBackend(Map<String, String> answers) async {
    try {
      final body = jsonEncode({
        'safe_color': answers[safeColorKey] ?? 'mint',
        'calming_pattern': answers[calmingPatternKey] ?? 'geometry',
        'calming_item': answers[calmingItemKey] ?? 'book',
        'sound_trigger': answers[soundTriggerKey] ?? 'crowd',
        'calming_action': answers[calmingActionKey] ?? 'breathing',
        'panic_style': answers[panicStyleKey] ?? 'shake',
        'support_message': answers[supportMessageKey] ?? 'safe_breathe',
      });

      final response = await http
          .post(
            Uri.parse('http://91.231.182.132:8066/survey'),
            headers: {
              'Content-Type': 'application/json',
              'User-Agent': 'Emvia/1.0',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final pattern = (data['pattern'] as String?) ?? '';
        final words = (data['words'] as List?)?.cast<String>() ?? [];
        final color = (data['color'] as String?) ?? '';
        final stressType = (data['stress_type'] as String?) ?? 'battery';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(aiPatternKey, pattern);
        await prefs.setString(aiWordsKey, jsonEncode(words));
        await prefs.setString(aiColorKey, color);
        await prefs.setString(aiStressTypeKey, stressType);
        await prefs.setString(aiColorKey, color);
      }
    } catch (_) {}
  }
}
