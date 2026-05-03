import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mix_match_mood/screens/upload_screen.dart';
import 'package:mix_match_mood/screens/mood_picker_screen.dart';
import 'package:mix_match_mood/screens/style_picker_screen.dart';
import 'package:mix_match_mood/screens/color_picker_screen.dart';
import 'package:mix_match_mood/screens/weather_screen.dart';
import 'package:mix_match_mood/screens/repeat_alert_screen.dart';
import 'package:mix_match_mood/screens/missing_piece_screen.dart';
import 'package:mix_match_mood/screens/emergency_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> _menuItems = [
    {'icon': '📸', 'title': 'Add Clothes'},
    {'icon': '😊', 'title': 'Mood Based'},
    {'icon': '🎨', 'title': 'Style Based'},
    {'icon': '🌈', 'title': 'Color Based'},
    {'icon': '⛅️', 'title': 'Reality Check'},
    {'icon': '🔔', 'title': 'Repeat Alert'},
    {'icon': '🧩', 'title': 'Missing Piece'},
    {'icon': '🚨', 'title': 'Emergency Mode'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text('Mix Match Mood', style: TextStyle(fontSize: 24)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ..._menuItems.map((item) => _buildMenuItem(item)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFE8E4DC),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '✨ Your AI Stylist',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Easy to use. Pick your style.',
          style: TextStyle(fontSize: 16, color: Color(0xFF2D2A26).withValues(alpha: 0.7)),
          textAlign: TextAlign.center,
        ),
      ],
    ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildMenuItem(Map<String, String> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _onMenuItemTap(item['title']!),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item['icon']!, style: TextStyle(fontSize: 36)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(item['title']!, style: TextStyle(fontWeight: FontWeight.w500)),
              ),
              Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFFC9A688)),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0);
  }

  void _onMenuItemTap(String title) {
    switch (title) {
      case 'Add Clothes':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UploadScreen()),
        );
        break;
      case 'Mood Based':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MoodPickerScreen()),
        );
        break;
      case 'Style Based':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StylePickerScreen()),
        );
        break;
      case 'Color Based':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ColorPickerScreen()),
        );
        break;
      case 'Reality Check':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WeatherScreen()),
        );
        break;
      case 'Repeat Alert':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RepeatAlertScreen()),
        );
        break;
      case 'Missing Piece':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MissingPieceScreen()),
        );
        break;
      case 'Emergency Mode':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EmergencyScreen()),
        );
        break;
    }
  }
}
