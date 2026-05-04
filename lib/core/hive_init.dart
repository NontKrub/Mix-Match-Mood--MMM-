import 'package:hive_flutter/hive_flutter.dart';
import 'models/clothes.dart';
import 'models/outfit.dart';
import 'models/user_preferences.dart';

Future<void> initHive() async {
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(ClothesAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(OutfitAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(UserPreferencesAdapter());
  }

  // Open boxes
  await Hive.openBox<Clothes>('clothes');
  await Hive.openBox<Outfit>('outfits');
  await Hive.openBox<UserPreferences>('user_preferences');
}
