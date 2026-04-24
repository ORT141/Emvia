import 'package:flutter/material.dart';

class PatternPainter extends CustomPainter {
  const PatternPainter({
    required this.patternId,
    required this.strokeColor,
    required this.accentColor,
  });

  final String patternId;
  final Color strokeColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    switch (patternId) {
      case 'nature':
        _paintNature(canvas, size);
        return;
      case 'stars':
        _paintStars(canvas, size);
        return;
      case 'clouds':
        _paintClouds(canvas, size);
        return;
      case 'geometry':
      default:
        _paintGeometry(canvas, size);
    }
  }

  void _paintGeometry(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    const step = 74.0;
    for (double x = -size.height; x < size.width + size.height; x += step) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
    for (double x = 0; x < size.width; x += step * 1.2) {
      canvas.drawRect(Rect.fromLTWH(x, size.height * 0.18, 42, 42), paint);
    }
  }

  void _paintNature(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final fill = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    for (double x = 80; x < size.width; x += 160) {
      final path = Path()
        ..moveTo(x, size.height * 0.18)
        ..quadraticBezierTo(x - 28, size.height * 0.26, x, size.height * 0.34)
        ..quadraticBezierTo(x + 28, size.height * 0.26, x, size.height * 0.18);
      canvas.drawPath(path, fill);
      canvas.drawPath(path, stroke);
    }

    for (double y = size.height * 0.58; y < size.height; y += 56) {
      final path = Path()..moveTo(0, y);
      for (double x = 0; x <= size.width; x += 48) {
        path.quadraticBezierTo(x + 24, y - 14, x + 48, y);
      }
      canvas.drawPath(path, stroke);
    }
  }

  void _paintStars(Canvas canvas, Size size) {
    final dot = Paint()
      ..color = Colors.white.withValues(alpha: 0.56)
      ..style = PaintingStyle.fill;
    final line = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    final points = <Offset>[];
    for (double y = 54; y < size.height; y += 82) {
      for (double x = 48; x < size.width; x += 120) {
        final offset = Offset(x + ((y / 16) % 22), y + ((x / 30) % 16));
        points.add(offset);
        canvas.drawCircle(offset, 2.4, dot);
      }
    }

    for (int i = 0; i < points.length - 1; i += 3) {
      canvas.drawLine(points[i], points[i + 1], line);
    }
  }

  void _paintClouds(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
    final outline = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    for (double x = -40; x < size.width + 80; x += 180) {
      for (double y = 40; y < size.height; y += 120) {
        final rect = Rect.fromLTWH(x, y, 120, 48);
        final path = Path()
          ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(26)))
          ..addOval(Rect.fromCircle(center: Offset(x + 34, y + 18), radius: 22))
          ..addOval(Rect.fromCircle(center: Offset(x + 64, y + 10), radius: 28))
          ..addOval(
            Rect.fromCircle(center: Offset(x + 94, y + 22), radius: 20),
          );
        canvas.drawPath(path, fill);
        canvas.drawPath(path, outline);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PatternPainter oldDelegate) {
    return oldDelegate.patternId != patternId ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.accentColor != accentColor;
  }
}
