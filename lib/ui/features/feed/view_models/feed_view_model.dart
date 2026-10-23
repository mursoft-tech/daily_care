import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/result.dart';
import '../../../../domain/models/post.dart';

class FeedViewModel extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() => _load();

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<List<Post>> _load() async {
    final result = await ref.read(feedRepositoryProvider).loadPosts();
    return switch (result) {
      Success(:final value) => value,
      Failure(:final failure) => throw failure,
    };
  }
}

final feedViewModelProvider = AsyncNotifierProvider<FeedViewModel, List<Post>>(
  FeedViewModel.new,
  retry: (_, _) => null,
);
