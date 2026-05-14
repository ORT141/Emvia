import 'package:emvia/game/emvia_game.dart';
import 'package:emvia/game/managers/game_state/game_state.dart';
import 'package:emvia/game/overlays/glass_ui.dart';
import 'package:emvia/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class LiamGraffitiSurveyOverlay extends StatefulWidget {
  final EmviaGame game;

  const LiamGraffitiSurveyOverlay({super.key, required this.game});

  @override
  State<LiamGraffitiSurveyOverlay> createState() =>
      _LiamGraffitiSurveyOverlayState();
}

class _LiamGraffitiSurveyOverlayState extends State<LiamGraffitiSurveyOverlay>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  LiamPhotoStyle? _photoStyle;
  LiamNavColor? _navColor;
  LiamSupportSymbol? _supportSymbol;
  LiamIrritation? _irritation;
  LiamCopingStyle? _copingStyle;

  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextQuestion() {
    if (_currentIndex < 4) {
      _controller.reverse().then((_) {
        setState(() => _currentIndex++);
        _controller.forward();
      });
    } else {
      _finish();
    }
  }

  void _finish() {
    final state = widget.game.liamState;
    if (state != null) {
      state.photoStyle = _photoStyle;
      state.navColor = _navColor;
      state.supportSymbol = _supportSymbol;
      state.irritation = _irritation;
      state.copingStyle = _copingStyle;
      state.hasCompletedGraffitiSurvey = true;
    }

    final shouldStartGame = widget.game.consumeStartGameAfterSurvey();
    widget.game.overlays.remove('LiamGraffitiSurvey');
    if (shouldStartGame) {
      widget.game.startGame();
    } else {
      widget.game.returnToMainMenuAfterSurvey();
    }
  }

  bool get _canProceed {
    switch (_currentIndex) {
      case 0:
        return _photoStyle != null;
      case 1:
        return _navColor != null;
      case 2:
        return _supportSymbol != null;
      case 3:
        return _irritation != null;
      case 4:
        return _copingStyle != null;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final isSmall = size.shortestSide < 600;

    return Stack(
      children: [
        Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: GlassPanel(
              width: isSmall ? size.width * 0.95 : 840,
              constraints: BoxConstraints(maxHeight: size.height * 0.9),
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 20 : 32,
                vertical: isSmall ? 20 : 32,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.liam_graffiti_survey_title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l.liam_graffiti_survey_subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) / 5,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_currentIndex + 1} / 5',
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: Colors.white54),
                    ),
                    const SizedBox(height: 24),
                    _buildQuestion(context, l),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onLongPressStart: (_) {
                          if (_canProceed) _finish();
                        },
                        child: GlassButton(
                          label: _currentIndex < 4 ? l.continueLabel : l.play,
                          onPressed: _canProceed ? _nextQuestion : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestion(BuildContext context, AppLocalizationsGen l) {
    switch (_currentIndex) {
      case 0:
        return _buildQ1(context, l);
      case 1:
        return _buildQ2(context, l);
      case 2:
        return _buildQ3(context, l);
      case 3:
        return _buildQ4(context, l);
      case 4:
        return _buildQ5(context, l);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildQ1(BuildContext context, AppLocalizationsGen l) {
    return _QuestionBlock(
      title: l.liam_graffiti_q1_title,
      options: [
        _Option(
          l.liam_graffiti_q1_street,
          _photoStyle == LiamPhotoStyle.street,
          () => setState(() => _photoStyle = LiamPhotoStyle.street),
        ),
        _Option(
          l.liam_graffiti_q1_minimalism,
          _photoStyle == LiamPhotoStyle.minimalism,
          () => setState(() => _photoStyle = LiamPhotoStyle.minimalism),
        ),
        _Option(
          l.liam_graffiti_q1_light_shadow,
          _photoStyle == LiamPhotoStyle.lightShadow,
          () => setState(() => _photoStyle = LiamPhotoStyle.lightShadow),
        ),
        _Option(
          l.liam_graffiti_q1_portrait,
          _photoStyle == LiamPhotoStyle.portrait,
          () => setState(() => _photoStyle = LiamPhotoStyle.portrait),
        ),
      ],
    );
  }

  Widget _buildQ2(BuildContext context, AppLocalizationsGen l) {
    return _QuestionBlock(
      title: l.liam_graffiti_q2_title,
      options: [
        _Option(
          l.liam_graffiti_q2_cyan,
          _navColor == LiamNavColor.cyan,
          () => setState(() => _navColor = LiamNavColor.cyan),
        ),
        _Option(
          l.liam_graffiti_q2_orange,
          _navColor == LiamNavColor.orange,
          () => setState(() => _navColor = LiamNavColor.orange),
        ),
        _Option(
          l.liam_graffiti_q2_red,
          _navColor == LiamNavColor.red,
          () => setState(() => _navColor = LiamNavColor.red),
        ),
        _Option(
          l.liam_graffiti_q2_green,
          _navColor == LiamNavColor.green,
          () => setState(() => _navColor = LiamNavColor.green),
        ),
      ],
    );
  }

  Widget _buildQ3(BuildContext context, AppLocalizationsGen l) {
    return _QuestionBlock(
      title: l.liam_graffiti_q3_title,
      options: [
        _Option(
          l.liam_graffiti_q3_heart,
          _supportSymbol == LiamSupportSymbol.heart,
          () => setState(() => _supportSymbol = LiamSupportSymbol.heart),
        ),
        _Option(
          l.liam_graffiti_q3_cat,
          _supportSymbol == LiamSupportSymbol.cat,
          () => setState(() => _supportSymbol = LiamSupportSymbol.cat),
        ),
        _Option(
          l.liam_graffiti_q3_star,
          _supportSymbol == LiamSupportSymbol.star,
          () => setState(() => _supportSymbol = LiamSupportSymbol.star),
        ),
        _Option(
          l.liam_graffiti_q3_wings,
          _supportSymbol == LiamSupportSymbol.wings,
          () => setState(() => _supportSymbol = LiamSupportSymbol.wings),
        ),
      ],
    );
  }

  Widget _buildQ4(BuildContext context, AppLocalizationsGen l) {
    return _QuestionBlock(
      title: l.liam_graffiti_q4_title,
      options: [
        _Option(
          l.liam_graffiti_q4_blocks,
          _irritation == LiamIrritation.blocksPath,
          () => setState(() => _irritation = LiamIrritation.blocksPath),
        ),
        _Option(
          l.liam_graffiti_q4_intrusive,
          _irritation == LiamIrritation.intrusiveHelp,
          () => setState(() => _irritation = LiamIrritation.intrusiveHelp),
        ),
        _Option(
          l.liam_graffiti_q4_inconvenient,
          _irritation == LiamIrritation.inconvenientLayout,
          () => setState(() => _irritation = LiamIrritation.inconvenientLayout),
        ),
        _Option(
          l.liam_graffiti_q4_others_decide,
          _irritation == LiamIrritation.othersDecide,
          () => setState(() => _irritation = LiamIrritation.othersDecide),
        ),
      ],
    );
  }

  Widget _buildQ5(BuildContext context, AppLocalizationsGen l) {
    return _QuestionBlock(
      title: l.liam_graffiti_q5_title,
      options: [
        _Option(
          l.liam_graffiti_q5_find_way,
          _copingStyle == LiamCopingStyle.findWay,
          () => setState(() => _copingStyle = LiamCopingStyle.findWay),
        ),
        _Option(
          l.liam_graffiti_q5_ask_help,
          _copingStyle == LiamCopingStyle.askHelp,
          () => setState(() => _copingStyle = LiamCopingStyle.askHelp),
        ),
        _Option(
          l.liam_graffiti_q5_try_myself,
          _copingStyle == LiamCopingStyle.tryMyself,
          () => setState(() => _copingStyle = LiamCopingStyle.tryMyself),
        ),
        _Option(
          l.liam_graffiti_q5_avoid,
          _copingStyle == LiamCopingStyle.avoid,
          () => setState(() => _copingStyle = LiamCopingStyle.avoid),
        ),
      ],
    );
  }
}

class _Option {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  _Option(this.label, this.selected, this.onTap);
}

class _QuestionBlock extends StatelessWidget {
  final String title;
  final List<_Option> options;

  const _QuestionBlock({required this.title, required this.options});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options
              .map(
                (o) => GlassOptionChip(
                  label: o.label,
                  selected: o.selected,
                  onTap: o.onTap,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
