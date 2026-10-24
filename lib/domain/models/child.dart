import '../value_objects/allergy.dart';
import 'guardian.dart';

/// Niño de la sala. Inmutable y sin dependencias de Flutter.
class Child {
  const Child({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.room,
    required this.enrolledAt,
    required this.colorToken,
    this.allergy,
    this.guardians = const <Guardian>[],
  });

  final String id;
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final String room;
  final DateTime enrolledAt;
  final String colorToken;
  final Allergy? allergy;
  final List<Guardian> guardians;

  String get fullName => '$firstName $lastName';

  String get initial => firstName.isEmpty
      ? ''
      : firstName.substring(0, 1).toUpperCase();

  bool get hasAllergy => allergy != null;

  int get linkedParents => guardians.length;
}
