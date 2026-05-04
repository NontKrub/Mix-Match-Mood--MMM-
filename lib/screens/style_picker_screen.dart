import 'package:flutter/material.dart';
import 'package:mix_match_mood/core/services/hive_service.dart';
import 'package:mix_match_mood/core/services/stylist_service.dart';

class StylePickerScreen extends StatefulWidget {
  const StylePickerScreen({super.key});

  @override
  State<StylePickerScreen> createState() => _StylePickerScreenState();
}

class _StylePickerScreenState extends State<StylePickerScreen> {
  static const List<Map<String, String>> _styles = [
    {'icon': '⚫', 'name': 'Minimal'},
    {'icon': '🎨', 'name': 'Classic'},
    {'icon': '🔥', 'name': 'Edgy'},
    {'icon': '🌿', 'name': 'Boho'},
    {'icon': '👔', 'name': 'Formal'},
    {'icon': '👕', 'name': 'Casual'},
  ];

  final HiveService _hiveService = HiveService();
  final StylistService _stylistService = StylistService();
  String? _selectedStyle;
  bool _loading = false;
  List<OutfitView> _outfits = [];

  @override
  void initState() {
    super.initState();
    _loadOutfits();
  }

  Future<void> _loadOutfits() async {
    final selectedStyle = _selectedStyle;
    setState(() {
      _outfits = _stylistService.getOutfitViews(style: selectedStyle);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text('Pick by Style'),
      ),
      body: Column(
        children: [
          // Style Selector
          Expanded(
            flex: 1,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
              ),
              itemCount: _styles.length,
              itemBuilder: (context, index) {
                final style = _styles[index];
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _selectStyle(style['name']!),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(style['icon']!,
                            style: const TextStyle(fontSize: 36)),
                        const SizedBox(height: 8),
                        Text(style['name']!, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Outfits Preview
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E4DC),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(16),
            child: _selectedStyle == null
                ? Center(
                    child: Text(
                      'Select a style to see outfits',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : _buildRecommendationPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationPanel() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _loading ? null : _generateStyleOutfit,
            icon: const Icon(Icons.auto_awesome),
            label: Text(_loading ? 'Generating...' : 'Generate Outfit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC9A688),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(child: _buildOutfitsList()),
      ],
    );
  }

  Widget _buildOutfitsList() {
    final filtered = _outfits;

    if (filtered.isEmpty) {
      return Center(
          child: Text('No outfits available for "$_selectedStyle"',
              style: const TextStyle(fontSize: 16)));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            child: ListTile(
              title: Text('Outfit ${index + 1}'),
              subtitle: Text(filtered[index].itemSummary),
              trailing: Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    icon: const Icon(Icons.thumb_up_alt_outlined),
                    onPressed: () => _recordFeedback(
                      filtered[index].outfit.id,
                      liked: true,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.thumb_down_alt_outlined),
                    onPressed: () => _recordFeedback(
                      filtered[index].outfit.id,
                      liked: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _selectStyle(String style) {
    setState(() {
      _selectedStyle = style;
    });
    _loadOutfits();
  }

  Future<void> _generateStyleOutfit() async {
    if (_selectedStyle == null) {
      return;
    }
    setState(() => _loading = true);
    await _stylistService.generateOutfit(
      style: _selectedStyle,
      occasion: 'daily',
      save: true,
    );
    await _loadOutfits();
    setState(() => _loading = false);
  }

  Future<void> _recordFeedback(String outfitId, {required bool liked}) async {
    await _hiveService.recordOutfitFeedback(
      outfitId: outfitId,
      liked: liked,
      style: _selectedStyle,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(liked ? 'Saved your like! ❤️' : 'Feedback noted 👍'),
        ),
      );
    }
  }
}
