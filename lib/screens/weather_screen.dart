import 'package:flutter/material.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text('Weather Reality Check'),
      ),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Weather API integration pending...',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                Text(
                  'Coming soon - will show weather-based outfit suggestions',
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
