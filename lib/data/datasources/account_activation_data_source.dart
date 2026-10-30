import '../../domain/models/account_invitation.dart';

abstract interface class AccountActivationDataSource {
  Future<AccountInvitation?> fetchInvitation(String code);

  Future<void> activate({
    required AccountInvitation invitation,
    required String password,
    required bool photoConsent,
  });
}
