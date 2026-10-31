import 'package:daily_care/ui/core/formatters/birth_date_input_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

TextEditingValue _edit(
  String previous,
  String next, {
  int? cursor,
}) {
  return const BirthDateInputFormatter().formatEditUpdate(
    TextEditingValue(
      text: previous,
      selection: TextSelection.collapsed(offset: previous.length),
    ),
    TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: cursor ?? next.length),
    ),
  );
}

void main() {
  group('BirthDateInputFormatter', () {
    test('inserts the slashes while typing digits', () {
      expect(_edit('12032', '120320').text, '12/03/20');
      expect(_edit('12/03/202', '12/03/2023').text, '12/03/2023');
    });

    test('adds the separator as soon as the day is complete', () {
      expect(_edit('1', '12').text, '12');
      expect(_edit('12', '120').text, '12/0');
    });

    test('ignores letters and symbols', () {
      expect(_edit('12/0', '12/a0').text, '12/0');
      expect(_edit('12/03', '12/03!').text, '12/03');
    });

    test('normalizes a pasted date', () {
      expect(_edit('', '12/03/2023').text, '12/03/2023');
      expect(_edit('', '12-03-2023').text, '12/03/2023');
    });

    test('caps the value at eight digits', () {
      expect(_edit('12/03/2023', '12/03/202399').text, '12/03/2023');
    });

    test('removes the last digit when deleting', () {
      expect(_edit('12/03/2023', '12/03/202').text, '12/03/202');
      expect(_edit('12/03/202', '12/03/20').text, '12/03/20');
    });

    test('keeps the cursor at the end when a ninth digit is typed', () {
      final value = _edit('12/03/2023', '12/03/20234', cursor: 12);

      expect(value.text, '12/03/2023');
      expect(value.selection.baseOffset, 10);
    });
  });
}
