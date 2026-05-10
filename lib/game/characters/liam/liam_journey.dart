import 'dart:math' as math;
import 'package:emvia/game/dialog/dialog_model.dart';
import 'package:emvia/game/emvia_game.dart';
import 'package:emvia/game/managers/game_state/game_state.dart';
import 'package:emvia/l10n/app_localizations_gen.dart';

class LiamJourney {
  static const int totalPhotos = LiamGameState.maxPhotos;

  static int currentSceneNumber(LiamGameState state) =>
      state.currentMissionIndex + 2;

  static List<String> currentTags(LiamGameState state) {
    switch (state.currentMissionIndex) {
      case 0:
        return const ['tag_freely', 'tag_impossible', 'tag_difficult'];
      case 1:
        return const ['tag_obstacle', 'tag_danger', 'tag_uncomfortable'];
      case 2:
        return const [
          'tag_no_choice',
          'tag_loss_of_control',
          'tag_intrusive_help',
          'tag_boundary_violation',
          'tag_deciding_for_me',
        ];
      case 3:
        return const ['tag_strength', 'tag_style', 'tag_personality'];
      case 4:
        return const ['tag_out_of_reach', 'tag_barrier', 'tag_unfairness'];
      case 5:
        return const ['tag_accessibility', 'tag_solution', 'tag_freedom'];
      default:
        return const <String>[];
    }
  }

  static String currentTitle(AppLocalizationsGen l, LiamGameState state) {
    switch (state.currentMissionIndex) {
      case 0:
        return l.liam_route_title;
      case 1:
        return l.liam_obstacle_title;
      case 2:
        return l.liam_boundary_title;
      case 3:
        return l.liam_self_title;
      case 4:
        return l.liam_almost_title;
      case 5:
        return l.liam_space_title;
      default:
        return l.camera_liam_title;
    }
  }

  static String currentPrompt(AppLocalizationsGen l, LiamGameState state) {
    switch (state.currentMissionIndex) {
      case 0:
        return l.liam_route_prompt;
      case 1:
        return l.liam_obstacle_prompt;
      case 2:
        return l.liam_boundary_prompt;
      case 3:
        return l.liam_self_prompt;
      case 4:
        return l.liam_almost_prompt;
      case 5:
        return l.liam_space_prompt;
      default:
        return l.liam_final_dialog;
    }
  }

  static String currentTagPrompt(AppLocalizationsGen l, LiamGameState state) {
    switch (state.currentMissionIndex) {
      case 0:
        return l.liam_route_tag_prompt;
      case 1:
        return l.liam_obstacle_tag_prompt;
      case 2:
        return l.liam_boundary_tag_prompt;
      case 3:
        return l.liam_self_tag_prompt;
      case 4:
        return l.liam_almost_tag_prompt;
      case 5:
        return l.liam_space_tag_prompt;
      default:
        return l.camera_liam_instructions;
    }
  }

  static String? currentQuote(AppLocalizationsGen l, LiamGameState state) {
    if (state.currentMissionIndex != 2) return null;

    switch (state.boundaryResponse) {
      case LiamBoundaryResponse.explain:
        return l.liam_boundary_response_explain;
      case LiamBoundaryResponse.joke:
        return l.liam_boundary_response_joke;
      case LiamBoundaryResponse.respondSharply:
        return l.liam_boundary_response_sharp;
      case null:
        return null;
    }
  }

  static String progressLabel(AppLocalizationsGen l, LiamGameState state) {
    final current = (state.currentMissionIndex + 1).clamp(1, totalPhotos);
    return l.camera_liam_progress(current, totalPhotos);
  }

  static void onPhotoSaved(EmviaGame game, int completedMissionIndex) {
    final context = game.buildContext;
    if (context == null || !context.mounted) return;

    final l = AppLocalizationsGen.of(context);
    if (l == null) return;

    game.showEducationalCard(
      _educationalCardForMission(l, completedMissionIndex),
      onDismiss: () {
        game.unfreezePlayer();
        maybeShowCurrentNarrative(game);
      },
    );
  }

