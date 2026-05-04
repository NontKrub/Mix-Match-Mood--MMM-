import 'package:flutter/material.dart';
import 'package:mix_match_mood/core/services/hive_service.dart';
import 'core/models/outfit.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final HiveService _hiveService = HiveService();
  List<dynamic> _clothes = [];
  List<dynamic> _selectedItems = [];
  String? _generatedOutfit;

  @override
  void initState() {
    super.initState();
    _loadClothes();
  }

  Future<void> _loadClothes() async {
    final clothes = _hiveService.getClothes();
    setState(() {
      _clothes = clothes.length > 0 ? clothes : _getSampleClothes();
    });
  }

  List<dynamic> _getSampleClothes() {
    return [
      {'id': '1', 'name': 'White Tee', 'type': 'top', 'colors': ['white'], 'styles': ['casual'], 'occasions': ['daily']},
      {'id': '2', 'name': 'Denim Jeans', 'type': 'bottom', 'colors': ['blue'], 'styles': ['casual'], 'occasions': ['daily']},
      {'id': '3', 'name': 'Blouse', 'type': 'top', 'colors': ['black'], 'styles': ['formal'], 'occasions': ['work']},
      {'id': '4', 'name': 'Pencil Skirt', 'type': 'bottom', 'colors': ['black'], 'styles': ['formal'], 'occasions': ['work']},
      {'id': '5', 'name': 'T-Shirt', 'type': 'top', 'colors': ['gray'], 'styles': ['casual'], 'occasions': ['daily']},
      {'id': '6', 'name': 'Sweater', 'type': 'top', 'colors': ['beige'], 'styles': ['cozy'], 'occasions': ['casual']},
      {'id': '7', 'name': 'Dress Pants', 'type': 'bottom', 'colors': ['navy'], 'styles': ['formal'], 'occasions': ['work']},
      {'id': '8', 'name': 'Shorts', 'type': 'bottom', 'colors': ['khaki'], 'styles': ['casual'], 'occasions': ['summer']},
      {'id': '9', 'name': 'Necklace', 'type': 'jewelry', 'colors': ['gold'], 'styles': ['elegant'], 'occasions': ['any']},
      {'id': '10', 'name': 'Earrings', 'type': 'jewelry', 'colors': ['silver'], 'styles': ['classic'], 'occasions': ['any']},
      {'id': '11', 'name': 'Watch', 'type': 'accessory', 'colors': ['black'], 'styles': ['modern'], 'occasions': ['any']},
      {'id': '12', 'name': 'Belt', 'type': 'accessory', 'colors': ['brown'], 'styles': ['classic'], 'occasions': ['formal']},
    ];
  }

  Future<void> _generateOutfit() async {
    if (_clothes.isEmpty) {
      _showSnackBar('Add clothes first!');
      return;
    }

    // Generate quick outfit
    final tops = _clothes.where((c) => c['type'] == 'top').toList();
    final bottoms = _clothes.where((c) => c['type'] == 'bottom').toList();
    final jewelry = _clothes.where((c) => c['type'] == 'jewelry').toList();
    final accessories = _clothes.where((c) => c['type'] == 'accessory').toList();

    List<dynamic> selected = [];

    // Random selection with bias toward matching types
    if (tops.isNotEmpty) {
      selected.add(tops[_randomIndex(tops.length)]);
    }
    if (bottoms.isNotEmpty) {
      selected.add(bottoms[_randomIndex(bottoms.length)]);
    }
    if (jewelry.isNotEmpty) {
      selected.add(jewelry[_randomIndex(jewelry.length)]);
    }
    if (accessories.isNotEmpty && selected.length < 4) {
      selected.add(accessories[_randomIndex(accessories.length)]);
    }

    // Create outfit
    final outfitId = 'emergency_outfit_${DateTime.now().millisecondsSinceEpoch}';
    final outfit = Outfit(
      id: outfitId,
      itemIds: selected.map((c) => c['id'].toString()).toList(),
      mood: 'Quick',
      occasion: 'Any',
      selectedAt: DateTime.now(),
    );

    await _hiveService.addOutfit(outfit);

    setState(() {
      _selectedItems = selected;
      _generatedOutfit = 'Outfit #${outfit.id.split('_').last}';
    });

    _showSnackBar('Quick outfit generated!');
  }

  int _randomIndex(int length) => (DateTime.now().millisecondsSinceEpoch % length);

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFC9A688),
        ),
      );
    }
  }

  void _reset() {
    setState(() {
      _selectedItems = [];
      _generatedOutfit = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text('Emergency Mode', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_selectedItems.isNotEmpty || _generatedOutfit != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reset,
            ),
        ],
      ),
      body: _clothes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text(
                    'No clothes in wardrobe',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add clothes first to use Emergency Mode',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFFC9A688), const Color(0xFFE8E4DC)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.speed, size: 32, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Emergency Mode',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'Generate outfits in seconds',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Main Generate Button
                GestureDetector(
                  onTap: _generateOutfit,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E4DC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFC9A688)),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, size: 48, color: const Color(0xFFC9A688)),
                          const SizedBox(height: 8),
                          const Text(
                            'Generate Quick Outfit',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D2A26),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_selectedItems.isNotEmpty || _generatedOutfit != null) ...[
                  const SizedBox(height: 16),
                  // Generated Outfit Preview
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.emoji_emotions, color: const Color(0xFFC9A688)),
                              const SizedBox(width: 12),
                              Text(
                                _generatedOutfit ?? 'Your Quick Outfit',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const Spacer(),
                              Text(
                                '3 items',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          ..._selectedItems.take(3).map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC9A688).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.ondemand, color: const Color(0xFFC9A688)),
                                ),
                                const SizedBox(width: 8),
                                Text('${item['name']}'),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
