import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'game_scene.dart';
import '../emvia_game.dart';
import '../components/npc.dart';
import '../dialog_data.dart';

class BlankRoom extends GameScene {
  BlankRoom() : super(backgroundPath: 'bg_classroom.jpg');

  @override
  Future<void> onLoad() async {
    const double sceneWidth = EmviaGame.worldWidth;

    add(
      RectangleComponent(
        size: Vector2(sceneWidth, game.size.y),
        paint: Paint()..color = const Color(0xFFF0F0F0),
      ),
    );

    add(
      NPC(
        npcName: 'Teacher',
        dialogTree: DialogData.getTeacherDialog(),
        position: Vector2(sceneWidth * 0.3, game.size.y / 2),
        size: Vector2(80, 150),
        themeColor: Colors.greenAccent,
      ),
    );

    add(
      NPC(
        npcName: 'Stranger',
        dialogTree: DialogData.getMysteriousStrangerDialog(),
        position: Vector2(sceneWidth * 0.7, game.size.y / 2),
        size: Vector2(80, 150),
        themeColor: Colors.purpleAccent,
      ),
    );
  }
}
