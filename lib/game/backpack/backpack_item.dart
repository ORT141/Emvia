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
    required this.soundAssets,
    this.quantity = 1,
  });

  final String id;
  final String name;
  final String status;
  final String description;
  final BackpackItemType type;
  final Map<String, String> soundAssets;
  final int quantity;

  String localizedSoundAsset(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final lang = locale.languageCode == 'uk' ? 'uk' : 'en';
    return soundAssets[lang] ?? soundAssets['en']!;
  }

  BackpackItem copyWith({
    String? id,
    String? name,
    String? status,
    String? description,
    BackpackItemType? type,
    Map<String, String>? soundAssets,
    int? quantity,
  }) {
    return BackpackItem(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      description: description ?? this.description,
      type: type ?? this.type,
      soundAssets: soundAssets ?? this.soundAssets,
      quantity: quantity ?? this.quantity,
    );
  }

  static List<BackpackItem> initialItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      BackpackItem(
        id: 'blanket',
        name: l10n.item_blanket_name,
        status: l10n.item_blanket_status,
        description: l10n.item_blanket_desc,
        type: BackpackItemType.tool,
        soundAssets: {
          'en': 'items/weighted blanket.mp3',
          'uk': 'items/важка ковдра.mp3',
        },
      ),
      BackpackItem(
        id: 'lunchbox',
        name: l10n.item_lunchbox_name,
        status: l10n.item_lunchbox_status,
        description: l10n.item_lunchbox_desc,
        type: BackpackItemType.tool,
        soundAssets: {'en': 'items/lunchbox.mp3', 'uk': 'items/ланчбокс.mp3'},
      ),
      BackpackItem(
        id: 'headphones',
        name: l10n.item_headphones_name,
        status: l10n.item_headphones_status,
        description: l10n.item_headphones_desc,
        type: BackpackItemType.tool,
        soundAssets: {
          'en': 'items/sensory headphones.mp3',
          'uk': 'items/сенсорні навушники.mp3',
        },
      ),
    ];
  }
}
