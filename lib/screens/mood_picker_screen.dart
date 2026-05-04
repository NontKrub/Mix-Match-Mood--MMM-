import 'package:flutter/material.dart';
import 'package:mix_match_mood/core/services/hive_service.dart';
import 'package:mix_match_mood/core/services/stylist_service.dart';

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

  final HiveService _hiveService = HiveService();
  final StylistService _stylistService = StylistService();
  String? _selectedMood;
  bool _loading = false;
  List<OutfitView> _outfits = [];

  @override
  void initState() {
    super.initState();
    _loadOutfits();
  }

  Future<void> _loadOutfits() async {
    final selectedMood = _selectedMood;
    setState(() {
      _outfits = _stylistService.getOutfitViews(mood: selectedMood);
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
                    leading: Text(mood['icon']!,
                        style: const TextStyle(fontSize: 32)),
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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(16),
            child: _selectedMood == null
                ? Center(
                    child: Text(
                      'Select a mood to see outfits',
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
            onPressed: _loading ? null : _generateMoodOutfit,
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
    if (_outfits.isEmpty) {
      return Center(
        child: Text(
          'No outfits available for "$_selectedMood"',
          style: const TextStyle(fontSize: 16),
        ),
      );
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
              title: Text('Outfit ${index + 1}'),
              subtitle: Text(_outfits[index].itemSummary),
              trailing: Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    icon: const Icon(Icons.thumb_up_alt_outlined),
                    onPressed: () => _recordFeedback(
                      _outfits[index].outfit.id,
                      liked: true,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.thumb_down_alt_outlined),
                    onPressed: () => _recordFeedback(
                      _outfits[index].outfit.id,
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

  void _selectMood(String mood) {
    setState(() {
      _selectedMood = mood;
    });
    _loadOutfits();
  }

  Future<void> _generateMoodOutfit() async {
    if (_selectedMood == null) {
      return;
    }
    setState(() => _loading = true);
    await _stylistService.generateOutfit(
      mood: _selectedMood,
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
      mood: _selectedMood,
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
