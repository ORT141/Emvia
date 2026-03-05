enum BackpackItemType { tool, collectible, consumable }

class BackpackItem {
  const BackpackItem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.iconAsset,
    this.quantity = 1,
  });

  final String id;
  final String name;
  final String description;
  final BackpackItemType type;
  final String iconAsset;
  final int quantity;

  BackpackItem copyWith({
    String? id,
    String? name,
    String? description,
    BackpackItemType? type,
    String? iconAsset,
    int? quantity,
  }) {
    return BackpackItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      iconAsset: iconAsset ?? this.iconAsset,
      quantity: quantity ?? this.quantity,
    );
  }

  static List<BackpackItem> placeholderItems() {
    return const [
      BackpackItem(
        id: 'calm_map',
        name: 'Calm Map',
        description: 'A folded map with safe routes around the school.',
        type: BackpackItemType.tool,
        iconAsset: 'assets/images/overlays/map1.jpg',
      ),
      BackpackItem(
        id: 'focus_stone',
        name: 'Focus Stone',
        description: 'Warm to touch. Helps Olya stay grounded.',
        type: BackpackItemType.collectible,
        iconAsset: 'assets/images/overlays/map2.jpg',
      ),
      BackpackItem(
        id: 'tea_token',
        name: 'Tea Token',
        description: 'A tiny voucher for a calming tea break.',
        type: BackpackItemType.consumable,
        iconAsset: 'assets/images/overlays/map1.jpg',
        quantity: 2,
      ),
    ];
  }
}
