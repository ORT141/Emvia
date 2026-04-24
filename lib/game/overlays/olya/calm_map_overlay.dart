import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:emvia/game/emvia_game.dart';
import 'package:emvia/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../glass_ui.dart';
import 'info_pill.dart';
import 'pattern_painter.dart';

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
    final size = MediaQuery.of(context).size;
    final isSmall = size.shortestSide < 600;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withValues(alpha: 0.4)),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isSmall ? size.width * 0.95 : 820,
                maxHeight: size.height * 0.95,
              ),
              child: Padding(
                padding: EdgeInsets.all(isSmall ? 8 : 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return FittedBox(
                            fit: BoxFit.scaleDown,
                            child: SizedBox(
                              width: constraints.maxWidth,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  isSmall ? 24 : 32,
                                ),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 15,
                                    sigmaY: 15,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        isSmall ? 24 : 32,
                                      ),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: RepaintBoundary(
                                      key: _exportKey,
                                      child: _CalmMapCard(
                                        game: widget.game,
                                        title: l.calm_map_title,
                                        artifactLabel:
                                            l.calm_map_personal_artifact,
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
                                        supportMessageLabel: profile
                                            .supportMessageLabel(context),
                                        supportSymbolLabel: l
                                            .calm_map_support_symbol(
                                              profile.supportSymbolLabel(
                                                context,
                                              ),
                                            ),
                                        selectedPathLabel: _selectedToolsLabel(
                                          context,
                                        ),
                                        isSmall: isSmall,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: isSmall ? 16 : 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GlassButton(
                          label: l.calm_map_export_png.toUpperCase(),
                          onPressed: _isExporting ? null : _exportPng,
                          compact: isSmall,
                        ),
                        SizedBox(width: isSmall ? 12 : 16),
                        GlassButton(
                          label: l.play_again.toUpperCase(),
                          onPressed: () =>
                              widget.game.returnToMainMenuAfterJourney(),
                          primary: false,
                          compact: isSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
    return values.isEmpty ? '-' : values.join(' • ');
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
    this.isSmall = false,
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
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    final profile = game.surveyProfile;
    final baseColor = profile.safeColorValue;
    final accentColor = Color.lerp(baseColor, Colors.white, 0.45)!;

    final isVerySmall = MediaQuery.of(context).size.shortestSide < 400;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(baseColor, const Color(0xFF0F2027), 0.3)!,
            const Color(0xFF0F2027),
          ],
        ),
        borderRadius: BorderRadius.circular(isSmall ? 20 : 32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: isSmall ? 16 : 40,
            offset: Offset(0, isSmall ? 6 : 20),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.05),
            blurRadius: 0,
            spreadRadius: -1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isSmall ? 12 : 24),
        child: CustomPaint(
          painter: PatternPainter(
            patternId: profile.calmingPattern,
            strokeColor: Colors.white.withValues(alpha: 0.18),
            accentColor: accentColor.withValues(alpha: 0.15),
          ),
          child: Padding(
            padding: EdgeInsets.all(isSmall ? 12 : 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              artifactLabel.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: isVerySmall ? 8 : (isSmall ? 9 : 12),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                          SizedBox(height: isSmall ? 2 : 8),
                          Text(
                            title,
                            style: GoogleFonts.baloo2(
                              fontSize: isVerySmall ? 20 : (isSmall ? 24 : 48),
                              height: 0.9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: isSmall ? 8 : 20),
                    Container(
                      width: isVerySmall ? 48 : (isSmall ? 56 : 100),
                      height: isVerySmall ? 48 : (isSmall ? 56 : 100),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        profile.supportSymbolEmoji,
                        style: TextStyle(
                          fontSize: isVerySmall ? 24 : (isSmall ? 28 : 52),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmall ? 12 : 32),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isSmall ? 10 : 24),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(isSmall ? 12 : 28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    supportMessageLabel,
                    style: GoogleFonts.baloo2(
                      fontSize: isVerySmall ? 16 : (isSmall ? 18 : 32),
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: isSmall ? 8 : 28),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          InfoPill(
                            label: safeColorLabel,
                            icon: Icons.palette_outlined,
                            isSmall: isSmall,
                          ),
                          SizedBox(height: isSmall ? 4 : 12),
                          InfoPill(
                            label: patternLabel,
                            icon: Icons.texture_outlined,
                            isSmall: isSmall,
                          ),
                          SizedBox(height: isSmall ? 4 : 12),
                          InfoPill(
                            label: itemLabel,
                            icon: Icons.category_outlined,
                            isSmall: isSmall,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: isSmall ? 6 : 14),
                    Expanded(
                      child: Column(
                        children: [
                          InfoPill(
                            label: actionLabel,
                            icon: Icons.self_improvement_outlined,
                            isSmall: isSmall,
                          ),
                          SizedBox(height: isSmall ? 4 : 12),
                          InfoPill(
                            label: soundLabel,
                            icon: Icons.volume_up_outlined,
                            isSmall: isSmall,
                          ),
                          SizedBox(height: isSmall ? 4 : 12),
                          InfoPill(
                            label: supportSymbolLabel,
                            icon: Icons.auto_awesome_outlined,
                            isSmall: isSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmall ? 8 : 28),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isSmall ? 8 : 20),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(isSmall ? 8 : 24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedPathLabel.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: isVerySmall ? 7 : (isSmall ? 8 : 11),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      SizedBox(height: isSmall ? 2 : 10),
                      Text(
                        selectedPathLabel,
                        style: GoogleFonts.baloo2(
                          fontSize: isVerySmall ? 11 : (isSmall ? 13 : 20),
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
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
