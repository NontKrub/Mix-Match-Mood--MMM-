import 'package:flutter_test/flutter_test.dart';
import 'package:mix_match_mood/core/models/clothes.dart';

void main() {
  test('clothes equality uses id', () {
    final first = Clothes(
      id: 'same-id',
      name: 'White Tee',
      type: 'top',
      colors: const ['white'],
      styles: const ['casual'],
      occasions: const ['daily'],
    );
    final second = Clothes(
      id: 'same-id',
      name: 'Different name',
      type: 'top',
      colors: const ['black'],
      styles: const ['formal'],
      occasions: const ['work'],
    );

    expect(first, equals(second));
  });

  test('clothes createdAt defaults to now', () {
    final before = DateTime.now();
    final item = Clothes(
      id: 'id-2',
      name: 'Blue Jeans',
      type: 'bottom',
      colors: const ['blue'],
      styles: const ['classic'],
      occasions: const ['daily'],
    );
    final after = DateTime.now();

    expect(
        item.createdAt.isAfter(before) ||
            item.createdAt.isAtSameMomentAs(before),
        isTrue);
    expect(
        item.createdAt.isBefore(after) ||
            item.createdAt.isAtSameMomentAs(after),
        isTrue);
  });
}
