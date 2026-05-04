import 'package:flutter/material.dart';
import 'package:mix_match_mood/core/services/hive_service.dart';
import 'package:mix_match_mood/screens/app_shell_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
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
  final Set<String> _selectedMoods = {'Casual'};
  final Set<String> _selectedStyles = {'Minimal'};
  bool _saving = false;

  Future<void> _continue() async {
    setState(() => _saving = true);
    await _hiveService.completeOnboarding(
      preferredMoods: _selectedMoods.toList(),
      preferredStyles: _selectedStyles.toList(),
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AppShellScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(title: const Text('Welcome to MMM')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Set your style preferences',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'MMM uses this to personalize outfit suggestions from day one.',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),
            const Text(
              'Preferred moods',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _moods.map((mood) {
                final selected = _selectedMoods.contains(mood);
                return FilterChip(
                  label: Text(mood),
                  selected: selected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _selectedMoods.add(mood);
                      } else if (_selectedMoods.length > 1) {
                        _selectedMoods.remove(mood);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Preferred styles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _styles.map((style) {
                final selected = _selectedStyles.contains(style);
                return FilterChip(
                  label: Text(style),
                  selected: selected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _selectedStyles.add(style);
                      } else if (_selectedStyles.length > 1) {
                        _selectedStyles.remove(style);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _saving ? null : _continue,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(_saving ? 'Saving...' : 'Start using MMM'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC9A688),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
