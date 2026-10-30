import '../../core/result.dart';
import '../models/account_invitation.dart';
import '../repositories/account_activation_repository.dart';

enum ActivationError {
  invalidCode,
  invalidEmail,
  emailMismatch,
  emptyPassword,
  weakPassword,
  consentRequired,
}

sealed class ActivationResult {
  const ActivationResult();
}

final class ActivationAccepted extends ActivationResult {
  const ActivationAccepted();
}

final class ActivationRejected extends ActivationResult {
  const ActivationRejected(this.error);

  final ActivationError error;
}

/// La activación no pudo completarse por un fallo de datos, no de validación.
final class ActivationFailed extends ActivationResult {
  const ActivationFailed();
}

class ActivateAccount {
  const ActivateAccount(this._repository);

  static const minPasswordLength = 8;
  static final RegExp _emailRegExp = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');

  final AccountActivationRepository _repository;

  Future<ActivationResult> execute({
    required AccountInvitation? invitation,
    required String code,
    required String email,
    required String password,
    required bool photoConsent,
  }) async {
    final trimmedCode = code.trim().toUpperCase();
    if (invitation == null || invitation.code != trimmedCode) {
      return const ActivationRejected(ActivationError.invalidCode);
    }

    final trimmedEmail = email.trim();
    if (!_emailRegExp.hasMatch(trimmedEmail)) {
      return const ActivationRejected(ActivationError.invalidEmail);
    }

    if (trimmedEmail.toLowerCase() != invitation.email.toLowerCase()) {
      return const ActivationRejected(ActivationError.emailMismatch);
    }

    if (password.isEmpty) {
      return const ActivationRejected(ActivationError.emptyPassword);
    }

    if (password.length < minPasswordLength) {
      return const ActivationRejected(ActivationError.weakPassword);
    }

    if (!photoConsent) {
      return const ActivationRejected(ActivationError.consentRequired);
    }

    final result = await _repository.activate(
      invitation: invitation,
      password: password,
      photoConsent: photoConsent,
    );

    return switch (result) {
      Success() => const ActivationAccepted(),
      Failure() => const ActivationFailed(),
    };
  }
}
