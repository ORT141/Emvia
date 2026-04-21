class CharacterData {
  final String name;
  final String assetPath;
  final int walkingFrames;
  final Map<String, String> extraAssets;
  final double widthFactor;
  final bool resetScaleOnIdle;

  const CharacterData({
    required this.name,
    required this.assetPath,
    required this.walkingFrames,
    this.extraAssets = const {},
    this.widthFactor = 1.0,
    this.resetScaleOnIdle = false,
  });
}
