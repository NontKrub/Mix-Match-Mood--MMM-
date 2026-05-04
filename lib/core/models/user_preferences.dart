import 'package:hive/hive.dart';
import 'outfit.dart';

part 'user_preferences.g.dart';

@HiveType(typeId: 2)
class UserPreferences extends HiveObject {
  @HiveField(0)
  List<String> preferredMoods;

  @HiveField(1)
  List<String> preferredStyles;

  @HiveField(2)
  List<String> wearHistory;

  @HiveField(3)
  List<Outfit> ratingHistory;

  @HiveField(4)
  bool darkMode;

  UserPreferences({
    this.preferredMoods = const [],
    this.preferredStyles = const [],
    this.wearHistory = const [],
    this.ratingHistory = const [],
    this.darkMode = false,
  });
}
