import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../emvia_game.dart';
import '../../l10n/app_localizations_gen.dart';
import 'glass_ui.dart';

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
    final isDark = theme.brightness == Brightness.dark;
    final overlayTextColor = isDark
        ? theme.colorScheme.onSurface
        : Colors.white;
    final overlaySubduedTextColor = isDark
        ? theme.colorScheme.onSurfaceVariant
        : Colors.white70;
    final sectionTitleStyle = TextStyle(
      color: overlayTextColor,
      fontWeight: FontWeight.w700,
      fontSize: isSmall ? 13 : 14,
    );

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Align(
          alignment: Alignment.centerRight,
          child: GlassPanel(
            padding: EdgeInsets.all(isSmall ? 12 : 16),
            borderRadius: BorderRadius.circular(20),
            alphaValue: widget.isDarkMode ? 0.06 : 0.14,
            width: isSmall ? (size.width * 0.85).clamp(280.0, 320.0) : 320,
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
                          color: overlaySubduedTextColor,
                          iconSize: isSmall ? 20 : 24,
                        ),
                      ],
                    ),
                    SizedBox(height: isSmall ? 8 : 12),
                    Text(loc.sound, style: sectionTitleStyle),
                    Slider(
                      value: widget.game.volume,
                      onChanged: (v) => setState(() => widget.game.volume = v),
                      min: 0,
                      max: 1,
                      activeColor: theme.colorScheme.primary,
                    ),
                    SizedBox(height: isSmall ? 8 : 12),
                    Text(loc.language, style: sectionTitleStyle),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        GlassOptionChip(
                          label: loc.lang_uk,
                          icon: null,
                          selected: currentLanguage == 'uk',
                          onTap: () => _setLanguage('uk'),
                          compact: isSmall,
                        ),
                        GlassOptionChip(
                          label: loc.lang_en,
                          icon: null,
                          selected: currentLanguage == 'en',
                          onTap: () => _setLanguage('en'),
                          compact: isSmall,
                        ),
                      ],
                    ),
                    SizedBox(height: isSmall ? 12 : 16),
                    Text(loc.theme, style: sectionTitleStyle),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        GlassOptionChip(
                          label: loc.light,
                          icon: Icon(
                            Icons.light_mode_rounded,
                            size: isSmall ? 14 : 16,
                          ),
                          selected: !widget.isDarkMode,
                          onTap: widget.isDarkMode
                              ? widget.onThemeToggled
                              : null,
                          compact: isSmall,
                        ),
                        GlassOptionChip(
                          label: loc.dark,
                          icon: Icon(
                            Icons.dark_mode_rounded,
                            size: isSmall ? 14 : 16,
                          ),
                          selected: widget.isDarkMode,
                          onTap: widget.isDarkMode
                              ? null
                              : widget.onThemeToggled,
                          compact: isSmall,
                        ),
                      ],
                    ),
                    SizedBox(height: isSmall ? 16 : 24),
                    GlassButton(
                      label: loc.done,
                      onPressed: _close,
                      compact: isSmall,
                    ),
                    SizedBox(height: isSmall ? 8 : 12),
                    ExpansionTile(
                      collapsedIconColor: overlaySubduedTextColor,
                      iconColor: overlayTextColor,
                      tilePadding: EdgeInsets.zero,
                      title: Text(loc.credits, style: sectionTitleStyle),
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
                                  color: overlayTextColor,
                                ),
                              ),
                              subtitle: Text(
                                loc.leadDeveloper,
                                style: TextStyle(
                                  fontSize: isSmall ? 11 : 12,
                                  color: overlaySubduedTextColor,
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
                                  color: overlayTextColor,
                                ),
                              ),
                              subtitle: Text(
                                loc.artistAndDesigner,
                                style: TextStyle(
                                  fontSize: isSmall ? 11 : 12,
                                  color: overlaySubduedTextColor,
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
                                  color: overlayTextColor,
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
