import 'package:daily_care/app/providers.dart';
import 'package:daily_care/core/result.dart';
import 'package:daily_care/domain/models/child.dart';
import 'package:daily_care/domain/models/guardian.dart';
import 'package:daily_care/domain/models/post.dart';
import 'package:daily_care/domain/repositories/feed_repository.dart';
import 'package:daily_care/domain/repositories/kids_repository.dart';
import 'package:daily_care/domain/use_cases/create_post.dart';
import 'package:daily_care/domain/value_objects/post_draft.dart';
import 'package:daily_care/ui/features/feed/view_models/create_post_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeFeedRepository implements FeedRepository {
  _FakeFeedRepository({this.saveFailure});

  final AppFailure? saveFailure;
  final List<Post> saved = <Post>[];

  @override
  Future<Result<List<Post>>> loadPosts() async => Success(List.of(saved));

  @override
  Future<Result<Post>> createPost(Post post) async {
    final failure = saveFailure;
    if (failure != null) return Failure(failure);
    saved.add(post);
    return Success(post);
  }
}

class _FakeKidsRepository implements KidsRepository {
  @override
  Future<Result<List<Child>>> loadChildren() async => const Success(<Child>[]);

  @override
  Future<Result<Child?>> loadChild(String id) async => const Success(null);

  @override
  Future<Result<Child>> addChild(Child child) async => Success(child);

  @override
  Future<Result<Guardian>> linkGuardian({
    required String childId,
    required String fullName,
    required String email,
    required GuardianRelationship relationship,
    required String invitationCode,
  }) async {
    throw UnimplementedError();
  }
}

ProviderContainer _container(_FakeFeedRepository feed) {
  return ProviderContainer.test(
    overrides: [
      feedRepositoryProvider.overrideWithValue(feed),
      kidsRepositoryProvider.overrideWithValue(_FakeKidsRepository()),
      todayProvider.overrideWithValue(() => DateTime(2026, 11, 1, 9, 5)),
    ],
  );
}

void main() {
  test('rejects an empty description', () async {
    final container = _container(_FakeFeedRepository());

    final post = await container
        .read(createPostViewModelProvider.notifier)
        .submit(const PostDraft(body: '  '));

    final state = container.read(createPostViewModelProvider);
    expect(post, isNull);
    expect(state.saved, isFalse);
    expect(state.isSaving, isFalse);
    expect(state.hasError(PostDraftError.bodyRequired), isTrue);
  });

  test('publishes a room post and exposes it in the state', () async {
    final feed = _FakeFeedRepository();
    final container = _container(feed);

    final post = await container
        .read(createPostViewModelProvider.notifier)
        .submit(const PostDraft(body: 'Almorzaron guiso'));

    final state = container.read(createPostViewModelProvider);
    expect(post, isNotNull);
    expect(state.saved, isTrue);
    expect(state.publishedPost, same(post));
    expect(feed.saved, hasLength(1));
  });

  test('maps a save failure to a generic error', () async {
    final container = _container(
      _FakeFeedRepository(saveFailure: const DataFailure()),
    );

    await container
        .read(createPostViewModelProvider.notifier)
        .submit(const PostDraft(body: 'Hola'));

    final state = container.read(createPostViewModelProvider);
    expect(state.hasError(PostDraftError.saveFailed), isTrue);
    expect(state.saved, isFalse);
  });

  test('clearErrors and reset restore an empty state', () async {
    final container = _container(_FakeFeedRepository());
    final notifier = container.read(createPostViewModelProvider.notifier);

    await notifier.submit(const PostDraft());
    expect(
      container.read(createPostViewModelProvider).errors,
      isNotEmpty,
    );

    notifier.clearErrors();
    expect(container.read(createPostViewModelProvider).errors, isEmpty);

    notifier.reset();
    expect(container.read(createPostViewModelProvider).isSaving, isFalse);
    expect(container.read(createPostViewModelProvider).saved, isFalse);
  });
}
