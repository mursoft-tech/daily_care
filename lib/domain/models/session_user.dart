enum SessionRole { teacher, family }

/// Usuario autenticado. Inmutable y sin dependencias de Flutter.
class SessionUser {
  const SessionUser({
    required this.id,
    required this.firstName,
    required this.fullName,
    required this.initial,
    required this.role,
  });

  /// Usuario de demostración mientras no exista autenticación real.
  const SessionUser.demo()
    : this(
        id: 'demo-teacher',
        firstName: 'Caro',
        fullName: 'Caro Giménez',
        initial: 'C',
        role: SessionRole.teacher,
      );

  final String id;
  final String firstName;
  final String fullName;
  final String initial;
  final SessionRole role;
}
