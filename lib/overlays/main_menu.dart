import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../game/emvia_game.dart';
import '../l10n/app_localizations_gen.dart';

class MainMenuOverlay extends StatefulWidget {
  final EmviaGame game;
  final ValueChanged<Locale>? onLocaleChanged;
  final VoidCallback? onThemeToggled;
  final bool isDarkMode;

  const MainMenuOverlay({
    super.key,
    required this.game,
    this.onLocaleChanged,
    this.onThemeToggled,
    this.isDarkMode = false,
  });

  @override
  State<MainMenuOverlay> createState() => _MainMenuOverlayState();
}

class _MainMenuOverlayState extends State<MainMenuOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startNewGame() {
    _openNewGameModal();
  }

  Future<void> _openNewGameModal() async {
    final loc = AppLocalizationsGen.of(context)!;
    final theme = Theme.of(context);
    PlayableCharacter? pendingCharacter;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final bool canStart =
              pendingCharacter != null &&
              widget.game.isCharacterUnlocked(pendingCharacter!);

          return AlertDialog(
            backgroundColor: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              loc.play,
              style: GoogleFonts.baloo2(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CharacterSelectBar(
                    game: widget.game,
                    selectedCharacter: pendingCharacter,
                    onCharacterSelected: (character) {
                      setModalState(() {
                        pendingCharacter = character;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(loc.cancel),
              ),
              ElevatedButton(
                onPressed: canStart
                    ? () {
                        widget.game.selectCharacter(pendingCharacter!);
                        Navigator.of(ctx).pop();
                        widget.game.startNewGameSurveyFlow();
                      }
                    : null,
                child: Text(loc.play),
              ),
            ],
          );
        },
      ),
    );
  }

  void _continueGame() {
    widget.game.overlays.remove('MainMenu');
  }

  void _openSettings() {
    widget.game.overlays.add('Settings');
  }

  void _openCredits() {
    widget.game.overlays.add('Credits');
  }

  void _switchLanguage(String languageCode) {
    widget.onLocaleChanged?.call(Locale(languageCode));
  }

  Future<void> _confirmExit() async {
    final loc = AppLocalizationsGen.of(context)!;
    final theme = Theme.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          loc.exit,
          style: GoogleFonts.baloo2(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          loc.exitConfirm,
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              loc.cancel,
              style: TextStyle(color: theme.colorScheme.outline),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              loc.exit,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (ok ?? false) {
      if (!mounted) return;
      try {
        if (Platform.isAndroid) {
          SystemNavigator.pop();
        } else {
          exit(0);
        }
      } catch (e) {
        Navigator.of(context).maybePop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizationsGen.of(context)!;
    final theme = Theme.of(context);
    final canContinue = widget.game.sceneIndex > 0;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/menu.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: theme.colorScheme.primaryContainer),
            ),
          ),

          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 400,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 400,
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 24),
                        _TopImageButton(
                          onTap: _openSettings,
                          assetPath:
                              'assets/images/main-menu/settings-main-menu.png',
                          width: 76,
                        ),
                        const SizedBox(width: 12),
                        _TopImageButton(
                          onTap: widget.onThemeToggled,
                          assetPath:
                              'assets/images/main-menu/theme-switch-main-menu.png',
                          width: 96,
                        ),
                        const SizedBox(width: 12),
                        _LanguageButton(onSelected: _switchLanguage),
                      ],
                    ),

                    const Spacer(flex: 1),

                    Center(
                      child: Column(
                        children: [
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final scale =
                                  1.0 + (_pulseController.value * 0.04);
                              return Transform.scale(
                                scale: scale,
                                child: child,
                              );
                            },
                            child: Image.asset(
                              'assets/images/main-menu/logo-main-menu.png',
                              width: 260,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 1),

                    _ImageMenuButton(
                      assetPath: 'assets/images/main-menu/play-main-menu.png',
                      onPressed: _startNewGame,
                    ),

                    const SizedBox(height: 20),

                    _ImageMenuButton(
                      assetPath:
                          'assets/images/main-menu/continue-main-menu.png',
                      onPressed: canContinue ? _continueGame : null,
                    ),

                    const SizedBox(height: 20),

                    const SizedBox(height: 40),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: _openCredits,
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.onSurfaceVariant,
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          child: Text(loc.credits),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.outlineVariant,
                            shape: BoxShape.circle,
                          ),
                        ),
                        TextButton(
                          onPressed: _confirmExit,
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.error.withValues(
                              alpha: 0.7,
                            ),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          child: Text(loc.exit),
                        ),
                      ],
                    ),

                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopImageButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String assetPath;
  final double width;

  const _TopImageButton({
    required this.onTap,
    required this.assetPath,
    this.width = 92,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Opacity(
          opacity: onTap != null ? 1.0 : 0.45,
          child: Image.asset(assetPath, width: width, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final ValueChanged<String> onSelected;

  const _LanguageButton({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      position: PopupMenuPosition.under,
      child: Image.asset(
        'assets/images/main-menu/lang-switch-main-menu.png',
        width: 96,
        fit: BoxFit.contain,
      ),
      itemBuilder: (context) => [
        _buildLanguageItem('en', '🇺🇸 English'),
        _buildLanguageItem('uk', '🇺🇦 Українська'),
      ],
    );
  }

  PopupMenuItem<String> _buildLanguageItem(String value, String label) {
    return PopupMenuItem(
      value: value,
      child: Text(
        label,
        style: GoogleFonts.baloo2(fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _ImageMenuButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback? onPressed;

  const _ImageMenuButton({required this.assetPath, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;

    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                height: 72,
                child: Center(child: Icon(Icons.broken_image_rounded)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CharacterSelectBar extends StatefulWidget {
  final EmviaGame game;
  final PlayableCharacter? selectedCharacter;
  final ValueChanged<PlayableCharacter> onCharacterSelected;

  const _CharacterSelectBar({
    required this.game,
    required this.selectedCharacter,
    required this.onCharacterSelected,
  });

  @override
  State<_CharacterSelectBar> createState() => _CharacterSelectBarState();
}

class _CharacterSelectBarState extends State<_CharacterSelectBar> {
  PlayableCharacter? _hoveredCharacter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCharacter = widget.selectedCharacter;
    final selectedCard = selectedCharacter != null
        ? _characterCardData(selectedCharacter)
        : null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Text(
            'Герої',
            style: GoogleFonts.baloo2(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CharacterGhost(
                imagePath: 'player-selecting/olya_ghost.png',
                realImagePath: 'player/standing.png',
                label: 'Оля',
                selected: selectedCharacter == PlayableCharacter.olya,
                hovered: _hoveredCharacter == PlayableCharacter.olya,
                locked: false,
                onHoverChanged: (isHovering) {
                  setState(() {
                    _hoveredCharacter = isHovering
                        ? PlayableCharacter.olya
                        : (_hoveredCharacter == PlayableCharacter.olya
                              ? null
                              : _hoveredCharacter);
                  });
                },
                onTap: () {
                  widget.onCharacterSelected(PlayableCharacter.olya);
                },
              ),
              const SizedBox(width: 10),
              _CharacterGhost(
                imagePath: 'player-selecting/liam_ghost.png',
                label: 'Ліам',
                selected: selectedCharacter == PlayableCharacter.liam,
                hovered: _hoveredCharacter == PlayableCharacter.liam,
                locked: true,
                onHoverChanged: (isHovering) {
                  setState(() {
                    _hoveredCharacter = isHovering
                        ? PlayableCharacter.liam
                        : (_hoveredCharacter == PlayableCharacter.liam
                              ? null
                              : _hoveredCharacter);
                  });
                },
              ),
              const SizedBox(width: 10),
              _CharacterGhost(
                imagePath: 'player-selecting/olenka_ghost.png',
                label: 'Оленка',
                selected: selectedCharacter == PlayableCharacter.olenka,
                hovered: _hoveredCharacter == PlayableCharacter.olenka,
                locked: true,
                onHoverChanged: (isHovering) {
                  setState(() {
                    _hoveredCharacter = isHovering
                        ? PlayableCharacter.olenka
                        : (_hoveredCharacter == PlayableCharacter.olenka
                              ? null
                              : _hoveredCharacter);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          _CharacterInfoCard(data: selectedCard),
        ],
      ),
    );
  }

  _CharacterCardData _characterCardData(PlayableCharacter character) {
    final loc = AppLocalizationsGen.of(context)!;
    switch (character) {
      case PlayableCharacter.olya:
        return _CharacterCardData(
          title: loc.character_olya_title,
          quote: loc.character_olya_quote,
          trait: loc.character_olya_trait,
          superPower: loc.character_olya_superPower,
          description: loc.character_olya_description,
        );
      case PlayableCharacter.liam:
        return _CharacterCardData(
          title: loc.character_liam_title,
          quote: loc.character_liam_quote,
          trait: loc.character_liam_trait,
          superPower: loc.character_liam_superPower,
          description: loc.character_liam_description,
        );
      case PlayableCharacter.olenka:
        return _CharacterCardData(
          title: loc.character_olenka_title,
          quote: loc.character_olenka_quote,
          trait: loc.character_olenka_trait,
          superPower: loc.character_olenka_superPower,
          description: loc.character_olenka_description,
        );
    }
  }
}

class _CharacterCardData {
  final String title;
  final String quote;
  final String trait;
  final String superPower;
  final String description;

  const _CharacterCardData({
    required this.title,
    required this.quote,
    required this.trait,
    required this.superPower,
    required this.description,
  });
}

class _CharacterInfoCard extends StatelessWidget {
  final _CharacterCardData? data;

  const _CharacterInfoCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: data == null
          ? Text(
              'Обери героя, щоб побачити опис',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data!.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data!.quote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Особливість: ${data!.trait}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Суперсила: ${data!.superPower}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(data!.description, style: theme.textTheme.bodySmall),
              ],
            ),
    );
  }
}

class _CharacterGhost extends StatelessWidget {
  final String imagePath;
  final String? realImagePath;
  final String label;
  final bool selected;
  final bool hovered;
  final bool locked;
  final ValueChanged<bool>? onHoverChanged;
  final VoidCallback? onTap;

  const _CharacterGhost({
    required this.imagePath,
    this.realImagePath,
    required this.label,
    required this.selected,
    required this.hovered,
    required this.locked,
    this.onHoverChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool showRealSprite =
        !locked && (selected || hovered) && realImagePath != null;
    final String displayPath = showRealSprite ? realImagePath! : imagePath;

    return MouseRegion(
      onEnter: (_) => onHoverChanged?.call(true),
      onExit: (_) => onHoverChanged?.call(false),
      child: InkWell(
        onTap: locked ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 84,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
            color: locked
                ? theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  )
                : (selected
                      ? theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        )
                      : theme.colorScheme.surface),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 76,
                child: Stack(
                  children: [
                    Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(
                                begin: 0.92,
                                end: 1.0,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Image.asset(
                          'assets/images/$displayPath',
                          key: ValueKey(displayPath),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    if (locked)
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Icon(
                          Icons.lock,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    if (selected && !locked)
                      Positioned(
                        left: 2,
                        top: 2,
                        child: Icon(
                          Icons.check_circle,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                label,
                style: GoogleFonts.baloo2(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
