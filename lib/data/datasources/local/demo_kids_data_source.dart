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
          email: 'lucia@ejemplo.com',
          relationship: GuardianRelationship.mother,
          status: GuardianStatus.active,
          colorToken: 'purple',
        ),
        Guardian(
          id: 'diego-fernandez',
          firstName: 'Diego',
          lastName: 'Fernández',
          email: 'diego@ejemplo.com',
          relationship: GuardianRelationship.father,
          status: GuardianStatus.invited,
          colorToken: 'blue',
          invitationCode: 'K7M2P',
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
          email: 'camila@ejemplo.com',
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
          email: 'andres@ejemplo.com',
          relationship: GuardianRelationship.father,
          status: GuardianStatus.active,
          colorToken: 'blue',
        ),
        Guardian(
          id: 'paula-gomez',
          firstName: 'Paula',
          lastName: 'Gómez',
          email: 'paula@ejemplo.com',
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
          email: 'mariana@ejemplo.com',
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
          email: 'julian@ejemplo.com',
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
          email: 'carla@ejemplo.com',
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
          email: 'martin@ejemplo.com',
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

  @override
  Future<Guardian> linkGuardian({
    required String childId,
    required String fullName,
    required String email,
    required GuardianRelationship relationship,
    required String invitationCode,
  }) async {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    final normalizedEmail = email.trim().toLowerCase();
    final guardianId = 'guardian-$childId-$normalizedEmail';

    final guardian = Guardian(
      id: guardianId,
      firstName: firstName,
      lastName: lastName,
      email: normalizedEmail,
      relationship: relationship,
      status: GuardianStatus.invited,
      colorToken: 'blue',
      invitationCode: invitationCode,
    );

    final index = _children.indexWhere((c) => c.id == childId);
    if (index != -1) {
      final child = _children[index];
      final updatedGuardians = List<Guardian>.from(child.guardians)..add(guardian);
      _children[index] = child.copyWith(guardians: updatedGuardians);
    }
    return guardian;
  }
}
