enum PlayableCharacter { olya, liam, olenka }

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
