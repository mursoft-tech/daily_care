import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/result.dart';
import '../../../../domain/models/child.dart';
import '../../../../domain/use_cases/calculate_age.dart';

class ChildProfileState {
  const ChildProfileState.notFound() : child = null, ageYears = null;

  const ChildProfileState.found({
    required this.child,
    required this.ageYears,
  });

  final Child? child;
  final int? ageYears;

  bool get notFound => child == null;
}

class ChildProfileViewModel extends AsyncNotifier<ChildProfileState> {
  ChildProfileViewModel(this.childId);

  final String childId;

  @override
  Future<ChildProfileState> build() async {
    final result = await ref.watch(kidsRepositoryProvider).loadChild(childId);
    return switch (result) {
      Success(:final value) => _stateFor(value),
      Failure(:final failure) => throw failure,
    };
  }

  ChildProfileState _stateFor(Child? child) {
    if (child == null) return const ChildProfileState.notFound();

    final today = ref.read(todayProvider)();
    return ChildProfileState.found(
      child: child,
      ageYears: calculateAge(child.birthDate, today),
    );
  }

  void retry() => ref.invalidateSelf();
}

final childProfileViewModelProvider =
    AsyncNotifierProvider.family<
      ChildProfileViewModel,
      ChildProfileState,
      String
    >(ChildProfileViewModel.new, retry: (_, _) => null);
