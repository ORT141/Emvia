import 'package:emvia/game/emvia_game.dart';
import 'package:emvia/game/survey_service.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:emvia/l10n/app_localizations.dart';

class SurveyOverlay extends StatefulWidget {
  final EmviaGame game;

  const SurveyOverlay({super.key, required this.game});

  @override
  State<SurveyOverlay> createState() => _SurveyOverlayState();
}

const bool kAllowSurveySkip = bool.fromEnvironment(
  'ALLOW_SURVEY_SKIP',
  defaultValue: false,
);

class _SurveyOverlayState extends State<SurveyOverlay> {
  final SurveyService _surveyService = SurveyService();
  final Map<String, String> _answers = {};
  bool _isLoading = false;
  int _currentIndex = 0;
  Future<void> Function()? _stopQuestionAudio;

  static const _soundFiles = {
    'en': [
      'what color.mp3',
      'what pattern.mp3',
      'which object.mp3',
      'what sounds.mp3',
      'what movements.mp3',
      'what panic.mp3',
      'what form of support.mp3',
    ],
    'uk': [
      'який колір.mp3',
      'який візерунок.mp3',
      'який предмет.mp3',
      'які звуки.mp3',
      'які рухи.mp3',
      'як виглядає паніка.mp3',
      'яку форму підтримки обереш.mp3',
    ],
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _playQuestionSound(_currentIndex);
  }

  void _playQuestionSound(int index) async {
    final locale = Localizations.localeOf(context);
    final lang = locale.languageCode == 'uk' ? 'uk' : 'en';
    final files = _soundFiles[lang]!;
    if (index >= files.length) return;
    await _stopQuestionAudio?.call();
    final player = await FlameAudio.play(
      'survey/${files[index]}',
      volume: widget.game.volume,
    );
    _stopQuestionAudio = player.stop;
  }

  @override
  void dispose() {
    _stopQuestionAudio?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final questions = SurveyService.localizedQuestions(context);
    final question = questions[_currentIndex];
    final selected = _answers[question.id];
    final isLast = _currentIndex == questions.length - 1;

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                  const SizedBox(height: 4),
                  Text(
                    l.survey_calibration_subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (_currentIndex + 1) / questions.length,
                            minHeight: 6,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_currentIndex + 1} / ${questions.length}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          question.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Play again',
                        icon: const Icon(Icons.volume_up_rounded),
                        color: theme.colorScheme.primary,
                        onPressed: () => _playQuestionSound(_currentIndex),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
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
                        selectedColor: theme.colorScheme.primary.withValues(
                          alpha: 0.14,
                        ),
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        elevation: isSelected ? 2 : 0,
                        onSelected: (value) {
                          if (!value) return;
                          setState(() {
                            _answers[question.id] = option.id;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  Row(
                    children: [
                      if (_currentIndex > 0)
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: _goBack,
                            child: const Text('←'),
                          ),
                        ),
                      if (_currentIndex > 0) const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
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
                          onPressed: selected != null && !_isLoading
                              ? (isLast ? _submit : _goNext)
                              : null,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(isLast ? l.survey_save_continue : '→'),
                        ),
                      ),
                    ],
                  ),

                  if (kAllowSurveySkip) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _skip,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _goNext() {
    setState(() => _currentIndex++);
    _playQuestionSound(_currentIndex);
  }

  void _goBack() {
    setState(() => _currentIndex--);
    _playQuestionSound(_currentIndex);
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await _surveyService.saveSurvey(_answers);
      await _surveyService.callAiBackend(_answers);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
    if (!mounted) return;
    final shouldStartGame = widget.game.consumeStartGameAfterSurvey();
    widget.game.overlays.remove('Survey');
    if (shouldStartGame) {
      widget.game.startGame();
    } else {
      widget.game.overlays.add('MainMenu');
    }
  }

  Future<void> _skip() async {
    final shouldStartGame = widget.game.consumeStartGameAfterSurvey();
    widget.game.overlays.remove('Survey');
    if (shouldStartGame) {
      widget.game.startGame();
    } else {
      widget.game.overlays.add('MainMenu');
    }
  }
}
