import 'package:emvia/l10n/app_localizations_gen.dart';
import 'package:flame/components.dart';

enum PlayableCharacter { liam, olya, olenka, anton }

class PathDetailInfo {
  final int index;
  final String title;
  final String name;
  final String description;
  final String confirmLabel;
  final String cancelLabel;

  PathDetailInfo({
    required this.index,
    required this.title,
    required this.name,
    required this.description,
    required this.confirmLabel,
    required this.cancelLabel,
  });
}

class StageItemCardData {
  const StageItemCardData({
    required this.id,
    required this.normalSpritePath,
    required this.selectedSpritePath,
    required this.uv,
    required this.heightFactor,
    required this.soundAssetEn,
    required this.soundAssetUk,
    required this.title,
    required this.description,
  });

  final String id;
  final String normalSpritePath;
  final String selectedSpritePath;
  final Vector2 uv;
  final double heightFactor;
  final String soundAssetEn;
  final String soundAssetUk;
  final String Function(AppLocalizationsGen) title;
  final String Function(AppLocalizationsGen) description;

  String localizedSoundAsset(String languageCode) {
    return languageCode == 'uk' ? soundAssetUk : soundAssetEn;
  }
}
