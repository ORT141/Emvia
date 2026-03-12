import 'dart:io';
import 'dart:ui' as ui;

import 'package:emvia/game/emvia_game.dart';
import 'package:emvia/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class CalmMapOverlay extends StatefulWidget {
  const CalmMapOverlay({super.key, required this.game});

  final EmviaGame game;

  @override
  State<CalmMapOverlay> createState() => _CalmMapOverlayState();
}

class _CalmMapOverlayState extends State<CalmMapOverlay> {
  final GlobalKey _exportKey = GlobalKey();
  bool _isExporting = false;

  Future<void> _exportPng() async {
    if (_isExporting || kIsWeb) return;

    setState(() => _isExporting = true);
    final l = AppLocalizations.of(context)!;

    try {
      await WidgetsBinding.instance.endOfFrame;

      final boundary =
          _exportKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        throw StateError('Render boundary is not ready');
      }

      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw StateError('Could not encode PNG');
      }

      final bytes = byteData.buffer.asUint8List();
      final directory =
          await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
      final fileName =
          'calm_map_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.png';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.calm_map_export_success)));
      await OpenFilex.open(file.path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.calm_map_export_failed)));
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final profile = widget.game.surveyProfile;
    final theme = Theme.of(context);

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.keyP) {
          _exportPng();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RepaintBoundary(
                      key: _exportKey,
                      child: _CalmMapCard(
                        game: widget.game,
                        title: l.calm_map_title,
                        artifactLabel: l.calm_map_personal_artifact,
                        safeColorLabel: l.calm_map_safe_color(
                          profile.safeColorLabel(context),
                        ),
                        patternLabel: l.calm_map_pattern(
                          profile.calmingPatternLabel(context),
                        ),
                        itemLabel: l.calm_map_item(
                          profile.calmingItemLabel(context),
                        ),
                        actionLabel: l.calm_map_calming_action(
                          profile.calmingActionLabel(context),
                        ),
                        soundLabel: l.calm_map_sound_trigger(
                          profile.soundTriggerLabel(context),
                        ),
                        supportMessageLabel: l.calm_map_support_message(
                          profile.supportMessageLabel(context),
                        ),
                        supportSymbolLabel: l.calm_map_support_symbol(
                          profile.supportSymbolLabel(context),
                        ),
                        selectedPathLabel: l.calm_map_selected_path(
                          _selectedToolsLabel(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l.calm_map_export_hint,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton.icon(
                          onPressed: _isExporting ? null : _exportPng,
                          icon: _isExporting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.image_outlined),
                          label: Text(l.calm_map_export_png),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () =>
                              widget.game.returnToMainMenuAfterJourney(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                          ),
                          child: Text(l.play_again),
                        ),
                      ],
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

  String _selectedToolsLabel(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final values = <String>[];
    for (final tool in widget.game.selectedTools) {
      final label = switch (tool) {
        'headphones' => l.item_headphones_name,
        _ => tool,
      };
      if (!values.contains(label)) {
        values.add(label);
      }
    }
    return values.isEmpty ? '—' : values.join(' • ');
  }
}

class _CalmMapCard extends StatelessWidget {
  const _CalmMapCard({
    required this.game,
    required this.title,
    required this.artifactLabel,
    required this.safeColorLabel,
    required this.patternLabel,
    required this.itemLabel,
    required this.actionLabel,
    required this.soundLabel,
    required this.supportMessageLabel,
    required this.supportSymbolLabel,
    required this.selectedPathLabel,
  });

  final EmviaGame game;
  final String title;
  final String artifactLabel;
  final String safeColorLabel;
  final String patternLabel;
  final String itemLabel;
  final String actionLabel;
  final String soundLabel;
  final String supportMessageLabel;
  final String supportSymbolLabel;
  final String selectedPathLabel;

  @override
  Widget build(BuildContext context) {
    final profile = game.surveyProfile;
    final baseColor = profile.safeColorValue;
    final accentColor = Color.lerp(baseColor, Colors.white, 0.45)!;

    return Container(
      width: 980,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(baseColor, Colors.white, 0.18)!,
            Color.lerp(baseColor, const Color(0xFF173047), 0.52)!,
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: CustomPaint(
          painter: _PatternPainter(
            patternId: profile.calmingPattern,
            strokeColor: Colors.white.withValues(alpha: 0.22),
            accentColor: accentColor.withValues(alpha: 0.20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            artifactLabel.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.6,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 38,
                              height: 1.05,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.34),
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        profile.supportSymbolEmoji,
                        style: const TextStyle(fontSize: 42),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    supportMessageLabel,
                    style: const TextStyle(
                      fontSize: 28,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _InfoPill(label: safeColorLabel),
                          const SizedBox(height: 12),
                          _InfoPill(label: patternLabel),
                          const SizedBox(height: 12),
                          _InfoPill(label: itemLabel),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        children: [
                          _InfoPill(label: actionLabel),
                          const SizedBox(height: 12),
                          _InfoPill(label: soundLabel),
                          const SizedBox(height: 12),
                          _InfoPill(label: supportSymbolLabel),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Text(
                    selectedPathLabel,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 18,
          height: 1.25,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  const _PatternPainter({
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
  bool shouldRepaint(covariant _PatternPainter oldDelegate) {
    return oldDelegate.patternId != patternId ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.accentColor != accentColor;
  }
}
