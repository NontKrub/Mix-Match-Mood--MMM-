import 'package:hive/hive.dart';

part 'clothes.g.dart';

@HiveType(typeId: 0)
class Clothes extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String type;

  @HiveField(3)
  List<String> colors;

  @HiveField(4)
  List<String> styles;

  @HiveField(5)
  List<String> occasions;

  @HiveField(6)
  String? imagePath;

  @HiveField(7)
  double? detectionConfidence;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9, defaultValue: <String>['all-season'])
  List<String> seasons;

  @HiveField(10)
  DateTime? lastWorn;

  Clothes({
    required this.id,
    required this.name,
    required this.type,
    required this.colors,
    required this.styles,
    required this.occasions,
    this.imagePath,
    this.detectionConfidence,
    DateTime? createdAt,
    this.seasons = const ['all-season'],
    this.lastWorn,
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Clothes && other.id == id;
  }
}
