import 'dart:ui';
import 'package:flutter/material.dart';
import '../emvia_game.dart';
import '../dialog/dialog_model.dart';
import '../scenes/classroom_scene.dart';
import '../scenes/corridor_scene.dart';
import '../scenes/stage_scene.dart';
import '../scenes/test_scene.dart';
import '../scenes/second_corridor_scene.dart';
import '../scenes/outside_scene.dart';
import '../scenes/survey_scene.dart';

class DebugOverlay extends StatefulWidget {
  final EmviaGame game;

  const DebugOverlay({super.key, required this.game});

  @override
  State<DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<DebugOverlay> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => widget.game.overlays.remove('Debug'),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(color: Colors.black26),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 450,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSection(
                              title: 'Game State',
                              icon: Icons.info_outline,
                              children: [
                                _buildInfoRow(
                                  'Current Scene',
                                  widget.game.currentScene?.runtimeType
                                          .toString() ??
                                      'None',
                                ),
                                _buildInfoRow(
                                  'Scene Index',
                                  widget.game.sceneIndex.toString(),
                                ),
                                _buildInfoRow(
                                  'Stress Level',
                                  widget.game.stressLevel.toString(),
                                ),
                                _buildInfoRow(
                                  'Character',
                                  widget.game.selectedCharacter.name,
                                ),
                                _buildInfoRow(
                                  'Is Frozen',
                                  widget.game.isFrozen.toString(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildSection(
                              title: 'AI Analysis',
                              icon: Icons.psychology_outlined,
                              children: [
                                _buildInfoRow(
                                  'AI Words',
                                  widget.game.surveyProfile.aiWords.isEmpty
                                      ? 'None'
                                      : widget.game.surveyProfile.aiWords.join(
                                          ', ',
                                        ),
                                ),
                                _buildInfoRow(
                                  'AI Color',
                                  widget.game.surveyProfile.aiColor.isEmpty
                                      ? 'None'
                                      : widget.game.surveyProfile.aiColor,
                                ),
                                _buildInfoRow(
                                  'AI Pattern',
                                  widget.game.surveyProfile.aiPattern.isEmpty
                                      ? 'None'
                                      : widget.game.surveyProfile.aiPattern,
                                ),
                                _buildInfoRow(
                                  'AI Stress Type',
                                  widget.game.surveyProfile.aiStressType.isEmpty
                                      ? 'None'
                                      : widget.game.surveyProfile.aiStressType,
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                            _buildSection(
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
                                    _buildSceneButton(
                                      'Test',
                                      () => widget.game.loadScene(TestScene()),
                                      color: Colors.redAccent,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildSection(
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
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildSection(
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: const Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.terminal, color: Colors.blueAccent, size: 24),
              SizedBox(width: 12),
              Text(
                'DEBUG CONSOLE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white54),
            onPressed: () => widget.game.overlays.remove('Debug'),
            hoverColor: Colors.redAccent.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Colors.blueAccent.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 8),
            Text(
              title.toUpperCase(),
              style: TextStyle(
                color: Colors.blueAccent.withValues(alpha: 0.8),
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
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSceneButton(
    String label,
    VoidCallback onPressed, {
    Color color = Colors.blueAccent,
  }) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {
        widget.game.overlays.remove('Debug');
        onPressed();
      },
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildActionButton(
    String label,
    VoidCallback onPressed,
    IconData icon, {
    Color color = Colors.blueAccent,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildToolButton(
    String label,
    VoidCallback onPressed, {
    bool active = false,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: active
            ? Colors.green.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.05),
        foregroundColor: active ? Colors.greenAccent : Colors.white70,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: active
                ? Colors.greenAccent.withValues(alpha: 0.5)
                : Colors.white10,
          ),
        ),
      ),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
