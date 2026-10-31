import '../models/room.dart';

/// Datos capturados en el formulario antes de validarse y convertirse en niño.
class ChildDraft {
  const ChildDraft({
    required this.fullName,
    required this.birthDateText,
    required this.room,
    this.allergyLabels = const <String>[],
    this.medicalNotes = '',
  });

  factory ChildDraft.empty() => ChildDraft(
    fullName: '',
    birthDateText: '',
    room: kRooms.first,
  );

  final String fullName;
  final String birthDateText;
  final String room;
  final List<String> allergyLabels;
  final String medicalNotes;

  String get trimmedName => fullName.trim();

  String get firstName => _nameParts.isEmpty ? '' : _nameParts.first;

  String get lastName => _nameParts.length < 2
      ? ''
      : _nameParts.skip(1).join(' ');

  List<String> get normalizedAllergyLabels => [
    for (final label in allergyLabels)
      if (label.trim().isNotEmpty) label.trim().toUpperCase(),
  ];

  List<String> get _nameParts =>
      trimmedName.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
}
