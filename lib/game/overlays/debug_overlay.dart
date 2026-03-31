import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../emvia_game.dart';
import '../scenes/classroom_scene.dart';
import '../scenes/corridor_scene.dart';

class DebugOverlay extends StatelessWidget {
  final EmviaGame game;

  const DebugOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Debug Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => game.overlays.remove('Debug'),
                    ),
                  ],
                ),
                const Divider(color: Colors.white24),
                _buildSectionTitle('Game Info'),
                _buildInfoRow(
                  'Scene',
                  game.currentScene?.runtimeType.toString() ?? 'None',
                ),
                _buildInfoRow('Stress Level', game.stressLevel.toString()),
                _buildInfoRow('Character', game.selectedCharacter.name),
                const SizedBox(height: 16),
                _buildSectionTitle('AI Info'),
                _buildInfoRow(
                  'Words',
                  game.surveyProfile.aiWords.join(', ').isEmpty
                      ? 'None'
                      : game.surveyProfile.aiWords.join(', '),
                ),
                _buildInfoRow(
                  'Color',
                  game.surveyProfile.aiColor.isEmpty
                      ? 'Default'
                      : game.surveyProfile.aiColor,
                ),
                _buildInfoRow(
                  'Pattern',
                  game.surveyProfile.aiPattern.isEmpty
                      ? 'None'
                      : game.surveyProfile.aiPattern,
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('Scene Manager'),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        game.overlays.remove('Debug');
                        await game.loadScene(ClassroomScene());
                      },
                      child: const Text('Classroom'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        game.overlays.remove('Debug');
                        await game.loadScene(CorridorScene());
                      },
                      child: const Text('Corridor'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('Actions'),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        game.currentScene?.redrawScene();
                      },
                      child: const Text('Redraw Scene'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        game.overlays.remove('Debug');
                        await game.reloadCurrentScene();
                      },
                      child: const Text('Reload Scene'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        game.overlays.remove('Debug');
                        game.toggleBackpack();
                      },
                      child: const Text('Toggle Inventory'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        game.overlays.remove('Debug');
                        await game.skipToCorridor();
                      },
                      child: const Text('Skip all => Corridor'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSectionTitle('Debug Tools'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final p1 = game.olya.position.clone();
                        await Future.delayed(const Duration(milliseconds: 120));
                        final p2 = game.olya.position.clone();
                        final dx = p2.x - p1.x;
                        final dy = p2.y - p1.y;
                        final dist = math.sqrt(dx * dx + dy * dy);
                        final measuredSpeed = dist / 0.12;
                        final zoom = game.worldRoot.scale.x;
                        final worldOffset = game.worldRoot.position;
                        final screenX =
                            worldOffset.x + game.olya.position.x * zoom;
                        final screenY =
                            worldOffset.y + game.olya.position.y * zoom;
                        debugPrint(
                          'PLAYER world=(${game.olya.position.x.toStringAsFixed(1)}, ${game.olya.position.y.toStringAsFixed(1)}) size=(${game.olya.size.x.toStringAsFixed(1)}, ${game.olya.size.y.toStringAsFixed(1)})',
                        );
                        debugPrint(
                          'PLAYER screen=(${screenX.toStringAsFixed(1)}, ${screenY.toStringAsFixed(1)}) zoom=${zoom.toStringAsFixed(3)} measured_speed=${measuredSpeed.toStringAsFixed(1)}',
                        );
                        debugPrint('PLAYER isFrozen=(${game.isFrozen})');
                      },
                      child: const Text('Print Player Info'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        game.setDebugTapEnabled(!game.debugTapEnabled);
                        debugPrint('Debug tap mode: ${game.debugTapEnabled}');
                      },
                      child: Text(
                        game.debugTapEnabled
                            ? 'Disable Tap Debug'
                            : 'Enable Tap Debug',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(label, style: const TextStyle(color: Colors.white70)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.right,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
