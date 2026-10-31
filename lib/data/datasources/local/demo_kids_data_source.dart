import '../../../domain/models/child.dart';
import '../../../domain/models/guardian.dart';
import '../../../domain/value_objects/allergy.dart';
import '../kids_data_source.dart';

class DemoKidsDataSource implements KidsDataSource {
  DemoKidsDataSource();

  final List<Child> _children = <Child>[
    Child(
      id: 'mateo-fernandez',
      firstName: 'Mateo',
      lastName: 'Fernández',
      birthDate: DateTime(2023, 3, 12),
      room: 'Soles',
      enrolledAt: DateTime(2025, 2),
      colorToken: 'blue',
      allergies: const [
        Allergy(
          label: 'MANÍ',
          notes:
              'Alergia al maní. Evitar frutos secos. '
              'Lleva inhalador en la mochila.',
        ),
      ],
      guardians: const [
        Guardian(
          id: 'lucia-fernandez',
          firstName: 'Lucía',
          lastName: 'Fernández',
          relationship: GuardianRelationship.mother,
          status: GuardianStatus.active,
          colorToken: 'purple',
        ),
        Guardian(
          id: 'diego-fernandez',
          firstName: 'Diego',
          lastName: 'Fernández',
          relationship: GuardianRelationship.father,
          status: GuardianStatus.invited,
          colorToken: 'blue',
        ),
      ],
    ),
    Child(
      id: 'sofia-mendez',
      firstName: 'Sofía',
      lastName: 'Méndez',
      birthDate: DateTime(2024, 5, 9),
      room: 'Soles',
      enrolledAt: DateTime(2025, 2),
      colorToken: 'pink',
      guardians: const [
        Guardian(
          id: 'camila-mendez',
          firstName: 'Camila',
          lastName: 'Méndez',
          relationship: GuardianRelationship.mother,
          status: GuardianStatus.active,
          colorToken: 'pink',
        ),
      ],
    ),
    Child(
      id: 'benjamin-ruiz',
      firstName: 'Benjamín',
      lastName: 'Ruiz',
      birthDate: DateTime(2023, 8, 21),
      room: 'Soles',
      enrolledAt: DateTime(2025, 3),
      colorToken: 'green',
      guardians: const [
        Guardian(
          id: 'andres-ruiz',
          firstName: 'Andrés',
          lastName: 'Ruiz',
          relationship: GuardianRelationship.father,
          status: GuardianStatus.active,
          colorToken: 'blue',
        ),
        Guardian(
          id: 'paula-gomez',
          firstName: 'Paula',
          lastName: 'Gómez',
          relationship: GuardianRelationship.mother,
          status: GuardianStatus.active,
          colorToken: 'pink',
        ),
      ],
    ),
    Child(
      id: 'valentina-soto',
      firstName: 'Valentina',
      lastName: 'Soto',
      birthDate: DateTime(2024, 7, 1),
      room: 'Soles',
      enrolledAt: DateTime(2025, 1),
      colorToken: 'yellow',
    ),
    Child(
      id: 'tomas-diaz',
      firstName: 'Tomás',
      lastName: 'Díaz',
      birthDate: DateTime(2023, 1, 30),
      room: 'Soles',
      enrolledAt: DateTime(2025, 2),
      colorToken: 'purple',
      allergies: const [
        Allergy(
          label: 'LACTOSA',
          notes:
              'Intolerancia a la lactosa. Sin lácteos. '
              'Lleva leche sin lactosa.',
        ),
      ],
      guardians: const [
        Guardian(
          id: 'mariana-diaz',
          firstName: 'Mariana',
          lastName: 'Díaz',
          relationship: GuardianRelationship.mother,
          status: GuardianStatus.active,
          colorToken: 'purple',
        ),
      ],
    ),
    Child(
      id: 'emma-castro',
      firstName: 'Emma',
      lastName: 'Castro',
      birthDate: DateTime(2024, 2, 18),
      room: 'Soles',
      enrolledAt: DateTime(2025, 4),
      colorToken: 'pink',
      guardians: const [
        Guardian(
          id: 'julian-castro',
          firstName: 'Julián',
          lastName: 'Castro',
          relationship: GuardianRelationship.father,
          status: GuardianStatus.active,
          colorToken: 'green',
        ),
      ],
    ),
    Child(
      id: 'lucas-romero',
      firstName: 'Lucas',
      lastName: 'Romero',
      birthDate: DateTime(2023, 6, 5),
      room: 'Soles',
      enrolledAt: DateTime(2025, 2),
      colorToken: 'blue',
      guardians: const [
        Guardian(
          id: 'carla-romero',
          firstName: 'Carla',
          lastName: 'Romero',
          relationship: GuardianRelationship.mother,
          status: GuardianStatus.active,
          colorToken: 'pink',
        ),
      ],
    ),
    Child(
      id: 'olivia-vega',
      firstName: 'Olivia',
      lastName: 'Vega',
      birthDate: DateTime(2024, 9, 23),
      room: 'Soles',
      enrolledAt: DateTime(2025, 3),
      colorToken: 'green',
      guardians: const [
        Guardian(
          id: 'martin-vega',
          firstName: 'Martín',
          lastName: 'Vega',
          relationship: GuardianRelationship.father,
          status: GuardianStatus.active,
          colorToken: 'blue',
        ),
      ],
    ),
  ];

  @override
  Future<List<Child>> fetchChildren() async => List.unmodifiable(_children);

  @override
  Future<Child?> fetchChild(String id) async {
    for (final child in _children) {
      if (child.id == id) return child;
    }
    return null;
  }

  @override
  Future<void> saveChild(Child child) async => _children.add(child);
}
