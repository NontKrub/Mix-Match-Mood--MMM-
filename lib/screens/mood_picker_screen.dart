import 'package:flutter/material.dart';
import 'package:mix_match_mood/core/services/hive_service.dart';

class MoodPickerScreen extends StatefulWidget {
  const MoodPickerScreen({super.key});

  @override
  State<MoodPickerScreen> createState() => _MoodPickerScreenState();
}

class _MoodPickerScreenState extends State<MoodPickerScreen> {
  static const List<Map<String, String>> _moods = [
    {'icon': '😊', 'name': 'Happy'},
    {'icon': '😎', 'name': 'Professional'},
    {'icon': '😌', 'name': 'Casual'},
    {'icon': '💕', 'name': 'Romantic'},
    {'icon': '🏃', 'name': 'Sporty'},
    {'icon': '😴', 'name': 'Sleepy'},
  ];

  String? _selectedMood;
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
        'name': o.mood ?? 'General',
        'itemIds': o.itemIds,
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text('Pick by Mood'),
      ),
      body: Column(
        children: [
          // Mood Selector
          Expanded(
            flex: 1,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _moods.length,
              itemBuilder: (context, index) {
                final mood = _moods[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Text(mood['icon']!, style: const TextStyle(fontSize: 32)),
                    title: Text(mood['name']!),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _selectMood(mood['name']!),
                  ),
                );
              },
            ),
          ),
          // Outfits Preview
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E4DC),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(16),
            child: _selectedMood == null
                ? Center(child: Text('Select a mood to see outfits', style: TextStyle(color: Colors.grey)))
                : _buildOutfitsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitsList() {
    if (_outfits.isEmpty) {
      return Center(child: Text('No outfits available for "$_selectedMood"', style: const TextStyle(fontSize: 16)));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _outfits.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            child: ListTile(
              title: Text('Outfit $index + 1'),
              subtitle: Text('${_outfits[index]['itemIds'].length} items'),
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

  void _selectMood(String mood) {
    setState(() {
      _selectedMood = mood;
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
