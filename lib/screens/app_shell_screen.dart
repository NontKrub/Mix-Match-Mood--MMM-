import 'package:flutter/material.dart';
import 'package:mix_match_mood/screens/closet_screen.dart';
import 'package:mix_match_mood/screens/home_screen.dart';
import 'package:mix_match_mood/screens/outfit_gen_screen.dart';
import 'package:mix_match_mood/screens/profile_screen.dart';

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({super.key});

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  int _currentIndex = 0;

  static const _pages = [
    HomeScreen(),
    ClosetScreen(),
    OutfitGenScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.checkroom_outlined), label: 'Closet'),
          NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined), label: 'Outfit Gen'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
