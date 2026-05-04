import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mix_match_mood/core/hive_init.dart';
import 'package:mix_match_mood/core/theme/app_theme.dart';
import 'package:mix_match_mood/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();

  runApp(const MixMatchMoodApp());
}

class MixMatchMoodApp extends StatelessWidget {
  const MixMatchMoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mix Match Mood',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