  static bool maybeShowCurrentNarrative(EmviaGame game) {
    final context = game.buildContext;
    final state = game.liamState;
    if (context == null || !context.mounted || state == null) return false;
    if (game.overlays.isActive('Camera') ||
        game.overlays.isActive('EducationalCard') ||
        game.overlays.isActive('Dialog')) {
      return false;
    }

    final l = AppLocalizationsGen.of(context);
    if (l == null) return false;

    if (!game.soundEnabled && !state.hasShownSilentIntro) {
      state.hasShownSilentIntro = true;
      _startDialog(
        game,
        DialogTree(
          startNodeId: 'silent_intro',
          nodes: {
            'silent_intro': DialogNode(
              id: 'silent_intro',
              speakerName: (_) => l.character_liam,
              text: (_) => l.liam_scene_intro_silent,
              choices: [_continueChoice(game, l)],
            ),
          },
        ),
      );
      return true;
    }

    if (state.isJourneyComplete) {
      if (state.hasShownCompletionDialog) return false;
      state.hasShownCompletionDialog = true;
      _startDialog(game, _buildCompletionDialog(game, l));
      return true;
    }

    if (!state.markCurrentBriefingShown()) {
      return false;
    }

    switch (state.currentMissionIndex) {
      case 0:
        _startDialog(
          game,
          _buildBriefingDialog(game, l, l.liam_route_briefing),
        );
        return true;
      case 1:
        _startDialog(
          game,
          _buildBriefingDialog(game, l, l.liam_obstacle_briefing),
        );
        return true;
      case 2:
        _startBoundarySequence(game, l, state);
        return true;
      case 3:
        _startDialog(game, _buildSelfExpressionDialog(game, l));
        return true;
      case 4:
        _startDialog(
          game,
          _buildBriefingDialog(game, l, l.liam_almost_briefing),
        );
        return true;
      case 5:
        _startDialog(
          game,
          _buildBriefingDialog(game, l, l.liam_space_briefing),
        );
        return true;
      default:
        return false;
    }
  }

  static void _startBoundarySequence(
    EmviaGame game,
    AppLocalizationsGen l,
    LiamGameState state,
  ) {
    game.freezePlayer();
    game.pendingCafeDialog = _buildBoundaryDialog(game, l, state);
    game.overlays.add('LiamCafeNear');
  }

  static void _startDialog(EmviaGame game, DialogTree tree) {
    game.freezePlayer();
    game.startDialog(tree);
  }

  static DialogTree _buildBriefingDialog(
    EmviaGame game,
    AppLocalizationsGen l,
    String text,
  ) {
    return DialogTree(
      startNodeId: 'briefing',
      nodes: {
        'briefing': DialogNode(
          id: 'briefing',
          speakerName: (_) => l.character_liam,
          text: (_) => text,
          choices: [_continueChoice(game, l)],
        ),
      },
    );
  }

  static DialogTree _buildBoundaryDialog(
    EmviaGame game,
    AppLocalizationsGen l,
    LiamGameState state,
  ) {
    return DialogTree(
      startNodeId: 'npc',
      nodes: {
        'npc': DialogNode(
          id: 'npc',
          text: (_) => '${l.liam_boundary_npc}\n${l.liam_boundary_stop}',
          nextNodeId: 'choice',
        ),
        'choice': DialogNode(
          id: 'choice',
          speakerName: (_) => l.character_liam,
          text: (_) => l.liam_boundary_choice_prompt,
          choices: [
            DialogChoice(
              label: (_) => l.liam_boundary_choice_explain,
              nextNodeId: 'result',
              onSelect: (_) {
                state.boundaryResponse = LiamBoundaryResponse.explain;
              },
            ),
            DialogChoice(
              label: (_) => l.liam_boundary_choice_joke,
              nextNodeId: 'result',
              onSelect: (_) {
                state.boundaryResponse = LiamBoundaryResponse.joke;
              },
            ),
            DialogChoice(
              label: (_) => l.liam_boundary_choice_sharp,
              nextNodeId: 'result',
              onSelect: (_) {
                state.boundaryResponse = LiamBoundaryResponse.respondSharply;
              },
            ),
          ],
        ),
        'result': DialogNode(
          id: 'result',
          speakerName: (_) => l.character_liam,
          text: (_) =>
              '${currentQuote(l, state) ?? ''}\n\n${l.liam_boundary_prompt}',
          choices: [_continueChoice(game, l)],
        ),
      },
    );
  }

  static DialogTree buildBoundaryDialog(
    EmviaGame game,
    AppLocalizationsGen l,
    LiamGameState state,
  ) {
    return _buildBoundaryDialog(game, l, state);
  }

