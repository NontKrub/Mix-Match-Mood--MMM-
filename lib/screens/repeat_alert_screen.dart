import 'package:flutter/material.dart';
import 'package:mix_match_mood/core/services/hive_service.dart';

class RepeatAlertScreen extends StatefulWidget {
  const RepeatAlertScreen({super.key});

  @override
  State<RepeatAlertScreen> createState() => _RepeatAlertScreenState();
}

class _RepeatAlertScreenState extends State<RepeatAlertScreen> {
  final HiveService _hiveService = HiveService();
  List<Map<String, dynamic>> _outfits = [];
  Map<String, int> _outfitCounts = {};
  bool _showArchived = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _analyzeWearHistory();
  }

  Future<void> _analyzeWearHistory() async {
    final outfits = _hiveService.getOutfits();
    outfits.sort((a, b) {
      final aTime = a.selectedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.selectedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });

    // Count outfit frequency
    final counts = _hiveService.getWearCounts();
    final archived = _hiveService.getArchivedOutfitIds().toSet();

    final preparedOutfits = outfits
        .take(20)
        .map((o) => {
              'id': o.id,
              'itemIds': o.itemIds,
              'count': counts[o.id] ?? 0,
              'name': 'Outfit with ${o.itemIds.length} items',
              'archived': archived.contains(o.id),
            })
        .toList();

    final recentOutfits = preparedOutfits
        .where((outfit) => _showArchived || !(outfit['archived'] as bool))
        .toList();

    setState(() {
      _outfits = recentOutfits;
      _outfitCounts = counts;
      _checking = false;
    });
  }

  Future<void> _markOutfitAsWorn(int index) async {
    final outfitId = _outfits[index]['id'] as String;
    await _hiveService.markOutfitAsWorn(outfitId);
    await _analyzeWearHistory();
    final updatedCount = _outfitCounts[outfitId] ?? 0;
    if (updatedCount >= 2 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'This outfit has been repeated $updatedCount times. Save a photo or archive it.'),
          action: SnackBarAction(
            label: 'Archive',
            onPressed: () => _setArchive(outfitId, archive: true),
          ),
        ),
      );
    }
  }

  Future<void> _setArchive(String outfitId, {required bool archive}) async {
    if (archive) {
      await _hiveService.archiveOutfit(outfitId);
    } else {
      await _hiveService.unarchiveOutfit(outfitId);
    }
    await _analyzeWearHistory();
  }

  void _toggleArchivedVisibility() {
    setState(() {
      _showArchived = !_showArchived;
    });
    _analyzeWearHistory();
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
        actions: [
          IconButton(
            tooltip: _showArchived ? 'Hide archived' : 'Show archived',
            icon: Icon(
              _showArchived ? Icons.visibility : Icons.archive_outlined,
            ),
            onPressed: _toggleArchivedVisibility,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: _outfits.isNotEmpty ? 2 : 1,
            child: _outfits.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_active,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _showArchived
                              ? 'No outfits available yet'
                              : 'No active repeat outfits',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _showArchived
                              ? 'Generate outfits and mark them worn to track repeats'
                              : 'Mark outfits as worn, then archive repeated ones',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : _buildOutfitList(),
          ),
          if (_outfits.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8E4DC),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Text(
                '${_outfitCounts.values.where((c) => c >= 2).length} outfit(s) worn multiple times • ${_hiveService.getArchivedOutfitIds().length} archived',
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
      itemCount: _outfits.length,
      itemBuilder: (context, index) {
        final outfit = _outfits[index];
        final outfitId = outfit['id'] as String;
        final count = outfit['count'] as int;
        final isArchived = outfit['archived'] as bool? ?? false;
        final isRepeat = count >= 2;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              isRepeat
                  ? Icons.warning_amber_rounded
                  : Icons.emoji_symbols_outlined,
              color:
                  isRepeat ? const Color(0xFFD4A574) : const Color(0xFFC9A688),
            ),
            title: Text(outfit['name']!),
            subtitle: Text(
              isArchived ? 'Archived • worn $count times' : 'Worn $count times',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Mark worn',
                  icon: const Icon(Icons.check_circle_outline),
                  onPressed: () => _markOutfitAsWorn(index),
                ),
                IconButton(
                  tooltip: isArchived ? 'Unarchive outfit' : 'Archive outfit',
                  icon: Icon(
                    isArchived
                        ? Icons.unarchive_outlined
                        : Icons.archive_outlined,
                  ),
                  onPressed: () => _setArchive(outfitId, archive: !isArchived),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
