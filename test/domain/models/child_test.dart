import 'package:daily_care/domain/models/child.dart';
import 'package:daily_care/domain/models/guardian.dart';
import 'package:daily_care/domain/value_objects/allergy.dart';
import 'package:flutter_test/flutter_test.dart';

const _lucia = Guardian(
  id: 'lucia-fernandez',
  firstName: 'Lucía',
  lastName: 'Fernández',
  relationship: GuardianRelationship.mother,
  status: GuardianStatus.active,
  colorToken: 'purple',
);

const _diego = Guardian(
  id: 'diego-fernandez',
  firstName: 'Diego',
  lastName: 'Fernández',
  relationship: GuardianRelationship.father,
  status: GuardianStatus.invited,
  colorToken: 'blue',
);

void main() {
  group('Child', () {
    final child = Child(
      id: 'mateo-fernandez',
      firstName: 'Mateo',
      lastName: 'Fernández',
      birthDate: DateTime(2023, 3, 12),
      room: 'Soles',
      enrolledAt: DateTime(2025, 2),
      colorToken: 'blue',
      allergies: const [
        Allergy(label: 'MANÍ', notes: 'Alergia al maní.'),
        Allergy(label: 'LACTOSA', notes: 'Sin lácteos.'),
      ],
      medicalNotes: 'Lleva inhalador en la mochila.',
      guardians: const [_lucia, _diego],
    );

    test('builds the full name, initial and dates', () {
      expect(child.fullName, 'Mateo Fernández');
      expect(child.initial, 'M');
      expect(child.birthDate, DateTime(2023, 3, 12));
      expect(child.enrolledAt, DateTime(2025, 2));
      expect(child.room, 'Soles');
    });

    test('trims the full name when there is no last name', () {
      final single = Child(
        id: 'martina',
        firstName: 'Martina',
        lastName: '',
        birthDate: DateTime(2024, 1, 1),
        room: 'Soles',
        enrolledAt: DateTime(2025, 2),
        colorToken: 'blue',
      );

      expect(single.fullName, 'Martina');
    });

    test('exposes the allergy labels and notes', () {
      expect(child.hasAllergy, isTrue);
      expect(child.allergies.map((allergy) => allergy.label), [
        'MANÍ',
        'LACTOSA',
      ]);
      expect(child.allergies.first.notes, 'Alergia al maní.');
    });

    test('exposes the medical notes', () {
      expect(child.hasMedicalNotes, isTrue);
      expect(child.medicalNotes, 'Lleva inhalador en la mochila.');
    });

    test('reports no allergy when the list is empty', () {
      final other = Child(
        id: 'sofia-mendez',
        firstName: 'Sofía',
        lastName: 'Méndez',
        birthDate: DateTime(2024, 5, 9),
        room: 'Soles',
        enrolledAt: DateTime(2025, 2),
        colorToken: 'pink',
      );

      expect(other.hasAllergy, isFalse);
      expect(other.allergies, isEmpty);
      expect(other.medicalNotes, isEmpty);
      expect(other.hasMedicalNotes, isFalse);
    });

    test('derives the linked parent count from the guardians', () {
      final withoutGuardians = Child(
        id: 'valentina-soto',
        firstName: 'Valentina',
        lastName: 'Soto',
        birthDate: DateTime(2024, 7, 1),
        room: 'Soles',
        enrolledAt: DateTime(2025, 2),
        colorToken: 'yellow',
      );
      final withOneGuardian = Child(
        id: 'sofia-mendez',
        firstName: 'Sofía',
        lastName: 'Méndez',
        birthDate: DateTime(2024, 5, 9),
        room: 'Soles',
        enrolledAt: DateTime(2025, 2),
        colorToken: 'pink',
        guardians: const [_lucia],
      );

      expect(withoutGuardians.linkedParents, 0);
      expect(withOneGuardian.linkedParents, 1);
      expect(child.linkedParents, 2);
    });
  });
}
