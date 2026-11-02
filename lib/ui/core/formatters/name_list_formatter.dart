/// Une nombres como "Mateo", "Mateo y Sofía" o "Mateo, Sofía y Benjamín".
String formatNameList(List<String> names) {
  final valid = [
    for (final name in names)
      if (name.trim().isNotEmpty) name.trim(),
  ];

  if (valid.isEmpty) return '';
  if (valid.length == 1) return valid.first;
  if (valid.length == 2) return '${valid[0]} y ${valid[1]}';

  return '${valid.sublist(0, valid.length - 1).join(', ')} y ${valid.last}';
}
