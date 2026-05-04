import 'package:flutter/material.dart';
import 'package:mix_match_mood/core/services/hive_service.dart';

class RepeatAlertScreen extends StatefulWidget {
  const RepeatAlertScreen({super.key});

  @override
  State<RepeatAlertScreen> createState() => _RepeatAlertScreenState();
}

class _RepeatAlertScreenState extends State<RepeatAlertScreen> {
  final HiveService _hiveService = HiveService();
  List<Map<String, dynamic>> _wearHistory = [];
  Map<String, int> _outfitCounts = {};
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _analyzeWearHistory();
  }

  Future<void> _analyzeWearHistory() async {
    final wearHistory = _hiveService.getWearHistory();
    final outfits = _hiveService.getOutfits();

    // Count outfit frequency
    final Map<String, int> counts = {};
    for (final outfit in outfits) {
      final outfitId = outfit.id;
      counts.putIfAbsent(outfitId, () => 0);
    }

    // Get recent outfits with counts
    final recentOutfits = outfits.where((outfit) {
      final count = counts[outfit.id] ?? 0;
      return count >= 2;
    }).take(10).map((o) => {
      'id': o.id,
      'itemIds': o.itemIds,
      'count': counts[o.id],
      'name': 'Outfit with ${o.itemIds.length} items',
    }).toList();

    setState(() {
      _wearHistory = recentOutfits.reversed.toList();
      _outfitCounts = counts;
      _checking = false;
    });
  }

  Future<void> _toggleWearHistory(String outfitId, bool isWorn) async {
    final wearHistory = _hiveService.getWearHistory();
    if (isWorn) {
      wearHistory.add(outfitId);
    } else {
      wearHistory.remove(outfitId);
    }
    await _hiveService.setUserPreferences(
      _hiveService.getUserPreferences()
        ..wearHistory = wearHistory,
    );
    _analyzeWearHistory();
  }

  Future<void> _markOutfitAsWorn(int index) async {
    final outfitId = _wearHistory[index]['id'];
    await _toggleWearHistory(outfitId, true);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAF9F6),
        appBar: AppBar(title: const Text('Repeat Alert')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text('Repeat Alert'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: _wearHistory.isNotEmpty ? 2 : 1,
            child: _wearHistory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_active, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No repeat outfits detected yet',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Mark outfits as worn to track repeats',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : _buildOutfitList(),
          ),
          if (_wearHistory.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8E4DC),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Text(
                '${_outfitCounts.values.where((c) => c >= 2).length} outfit(s) worn multiple times',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOutfitList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _wearHistory.length,
      itemBuilder: (context, index) {
        final outfit = _wearHistory[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(Icons.emoji_symbols_outlined, color: const Color(0xFFC9A688)),
            title: Text(outfit['name']!),
            subtitle: Text('Worn ${outfit['count']} times'),
            trailing: IconButton(
              icon: Icon(Icons.check_circle_outline),
              onPressed: () => _markOutfitAsWorn(index),
            ),
          ),
        );
      },
    );
  }
}
