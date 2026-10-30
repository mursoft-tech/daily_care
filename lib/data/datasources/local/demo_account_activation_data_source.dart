import '../../../domain/models/account_invitation.dart';
import '../account_activation_data_source.dart';

/// Invitación de demostración mientras no exista backend de invitaciones.
class DemoAccountActivationDataSource implements AccountActivationDataSource {
  const DemoAccountActivationDataSource();

  static const invitation = AccountInvitation(
    code: '7K4P9',
    email: 'lucia.fernandez@gmail.com',
    childName: 'Mateo',
    roomName: 'Sala Soles',
  );

  @override
  Future<AccountInvitation?> fetchInvitation(String code) async {
    final normalized = code.trim().toUpperCase();
    return normalized == invitation.code ? invitation : null;
  }

  @override
  Future<void> activate({
    required AccountInvitation invitation,
    required String password,
    required bool photoConsent,
  }) async {}
}
