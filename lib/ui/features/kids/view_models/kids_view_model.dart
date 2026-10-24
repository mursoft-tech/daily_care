import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/result.dart';
import '../../../../domain/models/child.dart';
import '../../../../domain/use_cases/filter_children.dart';

class KidsState {
  const KidsState({required this.all, this.query = ''});

  final List<Child> all;
  final String query;

  List<Child> get visible => filterChildren(all, query);

  KidsState withQuery(String value) => KidsState(all: all, query: value);
}

class KidsViewModel extends AsyncNotifier<KidsState> {
  @override
  Future<KidsState> build() async {
    final result = await ref.watch(kidsRepositoryProvider).loadChildren();
    return switch (result) {
      Success(:final value) => KidsState(all: value),
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
