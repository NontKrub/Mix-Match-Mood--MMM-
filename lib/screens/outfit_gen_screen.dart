import 'package:flutter/material.dart';
import 'package:mix_match_mood/screens/color_picker_screen.dart';
import 'package:mix_match_mood/screens/emergency_screen.dart';
import 'package:mix_match_mood/screens/mood_picker_screen.dart';
import 'package:mix_match_mood/screens/style_picker_screen.dart';

class OutfitGenScreen extends StatelessWidget {
  const OutfitGenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(title: const Text('Outfit Generator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _EntryCard(
            icon: Icons.mood_outlined,
            title: 'Generate by Mood',
            subtitle: 'Pick a feeling and get matching outfit ideas.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MoodPickerScreen()),
            ),
          ),
          _EntryCard(
            icon: Icons.style_outlined,
            title: 'Generate by Style',
            subtitle: 'Find outfits for your preferred vibe.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StylePickerScreen()),
            ),
          ),
          _EntryCard(
            icon: Icons.palette_outlined,
            title: 'Generate by Color',
            subtitle: 'Filter outfits by color palette or tone.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ColorPickerScreen()),
            ),
          ),
          _EntryCard(
            icon: Icons.bolt_outlined,
            title: 'Emergency One-Tap',
            subtitle: 'Generate a safe, simple outfit instantly.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EmergencyScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFC9A688)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
