import 'package:flutter/material.dart';
import '../game/emvia_game.dart';
import '../game/scenes/classroom_scene.dart';
import '../game/scenes/corridor_scene.dart';

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
                      onPressed: () async {
                        game.overlays.remove('Debug');
                        await game.loadScene(ClassroomScene());
                      },
                      child: const Text('Classroom'),
                    ),
                    ElevatedButton(
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
                      onPressed: () {
                        game.isStressMode = !game.isStressMode;
                      },
                      child: const Text('Toggle Stress'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        game.currentScene?.redrawScene();
                      },
                      child: const Text('Redraw Scene'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        game.overlays.remove('Debug');
                        game.toggleBackpack();
                      },
                      child: const Text('Toggle Inventory'),
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
