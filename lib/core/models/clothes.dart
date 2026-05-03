class Clothes {
  final String id;
  final String name;
  final String type;
  final List<String> colors;
  final List<String> styles;
  final List<String> occasions;
  final String imagePath;
  final double detectionConfidence;
  final DateTime createdAt;

  Clothes({
    required this.id,
    required this.name,
    required this.type,
    required this.colors,
    required this.styles,
    required this.occasions,
    required this.imagePath,
    this.detectionConfidence = 1.0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
