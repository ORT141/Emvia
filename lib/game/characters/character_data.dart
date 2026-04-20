class CharacterData {
  final String name;
  final String assetPath;
  final int walkingFrames;
  final Map<String, String> extraAssets;

  const CharacterData({
    required this.name,
    required this.assetPath,
    required this.walkingFrames,
    this.extraAssets = const {},
  });
}
