import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/result.dart';
import '../../../../domain/models/child.dart';
import '../../../../domain/models/guardian.dart';

class LinkParentFormState {
  const LinkParentFormState({
    required this.child,
    this.name = '',
    this.email = '',
    this.relationship = GuardianRelationship.mother,
    required this.invitationCode,
    this.nameError,
    this.emailError,
    this.isSubmitting = false,
    this.submitFailed = false,
  });

  final Child child;
  final String name;
  final String email;
  final GuardianRelationship relationship;
  final String invitationCode;
  final String? nameError;
  final String? emailError;
  final bool isSubmitting;
  final bool submitFailed;

  bool get isValid => name.trim().isNotEmpty && _isEmailValid(email);

  static bool _isEmailValid(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());
  }

  LinkParentFormState copyWith({
    Child? child,
    String? name,
    String? email,
    GuardianRelationship? relationship,
    String? invitationCode,
    String? Function()? nameError,
    String? Function()? emailError,
    bool? isSubmitting,
    bool? submitFailed,
  }) {
    return LinkParentFormState(
      child: child ?? this.child,
      name: name ?? this.name,
      email: email ?? this.email,
      relationship: relationship ?? this.relationship,
      invitationCode: invitationCode ?? this.invitationCode,
      nameError: nameError != null ? nameError() : this.nameError,
      emailError: emailError != null ? emailError() : this.emailError,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitFailed: submitFailed ?? this.submitFailed,
    );
  }
}

class LinkParentViewModel extends AsyncNotifier<LinkParentFormState> {
  LinkParentViewModel(this.childId);

  final String childId;

  @override
  Future<LinkParentFormState> build() async {
    final result = await ref.watch(kidsRepositoryProvider).loadChild(childId);
    return switch (result) {
      Success(:final value) => value != null
          ? _buildForm(value)
          : throw Exception('Child not found'),
      Failure(:final failure) => throw failure,
    };
  }

  LinkParentFormState _buildForm(Child child) {
    final reservedCodes = child.guardians
        .where((guardian) => guardian.status == GuardianStatus.invited)
        .map((guardian) => guardian.invitationCode);
    final invitationCode = ref
        .watch(generateInvitationCodeProvider)
        .execute(reservedCodes: reservedCodes);
    return LinkParentFormState(child: child, invitationCode: invitationCode);
  }

  void setName(String value) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        name: value,
        nameError: () => null,
        submitFailed: false,
      ),
    );
  }

  void setEmail(String value) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        email: value,
        emailError: () => null,
        submitFailed: false,
      ),
    );
  }

  void setRelationship(GuardianRelationship relationship) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        relationship: relationship,
        submitFailed: false,
      ),
    );
  }

  Future<bool> submit() async {
    final current = state.asData?.value;
    if (current == null || current.isSubmitting) return false;

    String? nameError;
    String? emailError;

    if (current.name.trim().isEmpty) {
      nameError = 'required';
    }

    if (current.email.trim().isEmpty) {
      emailError = 'required';
    } else if (!LinkParentFormState._isEmailValid(current.email)) {
      emailError = 'invalid';
    }

    if (nameError != null || emailError != null) {
      state = AsyncData(
        current.copyWith(
          nameError: () => nameError,
          emailError: () => emailError,
        ),
      );
      return false;
    }

    state = AsyncData(current.copyWith(isSubmitting: true, submitFailed: false));

    final result = await ref.read(kidsRepositoryProvider).linkGuardian(
          childId: current.child.id,
          fullName: current.name.trim(),
          email: current.email.trim(),
          relationship: current.relationship,
          invitationCode: current.invitationCode,
        );

    return switch (result) {
      Success() => () {
          state = AsyncData(current.copyWith(isSubmitting: false));
          return true;
        }(),
      Failure(:final failure) => () {
          final alreadyLinked = failure is GuardianAlreadyLinkedFailure;
          state = AsyncData(
            current.copyWith(
              isSubmitting: false,
              submitFailed: !alreadyLinked,
              emailError: alreadyLinked ? () => 'alreadyLinked' : null,
            ),
          );
          return false;
        }(),
    };
  }
}

final linkParentViewModelProvider = AsyncNotifierProvider.autoDispose.family<
    LinkParentViewModel,
    LinkParentFormState,
    String>(LinkParentViewModel.new);
