import 'package:flutter_test/flutter_test.dart';
import 'package:mix_match_mood/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('home menu shows key MMM features', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    expect(find.text('Mix Match Mood'), findsOneWidget);
    expect(find.text('Add Clothes'), findsOneWidget);
    expect(find.text('Mood Based'), findsOneWidget);
    expect(find.text('Style Based'), findsOneWidget);
    expect(find.text('Color Based'), findsOneWidget);
  });
}
