import 'package:flutter/material.dart';
import 'glass_ui.dart';
import '../emvia_game.dart';
import '../dialog/dialog_model.dart';
import '../scenes/classroom_scene.dart';
import '../scenes/corridor_scene.dart';
import '../scenes/stage_scene.dart';
import '../scenes/second_corridor_scene.dart';
import '../scenes/outside_scene.dart';
import '../scenes/survey_scene.dart';

class DebugOverlay extends StatefulWidget {
  final EmviaGame game;
  final VoidCallback? onThemeToggled;
  final bool isDarkMode;

  const DebugOverlay({
    super.key,
    required this.game,
    this.onThemeToggled,
    this.isDarkMode = false,
  });

  @override
  State<DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<DebugOverlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(onTap: () => widget.game.overlays.remove('Debug')),
        Center(
          child: GlassPanel(
            width: 450,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Builder(
              builder: (context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(context),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSection(
                              context,
                              title: 'Game State',
                              icon: Icons.info_outline,
                              children: [
                                _buildInfoRow(
                                  context,
                                  'Current Scene',
                                  widget.game.currentScene?.runtimeType
                                          .toString() ??
                                      'None',
                                ),
                                _buildInfoRow(
                                  context,
                                  'Scene Index',
                                  widget.game.sceneIndex.toString(),
                                ),
                                _buildInfoRow(
                                  context,
                                  'Stress Level',
                                  widget.game.stressLevel.toString(),
                                ),
                                _buildInfoRow(
                                  context,
                                  'Character',
                                  widget.game.selectedCharacter.name,
                                ),
                                _buildInfoRow(
                                  context,
                                  'Is Frozen',
                                  widget.game.gameState.isFrozen.toString(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildSection(
                              context,
                              title: 'AI Analysis',
                              icon: Icons.psychology_outlined,
                              children: [
                                _buildInfoRow(
                                  context,
                                  'AI Words',
                                  widget.game.surveyProfile.aiWords.isEmpty
                                      ? 'None'
                                      : widget.game.surveyProfile.aiWords.join(
                                          ', ',
                                        ),
                                ),
                                _buildInfoRow(
                                  context,
                                  'AI Color',
                                  widget.game.surveyProfile.aiColor.isEmpty
                                      ? 'None'
                                      : widget.game.surveyProfile.aiColor,
                                ),
                                _buildInfoRow(
                                  context,
                                  'AI Pattern',
                                  widget.game.surveyProfile.aiPattern.isEmpty
                                      ? 'None'
                                      : widget.game.surveyProfile.aiPattern,
                                ),
                                _buildInfoRow(
                                  context,
                                  'AI Stress Type',
                                  widget.game.surveyProfile.aiStressType.isEmpty
                                      ? 'None'
                                      : widget.game.surveyProfile.aiStressType,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildSection(
                              context,
                              title: 'Scene Manager',
                              icon: Icons.map_outlined,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildSceneButton(
                                      'Classroom',
                                      () => widget.game.loadScene(
                                        ClassroomScene(),
                                      ),
                                    ),
                                    _buildSceneButton(
                                      'Corridor',
                                      () => widget.game.loadScene(
                                        CorridorScene(),
                                      ),
                                    ),
                                    _buildSceneButton(
                                      'Corridor 2',
                                      () => widget.game.loadScene(
                                        SecondCorridorScene(),
                                      ),
                                    ),
                                    _buildSceneButton(
                                      'Outside',
                                      () =>
                                          widget.game.loadScene(OutsideScene()),
                                    ),
                                    _buildSceneButton(
                                      'Survey',
                                      () =>
                                          widget.game.loadScene(SurveyScene()),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildSection(
                              context,
                              title: 'Quick Actions',
                              icon: Icons.bolt_outlined,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildActionButton(
                                      'Redraw',
                                      () => widget.game.currentScene
                                          ?.redrawScene(),
                                      Icons.refresh,
                                    ),
                                    _buildActionButton(
                                      'Reload',
                                      () => widget.game.reloadCurrentScene(),
                                      Icons.replay,
                                    ),
                                    _buildActionButton(
                                      'Skip => Classroom',
                                      () => widget.game.skipToScene(
                                        ClassroomScene(),
                                      ),
                                      Icons.fast_forward,
                                      color: Colors.orangeAccent,
                                    ),
                                    _buildActionButton(
                                      'Skip => Corridor',
                                      () => widget.game.skipToScene(
                                        CorridorScene(),
                                      ),
                                      Icons.fast_forward,
                                      color: Colors.orangeAccent,
                                    ),
                                    _buildActionButton(
                                      'Skip => Stage',
                                      () =>
                                          widget.game.skipToScene(StageScene()),
                                      Icons.fast_forward,
                                      color: Colors.purpleAccent,
                                    ),
                                    if (widget.onThemeToggled != null)
                                      _buildActionButton(
                                        'Toggle Theme',
                                        widget.onThemeToggled!,
                                        widget.isDarkMode
                                            ? Icons.light_mode
                                            : Icons.dark_mode,
                                        color: Colors.blueAccent,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildSection(
                              context,
                              title: 'Debug Tools',
                              icon: Icons.bug_report_outlined,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildToolButton('Print Player Info', () async {
                                      await Future.delayed(
                                        const Duration(milliseconds: 120),
                                      );
                                      final zoom =
                                          widget.game.worldRoot.scale.x;
                                      final worldOffset =
                                          widget.game.worldRoot.position;
                                      final screenX =
                                          worldOffset.x +
                                          widget.game.player.position.x * zoom;
                                      final screenY =
                                          worldOffset.y +
                                          widget.game.player.position.y * zoom;
                                      debugPrint(
                                        'PLAYER world=(${widget.game.player.position.x.toStringAsFixed(1)}, ${widget.game.player.position.y.toStringAsFixed(1)})',
                                      );
                                      debugPrint(
                                        'PLAYER screen=(${screenX.toStringAsFixed(1)}, ${screenY.toStringAsFixed(1)}) zoom=${zoom.toStringAsFixed(3)}',
                                      );
                                    }),
                                    _buildToolButton(
                                      widget.game.debugTapEnabled
                                          ? 'Disable Tap Debug'
                                          : 'Enable Tap Debug',
                                      () {
                                        setState(() {
                                          widget.game.setDebugTapEnabled(
                                            !widget.game.debugTapEnabled,
                                          );
                                        });
                                      },
                                      active: widget.game.debugTapEnabled,
                                    ),
                                    _buildToolButton(
                                      widget.game.isMobileSpoofed
                                          ? 'Disable Mobile Spoof'
                                          : 'Enable Mobile Spoof',
                                      () {
                                        setState(() {
                                          widget.game.toggleMobileSpoof();
                                        });
                                      },
                                      active: widget.game.isMobileSpoofed,
                                    ),
                                    _buildToolButton('Test Dialog', () {
                                      widget.game.startDialog(
                                        DialogTree(
                                          nodes: {
                                            'start': DialogNode(
                                              id: 'start',
                                              text: (loc) =>
                                                  'Привіт! Це тестовий діалог зі скляним дизайном.',
                                              speakerName: (loc) => 'Debug Bot',
                                              choices: [
                                                DialogChoice(
                                                  label: (loc) => 'Круто!',
                                                  nextNodeId: 'next',
                                                ),
                                                DialogChoice(
                                                  label: (loc) => 'Закрити',
                                                  onSelect: (game) => game
                                                      .overlays
                                                      .remove('Dialog'),
                                                ),
                                              ],
                                            ),
                                            'next': DialogNode(
                                              id: 'next',
                                              text: (loc) =>
                                                  'Він також має анімацію появи та ефект матового скла.',
                                              speakerName: (loc) => 'Debug Bot',
                                            ),
                                          },
                                          startNodeId: 'start',
                                        ),
                                      );
                                      widget.game.overlays.remove('Debug');
                                    }),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.terminal, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'DEBUG CONSOLE',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (widget.onThemeToggled != null)
                IconButton(
                  icon: Icon(
                    widget.isDarkMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: widget.onThemeToggled,
                  tooltip: 'Toggle Theme',
                ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                onPressed: () => widget.game.overlays.remove('Debug'),
                hoverColor: Colors.redAccent.withValues(alpha: 0.2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: theme.colorScheme.primary.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 8),
            Text(
              title.toUpperCase(),
              style: TextStyle(
                color: theme.colorScheme.primary.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSceneButton(String label, VoidCallback onPressed) {
    return GlassButton(
      label: label,
      onPressed: () {
        widget.game.overlays.remove('Debug');
        onPressed();
      },
      primary: false,
      compact: true,
    );
  }

  Widget _buildActionButton(
    String label,
    VoidCallback onPressed,
    IconData icon, {
    Color? color,
  }) {
    return GlassButton(
      label: label,
      onPressed: onPressed,
      primary: color != null,
      compact: true,
    );
  }

  Widget _buildToolButton(
    String label,
    VoidCallback onPressed, {
    bool active = false,
  }) {
    return GlassOptionChip(
      label: label,
      selected: active,
      onTap: onPressed,
      compact: true,
    );
  }
}
