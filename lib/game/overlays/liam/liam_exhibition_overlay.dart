import 'dart:ui';
import 'dart:io';

import 'package:emvia/game/characters/liam/liam_journey.dart';
import 'package:emvia/game/emvia_game.dart';
import 'package:emvia/game/managers/game_state/game_state.dart';
import 'package:emvia/game/models/captured_photo.dart';
import 'package:emvia/game/overlays/glass_ui.dart';
import 'package:emvia/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LiamExhibitionOverlay extends StatelessWidget {
  const LiamExhibitionOverlay({super.key, required this.game});

  final EmviaGame game;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final state = game.liamState;
    final profile = game.surveyProfile;
    final photos = state?.capturedPhotos ?? const <CapturedPhoto>[];
    final supportSymbol = state != null
        ? LiamJourney.getSupportSymbolEmoji(state)
        : null;
    final selfiePhoto = _photoForScene(photos, 5) ?? _photoForFallback(photos);
    final localeCode = Localizations.localeOf(context).languageCode;
    final isUk = localeCode == 'uk';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withValues(alpha: 0.42)),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GlassPanel(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(context).height * 0.94,
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
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
                                        isUk ? 'ВИСТАВКА' : 'EXHIBITION',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.8,
                                          color: Colors.white.withValues(
                                            alpha: 0.72,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        l.character_liam_title,
                                        style: GoogleFonts.baloo2(
                                          fontSize: 34,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          height: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        l.liam_final_dialog,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white.withValues(
                                            alpha: 0.76,
                                          ),
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (supportSymbol != null) ...[
                                  const SizedBox(width: 16),
                                  GlassPanel(
                                    borderRadius: BorderRadius.circular(999),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    alphaValue: 0.14,
                                    child: Text(
                                      supportSymbol,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 20),
                            _SectionHeader(
                              label: isUk ? 'СТРІЧКА ФОТО' : 'PHOTO STRIP',
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 176,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: photos.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 14),
                                itemBuilder: (context, index) {
                                  final photo = photos[index];
                                  return _PhotoTile(
                                    filePath: photo.path,
                                    tagLabel: _tagLabel(context, photo.tagKey),
                                    styleLabel: _styleLabel(context, state?.photoStyle),
                                    sceneLabel: _sceneLabel(context, photo.sceneIndex),
                                    tintColor: profile.safeColorValue,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _CardBlock(
                                    title: isUk ? 'ПОСТЕР' : 'POSTER',
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (selfiePhoto != null)
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(18),
                                            child: AspectRatio(
                                              aspectRatio: 4 / 5,
                                              child: Image.file(
                                                File(selfiePhoto.path),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        const SizedBox(height: 12),
                                        Text(
                                          l.character_liam_quote,
                                          style: GoogleFonts.baloo2(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            height: 1.05,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          LiamJourney.getFinalPosterPhrase(
                                            l,
                                            state ?? LiamGameState(),
                                          ),
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white.withValues(
                                              alpha: 0.76,
                                            ),
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _CardBlock(
                                    title: isUk ? 'СЕРТИФІКАТ' : 'CERTIFICATE',
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.08,
                                            ),
                                            borderRadius: BorderRadius.circular(18),
                                            border: Border.all(
                                              color: Colors.white.withValues(
                                                alpha: 0.12,
                                              ),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                isUk
                                                    ? 'Розуміння безбар\'єрності'
                                                    : 'Understanding Accessibility',
                                                style: GoogleFonts.baloo2(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white,
                                                  height: 1.05,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                isUk
                                                    ? 'Certificate of completion'
                                                    : 'Certificate of completion',
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white.withValues(
                                                    alpha: 0.72,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        Text(
                                          l.liam_final_education,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            height: 1.35,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _CardBlock(
                              title: isUk ? 'ФІНАЛЬНА ФРАЗА' : 'FINAL PHRASE',
                              child: Text(
                                l.liam_final_dialog,
                                style: GoogleFonts.baloo2(
                                  fontSize: 24,
                                  height: 1.15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _CardBlock(
                              title: isUk
                                  ? 'ФІНАЛЬНА ОСВІТНЯ КАРТКА'
                                  : 'FINAL EDUCATIONAL CARD',
                              child: Text(
                                l.liam_final_education,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  height: 1.45,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.82),
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GlassButton(
                                label: l.return_to_menu,
                                onPressed: () => game.returnToMainMenuAfterJourney(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  CapturedPhoto? _photoForScene(List<CapturedPhoto> photos, int sceneIndex) {
    for (final photo in photos) {
      if (photo.sceneIndex == sceneIndex) return photo;
    }
    return null;
  }

  CapturedPhoto? _photoForFallback(List<CapturedPhoto> photos) {
    if (photos.isEmpty) return null;
    return photos[photos.length ~/ 2];
  }

  String _sceneLabel(BuildContext context, int sceneIndex) {
    final isUk = Localizations.localeOf(context).languageCode == 'uk';
    return switch (sceneIndex) {
      2 => isUk ? 'СЦЕНА 1' : 'SCENE 1',
      3 => isUk ? 'СЦЕНА 2' : 'SCENE 2',
      4 => isUk ? 'СЦЕНА 3' : 'SCENE 3',
      5 => isUk ? 'СЦЕНА 4' : 'SCENE 4',
      6 => isUk ? 'СЦЕНА 5' : 'SCENE 5',
      7 => isUk ? 'СЦЕНА 6' : 'SCENE 6',
      _ => isUk ? 'КАДР' : 'SHOT',
    };
  }

  String _styleLabel(BuildContext context, LiamPhotoStyle? style) {
    final isUk = Localizations.localeOf(context).languageCode == 'uk';
    return switch (style) {
      LiamPhotoStyle.street => isUk ? 'Стріт' : 'Street',
      LiamPhotoStyle.minimalism => isUk ? 'Мінімалізм' : 'Minimalism',
      LiamPhotoStyle.lightShadow => isUk ? 'Світло-тінь' : 'Light & Shadow',
      LiamPhotoStyle.portrait => isUk ? 'Портрет' : 'Portrait',
      null => isUk ? 'Стиль фото' : 'Photo style',
    };
  }

  String _tagLabel(BuildContext context, String key) {
    final l = AppLocalizations.of(context)!;
    return switch (key) {
      'tag_freely' => l.tag_freely,
      'tag_impossible' => l.tag_impossible,
      'tag_difficult' => l.tag_difficult,
      'tag_obstacle' => l.tag_obstacle,
      'tag_danger' => l.tag_danger,
      'tag_uncomfortable' => l.tag_uncomfortable,
      'tag_control' => l.tag_control,
      'tag_dependency' => l.tag_dependency,
      'tag_help' => l.tag_help,
      'tag_no_choice' => l.tag_no_choice,
      'tag_loss_of_control' => l.tag_loss_of_control,
      'tag_intrusive_help' => l.tag_intrusive_help,
      'tag_boundary_violation' => l.tag_boundary_violation,
      'tag_deciding_for_me' => l.tag_deciding_for_me,
      'tag_strength' => l.tag_strength,
      'tag_style' => l.tag_style,
      'tag_personality' => l.tag_personality,
      'tag_unreachable' => l.tag_unreachable,
      'tag_out_of_reach' => l.tag_out_of_reach,
      'tag_barrier' => l.tag_barrier,
      'tag_injustice' => l.tag_injustice,
      'tag_unfairness' => l.tag_unfairness,
      'tag_accessibility' => l.tag_accessibility,
      'tag_solution' => l.tag_solution,
      'tag_freedom' => l.tag_freedom,
      _ => key,
    };
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.7,
        color: Colors.white.withValues(alpha: 0.72),
      ),
    );
  }
}

class _CardBlock extends StatelessWidget {
  const _CardBlock({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(label: title),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.filePath,
    required this.tagLabel,
    required this.styleLabel,
    required this.sceneLabel,
    required this.tintColor,
  });

  final String filePath;
  final String tagLabel;
  final String styleLabel;
  final String sceneLabel;
  final Color tintColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 144,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  tintColor.withValues(alpha: 0.15),
                  BlendMode.screen,
                ),
                child: Image.file(File(filePath), fit: BoxFit.cover),
              ),
            ),
            Positioned(
              left: 8,
              top: 8,
              child: _Badge(label: sceneLabel),
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Badge(label: '#$tagLabel'),
                  const SizedBox(height: 6),
                  _Badge(label: styleLabel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: Colors.white.withValues(alpha: 0.92),
        ),
      ),
    );
  }
}
