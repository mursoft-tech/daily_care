import 'package:daily_care/domain/value_objects/allergy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exposes the label and notes of the allergy', () {
    const allergy = Allergy(
      label: 'MANÍ',
      notes: 'Alergia al maní. Evitar frutos secos.',
    );

    expect(allergy.label, 'MANÍ');
    expect(allergy.notes, 'Alergia al maní. Evitar frutos secos.');
  });
}
