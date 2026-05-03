import 'package:flutter/material.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text('Emergency Mode'),
      ),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.speed, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Quick outfit creation coming soon...',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                Text(
                  'One-button outfit generation pending implementation',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2D2A26).withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
