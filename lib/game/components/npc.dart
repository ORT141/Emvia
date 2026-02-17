import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../emvia_game.dart';
import '../dialog_model.dart';

class NPC extends PositionComponent
    with HasGameReference<EmviaGame>, TapCallbacks {
  final String npcName;
  final DialogTree dialogTree;
  final Color themeColor;

  NPC({
    required this.npcName,
    required this.dialogTree,
    required Vector2 position,
    required Vector2 size,
    this.themeColor = Colors.blueAccent,
  }) : super(position: position, size: size, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {}

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));

    canvas.drawRRect(rrect, Paint()..color = themeColor.withValues(alpha: 0.7));

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y),
        width: size.x * 0.8,
        height: 10,
      ),
      Paint()..color = Colors.black26,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: npcName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset(size.x / 2 - textPainter.width / 2, -25));

    final iconPainter = TextPainter(
      text: const TextSpan(text: '💬', style: TextStyle(fontSize: 24)),
      textDirection: TextDirection.ltr,
    )..layout();

    iconPainter.paint(canvas, Offset(size.x / 2 - iconPainter.width / 2, -60));
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.startDialog(dialogTree);
  }
}
