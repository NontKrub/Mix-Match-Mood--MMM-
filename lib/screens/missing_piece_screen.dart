import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mix_match_mood/core/models/clothes.dart';
import 'package:mix_match_mood/core/services/hive_service.dart';

class MissingPieceScreen extends StatefulWidget {
  const MissingPieceScreen({super.key});

  @override
  State<MissingPieceScreen> createState() => _MissingPieceScreenState();
}

class _MissingPieceScreenState extends State<MissingPieceScreen> {
  final HiveService _hiveService = HiveService();
  List<Clothes> _clothes = [];
  Map<String, int> _gapAnalysis = {};
  String? _selectedTopId;
  String? _selectedBottomId;
  List<Clothes> _matchingPieces = [];
  List<String> _buySuggestions = [];
  bool _analyzing = true;

  @override
  void initState() {
    super.initState();
    _loadAndAnalyze();
  }

  Future<void> _loadAndAnalyze() async {
    final clothes = _hiveService.getClothes();
    setState(() {
      _clothes = clothes;
      _performGapAnalysis();
      _analyzeSelectedSet();
      _analyzing = false;
    });
  }

  void _performGapAnalysis() {
    // Analyze what's missing for ideal wardrobe
    final types = {
      'top': 0,
      'bottom': 0,
      'hat': 0,
      'jewelry': 0,
      'accessory': 0
    };

    for (final cloth in _clothes) {
      final normalizedType = cloth.type == 'pants' ? 'bottom' : cloth.type;
      if (types.containsKey(normalizedType)) {
        types[normalizedType] = (types[normalizedType] ?? 0) + 1;
      }
    }

    // Ideal wardrobe composition
    final ideal = {
      'top': 10,
      'bottom': 8,
      'hat': 2,
      'jewelry': 5,
      'accessory': 5
    };

    _gapAnalysis = {
      'top': max(ideal['top']! - (types['top'] ?? 0), 0),
      'bottom': max(ideal['bottom']! - (types['bottom'] ?? 0), 0),
      'hat': max(ideal['hat']! - (types['hat'] ?? 0), 0),
      'jewelry': max(ideal['jewelry']! - (types['jewelry'] ?? 0), 0),
      'accessory': max(ideal['accessory']! - (types['accessory'] ?? 0), 0),
    };
  }

  void _analyzeSelectedSet() {
    final top = _selectedTop;
    final bottom = _selectedBottom;
    if (top == null || bottom == null) {
      _matchingPieces = [];
      _buySuggestions = [];
      return;
    }

    final referenceColors = {...top.colors, ...bottom.colors};
    final referenceStyles = {...top.styles, ...bottom.styles};
    final referenceOccasions = {...top.occasions, ...bottom.occasions};
    final complementTypes = {'accessory', 'jewelry', 'hat'};

    final scored = _clothes
        .where((item) => complementTypes.contains(item.type))
        .map((item) {
      final colorScore = item.colors.where(referenceColors.contains).length * 2;
      final styleScore = item.styles.where(referenceStyles.contains).length;
      final occasionScore =
          item.occasions.where(referenceOccasions.contains).length;
      return _ScoredPiece(item, colorScore + styleScore + occasionScore);
    }).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    _matchingPieces = scored
        .where((entry) => entry.score > 0)
        .take(4)
        .map((e) => e.item)
        .toList();

    _buySuggestions = _matchingPieces.isNotEmpty
        ? []
        : _buildBuySuggestions(
            referenceColors: referenceColors,
            referenceStyles: referenceStyles,
          );
  }

  List<String> _buildBuySuggestions({
    required Set<String> referenceColors,
    required Set<String> referenceStyles,
  }) {
    final accentColor =
        referenceColors.isNotEmpty ? referenceColors.first : 'neutral';
    final style = referenceStyles.isNotEmpty ? referenceStyles.first : 'casual';
    return [
      'A $accentColor watch to add a polished finishing touch.',
      'A $style-friendly bag that works with both pieces.',
      'A lightweight scarf in a matching tone for layering.',
    ];
  }

  List<Clothes> get _tops =>
      _clothes.where((item) => item.type == 'top').toList();
  List<Clothes> get _bottoms => _clothes
      .where((item) => item.type == 'bottom' || item.type == 'pants')
      .toList();

  Clothes? get _selectedTop => _findById(_tops, _selectedTopId);
  Clothes? get _selectedBottom => _findById(_bottoms, _selectedBottomId);

