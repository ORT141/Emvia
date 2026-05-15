import 'dart:async';

import 'package:emvia/game/scenes/game_scene.dart';
import 'package:emvia/l10n/app_localizations_gen.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GraffitiScene extends GameScene {
  bool _introShown = false;

  GraffitiScene()
    : super(
        backgroundPath: 'scenes/liam/graffiti/background.png',
        showControls: true,
        showPlayer: true,
      ) {
    GameScene.register(() => GraffitiScene());
  }

  @override
  int get sceneIndex => 9;

  @override
  String get ambientSoundPath => 'other/легкий біт.mp3';

  @override
  void onPlayerReachedRightEdge() => game.navigationManager.goToLiamElevator();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    layoutToWorld();
  }

  @override
  Future<void> onMount() async {
    super.onMount();
    _showIntroSequence();
  }

  void _showIntroSequence() {
    if (_introShown) return;
    _introShown = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final context = game.buildContext;
      if (context == null || !context.mounted) return;

      final loc = AppLocalizationsGen.of(context);
      if (loc == null) return;

      game.freezePlayer();

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.82),
        builder: (dialogContext) {
          return _CommentsDialog(
            title: loc.liam_self_title,
            body: loc.liam_comments_intro,
            continueLabel: loc.continueLabel,
          );
        },
      );

      game.unfreezePlayer();

      if (!context.mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.82),
        builder: (dialogContext) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF101820),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 30,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.character_liam,
                        style: const TextStyle(
                          color: Color(0xFFFFD54F),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        loc.liam_self_briefing,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
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
    });
  }

  @override
  double worldWidthForViewport(Vector2 viewportSize) {
    if (background.sprite?.srcSize != null &&
        background.sprite!.srcSize.y > 0) {
      final aspect =
          background.sprite!.srcSize.x / background.sprite!.srcSize.y;
      return viewportSize.y * aspect;
    }
    return viewportSize.x * 2;
  }

  @override
  Vector2 spawnPoint(Vector2 viewportSize, Vector2 worldSize) =>
      Vector2(worldSize.x * 0.1, worldSize.y * 0.68);
}

class _CommentsDialog extends StatefulWidget {
  final String title;
  final String body;
  final String continueLabel;

  const _CommentsDialog({
    required this.title,
    required this.body,
    required this.continueLabel,
  });

  @override
  State<_CommentsDialog> createState() => _CommentsDialogState();
}

