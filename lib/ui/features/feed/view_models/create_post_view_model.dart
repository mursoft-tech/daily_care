import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../domain/models/post.dart';
import '../../../../domain/use_cases/create_post.dart';
import '../../../../domain/value_objects/post_draft.dart';

class CreatePostState {
  const CreatePostState({
    this.isSaving = false,
    this.errors = const [],
    this.publishedPost,
  });

  final bool isSaving;
  final List<PostDraftError> errors;
  final Post? publishedPost;

  bool get saved => publishedPost != null;

  bool hasError(PostDraftError error) => errors.contains(error);

  CreatePostState copyWith({
    bool? isSaving,
    List<PostDraftError>? errors,
    Post? publishedPost,
  }) {
    return CreatePostState(
      isSaving: isSaving ?? this.isSaving,
      errors: errors ?? this.errors,
      publishedPost: publishedPost ?? this.publishedPost,
    );
  }
}

class CreatePostViewModel extends Notifier<CreatePostState> {
  @override
  CreatePostState build() => const CreatePostState();

  void reset() => state = const CreatePostState();

  void clearErrors() {
    if (state.errors.isNotEmpty) state = state.copyWith(errors: const []);
  }

  Future<Post?> submit(PostDraft draft) async {
    if (state.isSaving) return null;

    state = state.copyWith(isSaving: true, errors: const []);
    final result = await ref.read(createPostUseCaseProvider).execute(draft);

    state = switch (result) {
      PostCreated(:final post) => CreatePostState(publishedPost: post),
      PostRejected(:final errors) => CreatePostState(errors: errors),
      PostFailed() => const CreatePostState(
        errors: [PostDraftError.saveFailed],
      ),
    };

    return state.publishedPost;
  }
}

final createPostViewModelProvider =
    NotifierProvider<CreatePostViewModel, CreatePostState>(
      CreatePostViewModel.new,
    );
