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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: width,
      height: height,
      constraints: constraints,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
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
              color: (isDark ? Colors.black : Colors.white).withValues(alpha: alphaValue),
              borderRadius: borderRadius,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: child,
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
          child: Container(
            color: Colors.black.withValues(alpha: alphaValue),
          ),
        ),
      ),
    );
  }
}
