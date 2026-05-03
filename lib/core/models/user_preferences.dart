class UserPreferences {
  final List<String> preferredMoods;
  final List<String> preferredStyles;
  final List<Map<String, dynamic>> wearHistory;
  final List<Map<String, dynamic>> ratingHistory;

  UserPreferences({
    this.preferredMoods = const [],
    this.preferredStyles = const [],
    this.wearHistory = const [],
    this.ratingHistory = const [],
  });
}
