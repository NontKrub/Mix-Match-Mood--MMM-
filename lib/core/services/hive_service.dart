import 'package:hive/hive.dart';
import '../models/clothes.dart';
import '../models/outfit.dart';
import '../models/user_preferences.dart';

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

  Future<void> addClothes(Clothes clothes) =>
      _clothesBox.put(clothes.id, clothes);

  Future<void> updateClothes(String id, Clothes newClothes) =>
      _clothesBox.put(id, newClothes);

  Future<void> deleteClothes(String id) => _clothesBox.delete(id);

  // Outfit operations
  List<Outfit> getOutfits() => _outfitsBox.values.toList();

  Outfit? getOutfitById(String id) => _outfitsBox.get(id);

  Future<void> addOutfit(Outfit outfit) => _outfitsBox.put(outfit.id, outfit);

  Future<void> likeOutfit(String id) =>
      recordOutfitFeedback(outfitId: id, liked: true);

  Future<void> dislikeOutfit(String id) =>
      recordOutfitFeedback(outfitId: id, liked: false);

  Future<void> recordOutfitFeedback({
    required String outfitId,
    bool? liked,
    int? rating,
    String? mood,
    String? style,
  }) async {
    final outfit = _outfitsBox.get(outfitId);
    if (outfit == null) {
      return;
    }

    final updatedOutfit = Outfit(
      id: outfit.id,
      itemIds: outfit.itemIds,
      mood: outfit.mood,
      occasion: outfit.occasion,
      selectedAt: outfit.selectedAt,
      liked: liked ?? outfit.liked,
      rating: rating ?? outfit.rating,
    );
    await _outfitsBox.put(outfitId, updatedOutfit);

    if ((liked == true) || rating != null) {
      final prefs = getUserPreferences();
      var changed = false;

      if (liked == true && mood != null && mood.isNotEmpty) {
        final normalized = mood.trim();
        if (!prefs.preferredMoods.contains(normalized)) {
          prefs.preferredMoods = [...prefs.preferredMoods, normalized];
          changed = true;
        }
      }

      if (liked == true && style != null && style.isNotEmpty) {
        final normalized = style.trim();
        if (!prefs.preferredStyles.contains(normalized)) {
          prefs.preferredStyles = [...prefs.preferredStyles, normalized];
          changed = true;
        }
      }

      if (rating != null) {
        final nextHistory = [
          updatedOutfit,
          ...prefs.ratingHistory.where((entry) => entry.id != updatedOutfit.id),
        ];
        prefs.ratingHistory = nextHistory.take(50).toList();
        changed = true;
      }

      if (changed) {
        await setUserPreferences(prefs);
      }
    }
  }

  Future<void> setOutfitRating(String id, int rating) async {
    await recordOutfitFeedback(outfitId: id, rating: rating);
  }

  Future<void> markOutfitAsWorn(String outfitId) async {
    final prefs = getUserPreferences();
    prefs.wearHistory = [...prefs.wearHistory, outfitId];
    await setUserPreferences(prefs);
  }

  Future<void> removeOutfitFromWearHistory(String outfitId) async {
    final prefs = getUserPreferences();
    prefs.wearHistory =
        prefs.wearHistory.where((id) => id != outfitId).toList();
    await setUserPreferences(prefs);
  }

  Map<String, int> getWearCounts() {
    final counts = <String, int>{};
    for (final outfitId in getWearHistory()) {
      counts[outfitId] = (counts[outfitId] ?? 0) + 1;
    }
    return counts;
  }

  Future<void> clearOutfits() => _outfitsBox.clear();

  Future<List<Outfit>> getLikedOutfits() async =>
      getOutfits().where((o) => o.liked == true).toList();

  // User preferences operations
  UserPreferences? _getPrefs() => _prefsBox.get('prefs');

  UserPreferences getUserPreferences() =>
      _prefsBox.get('prefs') ?? UserPreferences();

  List<String> getPreferredMoods() => _getPrefs()?.preferredMoods ?? [];

  List<String> getPreferredStyles() => _getPrefs()?.preferredStyles ?? [];

  List<String> getWearHistory() => _getPrefs()?.wearHistory ?? [];

  Future<void> setUserPreferences(UserPreferences preferences) =>
      _prefsBox.put('prefs', preferences);
}