  Clothes? _findById(List<Clothes> items, String? id) {
    if (id == null) return null;
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_analyzing) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAF9F6),
        appBar: AppBar(title: const Text('Missing Piece Finder')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text('Missing Piece Finder'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'Wardrobe Gap Analysis',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              'Build a balanced wardrobe for maximum outfit combinations',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            // Gap Analysis Chart
            _buildGapChart(),
            const SizedBox(height: 24),
            // Recommendations
            Text(
              'Recommendations',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            const SizedBox(height: 12),
            // Items to add
            if (_gapAnalysis.values.any((c) => c > 0))
              ..._gapAnalysis.entries.where((e) => e.value > 0).map((entry) {
                return _buildRecommendationCard(
                  entry.key,
                  entry.value,
                  _getCategoryName(entry.key),
                );
              }).toList()
            else
              _buildNoGapsCard(),
            // Current Wardrobe Summary
            const SizedBox(height: 24),
            _buildSelectedSetAnalyzer(),
            const SizedBox(height: 24),
            _buildWardrobeSummary(),
            const SizedBox(height: 24),
            _buildSmartMatchSuggestions(),
          ],
        ),
      ),
    );
  }

  Widget _buildGapChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E4DC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildGapBar('top', _gapAnalysis['top'] ?? 0, colors['top']!),
          const SizedBox(width: 8),
          _buildGapBar(
              'bottom', _gapAnalysis['bottom'] ?? 0, colors['bottom']!),
          const SizedBox(width: 8),
          _buildGapBar('hat', _gapAnalysis['hat'] ?? 0, colors['hat']!),
          const SizedBox(width: 8),
          _buildGapBar(
              'jewelry', _gapAnalysis['jewelry'] ?? 0, colors['jewelry']!),
          const SizedBox(width: 8),
          _buildGapBar('accessory', _gapAnalysis['accessory'] ?? 0,
              colors['accessory']!),
        ],
      ),
    );
  }

  Widget _buildGapBar(String category, int count, Color color) {
    final maxItems = 10;
    final height = (count / maxItems) * 40;
    return Column(
      children: [
        Container(
          width: 40,
          height: height.clamp(0, 40),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(category.toUpperCase(), style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildRecommendationCard(
      String category, int count, String categoryName) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: colors[category]!.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  _getIcon(category),
                  color: colors[category],
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(categoryName,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    'Consider adding $count more ${categoryName.toLowerCase()}s to your wardrobe',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoGapsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.check_circle, size: 48, color: const Color(0xFF8DB998)),
            const SizedBox(height: 12),
            const Text(
              'Great job! Your wardrobe is well-balanced.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'You have a good mix of items across all categories.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWardrobeSummary() {
    final totalItems = _clothes.length;
    final types = _clothes.map((c) => c.type).toSet().length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.folder, color: const Color(0xFFC9A688)),
                const SizedBox(width: 8),
                Text(
                  'Wardrobe Summary',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem('Total Items', '$totalItems'),
                _buildSummaryItem('Categories', '$types types'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSelectedSetAnalyzer() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What is missing from this set?',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            const SizedBox(height: 6),
            const Text(
              'Pick one top and one bottom, then MMM will suggest matching finishing pieces.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            const Text(
              'Select Top',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedTopId,
              hint: const Text('Choose a top'),
              items: _tops
                  .map((item) =>
                      DropdownMenuItem(value: item.id, child: Text(item.name)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTopId = value;
                  _analyzeSelectedSet();
                });
              },
            ),
            const SizedBox(height: 10),
            const Text(
              'Select Bottom',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedBottomId,
              hint: const Text('Choose a bottom'),
              items: _bottoms
                  .map((item) =>
                      DropdownMenuItem(value: item.id, child: Text(item.name)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBottomId = value;
                  _analyzeSelectedSet();
                });
              },
            ),
            if (_tops.isEmpty || _bottoms.isEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Add at least one top and one bottom to use set analysis.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
            if (_selectedTop != null && _selectedBottom != null) ...[
              const SizedBox(height: 12),
              const Text(
                'Recommended matching pieces',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              if (_matchingPieces.isNotEmpty)
                ..._matchingPieces.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(_getIcon(item.type), color: colors[item.type]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${item.name} • ${_getCategoryName(item.type)}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_buySuggestions.isNotEmpty)
                ..._buySuggestions.map(
                  (suggestion) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(suggestion)),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSmartMatchSuggestions() {
    final tops = _clothes.where((item) => item.type == 'top').length;
    final bottoms = _clothes
        .where((item) => item.type == 'bottom' || item.type == 'pants')
        .length;
    final accessories =
        _clothes.where((item) => item.type == 'accessory').length;
    final jewelry = _clothes.where((item) => item.type == 'jewelry').length;

    final suggestions = <String>[
      if (tops > 0 && bottoms > 0 && accessories == 0)
        'Add 1-2 accessories (belt/watch/bag) to complete your top + bottom sets.',
      if (tops > 0 && bottoms > 0 && jewelry == 0)
        'Add a jewelry piece for more polished combinations.',
      if (tops > bottoms + 2)
        'You have many tops; adding more bottoms will increase outfit variety.',
      if (bottoms > tops + 2)
        'You have many bottoms; adding more tops will balance combinations.',
      if (tops == 0 || bottoms == 0)
        'Start with at least one top and one bottom to unlock matching suggestions.',
    ];

    if (suggestions.isEmpty) {
      suggestions.add(
          'Your wardrobe has the core pieces needed for flexible matching.');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Smart Match Suggestions',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...suggestions.map(
              (suggestion) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(suggestion)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const Map<String, Color> colors = {
    'top': Color(0xFFC9A688),
    'bottom': Color(0xFF8B5A2B),
    'hat': Color(0xFFE8D5B5),
    'jewelry': Color(0xFF8DB998),
    'accessory': Color(0xFFF0E6D2),
  };

  static const Map<String, IconData> icons = {
    'top': Icons.checkroom,
    'bottom': Icons.style,
    'hat': Icons.face,
    'jewelry': Icons.diamond_outlined,
    'accessory': Icons.watch,
  };

  String _getCategoryName(String key) => key.toUpperCase();

  IconData _getIcon(String category) => icons[category] ?? Icons.emoji_emotions;
}

class _ScoredPiece {
  const _ScoredPiece(this.item, this.score);

  final Clothes item;
  final int score;
}
