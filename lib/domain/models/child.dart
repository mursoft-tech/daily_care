/// Niño de la sala. Inmutable y sin dependencias de Flutter.
class Child {
  const Child({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.ageYears,
    required this.linkedParents,
    required this.colorToken,
    this.allergyLabel,
  });

  final String id;
  final String firstName;
  final String lastName;
  final int ageYears;
  final int linkedParents;
  final String colorToken;
  final String? allergyLabel;

  String get fullName => '$firstName $lastName';

  String get initial => firstName.isEmpty
      ? ''
      : firstName.substring(0, 1).toUpperCase();

  bool get hasAllergy => allergyLabel != null;
}
