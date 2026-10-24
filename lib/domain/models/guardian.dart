enum GuardianRelationship { mother, father, guardian }

enum GuardianStatus { active, invited }

/// Padre o tutor vinculado a un niño. Inmutable y sin dependencias de Flutter.
class Guardian {
  const Guardian({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.relationship,
    required this.status,
    required this.colorToken,
  });

  final String id;
  final String firstName;
  final String lastName;
  final GuardianRelationship relationship;
  final GuardianStatus status;
  final String colorToken;

  String get fullName => '$firstName $lastName';

  String get initial => firstName.isEmpty
      ? ''
      : firstName.substring(0, 1).toUpperCase();

  bool get isActive => status == GuardianStatus.active;
}
