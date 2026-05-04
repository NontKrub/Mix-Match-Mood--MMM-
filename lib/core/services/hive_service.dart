import 'package:hive/hive.dart';
import 'models/clothes.dart';
import 'models/outfit.dart';
import 'models/user_preferences.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  final Box<Clothes> _clothesBox;
  final Box<Outfit> _outfitsBox;
  final Box<UserPreferences> _prefsBox;

  HiveService._internal()
      : _clothesBox = Hive.box<Clothes>('clothes'),
        _outfitsBox = Hive.box<Outfit>('outfits'),
        _prefsBox = Hive.box<UserPreferences>('user_preferences');

  // Clothes operations
  List<Clothes> getClothes() => _clothesBox.values.toList();

  Clothes? getClothesById(String id) => _clothesBox.get(id);

  Future<void> addClothes(Clothes clothes) => _clothesBox.put(clothes.id, clothes);

  Future<void> updateClothes(String id, Clothes newClothes) =>
      _clothesBox.put(id, newClothes);

  Future<void> deleteClothes(String id) => _clothesBox.delete(id);

  // Outfit operations
  List<Outfit> getOutfits() => _outfitsBox.values.toList();

  Outfit? getOutfitById(String id) => _outfitsBox.get(id);

  Future<void> addOutfit(Outfit outfit) => _outfitsBox.put(outfit.id, outfit);

  Future<void> likeOutfit(String id) async {
    final outfit = _outfitsBox.get(id);
    if (outfit != null) {
      final updated = Outfit(
        id: outfit.id,
        itemIds: outfit.itemIds,
        mood: outfit.mood,
        occasion: outfit.occasion,
        selectedAt: outfit.selectedAt,
        liked: true,
        rating: outfit.rating,
      );
      await _outfitsBox.put(id, updated);
    }
  }

  Future<void> setOutfitRating(String id, int rating) async {
    final outfit = _outfitsBox.get(id);
    if (outfit != null) {
      final updated = Outfit(
        id: outfit.id,
        itemIds: outfit.itemIds,
        mood: outfit.mood,
        occasion: outfit.occasion,
        selectedAt: outfit.selectedAt,
        liked: outfit.liked,
        rating: rating,
      );
      await _outfitsBox.put(id, updated);
    }
  }

  Future<List<Outfit>> getLikedOutfits() async {
    final outfits = getOutfits();
    return outfits.where((o) => o.liked != null && o.liked!).toList();
  }

  // User preferences operations
  UserPreferences? _getPrefs() => _prefsBox.get('prefs');

  UserPreferences getUserPreferences() => _prefsBox.get('prefs') ?? UserPreferences();

  List<String> getPreferredMoods() => _getPrefs()?.preferredMoods ?? [];

  List<String> getPreferredStyles() => _getPrefs()?.preferredStyles ?? [];

  List<String> getWearHistory() => _getPrefs()?.wearHistory ?? [];
}
