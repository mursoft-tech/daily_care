import '../../core/formatters/app_date_formatter.dart';
import '../../core/result.dart';
import '../models/child.dart';
import '../models/post.dart';
import '../models/post_audience.dart';
import '../repositories/feed_repository.dart';
import '../repositories/kids_repository.dart';
import '../value_objects/post_draft.dart';

enum PostDraftError { bodyRequired, recipientRequired, saveFailed }

sealed class CreatePostResult {
  const CreatePostResult();
}

final class PostCreated extends CreatePostResult {
  const PostCreated(this.post);

  final Post post;
}

final class PostRejected extends CreatePostResult {
  const PostRejected(this.errors);

  final List<PostDraftError> errors;
}

/// La publicación no pudo completarse por un fallo de datos, no de validación.
final class PostFailed extends CreatePostResult {
  const PostFailed();
}

class CreatePost {
  const CreatePost(this._feedRepository, this._kidsRepository, this._now);

  static const roomAuthor = 'Toda la sala';

  final FeedRepository _feedRepository;
  final KidsRepository _kidsRepository;
  final DateTime Function() _now;

  Future<CreatePostResult> execute(PostDraft draft) async {
    final errors = _validate(draft);
    if (errors.isNotEmpty) return PostRejected(errors);

    final children = <Child>[];
    for (final id in _normalizedChildIds(draft.childIds)) {
      final child = await _resolveChild(id);
      if (child == null) return const PostFailed();
      children.add(child);
    }

    final first = children.isEmpty ? null : children.first;
    final now = _now();
    final post = Post(
      id: 'post-${now.microsecondsSinceEpoch}',
      childName: first?.firstName ?? roomAuthor,
      childInitial: first?.initial,
      childColorToken: first?.colorToken ?? 'announcement',
      recipientNames: [for (final child in children) child.firstName],
      timeLabel: formatPostTime(now),
      audience: children.isEmpty ? PostAudience.room : PostAudience.family,
      type: draft.type,
      body: draft.trimmedBody,
      likes: 0,
      comments: 0,
    );

    final saved = await _feedRepository.createPost(post);
    return switch (saved) {
      Success(:final value) => PostCreated(value),
      Failure() => const PostFailed(),
    };
  }

  List<PostDraftError> _validate(PostDraft draft) {
    final errors = <PostDraftError>[];

    if (draft.trimmedBody.isEmpty) {
      errors.add(PostDraftError.bodyRequired);
    }
    if (draft.childIds.any((id) => id.trim().isEmpty)) {
      errors.add(PostDraftError.recipientRequired);
    }

    return errors;
  }

  List<String> _normalizedChildIds(List<String> childIds) {
    final unique = <String>[];
    for (final id in childIds) {
      final trimmed = id.trim();
      if (!unique.contains(trimmed)) unique.add(trimmed);
    }
    return unique;
  }

  Future<Child?> _resolveChild(String childId) async {
    final loaded = await _kidsRepository.loadChild(childId);
    return switch (loaded) {
      Success(:final value) => value,
      Failure() => null,
    };
  }
}
