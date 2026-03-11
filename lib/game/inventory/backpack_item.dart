import 'package:flutter/widgets.dart';
import 'package:emvia/l10n/app_localizations.dart';

enum BackpackItemType { tool, collectible, consumable }

class BackpackItem {
  const BackpackItem({
    required this.id,
    required this.name,
    required this.status,
    required this.description,
    required this.type,
    required this.iconAsset,
    required this.soundAsset,
    this.quantity = 1,
  });

  final String id;
  final String name;
  final String status;
  final String description;
  final BackpackItemType type;
  final String iconAsset;
  final String soundAsset;
  final int quantity;

  BackpackItem copyWith({
    String? id,
    String? name,
    String? status,
    String? description,
    BackpackItemType? type,
    String? iconAsset,
    String? soundAsset,
    int? quantity,
  }) {
    return BackpackItem(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      description: description ?? this.description,
      type: type ?? this.type,
      iconAsset: iconAsset ?? this.iconAsset,
      soundAsset: soundAsset ?? this.soundAsset,
      quantity: quantity ?? this.quantity,
    );
  }

  static List<BackpackItem> initialItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      BackpackItem(
        id: 'headphones',
        name: l10n.item_headphones_name,
        status: l10n.item_headphones_status,
        description: l10n.item_headphones_desc,
        type: BackpackItemType.tool,
        iconAsset: 'assets/images/backpack/headphones.png',
        soundAsset: 'items/sensory headphones.mp3',
      ),
      BackpackItem(
        id: 'blanket',
        name: l10n.item_blanket_name,
        status: l10n.item_blanket_status,
        description: l10n.item_blanket_desc,
        type: BackpackItemType.tool,
        iconAsset: 'assets/images/backpack/coat.png',
        soundAsset: 'items/weighted blanket.mp3',
      ),
      BackpackItem(
        id: 'lunchbox',
        name: l10n.item_lunchbox_name,
        status: l10n.item_lunchbox_status,
        description: l10n.item_lunchbox_desc,
        type: BackpackItemType.tool,
        iconAsset: 'assets/images/backpack/lunchbox.png',
        soundAsset: 'items/lunchbox.mp3',
      ),
    ];
  }
}
