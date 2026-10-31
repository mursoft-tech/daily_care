import 'package:daily_care/domain/value_objects/child_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChildDraft', () {
    test('splits a two-word name into first and last name', () {
      const draft = ChildDraft(
        fullName: '  Martina   López ',
        birthDateText: '12/03/2023',
        room: 'Soles',
      );

      expect(draft.trimmedName, 'Martina   López');
      expect(draft.firstName, 'Martina');
      expect(draft.lastName, 'López');
    });

    test('keeps a single word as the first name and an empty last name', () {
      const draft = ChildDraft(
        fullName: 'Martina',
        birthDateText: '12/03/2023',
        room: 'Soles',
      );

      expect(draft.firstName, 'Martina');
      expect(draft.lastName, '');
    });

    test('keeps compound last names together', () {
      const draft = ChildDraft(
        fullName: 'Ana María Pérez Gómez',
        birthDateText: '12/03/2023',
        room: 'Soles',
      );

      expect(draft.firstName, 'Ana');
      expect(draft.lastName, 'María Pérez Gómez');
    });

    test('trims and normalizes the allergy labels, dropping empty ones', () {
      const draft = ChildDraft(
        fullName: 'Martina López',
        birthDateText: '12/03/2023',
        room: 'Soles',
        allergyLabels: [' maní ', '', 'Lactosa'],
      );

      expect(draft.normalizedAllergyLabels, ['MANÍ', 'LACTOSA']);
    });

    test('preselects the only available room', () {
      final draft = ChildDraft.empty();

      expect(draft.room, 'Soles');
    });
  });
}
