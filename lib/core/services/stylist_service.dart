import 'dart:math';

import 'package:mix_match_mood/core/models/clothes.dart';
import 'package:mix_match_mood/core/models/outfit.dart';
import 'package:mix_match_mood/core/services/hive_service.dart';

class OutfitView {
  OutfitView({
    required this.outfit,
    required this.items,
  });

  final Outfit outfit;
  final List<Clothes> items;

  List<String> get colors => items
      .expand((item) => item.colors.map((c) => c.toLowerCase()))
      .toSet()
      .toList();

  List<String> get styles => items
      .expand((item) => item.styles.map((s) => s.toLowerCase()))
      .toSet()
      .toList();

  String get itemSummary => items.map((item) => item.name).join(' • ');
}

class StylistService {
  StylistService({HiveService? hiveService})
      : _hiveService = hiveService ?? HiveService();

  final HiveService _hiveService;
  final Random _random = Random();

  static const Map<String, String> _moodStyleBias = {
    'happy': 'casual',
    'professional': 'formal',
    'casual': 'casual',
    'romantic': 'classic',
    'sporty': 'modern',
    'sleepy': 'casual',
  };

  Future<OutfitView?> generateOutfit({
    String? mood,
    String? style,
    Set<String>? colorFilters,
    String occasion = 'daily',
    bool save = true,
  }) async {
    final clothes = _hiveService.getClothes();
    if (clothes.isEmpty) {
      return null;
    }

    final outfits = _hiveService.getOutfits();
    final prefs = _hiveService.getUserPreferences();
    final clothesById = {for (final item in clothes) item.id: item};
    final feedbackScores = _buildItemFeedbackScores(outfits);
    final itemWearCounts =
        _buildItemWearCounts(_hiveService.getWearCounts(), outfits);
    final preferredStyles = prefs.preferredStyles
        .map((style) => style.trim().toLowerCase())
        .where((style) => style.isNotEmpty)
        .toSet();
    final preferredColors = _buildPreferredColors(outfits, clothesById);

    final normalizedMood = mood?.toLowerCase();
    final explicitStyle = style?.trim().toLowerCase();
    final moodBiasedStyle =
        normalizedMood != null ? _moodStyleBias[normalizedMood] : null;
    final normalizedStyle = (explicitStyle != null && explicitStyle.isNotEmpty)
        ? explicitStyle
        : (moodBiasedStyle ??
            (preferredStyles.isNotEmpty ? preferredStyles.first : null));
    final normalizedColors = (colorFilters ?? <String>{})
        .map((color) => color.toLowerCase())
        .toSet();
    final seededColors = normalizedColors.isNotEmpty
        ? normalizedColors
        : preferredColors.take(2).toSet();

    final selected = <Clothes>[];

    final tops = clothes.where((item) => item.type == 'top').toList();
    final bottoms = clothes
        .where((item) => item.type == 'bottom' || item.type == 'pants')
        .toList();
    final accessories = clothes
        .where((item) =>
            item.type == 'accessory' ||
            item.type == 'hat' ||
            item.type == 'jewelry')
        .toList();

    final topPick = _pickBest(
      tops,
      style: normalizedStyle,
      colors: seededColors,
      occasion: occasion,
      excludedIds: selected.map((item) => item.id).toSet(),
      preferredStyles: preferredStyles,
      preferredColors: preferredColors,
      feedbackScores: feedbackScores,
      itemWearCounts: itemWearCounts,
    );
    if (topPick != null) {
      selected.add(topPick);
    }

    final bottomTargetColors = {
      ...seededColors,
      ...selected
          .expand((item) => item.colors.map((color) => color.toLowerCase())),
    };
    final bottomPick = _pickBest(
      bottoms,
      style: normalizedStyle,
      colors: bottomTargetColors,
      occasion: occasion,
      excludedIds: selected.map((item) => item.id).toSet(),
      preferredStyles: preferredStyles,
      preferredColors: preferredColors,
      feedbackScores: feedbackScores,
      itemWearCounts: itemWearCounts,
    );
    if (bottomPick != null) {
      selected.add(bottomPick);
    }

    if (selected.length < 2) {
      final fallbackPool = clothes
          .where((item) => !selected
              .map((selectedItem) => selectedItem.id)
              .contains(item.id))
          .toList();
      final fallback = _pickBest(
        fallbackPool,
        style: normalizedStyle,
        colors: bottomTargetColors,
        occasion: occasion,
        excludedIds: selected.map((item) => item.id).toSet(),
        preferredStyles: preferredStyles,
        preferredColors: preferredColors,
        feedbackScores: feedbackScores,
        itemWearCounts: itemWearCounts,
      );
      if (fallback != null) {
        selected.add(fallback);
      }
    }

    final accessoryTargetColors = {
      ...bottomTargetColors,
      ...selected
          .expand((item) => item.colors.map((color) => color.toLowerCase())),
    };
    final accessoryPick = _pickBest(
      accessories,
      style: normalizedStyle,
      colors: accessoryTargetColors,
      occasion: occasion,
      excludedIds: selected.map((item) => item.id).toSet(),
      preferredStyles: preferredStyles,
      preferredColors: preferredColors,
      feedbackScores: feedbackScores,
      itemWearCounts: itemWearCounts,
    );
    if (accessoryPick != null) {
      selected.add(accessoryPick);
    }

    if (selected.isEmpty) {
      return null;
    }

    final outfit = Outfit(
      id: 'outfit_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(10000)}',
      itemIds: selected.map((item) => item.id).toList(),
      mood: mood,
      occasion: occasion,
      selectedAt: DateTime.now(),
    );

    if (save) {
      await _hiveService.addOutfit(outfit);
    }

    return OutfitView(outfit: outfit, items: selected);
  }

