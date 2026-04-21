import 'dart:ui';
import 'package:flutter/material.dart';

class _GlassTheme {
  final ColorScheme colors;
  final bool isDark;

  _GlassTheme(BuildContext context)
    : colors = Theme.of(context).colorScheme,
      isDark = Theme.of(context).brightness == Brightness.dark;

  Color get panelBackground => isDark
      ? colors.surface.withValues(alpha: 0.12)
      : colors.surface.withValues(alpha: 0.6);

  Color get panelBorder => isDark
      ? colors.outline.withValues(alpha: 0.15)
      : colors.outline.withValues(alpha: 0.1);

  Color get panelText => colors.onSurface;
  Color get panelTextSecondary => colors.onSurfaceVariant;

  Color get buttonPrimaryBackground => colors.primary;
  Color get buttonPrimaryForeground => colors.onPrimary;

  Color get buttonSecondaryForeground => colors.onSurface;
  Color get buttonSecondaryBorder =>
      colors.outline.withValues(alpha: isDark ? 0.3 : 0.2);

  Color chipBackground(bool selected) => selected
      ? colors.primaryContainer
      : colors.surfaceContainerHighest.withValues(alpha: isDark ? 0.4 : 0.5);

  Color chipBorder(bool selected) =>
      selected ? colors.primary : colors.outlineVariant.withValues(alpha: 0.5);

  Color chipText(bool selected) =>
      selected ? colors.onPrimaryContainer : colors.onSurfaceVariant;
}

class _GlassBase extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final double blurSigma;
  final Color backgroundColor;
  final Color borderColor;
  final EdgeInsetsGeometry? padding;

  const _GlassBase({
    required this.child,
    required this.borderRadius,
    required this.blurSigma,
    required this.backgroundColor,
    required this.borderColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: borderRadius),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: borderRadius,
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class GlassPanel extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius borderRadius;
  final double blurSigma;
  final double? alphaValue;
  final BoxConstraints? constraints;

  const GlassPanel({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.blurSigma = 12,
    this.alphaValue,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final glassTheme = _GlassTheme(context);

    final backgroundColor = alphaValue != null
        ? glassTheme.colors.surface.withValues(alpha: alphaValue!)
        : glassTheme.panelBackground;

    return Container(
      width: width,
      height: height,
      constraints: constraints,
      child: _GlassBase(
        borderRadius: borderRadius,
        blurSigma: blurSigma,
        backgroundColor: backgroundColor,
        borderColor: glassTheme.panelBorder,
        padding: padding ?? const EdgeInsets.all(24),
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: glassTheme.colors.copyWith(
              onSurface: glassTheme.panelText,
              onSurfaceVariant: glassTheme.panelTextSecondary,
            ),
            textTheme: Theme.of(context).textTheme.apply(
              bodyColor: glassTheme.panelText,
              displayColor: glassTheme.panelText,
              decorationColor: glassTheme.panelText,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: DefaultTextStyle.merge(
              style: TextStyle(color: glassTheme.panelText),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final bool compact;
  final bool loading;

  const GlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.primary = true,
    this.compact = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final glassTheme = _GlassTheme(context);
    final padding = EdgeInsets.symmetric(
      vertical: compact ? 12 : 14,
      horizontal: 24,
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    final child = loading
        ? SizedBox(
            height: compact ? 16 : 20,
            width: compact ? 16 : 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: primary
                  ? glassTheme.buttonPrimaryForeground
                  : glassTheme.buttonSecondaryForeground,
            ),
          )
        : Text(
            label,
            style: TextStyle(
              fontSize: compact ? 14 : 16,
              fontWeight: primary ? FontWeight.w700 : FontWeight.w600,
            ),
          );

    if (primary) {
      return FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: glassTheme.buttonPrimaryBackground,
          foregroundColor: glassTheme.buttonPrimaryForeground,
          padding: padding,
          shape: shape,
        ),
        child: child,
      );
    } else {
      return OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: glassTheme.buttonSecondaryForeground,
          side: BorderSide(color: glassTheme.buttonSecondaryBorder, width: 1.5),
          padding: padding,
          shape: shape,
        ),
        child: child,
      );
    }
  }
}

class GlassOptionChip extends StatelessWidget {
  final String label;
  final Widget? icon;
  final bool selected;
  final VoidCallback? onTap;
  final bool compact;

  const GlassOptionChip({
    super.key,
    required this.label,
    this.icon,
    required this.selected,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final glassTheme = _GlassTheme(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          vertical: compact ? 8 : 10,
          horizontal: compact ? 10 : 14,
        ),
        decoration: BoxDecoration(
          color: glassTheme.chipBackground(selected),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: glassTheme.chipBorder(selected),
            width: selected ? 2.0 : 1.0,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: glassTheme.colors.primary.withValues(alpha: 0.2),
                blurRadius: 8,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null || selected) ...[
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: selected
                    ? Icon(
                        Icons.check_circle_rounded,
                        key: const ValueKey('check'),
                        color: glassTheme.chipText(selected),
                        size: compact ? 14 : 16,
                      )
                    : (icon != null
                        ? IconTheme(
                            data: IconThemeData(
                              color: glassTheme.chipText(selected),
                              size: compact ? 14 : 16,
                            ),
                            child: icon!,
                          )
                        : const SizedBox.shrink()),
              ),
              const SizedBox(width: 6),
            ],
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: compact ? 12 : 14,
                color: glassTheme.chipText(selected),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class GlassDialog extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const GlassDialog({super.key, required this.child, this.maxWidth = 400});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: GlassPanel(padding: const EdgeInsets.all(32), child: child),
        ),
      ),
    );
  }
}
