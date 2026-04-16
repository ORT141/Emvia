import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../emvia_game.dart';
import '../../l10n/app_localizations_gen.dart';

class SettingsOverlay extends StatefulWidget {
  final EmviaGame game;
  final ValueChanged<Locale>? onLocaleChanged;
  final VoidCallback? onThemeToggled;
  final bool isDarkMode;

  const SettingsOverlay({
    super.key,
    required this.game,
    this.onLocaleChanged,
    this.onThemeToggled,
    this.isDarkMode = false,
  });

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _close() {
    _slideController.reverse().then((_) {
      widget.game.overlays.remove('Settings');
    });
  }

  void _setLanguage(String code) {
    widget.onLocaleChanged?.call(Locale(code));
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
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
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
      try {
        if (Platform.isAndroid) {
          SystemNavigator.pop();
        } else {
          exit(0);
        }
      } catch (e) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).maybePop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizationsGen.of(context)!;
    final theme = Theme.of(context);
    final currentLanguage = Localizations.localeOf(context).languageCode;
    final size = MediaQuery.of(context).size;
    final isSmall = size.shortestSide < 600;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin:
                MediaQuery.of(context).padding +
                EdgeInsets.all(isSmall ? 8 : 16),
            padding: EdgeInsets.all(isSmall ? 12 : 16),
            width: isSmall ? (size.width * 0.85).clamp(280.0, 320.0) : 320,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: widget.isDarkMode ? 0.3 : 0.08,
                  ),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: SingleChildScrollView(
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.settings,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: isSmall ? 18 : 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _close,
                          color: theme.colorScheme.onSurfaceVariant,
                          iconSize: isSmall ? 20 : 24,
                        ),
                      ],
                    ),
                    SizedBox(height: isSmall ? 8 : 12),
                    Text(
                      loc.sound,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: isSmall ? 13 : 14,
                      ),
                    ),
                    Slider(
                      value: widget.game.volume,
                      onChanged: (v) => setState(() => widget.game.volume = v),
                      min: 0,
                      max: 1,
                      activeColor: theme.colorScheme.primary,
                    ),
                    SizedBox(height: isSmall ? 8 : 12),
                    Text(
                      loc.language,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: isSmall ? 13 : 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _LangChip(
                          label: loc.lang_uk,
                          code: 'uk',
                          selected: currentLanguage == 'uk',
                          onTap: _setLanguage,
                          compact: isSmall,
                        ),
                        _LangChip(
                          label: loc.lang_en,
                          code: 'en',
                          selected: currentLanguage == 'en',
                          onTap: _setLanguage,
                          compact: isSmall,
                        ),
                      ],
                    ),
                    SizedBox(height: isSmall ? 12 : 16),
                    Text(
                      loc.theme,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: isSmall ? 13 : 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ThemeChip(
                          label: loc.light,
                          isDark: false,
                          selected: !widget.isDarkMode,
                          onTap: !widget.isDarkMode
                              ? null
                              : widget.onThemeToggled,
                          compact: isSmall,
                        ),
                        _ThemeChip(
                          label: loc.dark,
                          isDark: true,
                          selected: widget.isDarkMode,
                          onTap: widget.isDarkMode
                              ? null
                              : widget.onThemeToggled,
                          compact: isSmall,
                        ),
                      ],
                    ),
                    SizedBox(height: isSmall ? 16 : 24),
                    FilledButton(
                      onPressed: _close,
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmall ? 12 : 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        loc.done,
                        style: TextStyle(
                          fontSize: isSmall ? 14 : 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: isSmall ? 8 : 12),
                    ExpansionTile(
                      collapsedIconColor: theme.colorScheme.onSurfaceVariant,
                      tilePadding: EdgeInsets.zero,
                      title: Text(
                        loc.credits,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: isSmall ? 13 : 14,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              visualDensity: VisualDensity.compact,
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                radius: isSmall ? 16 : 20,
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                child: Text(
                                  'RD',
                                  style: TextStyle(
                                    fontSize: isSmall ? 10 : 12,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              title: Text(
                                'Remez Devid',
                                style: TextStyle(
                                  fontSize: isSmall ? 13 : 14,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              subtitle: Text(
                                loc.leadDeveloper,
                                style: TextStyle(
                                  fontSize: isSmall ? 11 : 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            ListTile(
                              visualDensity: VisualDensity.compact,
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                radius: isSmall ? 16 : 20,
                                backgroundColor:
                                    theme.colorScheme.secondaryContainer,
                                child: Text(
                                  'AD',
                                  style: TextStyle(
                                    fontSize: isSmall ? 10 : 12,
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ),
                              title: Text(
                                'Alice Dudarok',
                                style: TextStyle(
                                  fontSize: isSmall ? 13 : 14,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              subtitle: Text(
                                loc.artistAndDesigner,
                                style: TextStyle(
                                  fontSize: isSmall ? 11 : 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Text(
                                loc.thanksForPlaying,
                                style: TextStyle(
                                  fontSize: isSmall ? 12 : 13,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _confirmExit,
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmall ? 8 : 12,
                        ),
                      ),
                      child: Text(
                        loc.exit,
                        style: TextStyle(fontSize: isSmall ? 13 : 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final String code;
  final bool selected;
  final void Function(String) onTap;
  final bool compact;

  const _LangChip({
    required this.label,
    required this.code,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => onTap(code),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: compact ? 8 : 10,
          horizontal: compact ? 10 : 14,
        ),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: compact ? 12 : 14,
            color: selected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;
  final bool isDark;
  final bool selected;
  final VoidCallback? onTap;
  final bool compact;

  const _ThemeChip({
    required this.label,
    required this.isDark,
    required this.selected,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: compact ? 8 : 10,
          horizontal: compact ? 10 : 14,
        ),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              size: compact ? 14 : 16,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: compact ? 12 : 14,
                color: selected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
