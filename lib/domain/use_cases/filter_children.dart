import '../models/child.dart';

const _diacritics = <String, String>{
  'á': 'a',
  'é': 'e',
  'í': 'i',
  'ó': 'o',
  'ú': 'u',
  'ü': 'u',
  'ñ': 'n',
};

String _normalize(String value) {
  final lower = value.trim().toLowerCase();
  return lower.split('').map((char) => _diacritics[char] ?? char).join();
}

List<Child> filterChildren(List<Child> children, String query) {
  final needle = _normalize(query);
  if (needle.isEmpty) return children;

  return children
      .where((child) => _normalize(child.fullName).contains(needle))
      .toList(growable: false);
}
