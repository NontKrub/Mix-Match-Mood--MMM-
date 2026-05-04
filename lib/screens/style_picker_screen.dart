import 'package:flutter/material.dart';
import 'package:mix_match_mood/core/services/hive_service.dart';

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

  String? _selectedStyle;
  List<Map<String, dynamic>> _outfits = [];

  @override
  void initState() {
    super.initState();
    _loadOutfits();
  }

  Future<void> _loadOutfits() async {
    final hiveService = HiveService();
    final outfits = hiveService.getOutfits();
    setState(() {
      _outfits = outfits.map((o) => {
        'styles': o.itemIds,
        'itemIds': o.itemIds,
      }).toList();
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(style['icon']!, style: const TextStyle(fontSize: 36)),
                      const SizedBox(height: 8),
                      Text(style['name']!, textAlign: TextAlign.center),
                    ],
                  ),
                ).onTap(() => _selectStyle(style['name']!));
              },
            ),
          ),
          // Outfits Preview
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E4DC),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(16),
            child: _selectedStyle == null
                ? Center(child: Text('Select a style to see outfits', style: TextStyle(color: Colors.grey)))
                : _buildOutfitsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitsList() {
    final filtered = _outfits.where((o) => o['styles']?.any((s) => s.contains(_selectedStyle ?? ''))).toList();

    if (filtered.isEmpty) {
      return Center(child: Text('No outfits available for "$_selectedStyle"', style: const TextStyle(fontSize: 16)));
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
              title: Text('Outfit $index + 1'),
              subtitle: Text('${filtered[index]['itemIds'].length} items'),
              trailing: IconButton(
                icon: const Icon(Icons.heart_broken),
                onPressed: () => _likeOutfit(index),
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

  Future<void> _likeOutfit(int index) async {
    final hiveService = HiveService();
    final outfitId = 'outfit_${_outfits[index]['itemIds'].join('_')}';
    await hiveService.likeOutfit(outfitId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Outfit liked! ❤️')),
      );
    }
  }
}
