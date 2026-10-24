import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/result.dart';
import '../../../../domain/models/child.dart';
import '../../../../domain/use_cases/calculate_age.dart';
import '../../../../domain/use_cases/filter_children.dart';

class KidsState {
  const KidsState({
    required this.all,
    required this.today,
    this.query = '',
  });

  final List<Child> all;
  final DateTime today;
  final String query;

  List<Child> get visible => filterChildren(all, query);

  int ageOf(Child child) => calculateAge(child.birthDate, today);

  KidsState withQuery(String value) =>
      KidsState(all: all, today: today, query: value);
}

class KidsViewModel extends AsyncNotifier<KidsState> {
  @override
  Future<KidsState> build() async {
    final today = ref.watch(todayProvider)();
    final result = await ref.watch(kidsRepositoryProvider).loadChildren();
    return switch (result) {
      Success(:final value) => KidsState(all: value, today: today),
      Failure(:final failure) => throw failure,
    };
  }

  void search(String query) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.withQuery(query));
  }

  void retry() => ref.invalidateSelf();
}

final kidsViewModelProvider = AsyncNotifierProvider<KidsViewModel, KidsState>(
  KidsViewModel.new,
  retry: (_, _) => null,
);