  static DialogTree _buildSelfExpressionDialog(
    EmviaGame game,
    AppLocalizationsGen l,
  ) {
    return DialogTree(
      startNodeId: 'comments',
      nodes: {
        'comments': DialogNode(
          id: 'comments',
          text: (_) => l.liam_comments_intro,
          nextNodeId: 'prompt',
        ),
        'prompt': DialogNode(
          id: 'prompt',
          speakerName: (_) => l.character_liam,
          text: (_) => l.liam_self_briefing,
          choices: [_continueChoice(game, l)],
        ),
      },
    );
  }

  static DialogTree _buildCompletionDialog(
    EmviaGame game,
    AppLocalizationsGen l,
  ) {
    return DialogTree(
      startNodeId: 'complete',
      nodes: {
        'complete': DialogNode(
          id: 'complete',
          speakerName: (_) => l.character_liam,
          text: (_) => l.liam_final_dialog,
          choices: [
            DialogChoice(
              label: (_) => l.continueLabel,
              onSelect: (_) {
                game.showEducationalCard(l.liam_final_education);
              },
            ),
          ],
        ),
      },
    );
  }

  static DialogChoice _continueChoice(EmviaGame game, AppLocalizationsGen l) {
    return DialogChoice(
      label: (_) => l.continueLabel,
      onSelect: (_) {
        game.unfreezePlayer();
      },
    );
  }

  static String _educationalCardForMission(
    AppLocalizationsGen l,
    int missionIndex,
  ) {
    switch (missionIndex) {
      case 0:
        return l.liam_route_education;
      case 1:
        return l.liam_obstacle_education;
      case 2:
        return l.liam_boundary_education;
      case 3:
        return l.liam_self_education;
      case 4:
        return l.liam_almost_education;
      case 5:
        return l.liam_space_education;
      default:
        return l.liam_final_education;
    }
  }

  static String getObstaclePhrase(AppLocalizationsGen l, LiamGameState state) {
    final rng = math.Random();
    switch (state.irritation) {
      case LiamIrritation.blocksPath:
        final phrases = [
          l.liam_obstacle_phrase_blocks_1,
          l.liam_obstacle_phrase_blocks_2,
          l.liam_obstacle_phrase_blocks_3,
        ];
        return phrases[rng.nextInt(phrases.length)];
      case LiamIrritation.intrusiveHelp:
        final phrases = [
          l.liam_obstacle_phrase_intrusive_1,
          l.liam_obstacle_phrase_intrusive_2,
          l.liam_obstacle_phrase_intrusive_3,
        ];
        return phrases[rng.nextInt(phrases.length)];
      case LiamIrritation.inconvenientLayout:
        final phrases = [
          l.liam_obstacle_phrase_inconvenient_1,
          l.liam_obstacle_phrase_inconvenient_2,
          l.liam_obstacle_phrase_inconvenient_3,
        ];
        return phrases[rng.nextInt(phrases.length)];
      case LiamIrritation.othersDecide:
        final phrases = [
          l.liam_obstacle_phrase_others_1,
          l.liam_obstacle_phrase_others_2,
          l.liam_obstacle_phrase_others_3,
        ];
        return phrases[rng.nextInt(phrases.length)];
      case null:
        return l.liam_obstacle_phrase_blocks_1;
    }
  }

  static String getFinalPosterPhrase(
    AppLocalizationsGen l,
    LiamGameState state,
  ) {
    switch (state.copingStyle) {
      case LiamCopingStyle.findWay:
        return l.liam_poster_phrase_find_way;
      case LiamCopingStyle.askHelp:
        return l.liam_poster_phrase_ask_help;
      case LiamCopingStyle.tryMyself:
        return l.liam_poster_phrase_try_myself;
      case LiamCopingStyle.avoid:
        return l.liam_poster_phrase_avoid;
      case null:
        return l.liam_poster_phrase_find_way;
    }
  }

  static int getNavColorValue(LiamGameState state) {
    switch (state.navColor) {
      case LiamNavColor.cyan:
        return 0xFF00E5FF;
      case LiamNavColor.orange:
        return 0xFFFF6D00;
      case LiamNavColor.red:
        return 0xFFE53935;
      case LiamNavColor.green:
        return 0xFF43A047;
      case null:
        return 0xFF00E5FF;
    }
  }

  static String getSupportSymbolEmoji(LiamGameState state) {
    switch (state.supportSymbol) {
      case LiamSupportSymbol.heart:
        return '❤️';
      case LiamSupportSymbol.cat:
        return '🐱';
      case LiamSupportSymbol.star:
        return '⭐';
      case LiamSupportSymbol.wings:
        return '🪽';
      case null:
        return '❤️';
    }
  }
}
