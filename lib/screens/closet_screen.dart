import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mix_match_mood/core/models/clothes.dart';
import 'package:mix_match_mood/core/services/hive_service.dart';
import 'package:mix_match_mood/screens/upload_screen.dart';

class ClosetScreen extends StatefulWidget {
  const ClosetScreen({super.key});

  @override
  State<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends State<ClosetScreen> {
  final HiveService _hiveService = HiveService();
  final DateFormat _dateFormat = DateFormat('MMM d, yyyy');
  List<Clothes> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = _hiveService.getClothes().toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _deleteItem(Clothes item) async {
    await _hiveService.deleteClothes(item.id);
    await _loadItems();
  }

  Future<void> _goToAdd() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const UploadScreen()),
    );
    await _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text('Closet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadItems,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToAdd,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Text(
                    'Your closet is empty.\nAdd your first clothing item.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadItems,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Card(
                        child: ListTile(
                          leading: _buildLeadingImage(item),
                          title: Text(item.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item.type.toUpperCase()} • ${item.colors.join(', ')}',
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Season: ${item.seasons.join(', ')}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.lastWorn == null
                                    ? 'Last worn: never'
                                    : 'Last worn: ${_dateFormat.format(item.lastWorn!)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _deleteItem(item),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildLeadingImage(Clothes item) {
    final imagePath = item.imagePath;
    if (imagePath == null ||
        imagePath.isEmpty ||
        !File(imagePath).existsSync()) {
      return const CircleAvatar(child: Icon(Icons.checkroom_outlined));
    }
    return CircleAvatar(
      backgroundImage: FileImage(File(imagePath)),
    );
  }
}
