import '../../core/result.dart';
import '../models/account_invitation.dart';

/// Contrato para resolver invitaciones y activar cuentas familiares.
abstract class AccountActivationRepository {
  /// Devuelve `null` cuando el código no corresponde a ninguna invitación.
  Future<Result<AccountInvitation?>> loadInvitation(String code);

  Future<Result<void>> activate({
    required AccountInvitation invitation,
    required String password,
    required bool photoConsent,
  });
}
