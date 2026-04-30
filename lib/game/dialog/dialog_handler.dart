import 'package:flame/game.dart';
import 'dialog_model.dart';
import '../emvia_game.dart';

mixin DialogHandler on FlameGame {
  EmviaGame get _g => this as EmviaGame;

  void startDialog(DialogTree tree) {
    _g.currentTree = tree;
    _g.currentNode = tree.getNode(tree.startNodeId);
    _g.currentNode?.onSelect?.call(_g);
    overlays.add('Dialog');
  }

  void selectChoice(DialogChoice choice) {
    choice.onSelect?.call(_g);
    if (choice.nextNodeId != null) {
      _g.currentNode = _g.currentTree?.getNode(choice.nextNodeId);
      _g.currentNode?.onSelect?.call(_g);
      if (_g.currentNode == null) overlays.remove('Dialog');
    } else {
      overlays.remove('Dialog');
      _g.currentNode = null;
    }
  }

  void nextDialog() {
    if (_g.currentNode?.choices != null &&
        _g.currentNode!.choices!.isNotEmpty) {
      return;
    }

    if (_g.currentNode?.nextNodeId != null) {
      _g.currentNode = _g.currentTree?.getNode(_g.currentNode!.nextNodeId);
      _g.currentNode?.onSelect?.call(_g);
      if (_g.currentNode == null) overlays.remove('Dialog');
    } else {
      overlays.remove('Dialog');
      _g.currentNode = null;
    }
  }
}
