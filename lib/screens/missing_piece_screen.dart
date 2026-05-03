import 'package:flutter/material.dart';

class MissingPieceScreen extends StatelessWidget {
  const MissingPieceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text('Missing Piece Finder'),
      ),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Gap analysis coming soon...',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                Text(
                  'Will analyze your wardrobe and suggest what to buy',
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
