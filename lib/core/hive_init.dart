import 'package:hive_flutter/hive_flutter.dart';
import './models/clothes.dart';
import './models/outfit.dart';
import './models/user_preferences.dart';

Future<void> initHive() async {
  await Hive.initFlutter();

  // Open boxes
  await Hive.openBox('clothes');
  await Hive.openBox('outfits');
  await Hive.openBox('user_preferences');
}