  List<OutfitView> getOutfitViews({
    String? mood,
    String? style,
    Set<String>? colorFilters,
  }) {
    final outfits = _hiveService.getOutfits().toList()
      ..sort((a, b) {
        final aTime = a.selectedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.selectedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

    final clothesById = {
      for (final item in _hiveService.getClothes()) item.id: item,
    };

    final normalizedMood = mood?.toLowerCase();
    final normalizedStyle = style?.toLowerCase();
    final normalizedColors = (colorFilters ?? <String>{})
        .map((color) => color.toLowerCase())
        .toSet();

    final views = <OutfitView>[];
    for (final outfit in outfits) {
      final items = outfit.itemIds
          .map((id) => clothesById[id])
          .whereType<Clothes>()
          .toList();
      if (items.isEmpty) {
        continue;
      }

      final view = OutfitView(outfit: outfit, items: items);

      if (normalizedMood != null &&
          normalizedMood.isNotEmpty &&
          (outfit.mood?.toLowerCase() ?? '') != normalizedMood) {
        continue;
      }
      if (normalizedStyle != null &&
          normalizedStyle.isNotEmpty &&
          !view.styles.any((s) => s.contains(normalizedStyle))) {
        continue;
      }
      if (normalizedColors.isNotEmpty &&
          !view.colors.any((color) => normalizedColors.contains(color))) {
        continue;
      }

      views.add(view);
    }

    return views;
  }

  Clothes? _pickBest(
    List<Clothes> candidates, {
    required String? style,
    required Set<String> colors,
    required String occasion,
    required Set<String> excludedIds,
    required Set<String> preferredStyles,
    required Set<String> preferredColors,
    required Map<String, int> feedbackScores,
    required Map<String, int> itemWearCounts,
  }) {
    final filtered =
        candidates.where((item) => !excludedIds.contains(item.id)).toList();
    if (filtered.isEmpty) {
      return null;
    }

    final scored = filtered.map((item) {
      var score = 0;
      if (style != null &&
          item.styles.map((s) => s.toLowerCase()).contains(style)) {
        score += 3;
      }
      if (preferredStyles.isNotEmpty &&
          item.styles
              .map((s) => s.toLowerCase())
              .any((styleName) => preferredStyles.contains(styleName))) {
        score += 2;
      }
      if (colors.isNotEmpty &&
          item.colors.map((c) => c.toLowerCase()).any(colors.contains)) {
        score += 2;
      } else if (colors.isEmpty &&
          preferredColors.isNotEmpty &&
          item.colors
              .map((c) => c.toLowerCase())
              .any((color) => preferredColors.contains(color))) {
        score += 1;
      }
      if (item.occasions
              .map((o) => o.toLowerCase())
              .contains(occasion.toLowerCase()) ||
          item.occasions.map((o) => o.toLowerCase()).contains('any') ||
          item.occasions.map((o) => o.toLowerCase()).contains('daily')) {
        score += 1;
      }
      score += feedbackScores[item.id] ?? 0;
      score -= min(itemWearCounts[item.id] ?? 0, 3);
      score += _random.nextInt(2);
      return (item: item, score: score);
    }).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    final topChoices = scored.take(3).toList();
    return topChoices[_random.nextInt(topChoices.length)].item;
  }

  Map<String, int> _buildItemFeedbackScores(List<Outfit> outfits) {
    final scores = <String, int>{};
    for (final outfit in outfits) {
      var delta = 0;
      if (outfit.liked == true) {
        delta += 2;
      } else if (outfit.liked == false) {
        delta -= 2;
      }
      if (outfit.rating != null) {
        delta += (outfit.rating! - 3);
      }
      if (delta == 0) {
        continue;
      }
      for (final itemId in outfit.itemIds) {
        scores[itemId] = (scores[itemId] ?? 0) + delta;
      }
    }
    return scores;
  }

  Map<String, int> _buildItemWearCounts(
    Map<String, int> outfitWearCounts,
    List<Outfit> outfits,
  ) {
    final outfitsById = {for (final outfit in outfits) outfit.id: outfit};
    final itemWearCounts = <String, int>{};
    outfitWearCounts.forEach((outfitId, count) {
      final outfit = outfitsById[outfitId];
      if (outfit == null) {
        return;
      }
      for (final itemId in outfit.itemIds) {
        itemWearCounts[itemId] = (itemWearCounts[itemId] ?? 0) + count;
      }
    });
    return itemWearCounts;
  }

  Set<String> _buildPreferredColors(
    List<Outfit> outfits,
    Map<String, Clothes> clothesById,
  ) {
    final colorWeights = <String, int>{};
    for (final outfit in outfits) {
      final positiveSignal = outfit.liked == true || (outfit.rating ?? 0) >= 4;
      if (!positiveSignal) {
        continue;
      }
      for (final itemId in outfit.itemIds) {
        final item = clothesById[itemId];
        if (item == null) {
          continue;
        }
        for (final color in item.colors.map((c) => c.toLowerCase())) {
          colorWeights[color] = (colorWeights[color] ?? 0) + 1;
        }
      }
    }

    final ranked = colorWeights.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return ranked.take(3).map((entry) => entry.key).toSet();
  }
}
