import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/result.dart';
import '../../../../domain/models/post.dart';

class FeedViewModel extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final result = await ref.watch(feedRepositoryProvider).loadPosts();
    return switch (result) {
      Success(:final value) => value,
      Failure(:final failure) => throw failure,
    };
  }

  void retry() => ref.invalidateSelf();
}

final feedViewModelProvider = AsyncNotifierProvider<FeedViewModel, List<Post>>(
  FeedViewModel.new,
  retry: (_, _) => null,
);
