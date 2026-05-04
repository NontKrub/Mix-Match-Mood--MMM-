import 'package:hive/hive.dart';

part 'outfit.g.dart';

@HiveType(typeId: 1)
class Outfit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  List<String> itemIds;

  @HiveField(2)
  String? mood;

  @HiveField(3)
  String? occasion;

  @HiveField(4)
  DateTime? selectedAt;

  @HiveField(5)
  bool? liked;

  @HiveField(6)
  int? rating;

  Outfit({
    required this.id,
    required this.itemIds,
    this.mood,
    this.occasion,
    this.selectedAt,
    this.liked,
    this.rating,
  });
}
