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
    if (!widget.game.isCharacterUnlocked(widget.game.selectedCharacter)) {
      return;
    }
    widget.game.startGame();
    widget.game.overlays.remove('MainMenu');
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
    final currentLocale = Localizations.localeOf(
      context,
    ).languageCode.toUpperCase();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/menu.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: theme.colorScheme.primaryContainer),
            ),
          ),

          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 400,
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _SmallIconButton(
                          onTap: widget.onThemeToggled,
                          icon: widget.isDarkMode
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          label: widget.isDarkMode ? loc.light : loc.dark,
                        ),
                        const SizedBox(width: 8),
                        _LanguageButton(
                          currentLocale: currentLocale,
                          onSelected: _switchLanguage,
                        ),
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
                            child: Text(
                              loc.title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.baloo2(
                                color: theme.colorScheme.primary,
                                fontSize: 48,
                                height: 1.1,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    offset: const Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            loc.subtitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 18,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 1),

                    _CharacterSelectBar(game: widget.game),

                    const SizedBox(height: 20),

                    _MenuButton(
                      label: loc.play,
                      color: theme.colorScheme.primaryContainer,
                      onColor: theme.colorScheme.onPrimaryContainer,
                      icon: Icons.play_arrow_rounded,
                      onPressed: _startNewGame,
                    ),

                    const SizedBox(height: 20),

                    _MenuButton(
                      label: loc.continueLabel,
                      color: theme.colorScheme.secondaryContainer,
                      onColor: theme.colorScheme.onSecondaryContainer,
                      icon: Icons.fast_forward_rounded,
                      onPressed: canContinue ? _continueGame : null,
                    ),

                    const SizedBox(height: 20),

                    _MenuButton(
                      label: loc.settings,
                      color: theme.colorScheme.tertiaryContainer,
                      onColor: theme.colorScheme.onTertiaryContainer,
                      icon: Icons.settings_rounded,
                      onPressed: _openSettings,
                    ),

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

class _SmallIconButton extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final String label;

  const _SmallIconButton({
    required this.onTap,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.baloo2(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String currentLocale;
  final ValueChanged<String> onSelected;

  const _LanguageButton({
    required this.currentLocale,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<String>(
      onSelected: onSelected,
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      position: PopupMenuPosition.under,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.public_rounded,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              currentLocale,
              style: GoogleFonts.baloo2(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
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

class _MenuButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color onColor;
  final IconData icon;
  final VoidCallback? onPressed;

  const _MenuButton({
    required this.label,
    required this.color,
    required this.onColor,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool enabled = onPressed != null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: enabled ? null : theme.colorScheme.surfaceContainerHighest,
        gradient: enabled
            ? LinearGradient(
                colors: [color.withValues(alpha: 0.8), color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: enabled ? onColor : onColor.withValues(alpha: 0.3),
                ),
                const SizedBox(width: 8),
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.baloo2(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: enabled ? onColor : onColor.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CharacterSelectBar extends StatefulWidget {
  final EmviaGame game;

  const _CharacterSelectBar({required this.game});

  @override
  State<_CharacterSelectBar> createState() => _CharacterSelectBarState();
}

class _CharacterSelectBarState extends State<_CharacterSelectBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            'Character',
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
                imagePath: 'images/player-selecting/olya_ghost.png',
                label: 'Olya',
                selected:
                    widget.game.selectedCharacter == PlayableCharacter.olya,
                locked: false,
                onTap: () {
                  setState(() {
                    widget.game.selectCharacter(PlayableCharacter.olya);
                  });
                },
              ),
              const SizedBox(width: 10),
              _CharacterGhost(
                imagePath: 'images/player-selecting/liam_ghost.png',
                label: 'Liam',
                selected:
                    widget.game.selectedCharacter == PlayableCharacter.liam,
                locked: true,
              ),
              const SizedBox(width: 10),
              _CharacterGhost(
                imagePath: 'images/player-selecting/olenka_ghost.png',
                label: 'Olenka',
                selected:
                    widget.game.selectedCharacter == PlayableCharacter.olenka,
                locked: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CharacterGhost extends StatelessWidget {
  final String imagePath;
  final String label;
  final bool selected;
  final bool locked;
  final VoidCallback? onTap;

  const _CharacterGhost({
    required this.imagePath,
    required this.label,
    required this.selected,
    required this.locked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
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
          color: locked
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
              : theme.colorScheme.surface,
        ),
        child: Column(
          children: [
            SizedBox(
              height: 76,
              child: Stack(
                children: [
                  Center(child: Image.asset(imagePath, fit: BoxFit.contain)),
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
    );
  }
}
