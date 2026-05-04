import 'package:flutter/material.dart';
import 'package:mix_match_mood/core/models/user_preferences.dart';
import 'package:mix_match_mood/core/services/hive_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const List<String> _moods = [
    'Happy',
    'Professional',
    'Casual',
    'Romantic',
    'Sporty',
    'Relaxed',
  ];

  static const List<String> _styles = [
    'Minimal',
    'Classic',
    'Formal',
    'Casual',
    'Streetwear',
    'Boho',
  ];

  final HiveService _hiveService = HiveService();
  late UserPreferences _prefs;
  int _clothesCount = 0;
  int _outfitsCount = 0;
  int _wearCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = _hiveService.getUserPreferences();
    setState(() {
      _prefs = prefs;
      _clothesCount = _hiveService.getClothes().length;
      _outfitsCount = _hiveService.getOutfits().length;
      _wearCount = _hiveService.getWearHistory().length;
      _loading = false;
    });
  }

  Future<void> _savePreferences() async {
    await _hiveService.setUserPreferences(_prefs);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferences updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Stat(label: 'Items', value: _clothesCount.toString()),
                  _Stat(label: 'Outfits', value: _outfitsCount.toString()),
                  _Stat(label: 'Wears', value: _wearCount.toString()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preferred moods',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _moods.map((mood) {
                      final selected = _prefs.preferredMoods.contains(mood);
                      return FilterChip(
                        label: Text(mood),
                        selected: selected,
                        onSelected: (value) {
                          setState(() {
                            final next = [..._prefs.preferredMoods];
                            if (value) {
                              if (!next.contains(mood)) {
                                next.add(mood);
                              }
                            } else {
                              next.remove(mood);
                            }
                            _prefs.preferredMoods = next;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Preferred styles',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _styles.map((style) {
                      final selected = _prefs.preferredStyles.contains(style);
                      return FilterChip(
                        label: Text(style),
                        selected: selected,
                        onSelected: (value) {
                          setState(() {
                            final next = [..._prefs.preferredStyles];
                            if (value) {
                              if (!next.contains(style)) {
                                next.add(style);
                              }
                            } else {
                              next.remove(style);
                            }
                            _prefs.preferredStyles = next;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _savePreferences,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save preferences'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(color: Colors.grey.shade700)),
      ],
    );
  }
}
