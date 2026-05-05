import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mix_match_mood/core/services/hive_service.dart';

class RepeatAlertScreen extends StatefulWidget {
  const RepeatAlertScreen({super.key});

  @override
  State<RepeatAlertScreen> createState() => _RepeatAlertScreenState();
}

class _RepeatAlertScreenState extends State<RepeatAlertScreen> {
  final HiveService _hiveService = HiveService();
  final ImagePicker _picker = ImagePicker();
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
              'referencePhotoPath': o.referencePhotoPath,
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
          content: Text('This outfit has been repeated $updatedCount times.'),
          action: SnackBarAction(
            label: 'Save Photo',
            onPressed: () => _saveRepeatPhotoForOutfit(outfitId),
          ),
        ),
      );
    }
  }

  Future<void> _saveRepeatPhoto(int index) async {
    final outfitId = _outfits[index]['id'] as String;
    await _saveRepeatPhotoForOutfit(outfitId);
  }

  Future<ImageSource?> _pickImageSource() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Save reference photo',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _saveRepeatPhotoForOutfit(String outfitId) async {
    final source = await _pickImageSource();
    if (source == null) {
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) {
        return;
      }

      await _hiveService.saveOutfitReferencePhoto(outfitId, image.path);
      await _analyzeWearHistory();
      _showSnackBar('Outfit photo saved');
    } on PlatformException catch (e) {
      _showSnackBar('Image access failed: ${e.message ?? e.code}');
    }
  }

  void _openReferencePhoto(String path) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              automaticallyImplyLeading: false,
              title: const Text('Reference photo'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Flexible(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 3,
                child: Image.file(File(path), fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );
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
        final referencePhotoPath =
            (outfit['referencePhotoPath'] as String?) ?? '';
        final hasReferencePhoto = referencePhotoPath.isNotEmpty;
        final hasReferencePhotoFile =
            hasReferencePhoto && File(referencePhotoPath).existsSync();
        final isRepeat = count >= 2;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: hasReferencePhotoFile
                  ? () => _openReferencePhoto(referencePhotoPath)
                  : null,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFE8E4DC),
                  image: hasReferencePhotoFile
                      ? DecorationImage(
                          image: FileImage(File(referencePhotoPath)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: hasReferencePhotoFile
                    ? null
                    : Icon(
                        isRepeat
                            ? Icons.warning_amber_rounded
                            : Icons.emoji_symbols_outlined,
                        color: isRepeat
                            ? const Color(0xFFD4A574)
                            : const Color(0xFFC9A688),
                      ),
              ),
            ),
            title: Text(outfit['name']!),
            subtitle: Text(
              [
                if (isArchived) 'Archived',
                'Worn $count times',
                if (hasReferencePhotoFile) 'Photo saved',
                if (hasReferencePhoto && !hasReferencePhotoFile)
                  'Photo missing',
              ].join(' • '),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: hasReferencePhotoFile
                      ? 'Update reference photo'
                      : 'Save reference photo',
                  icon: Icon(hasReferencePhotoFile
                      ? Icons.camera_alt
                      : Icons.camera_alt_outlined),
                  onPressed: () => _saveRepeatPhoto(index),
                ),
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
