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
    this.allergies = const <Allergy>[],
    this.medicalNotes = '',
    this.guardians = const <Guardian>[],
  });

  final String id;
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final String room;
  final DateTime enrolledAt;
  final String colorToken;
  final List<Allergy> allergies;
  final String medicalNotes;
  final List<Guardian> guardians;

  String get fullName => '$firstName $lastName'.trim();

  String get initial => firstName.isEmpty
      ? ''
      : firstName.substring(0, 1).toUpperCase();

  bool get hasAllergy => allergies.isNotEmpty;

  bool get hasMedicalNotes => medicalNotes.trim().isNotEmpty;

  int get linkedParents => guardians.length;
}
