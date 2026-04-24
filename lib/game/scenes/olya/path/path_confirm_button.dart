import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:emvia/l10n/app_localizations.dart';
import '../../../emvia_game.dart';

class PathConfirmButton extends PositionComponent
    with TapCallbacks, HasGameReference<EmviaGame> {
  final VoidCallback onConfirm;
  bool isEnabled = false;
  final double radius;

  PathConfirmButton({
    required this.onConfirm,
    required Vector2 position,
    Vector2? size,
    this.radius = 12,
  }) : super(
         position: position,
         size: size ?? Vector2(200, 60),
         anchor: Anchor.center,
         priority: 100,
       );

  final Paint _activePaint = Paint()..color = Colors.white;
  final Paint _disabledPaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.5);
  late Paint _currentPaint;

  late TextPainter _textPainter;

  @override
  Future<void> onLoad() async {
    _currentPaint = _disabledPaint;
    _updateText();
  }

  void _updateText() {
    final context = game.buildContext;
    if (context == null) return;

    final l = AppLocalizations.of(context)!;
    _textPainter = TextPainter(
      text: TextSpan(
        text: l.confirm,
        style: TextStyle(
          color: isEnabled ? const Color(0xFF333333) : const Color(0xFF999999),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  @override
  void render(Canvas canvas) {
    final rect = RRect.fromRectAndRadius(
      size.toRect(),
      Radius.circular(radius),
    );
    canvas.drawRRect(rect, _currentPaint);

    if (isEnabled) {
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRRect(rect, borderPaint);
    }

    if (game.buildContext != null) {
      _updateText();
      _textPainter.paint(
        canvas,
        Offset(
          (size.x - _textPainter.width) / 2,
          (size.y - _textPainter.height) / 2,
        ),
      );
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    if (!isEnabled) {
      return false;
    }
    return super.containsLocalPoint(point);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isEnabled) {
      onConfirm();
    }
  }

  void setEnabled(bool enabled) {
    isEnabled = enabled;
    _currentPaint = enabled ? _activePaint : _disabledPaint;
  }
}
