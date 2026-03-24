import 'package:flame/game.dart';
import 'dialog_model.dart';
import '../emvia_game.dart';

mixin DialogHandler on FlameGame {
  void startDialog(DialogTree tree) {
    if (this is! EmviaGame) return;
    final game = this as EmviaGame;

    game.currentTree = tree;
    game.currentNode = tree.getNode(tree.startNodeId);
    game.currentNode?.onSelect?.call(game);
    game.overlays.add('Dialog');
  }

  void selectChoice(DialogChoice choice) {
    if (this is! EmviaGame) return;
    final game = this as EmviaGame;

    choice.onSelect?.call(game);
    if (choice.nextNodeId != null) {
      game.currentNode = game.currentTree?.getNode(choice.nextNodeId);
      game.currentNode?.onSelect?.call(game);
      if (game.currentNode == null) {
        game.overlays.remove('Dialog');
      }
    } else {
      game.overlays.remove('Dialog');
      game.currentNode = null;
    }
  }

  void nextDialog() {
    if (this is! EmviaGame) return;
    final game = this as EmviaGame;

    if (game.currentNode?.choices != null &&
        game.currentNode!.choices!.isNotEmpty) {
      return;
    }

    if (game.currentNode?.nextNodeId != null) {
      game.currentNode = game.currentTree?.getNode(
        game.currentNode!.nextNodeId,
      );
      game.currentNode?.onSelect?.call(game);
      if (game.currentNode == null) {
        game.overlays.remove('Dialog');
      }
    } else {
      game.overlays.remove('Dialog');
      game.currentNode = null;
    }
  }
}
