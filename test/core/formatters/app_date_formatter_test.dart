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
}
