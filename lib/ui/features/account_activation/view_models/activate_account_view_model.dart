import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/result.dart';
import '../../../../domain/models/account_invitation.dart';
import '../../../../domain/use_cases/activate_account.dart';

class ActivateAccountState {
  const ActivateAccountState({
    required this.invitation,
    required this.code,
    required this.email,
    this.password = '',
    this.photoConsent = false,
    this.isSubmitting = false,
    this.errorType,
    this.submitFailed = false,
    this.isActivated = false,
  });

  final AccountInvitation? invitation;
  final String code;
  final String email;
  final String password;
  final bool photoConsent;
  final bool isSubmitting;
  final ActivationError? errorType;
  final bool submitFailed;
  final bool isActivated;

  ActivateAccountState copyWith({
    AccountInvitation? invitation,
    String? code,
    String? email,
    String? password,
    bool? photoConsent,
    bool? isSubmitting,
    ActivationError? errorType,
    bool clearError = false,
    bool? submitFailed,
    bool? isActivated,
  }) {
    return ActivateAccountState(
      invitation: invitation ?? this.invitation,
      code: code ?? this.code,
      email: email ?? this.email,
      password: password ?? this.password,
      photoConsent: photoConsent ?? this.photoConsent,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorType: clearError ? null : errorType ?? this.errorType,
      submitFailed: submitFailed ?? this.submitFailed,
      isActivated: isActivated ?? this.isActivated,
    );
  }
}

class ActivateAccountViewModel extends AsyncNotifier<ActivateAccountState> {
  ActivateAccountViewModel(this.requestedCode);

  final String requestedCode;

  @override
  Future<ActivateAccountState> build() async {
    final result = await ref
        .watch(accountActivationRepositoryProvider)
        .loadInvitation(requestedCode);

    return switch (result) {
      Success(:final value) => ActivateAccountState(
        invitation: value,
        code: requestedCode,
        email: value?.email ?? '',
      ),
      Failure(:final failure) => throw failure,
    };
  }

  void setCode(String code) => _update((state) => state.copyWith(
    code: code,
    clearError: true,
    submitFailed: false,
  ));

  void setEmail(String email) => _update((state) => state.copyWith(
    email: email,
    clearError: true,
    submitFailed: false,
  ));

  void setPassword(String password) => _update((state) => state.copyWith(
    password: password,
    clearError: true,
    submitFailed: false,
  ));

  void setPhotoConsent(bool value) => _update((state) => state.copyWith(
    photoConsent: value,
    clearError: true,
    submitFailed: false,
  ));

  Future<bool> submit() async {
    final current = state.value;
    if (current == null || current.isSubmitting) return false;

    state = AsyncData(
      current.copyWith(isSubmitting: true, clearError: true, submitFailed: false),
    );

    final result = await ref.read(activateAccountUseCaseProvider).execute(
      invitation: current.invitation,
      code: current.code,
      email: current.email,
      password: current.password,
      photoConsent: current.photoConsent,
    );

    final updated = switch (result) {
      ActivationAccepted() => current.copyWith(
        isSubmitting: false,
        isActivated: true,
      ),
      ActivationRejected(:final error) => current.copyWith(
        isSubmitting: false,
        errorType: error,
      ),
      ActivationFailed() => current.copyWith(
        isSubmitting: false,
        submitFailed: true,
      ),
    };

    state = AsyncData(updated);
    return result is ActivationAccepted;
  }

  void retry() => ref.invalidateSelf();

  void _update(
    ActivateAccountState Function(ActivateAccountState state) transform,
  ) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(transform(current));
  }
}

final activateAccountViewModelProvider =
    AsyncNotifierProvider.family<
      ActivateAccountViewModel,
      ActivateAccountState,
      String
    >(ActivateAccountViewModel.new, retry: (_, _) => null);
