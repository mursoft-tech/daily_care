import 'package:daily_care/domain/models/child.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Child', () {
    const child = Child(
      id: 'mateo-fernandez',
      firstName: 'Mateo',
      lastName: 'Fernández',
      ageYears: 3,
      linkedParents: 2,
      colorToken: 'blue',
      allergyLabel: 'MANÍ',
    );

    test('builds the full name and initial', () {
      expect(child.fullName, 'Mateo Fernández');
      expect(child.initial, 'M');
      expect(child.hasAllergy, isTrue);
    });

    test('reports no allergy when the label is absent', () {
      const other = Child(
        id: 'sofia-mendez',
        firstName: 'Sofía',
        lastName: 'Méndez',
        ageYears: 2,
        linkedParents: 1,
        colorToken: 'pink',
      );

      expect(other.hasAllergy, isFalse);
    });
  });
}
