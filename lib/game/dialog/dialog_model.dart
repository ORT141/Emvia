import '../emvia_game.dart';
import '../../l10n/app_localizations_gen.dart';

class DialogChoice {
  final String Function(AppLocalizationsGen loc) label;
  final String? nextNodeId;
  final void Function(EmviaGame game)? onSelect;

  DialogChoice({required this.label, this.nextNodeId, this.onSelect});
}

class DialogNode {
  final String id;
  final String Function(AppLocalizationsGen loc) text;
  final String Function(AppLocalizationsGen loc)? speakerName;
  final List<DialogChoice>? choices;
  final String? nextNodeId;
  final void Function(EmviaGame game)? onSelect;

  DialogNode({
    required this.id,
    required this.text,
    this.speakerName,
    this.choices,
    this.nextNodeId,
    this.onSelect,
  });
}

class DialogTree {
  final Map<String, DialogNode> nodes;
  final String startNodeId;

  DialogTree({required this.nodes, required this.startNodeId});

  DialogNode? getNode(String? id) => nodes[id];
}
