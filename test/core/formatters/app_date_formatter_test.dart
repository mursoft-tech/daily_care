import 'package:daily_care/core/formatters/app_date_formatter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  test('formats a birth date in abbreviated Spanish', () {
    expect(formatBirthDate(DateTime(2023, 3, 12), 'es'), '12 mar 2023');
  });

  test('formats a month and year in abbreviated Spanish', () {
    expect(formatMonthYear(DateTime(2025, 2), 'es'), 'feb 2025');
  });

  group('parseBirthDate', () {
    test('parses a valid dd/mm/yyyy date', () {
      expect(parseBirthDate('12/03/2023'), DateTime(2023, 3, 12));
    });

    test('accepts a leap day in a leap year', () {
      expect(parseBirthDate('29/02/2024'), DateTime(2024, 2, 29));
    });

    test('rejects a date that does not exist', () {
      expect(parseBirthDate('31/02/2023'), isNull);
      expect(parseBirthDate('29/02/2023'), isNull);
    });

    test('rejects an incomplete or malformed value', () {
      expect(parseBirthDate('12/03'), isNull);
      expect(parseBirthDate('12-03-2023'), isNull);
      expect(parseBirthDate(''), isNull);
    });
  });
}
