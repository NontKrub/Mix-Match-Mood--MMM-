import 'package:flutter/material.dart';
import 'package:mix_match_mood/core/hive_init.dart';
import 'package:mix_match_mood/core/services/hive_service.dart';
import 'package:mix_match_mood/core/theme/app_theme.dart';
import 'package:mix_match_mood/screens/app_shell_screen.dart';
import 'package:mix_match_mood/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();

  runApp(const MixMatchMoodApp());
}

class MixMatchMoodApp extends StatelessWidget {
  const MixMatchMoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    final hiveService = HiveService();
    return MaterialApp(
      title: 'Mix Match Mood',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: hiveService.isOnboardingComplete()
          ? const AppShellScreen()
          : const OnboardingScreen(),
    );
  }
}
