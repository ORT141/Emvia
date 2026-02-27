import 'package:emvia/game/emvia_game.dart';
import 'package:emvia/game/survey_service.dart';
import 'package:flutter/material.dart';
import 'package:emvia/l10n/app_localizations.dart';

class SurveyOverlay extends StatefulWidget {
  final EmviaGame game;

  const SurveyOverlay({super.key, required this.game});

  @override
  State<SurveyOverlay> createState() => _SurveyOverlayState();
}

class _SurveyOverlayState extends State<SurveyOverlay> {
  final SurveyService _surveyService = SurveyService();
  final Map<String, String> _answers = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final questions = SurveyService.localizedQuestions(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.32),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: theme.colorScheme.surface,
            elevation: 24,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.survey_calibration_title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.survey_calibration_subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...questions.map((question) {
                    final selected = _answers[question.id];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: question.options.map((option) {
                              final isSelected = selected == option.id;
                              return ChoiceChip(
                                label: Text(option.label),
                                selected: isSelected,
                                avatar: isSelected
                                    ? Icon(
                                        Icons.check,
                                        size: 16,
                                        color: theme.colorScheme.primary,
                                      )
                                    : null,
                                selectedColor: theme.colorScheme.primary
                                    .withValues(alpha: 0.14),
                                onSelected: (value) {
                                  if (!value) return;
                                  setState(() {
                                    _answers[question.id] = option.id;
                                  });
                                },
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                                elevation: isSelected ? 2 : 0,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: _isComplete(questions) ? _submit : null,
                      child: Text(l.survey_save_continue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isComplete(List<SurveyQuestion> questions) =>
      _answers.length == questions.length;

  Future<void> _submit() async {
    await _surveyService.saveSurvey(_answers);
    final shouldStartGame = widget.game.consumeStartGameAfterSurvey();
    widget.game.overlays.remove('Survey');
    if (shouldStartGame) {
      widget.game.startGame();
    } else {
      widget.game.overlays.add('MainMenu');
    }
  }
}
