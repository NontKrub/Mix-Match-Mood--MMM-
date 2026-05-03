import 'package:flutter/material.dart';

class RepeatAlertScreen extends StatelessWidget {
  const RepeatAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text('Repeat Alert'),
      ),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_active, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Smart alerts coming soon...',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                Text(
                  'Will notify you when you wear an outfit again',
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
