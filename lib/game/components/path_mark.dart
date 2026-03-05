import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class PathMark extends CircleComponent with TapCallbacks, HoverCallbacks {
  final int index;
  final void Function(int) onSelected;
  bool isSelected = false;
  
  @override
  bool isHovered = false;

  PathMark({
    required this.index,
    required this.onSelected,
    required Vector2 position,
    double radius = 16.0,
    Color? color,
    Color? explicitColor,
  }) : _explicitColor = explicitColor,
       super(
         radius: radius,
         position: position,
         anchor: Anchor.center,
         priority: 30,
       );
  Paint get _basePaint {
    final base = _resolvedBaseColor;
    return Paint()..color = base.withValues(alpha: 0.5);
  }

  Paint get _selectedPaint {
    final base = _resolvedBaseColor;
    return Paint()..color = base.withValues(alpha: 0.85);
  }

  Paint get _hoverPaint {
    final base = _resolvedBaseColor;
    return Paint()..color = base.withValues(alpha: 0.65);
  }

  Color get _resolvedBaseColor {
    if (_explicitColor != null) return _explicitColor;
    switch (index) {
      case 0:
        return const Color(0xFF4CAF50);
      case 1:
        return const Color(0xFF42A5F5);
      case 2:
        return const Color(0xFFFFA726);
      case 3:
        return const Color(0xFFAB47BC);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  final Color? _explicitColor;

  final Paint _borderPaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.6)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  @override
  void render(Canvas canvas) {
    final offset = (size / 2).toOffset();
    final currentRadius = radius * (isSelected ? 1.6 : 1.0);

    if (isHovered || isSelected) {
      final glowPaint = Paint()
        ..color = (isSelected ? const Color(0xFFFFA000) : Colors.white)
            .withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(offset, currentRadius + 6, glowPaint);
    }

    Paint bgPaint;
    if (isSelected) {
      bgPaint = _selectedPaint;
    } else if (isHovered) {
      bgPaint = _hoverPaint;
    } else {
      bgPaint = _basePaint;
    }

    canvas.drawCircle(offset, currentRadius, bgPaint);

    canvas.drawCircle(offset, currentRadius, _borderPaint);

    canvas.drawCircle(
      offset,
      currentRadius * (isHovered ? 0.5 : 0.42),
      Paint()..color = Colors.white.withValues(alpha: isSelected ? 0.95 : 0.8),
    );
  }

  @override
  void onHoverEnter() {
    isHovered = true;
  }

  @override
  void onHoverExit() {
    isHovered = false;
  }

  @override
  void onTapDown(TapDownEvent event) {
    onSelected(index);
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    final assistRadius = radius + 15.0;
    final center = size / 2;
    return point.distanceToSquared(center) <= assistRadius * assistRadius;
  }
}
