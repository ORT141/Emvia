import 'package:emvia/l10n/app_localizations_gen.dart';
import 'package:flame/components.dart';

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
