import 'package:emvia/game/emvia_game.dart';
import 'package:emvia/game/emvia_types.dart';
import 'package:emvia/game/overlays/glass_ui.dart';
import 'package:emvia/game/utils/survey_service.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:emvia/l10n/app_localizations.dart';

class SurveyOverlay extends StatefulWidget {
  final EmviaGame game;

  const SurveyOverlay({super.key, required this.game});

  @override
  State<SurveyOverlay> createState() => _SurveyOverlayState();
}

class _SurveyOverlayState extends State<SurveyOverlay>
    with SingleTickerProviderStateMixin {
  final SurveyService _surveyService = SurveyService();
  final Map<String, String> _answers = {};
  bool _isLoading = false;
  int _currentIndex = 0;
  Future<void> Function()? _stopQuestionAudio;

  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 1.0, curve: Curves.easeOutQuint),
    );

    _entranceController.forward();
  }

  static const _soundFiles = {
    'en': [
      'what_color.mp3',
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

  static const _liamSoundFiles = {
    'en': [
      'what_color.mp3',
      'which_photography_style.mp3',
      'what_does_support_means_to_you.mp3',
      'what_anoise_you_the_most.mp3',
      'how_do_you_usually_act.mp3',
      'symbol_of_support.mp3',
    ],
    'uk': [
      'який колір найкраще описує твій стан зараз.mp3',
      'який стиль фото тобі найближчий.mp3',
      'shcho_dlia_tebe_oznachaie_pidtrimka.mp3',
      'що найбільше дратує тебе у просторі.mp3',
      'як ти зазвичай дієш у складних ситуаціях.mp3',
      'що буде твоїм символом підтримки.mp3',
    ],
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _playQuestionSound(_currentIndex);
  }

  void _playQuestionSound(int index) async {
    if (index < 0) return;
    final locale = Localizations.localeOf(context);
    final lang = locale.languageCode == 'uk' ? 'uk' : 'en';

    final isLiam = widget.game.selectedCharacter == PlayableCharacter.liam;
    final files = isLiam ? _liamSoundFiles[lang]! : _soundFiles[lang]!;
    if (index >= files.length) return;

    await _stopQuestionAudio?.call();
    final folder = isLiam ? 'liam' : 'survey';
    final player = await FlameAudio.play(
      '$folder/${files[index]}',
      volume: widget.game.volume,
    );
    _stopQuestionAudio = player.stop;
  }

  @override
  void dispose() {
    _stopQuestionAudio?.call();
    _entranceController.dispose();
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
    final size = MediaQuery.of(context).size;
    final isSmall = size.shortestSide < 600;

    return Stack(
      children: [
        Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: GlassPanel(
                width: isSmall ? size.width * 0.95 : 840,
                constraints: BoxConstraints(maxHeight: size.height * 0.9),
                padding: EdgeInsets.symmetric(
                  horizontal: isSmall ? 20 : 32,
                  vertical: isSmall ? 20 : 32,
                ),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  clipBehavior: Clip.none,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    layoutBuilder:
                        (Widget? currentChild, List<Widget> previousChildren) {
                          return Stack(
                            alignment: Alignment.topCenter,
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              ...previousChildren,
                              ?currentChild,
                            ],
                          );
                        },
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.05, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                    child: SingleChildScrollView(
                      key: ValueKey<int>(_currentIndex),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 0,
                      ).copyWith(bottom: 16),
                      clipBehavior: Clip.none,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          Text(
                            l.survey_calibration_subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: isSmall ? 13 : 14,
                            ),
                          ),
                          SizedBox(height: isSmall ? 12 : 16),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      return Stack(
                                        children: [
                                          Container(
                                            height: isSmall ? 4 : 6,
                                            color: Colors.white.withValues(
                                              alpha: 0.1,
                                            ),
                                          ),
                                          AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 500,
                                            ),
                                            curve: Curves.easeInOut,
                                            height: isSmall ? 4 : 6,
                                            width:
                                                constraints.maxWidth *
                                                ((_currentIndex + 1) /
                                                    questions.length),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: theme
                                                      .colorScheme
                                                      .primary
                                                      .withValues(alpha: 0.4),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${_currentIndex + 1} / ${questions.length}',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isSmall ? 16 : 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  question.title,
                                  style:
                                      (isSmall
                                              ? theme.textTheme.titleMedium
                                              : theme.textTheme.titleLarge)
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.5,
                                          ),
                                ),
                              ),
                              _AnimatedIconButton(
                                icon: Icons.volume_up_rounded,
                                onPressed: () =>
                                    _playQuestionSound(_currentIndex),
                                size: isSmall ? 20 : 24,
                              ),
                            ],
                          ),
                          SizedBox(height: isSmall ? 12 : 16),
                          Wrap(
                            spacing: isSmall ? 8 : 10,
                            runSpacing: isSmall ? 8 : 10,
                            clipBehavior: Clip.none,
                            children: question.options.asMap().entries.map((
                              entry,
                            ) {
                              final index = entry.key;
                              final option = entry.value;
                              final isSelected = selected == option.id;

                              return TweenAnimationBuilder<double>(
                                duration: Duration(
                                  milliseconds: 600 + (index * 150),
                                ),
                                tween: Tween(begin: 0.0, end: 1.0),
                                curve: Curves.easeOutBack,
                                builder: (context, entranceValue, child) {
                                  return TweenAnimationBuilder<double>(
                                    duration: const Duration(milliseconds: 400),
                                    tween: Tween(
                                      begin: 1.0,
                                      end: isSelected ? 1.05 : 1.0,
                                    ),
                                    curve: Curves.easeOutBack,
                                    builder: (context, selectionValue, child) {
                                      return Transform.scale(
                                        scale: entranceValue * selectionValue,
                                        child: Opacity(
                                          opacity: entranceValue.clamp(
                                            0.0,
                                            1.0,
                                          ),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: child,
                                  );
                                },
                                child: GlassOptionChip(
                                  key: ValueKey(option.id),
                                  label: option.label,
                                  selected: isSelected,
                                  compact: isSmall,
                                  onTap: () {
                                    setState(() {
                                      _answers[question.id] = option.id;
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: isSmall ? 20 : 28),
                          GestureDetector(
                            onLongPressStart: (_) => _submit(),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 300),
                                    opacity: selected != null ? 1.0 : 0.5,
                                    child: GlassButton(
                                      label: isLast
                                          ? l.survey_save_continue
                                          : l.continueLabel,
                                      onPressed: selected != null && !_isLoading
                                          ? (isLast ? _submit : _goNext)
                                          : null,
                                      loading: _isLoading,
                                      compact: isSmall,
                                    ),
                                  ),
                                ),
                                if (_currentIndex > 0)
                                  const SizedBox(width: 12),
                                if (_currentIndex > 0)
                                  Expanded(
                                    child: GlassButton(
                                      label: '←',
                                      onPressed: _goBack,
                                      primary: false,
                                      compact: isSmall,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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

    // await _showPostSurveyModal();

    final shouldStartGame = widget.game.consumeStartGameAfterSurvey();
    widget.game.overlays.remove('Survey');
    _resetState();
    if (shouldStartGame) {
      widget.game.startGame();
    } else {
      await widget.game.returnToMainMenuAfterSurvey();
    }
  }

  void _resetState() {
    _answers.clear();
    _currentIndex = 0;
    _isLoading = false;
    _stopQuestionAudio?.call();
    _stopQuestionAudio = null;
  }

  // ignore: unused_element
  Future<void> _showPostSurveyModal() async {
    final l = AppLocalizations.of(context)!;
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: l.continueLabel,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          backgroundColor: Colors.black.withValues(alpha: 0.6),
          body: SafeArea(
            child: Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.survey_post_modal_title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l.survey_post_modal_text,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(l.survey_post_modal_button),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;

  const _AnimatedIconButton({
    required this.icon,
    required this.onPressed,
    required this.size,
  });

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      icon: Icon(widget.icon),
      color: theme.colorScheme.primary,
      onPressed: () {
        widget.onPressed();
      },
      iconSize: widget.size,
    );
  }
}
