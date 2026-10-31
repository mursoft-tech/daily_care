import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../domain/models/child.dart';
import '../../../../domain/use_cases/create_child.dart';
import '../../../../domain/value_objects/child_draft.dart';

class NewChildState {
  const NewChildState({
    this.isSaving = false,
    this.errors = const [],
    this.savedChild,
  });

  final bool isSaving;
  final List<RegistrationError> errors;
  final Child? savedChild;

  bool get saved => savedChild != null;

  bool hasError(RegistrationError error) => errors.contains(error);

  NewChildState copyWith({
    bool? isSaving,
    List<RegistrationError>? errors,
    Child? savedChild,
  }) {
    return NewChildState(
      isSaving: isSaving ?? this.isSaving,
      errors: errors ?? this.errors,
      savedChild: savedChild ?? this.savedChild,
    );
  }
}

class NewChildViewModel extends Notifier<NewChildState> {
  @override
  NewChildState build() => const NewChildState();

  void reset() => state = const NewChildState();

  void clearErrors() {
    if (state.errors.isNotEmpty) state = state.copyWith(errors: const []);
  }

  Future<Child?> submit(ChildDraft draft) async {
    if (state.isSaving) return null;

    state = state.copyWith(isSaving: true, errors: const []);
    final result = await ref.read(createChildUseCaseProvider).execute(draft);

    state = switch (result) {
      ChildCreated(:final child) => NewChildState(savedChild: child),
      ChildRejected(:final errors) => NewChildState(errors: errors),
      ChildFailed() => const NewChildState(
        errors: [RegistrationError.saveFailed],
      ),
    };

    return state.savedChild;
  }
}

final newChildViewModelProvider =
    NotifierProvider<NewChildViewModel, NewChildState>(NewChildViewModel.new);
