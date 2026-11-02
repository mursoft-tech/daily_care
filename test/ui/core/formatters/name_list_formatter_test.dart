import 'package:daily_care/ui/core/formatters/name_list_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats one, two and several names in Spanish', () {
    expect(formatNameList(const ['Mateo']), 'Mateo');
    expect(formatNameList(const ['Mateo', 'Sofía']), 'Mateo y Sofía');
    expect(
      formatNameList(const ['Mateo', 'Sofía', 'Benjamín']),
      'Mateo, Sofía y Benjamín',
    );
  });

  test('ignores blank names and trims the rest', () {
    expect(
      formatNameList(const ['  Mateo ', '', 'Sofía  ']),
      'Mateo y Sofía',
    );
    expect(formatNameList(const []), isEmpty);
  });
}
