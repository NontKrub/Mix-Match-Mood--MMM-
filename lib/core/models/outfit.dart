class Outfit {
  final String id;
  final List<String> itemIds;
  final String mood;
  final String occasion;
  final DateTime selectedAt;
  final bool liked;
  final int rating;

  Outfit({
    required this.id,
    required this.itemIds,
    required this.mood,
    required this.occasion,
    required this.selectedAt,
    this.liked = false,
    this.rating = 0,
  });
}
