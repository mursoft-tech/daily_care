/// Invitación pendiente para activar la cuenta de una familia. Inmutable y sin
/// dependencias de Flutter.
class AccountInvitation {
  const AccountInvitation({
    required this.code,
    required this.email,
    required this.childName,
    required this.roomName,
  });

  final String code;
  final String email;
  final String childName;
  final String roomName;

  String get childInitial =>
      childName.isEmpty ? '' : childName.substring(0, 1).toUpperCase();
}
