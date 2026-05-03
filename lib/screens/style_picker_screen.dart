import 'package:flutter/material.dart';

class StylePickerScreen extends StatefulWidget {
  const StylePickerScreen({super.key});

  @override
  State<StylePickerScreen> createState() => _StylePickerScreenState();
}

class _StylePickerScreenState extends State<StylePickerScreen> {
  static const List<Map<String, String>> _styles = [
    {'icon': '⚫', 'name': 'Minimal'},
    {'icon': '🎨', 'name': 'Classic'},
    {'icon': '🔥', 'name': 'Edgy'},
    {'icon': '🌿', 'name': 'Boho'},
    {'icon': '👔', 'name': 'Formal'},
    {'icon': '👕', 'name': 'Casual'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(title: const Text('Pick by Style')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
        ),
        itemCount: _styles.length,
        itemBuilder: (context, index) {
          final style = _styles[index];
          return Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(style['icon']!, style: const TextStyle(fontSize: 36)),
                const SizedBox(height: 8),
                Text(style['name']!, textAlign: TextAlign.center),
              ],
            ),
          );
        },
      ),
    );
  }
}
