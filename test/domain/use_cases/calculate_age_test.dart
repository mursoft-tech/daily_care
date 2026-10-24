import 'package:daily_care/domain/use_cases/calculate_age.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calculateAge', () {
    test('counts a birthday that already happened', () {
      expect(calculateAge(DateTime(2023, 3, 12), DateTime(2026, 10, 24)), 3);
    });

    test('does not count a birthday that is still pending', () {
      expect(calculateAge(DateTime(2023, 12, 30), DateTime(2026, 10, 24)), 2);
    });

    test('counts the age on the birthday', () {
      expect(calculateAge(DateTime(2023, 10, 24), DateTime(2026, 10, 24)), 3);
    });

    test('handles a leap-day birthday before the anniversary', () {
      expect(calculateAge(DateTime(2024, 2, 29), DateTime(2026, 2, 28)), 1);
    });

    test('handles a leap-day birthday after the anniversary', () {
      expect(calculateAge(DateTime(2024, 2, 29), DateTime(2026, 3, 1)), 2);
    });
  });
}
