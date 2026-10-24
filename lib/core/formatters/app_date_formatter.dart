import 'package:intl/intl.dart';

String formatBirthDate(DateTime date, String locale) {
  return DateFormat('d MMM y', locale).format(date);
}

String formatMonthYear(DateTime date, String locale) {
  return DateFormat('MMM y', locale).format(date);
}
