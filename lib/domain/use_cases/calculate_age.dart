/// Años cumplidos entre la fecha de nacimiento y la fecha de referencia.
int calculateAge(DateTime birthDate, DateTime today) {
  var age = today.year - birthDate.year;
  final birthdayPending =
      today.month < birthDate.month ||
      (today.month == birthDate.month && today.day < birthDate.day);
  if (birthdayPending) age--;
  return age < 0 ? 0 : age;
}
