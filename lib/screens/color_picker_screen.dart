import 'package:flutter/material.dart';
import 'package:mix_match_mood/core/services/stylist_service.dart';

class ColorPickerScreen extends StatefulWidget {
  const ColorPickerScreen({super.key});

  @override
  State<ColorPickerScreen> createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends State<ColorPickerScreen> {
  static const List<Color> colors = [
    Color(0xFF000000),
    Color(0xFFFFF9F0),
    Color(0xFFC9A688),
    Color(0xFF8B5A2B),
    Color(0xFFE8D5B5),
    Color(0xFFFAF9F6),
    Color(0xFF2D2A26),
    Color(0xFF8DB998),
  ];

  final StylistService _stylistService = StylistService();
  List<OutfitView> _outfits = [];
  List<String> _activeFilters = [];
  bool _loading = false;

  static const Map<String, String> _hexToColorName = {
    '000000': 'black',
    'FFF9F0': 'white',
    'C9A688': 'brown',
    '8B5A2B': 'brown',
    'E8D5B5': 'beige',
    'FAF9F6': 'white',
    '2D2A26': 'black',
    '8DB998': 'green',
  };

  @override
  void initState() {
    super.initState();
    _loadOutfits();
  }

  Future<void> _loadOutfits() async {
    setState(() {
      _outfits = _stylistService.getOutfitViews(
        colorFilters: _activeColorNames,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text('Pick by Color'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _activeFilters.isEmpty ? null : () => _resetFilters(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Color Filters
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Color Selector Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: colors.length,
                  itemBuilder: (context, index) {
                    final color = colors[index];
                    final colorHex = _rgbHex(color);
                    final isSelected = _activeFilters.contains(colorHex);
                    return GestureDetector(
                      onTap: () => _toggleColorFilter(colorHex),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.8)
                                : Colors.transparent,
                            width: isSelected ? 3 : 0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 28,
                              )
                            : const Icon(Icons.add),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Active Filters
                if (_activeFilters.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E4DC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Filters',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _activeFilters.map((hex) {
                            final color = Color(int.parse('FF$hex', radix: 16));
                            return FilterChip(
                              label: Text(_colorName(color)),
                              selected: true,
                              onSelected: (selected) {
                                if (!selected) _resetFilters();
                              },
                              backgroundColor: color.withValues(alpha: 0.3),
                              labelStyle: TextStyle(color: color),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                // Outfits Preview
                Text(
                  'Matching Outfits',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _outfits.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'No outfits yet. Add some clothes first!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : _buildFilteredOutfits(),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _generateColorOutfit,
                    icon: const Icon(Icons.auto_awesome),
                    label: Text(_loading
                        ? 'Generating...'
                        : 'Generate Matching Outfit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC9A688),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _colorName(Color color) {
    const names = {
      '000000': 'Black',
      'FFF9F0': 'Cream',
      'C9A688': 'Terracotta',
      '8B5A2B': 'Brown',
      'E8D5B5': 'Beige',
      'FAF9F6': 'Off White',
      '2D2A26': 'Dark Brown',
      '8DB998': 'Green',
    };
    return names[_rgbHex(color)] ?? 'Color';
  }

  String _rgbHex(Color color) {
    final rgb = color.toARGB32() & 0x00FFFFFF;
    return rgb.toRadixString(16).padLeft(6, '0').toUpperCase();
  }

  Widget _buildFilteredOutfits() {
    final filtered = _outfits;
    return filtered.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'No outfits match your color filters. Adjust them!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          )
        : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text('Outfit ${index + 1}'),
                  subtitle: Text(filtered[index].itemSummary),
                ),
              );
            },
          );
  }

  void _toggleColorFilter(String hex) {
    setState(() {
      if (_activeFilters.contains(hex)) {
        _activeFilters.remove(hex);
      } else {
        _activeFilters.add(hex);
      }
    });
    _loadOutfits();
  }

  void _resetFilters() {
    setState(() {
      _activeFilters = [];
    });
    _loadOutfits();
  }

  Set<String> get _activeColorNames => _activeFilters
      .map((hex) => _hexToColorName[hex])
      .whereType<String>()
      .toSet();

  Future<void> _generateColorOutfit() async {
    setState(() => _loading = true);
    await _stylistService.generateOutfit(
      colorFilters: _activeColorNames,
      occasion: 'daily',
      save: true,
    );
    await _loadOutfits();
    setState(() => _loading = false);
  }
}
