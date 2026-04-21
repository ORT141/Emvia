import 'dart:ui';
import 'package:flutter/material.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius borderRadius;
  final double blurSigma;
  final double alphaValue;
  final BoxConstraints? constraints;

  const GlassPanel({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.blurSigma = 12,
    this.alphaValue = 0.15,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final panelTextColor = isDark
        ? theme.colorScheme.onSurface
        : Colors.white.withOpacity(0.95);
    final borderColor = isDark
        ? theme.colorScheme.outline.withOpacity(0.2)
        : Colors.white.withOpacity(0.25);
    final backgroundColor = isDark
        ? theme.colorScheme.surface.withOpacity(alphaValue)
        : Colors.black.withOpacity(0.2);

    return Container(
      width: width,
      height: height,
      constraints: constraints,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding ?? const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: borderRadius,
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Material(
              color: Colors.transparent,
              child: DefaultTextStyle.merge(
                style: TextStyle(color: panelTextColor),
                child: child,
              ),
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

  const GlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.primary = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (primary) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor:
              isDark ? theme.colorScheme.onPrimary : Colors.black87,
          padding: EdgeInsets.symmetric(
            vertical: compact ? 12 : 14,
            horizontal: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: compact ? 14 : 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    } else {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? Colors.white : Colors.black87,
          side: BorderSide(
            color: isDark ? Colors.white24 : Colors.black26,
            width: 1.5,
          ),
          padding: EdgeInsets.symmetric(
            vertical: compact ? 12 : 14,
            horizontal: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: compact ? 14 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
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
    final theme = Theme.of(context);

    final backgroundColor = selected
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4);

    final borderColor = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.5);

    final textColor = selected
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: compact ? 8 : 10,
          horizontal: compact ? 10 : 14,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              IconTheme(
                data: IconThemeData(color: textColor, size: compact ? 14 : 16),
                child: icon!,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: compact ? 12 : 14,
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
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

  const GlassDialog({
    super.key,
    required this.child,
    this.maxWidth = 400,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: GlassPanel(
            padding: const EdgeInsets.all(32),
            child: Material(
              color: Colors.transparent,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class GlassOverlayScrim extends StatelessWidget {
  final VoidCallback? onTap;
  final double blurSigma;
  final double alphaValue;

  const GlassOverlayScrim({
    super.key,
    this.onTap,
    this.blurSigma = 8,
    this.alphaValue = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onTap,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(color: Colors.black.withValues(alpha: alphaValue)),
        ),
      ),
    );
  }
}
