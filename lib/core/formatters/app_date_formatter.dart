import 'package:intl/intl.dart';

String formatBirthDate(DateTime date, String locale) {
  return DateFormat('d MMM y', locale).format(date);
}

String formatMonthYear(DateTime date, String locale) {
  return DateFormat('MMM y', locale).format(date);
}

/// Parsea `dd/mm/aaaa` y descarta fechas que no existen en el calendario.
DateTime? parseBirthDate(String value) {
  final match = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(value.trim());
  if (match == null) return null;

  final day = int.parse(match[1]!);
  final month = int.parse(match[2]!);
  final year = int.parse(match[3]!);

  final date = DateTime(year, month, day);
  final exists =
      date.year == year && date.month == month && date.day == day;
  return exists ? date : null;
}