class _CommentsDialogState extends State<_CommentsDialog>
  with SingleTickerProviderStateMixin {
  static const List<String> _comments = [
    'How did you even get here?',
    'Wow, can you actually get there in a wheelchair?',
    'Did someone help you get there?',
    'You are so brave for going out at all.',
    'A real hero. I would not be able to do that in your place.',
    'Honestly, at first I was not even looking at the photo - I was looking at the wheelchair.',
    'Careful, the pavement there is uneven. Dont get stuck.',
    'I do not even know what is more impressive - the place or the fact that you are there.',
    'It must be really hard for you to create such content.',
    'It is great that you are not just staying at home.',
  ];

  late final ScrollController _scrollController;
  late final AnimationController _autoScrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _autoScrollController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )
      ..addListener(_syncScroll)
      ..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  @override
  void dispose() {
    _autoScrollController
      ..removeListener(_syncScroll)
      ..dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _syncScroll();
  }

  void _syncScroll() {
    if (!mounted || !_scrollController.hasClients) return;

    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent <= 0) return;

    final targetOffset = maxExtent * _autoScrollController.value;
    _scrollController.jumpTo(targetOffset);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.shortestSide < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isSmall ? size.width : 430),
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0E1520),
                  Color(0xFF111827),
                  Color(0xFF1B2433),
                ],
              ),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  blurRadius: 36,
                  offset: const Offset(0, 22),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(-0.35, -0.85),
                          radius: 1.1,
                          colors: [
                            const Color(0xFF3A4A66).withValues(alpha: 0.95),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    child: Column(
                      children: [
                        _PhoneChrome(
                          title: widget.title,
                          onClose: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                children: [
                                  _PostHeader(title: widget.title),
                                  const SizedBox(height: 12),
                                  Expanded(
                                    flex: 5,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Container(
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Color(0xFF2B3345),
                                                  Color(0xFF1C2230),
                                                  Color(0xFF0D1118),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 18,
                                            top: 18,
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.08),
                                                borderRadius: BorderRadius.circular(18),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                                child: Text(
                                                  widget.body,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    height: 1.35,
                                                    fontWeight: FontWeight.w700,
                                                    decoration: TextDecoration.none,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 18,
                                            right: 18,
                                            bottom: 18,
                                            child: Row(
                                              children: [
                                                Icon(Icons.location_on_outlined, color: Colors.white.withValues(alpha: 0.9), size: 16),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'City frame 01',
                                                  style: TextStyle(
                                                    color: Colors.white.withValues(alpha: 0.9),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    decoration: TextDecoration.none,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0B1018),
                                        borderRadius: BorderRadius.circular(22),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.07),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                                            child: Row(
                                              children: [
                                                const CircleAvatar(
                                                  radius: 12,
                                                  backgroundColor: Color(0xFFFFD54F),
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 14,
                                                    color: Color(0xFF101820),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      widget.title,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w800,
                                                        decoration: TextDecoration.none,
                                                      ),
                                                    ),
                                                    Text(
                                                      '4h ago',
                                                      style: TextStyle(
                                                        color: Colors.white.withValues(alpha: 0.5),
                                                        fontSize: 11,
                                                        decoration: TextDecoration.none,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Spacer(),
                                                Icon(
                                                  Icons.more_horiz,
                                                  color: Colors.white.withValues(alpha: 0.7),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Divider(
                                            height: 1,
                                            color: Colors.white.withValues(alpha: 0.06),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                                            child: Row(
                                              children: [
                                                _metricChip(Icons.favorite_border, '1.2K'),
                                                const SizedBox(width: 8),
                                                _metricChip(Icons.mode_comment_outlined, '${_comments.length}'),
                                                const SizedBox(width: 8),
                                                _metricChip(Icons.send_outlined, 'Share'),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 14),
                                            child: Divider(
                                              height: 1,
                                              color: Colors.white.withValues(alpha: 0.06),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                                              child: SingleChildScrollView(
                                                controller: _scrollController,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    for (final comment in _comments)
                                                      Padding(
                                                        padding: const EdgeInsets.only(bottom: 12),
                                                        child: _CommentTile(comment: comment),
                                                      ),
                                                    for (final comment in _comments)
                                                      Padding(
                                                        padding: const EdgeInsets.only(bottom: 12),
                                                        child: _CommentTile(comment: comment),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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
}

Widget _metricChip(IconData icon, String label) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(999),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.9)),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    ),
  );
}

class _PhoneChrome extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const _PhoneChrome({required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Text(
            '9:41',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w800,
              decoration: TextDecoration.none,
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              decoration: TextDecoration.none,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.signal_cellular_alt, size: 14, color: Colors.white.withValues(alpha: 0.85)),
              const SizedBox(width: 6),
              Icon(Icons.wifi, size: 14, color: Colors.white.withValues(alpha: 0.85)),
              const SizedBox(width: 6),
              Icon(Icons.battery_full, size: 14, color: Colors.white.withValues(alpha: 0.85)),
              const SizedBox(width: 8),
              _ChromeCloseButton(onPressed: onClose),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChromeCloseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ChromeCloseButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.10),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.close,
            size: 14,
            color: Colors.white.withValues(alpha: 0.92),
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _ActionRow extends StatelessWidget {
  final String continueLabel;

  const _ActionRow({required this.continueLabel});

  @override
  Widget build(BuildContext context) {
    Widget iconButton(IconData icon) {
      return Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      );
    }

    return Row(
      children: [
        iconButton(Icons.favorite_border),
        const SizedBox(width: 8),
        iconButton(Icons.mode_comment_outlined),
        const SizedBox(width: 8),
        iconButton(Icons.send_outlined),
        const Spacer(),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                continueLabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PostHeader extends StatelessWidget {
  final String title;

  const _PostHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFFFFD54F),
          child: Icon(Icons.person, color: Color(0xFF101820)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  decoration: TextDecoration.none,
                ),
              ),
              Text(
                'shared a new post',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 11,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.more_horiz, color: Colors.white.withValues(alpha: 0.75)),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  final String comment;

  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 12,
          backgroundColor: Color(0xFF2A3443),
          child: Icon(Icons.person, size: 12, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'user',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'now',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 11,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                comment,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  height: 1.35,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
