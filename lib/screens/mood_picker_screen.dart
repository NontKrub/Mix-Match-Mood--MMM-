import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(title: const Text('Pick by Mood')),
      body: ListView.builder(
        itemCount: _moods.length,
        padding: const EdgeInsets.all(16),
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
    );
  }

  void _selectMood(String mood) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecting $mood outfits...')),
      );
    }
  }
}
