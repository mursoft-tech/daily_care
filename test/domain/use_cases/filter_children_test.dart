import 'package:daily_care/domain/models/child.dart';
import 'package:daily_care/domain/use_cases/filter_children.dart';
import 'package:flutter_test/flutter_test.dart';

final _children = <Child>[
  Child(
    id: 'mateo',
    firstName: 'Mateo',
    lastName: 'Fernández',
    birthDate: DateTime(2023, 3, 12),
    room: 'Soles',
    enrolledAt: DateTime(2025, 2),
    colorToken: 'blue',
  ),
  Child(
    id: 'sofia',
    firstName: 'Sofía',
    lastName: 'Méndez',
    birthDate: DateTime(2024, 5, 9),
    room: 'Soles',
    enrolledAt: DateTime(2025, 2),
    colorToken: 'pink',
  ),
  Child(
    id: 'benjamin',
    firstName: 'Benjamín',
    lastName: 'Ruiz',
    birthDate: DateTime(2023, 8, 21),
    room: 'Soles',
    enrolledAt: DateTime(2025, 2),
    colorToken: 'green',
  ),
];

void main() {
  group('filterChildren', () {
    test('ignores case and accents', () {
      expect(filterChildren(_children, 'sofia').single.firstName, 'Sofía');
      expect(filterChildren(_children, 'BENJAMIN').single.firstName, 'Benjamín');
    });

    test('matches a partial full name', () {
      expect(filterChildren(_children, 'fernandez').single.firstName, 'Mateo');
      expect(filterChildren(_children, 'ruiz').single.firstName, 'Benjamín');
    });

    test('returns every child when the query is blank', () {
      expect(filterChildren(_children, '   '), _children);
    });

    test('returns an empty list when nothing matches', () {
      expect(filterChildren(_children, 'zzz'), isEmpty);
    });
  });
}
