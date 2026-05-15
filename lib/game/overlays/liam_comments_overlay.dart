import 'package:flutter/material.dart';

import '../../l10n/app_localizations_gen.dart';
import '../characters/liam/liam_journey.dart';
import '../emvia_game.dart';
import 'glass_ui.dart';

class LiamCommentsOverlay extends StatelessWidget {
  final EmviaGame game;
  final VoidCallback onContinue;

  const LiamCommentsOverlay({
    super.key,
    required this.game,
    required this.onContinue,
  });

  static const List<String> _commentsEn = [
    'How did you even get here?',
    'Wow, can you actually get there in a wheelchair?',
    'Did someone help you get there?',
    'You’re so brave for going out at all.',
    'A real hero. I wouldn’t be able to do that in your place.',
    'Honestly, at first I wasn’t even looking at the photo — I was looking at the wheelchair.',
    'Careful, the pavement there is uneven. Don’t get stuck.',
    'I don’t even know what’s more impressive — the place or the fact that you’re there.',
    'It must be really hard for you to create this kind of content.',
    'It’s great that you’re not just staying at home.',
  ];

  static const List<String> _commentsUk = [
    'Як ти сюди взагалі потрапив?',
    'Ого, а хіба туди можна на візку?',
    'Тобі хтось допоміг дістатися?',
    'Ти такий молодець, що взагалі кудись виходиш.',
    'Справжній герой. Я б на твоєму місці не зміг.',
    'Чесно, я спочатку дивився не на фото, а на візок.',
    'Обережно, там же незручна плитка. Не застрягни.',
    'Навіть не знаю, що більше вражає — місце чи те, що ти там.',
    'Тобі, мабуть, дуже важко знімати такий контент.',
    'Круто, що ти не сидиш удома.',
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizationsGen.of(context)!;
    final isUk = Localizations.localeOf(context).languageCode == 'uk';
    final comments = isUk ? _commentsUk : _commentsEn;
    final supportSymbol = game.liamState != null
        ? LiamJourney.getSupportSymbolEmoji(game.liamState!)
        : null;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.72),
                    Colors.black.withValues(alpha: 0.88),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 880),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GlassPanel(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l.liam_self_title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    l.liam_comments_intro,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            if (supportSymbol != null) ...[
                              const SizedBox(width: 16),
                              GlassPanel(
                                borderRadius: BorderRadius.circular(999),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                alphaValue: 0.14,
                                child: Text(
                                  supportSymbol,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 360,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            child: Scrollbar(
                              child: ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: comments.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final alignRight = index.isEven;
                                  return Align(
                                    alignment: alignRight
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: 0.88,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: alignRight
                                              ? Colors.white.withValues(
                                                  alpha: 0.08,
                                                )
                                              : Colors.black.withValues(
                                                  alpha: 0.2,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.12,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          comments[index],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                color: Colors.white,
                                                height: 1.35,
                                              ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GlassButton(
                            label: l.continueLabel,
                            onPressed: () {
                              game.overlays.remove('LiamCommentsFeed');
                              onContinue();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
