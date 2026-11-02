import 'package:daily_care/core/result.dart';
import 'package:daily_care/domain/models/child.dart';
import 'package:daily_care/domain/models/guardian.dart';
import 'package:daily_care/domain/models/post.dart';
import 'package:daily_care/domain/models/post_audience.dart';
import 'package:daily_care/domain/models/post_type.dart';
import 'package:daily_care/domain/repositories/feed_repository.dart';
import 'package:daily_care/domain/repositories/kids_repository.dart';
import 'package:daily_care/domain/use_cases/create_post.dart';
import 'package:daily_care/domain/value_objects/post_draft.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeFeedRepository implements FeedRepository {
  _FakeFeedRepository({this.saveFailure});

  final AppFailure? saveFailure;
  final List<Post> saved = <Post>[];

  @override
  Future<Result<List<Post>>> loadPosts() async => const Success(<Post>[]);

  @override
  Future<Result<Post>> createPost(Post post) async {
    final failure = saveFailure;
    if (failure != null) return Failure(failure);
    saved.add(post);
    return Success(post);
  }
}

class _FakeKidsRepository implements KidsRepository {
  const _FakeKidsRepository({this.children = const [], this.loadFailure});

  final List<Child> children;
  final AppFailure? loadFailure;

  @override
  Future<Result<List<Child>>> loadChildren() async => Success(children);

  @override
  Future<Result<Child?>> loadChild(String id) async {
    final failure = loadFailure;
    if (failure != null) return Failure(failure);
    for (final child in children) {
      if (child.id == id) return Success(child);
    }
    return const Success(null);
  }

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

DateTime _now() => DateTime(2026, 11, 1, 9, 5);

Child _mateo() => Child(
  id: 'mateo-fernandez',
  firstName: 'Mateo',
  lastName: 'Fernández',
  birthDate: DateTime(2023, 3, 12),
  room: 'Soles',
  enrolledAt: DateTime(2025, 2),
  colorToken: 'blue',
);

Child _sofia() => Child(
  id: 'sofia-mendez',
  firstName: 'Sofía',
  lastName: 'Méndez',
  birthDate: DateTime(2024, 5, 9),
  room: 'Soles',
  enrolledAt: DateTime(2025, 2),
  colorToken: 'pink',
);

CreatePost _useCase({
  _FakeFeedRepository? feed,
  _FakeKidsRepository? kids,
}) {
  return CreatePost(
    feed ?? _FakeFeedRepository(),
    kids ?? const _FakeKidsRepository(),
    _now,
  );
}

void main() {
  group('CreatePost', () {
    test('creates a room post with the current time and zero counters', () async {
      final feed = _FakeFeedRepository();

      final result = await _useCase(feed: feed).execute(
        const PostDraft(type: PostType.food, body: '  Almorzaron guiso  '),
      );

      expect(result, isA<PostCreated>());
      final post = (result as PostCreated).post;
      expect(post.id, 'post-${_now().microsecondsSinceEpoch}');
      expect(post.childName, 'Toda la sala');
      expect(post.childInitial, isNull);
      expect(post.childColorToken, 'announcement');
      expect(post.recipientNames, isEmpty);
      expect(post.timeLabel, '09:05');
      expect(post.audience, PostAudience.room);
      expect(post.type, PostType.food);
      expect(post.body, 'Almorzaron guiso');
      expect(post.likes, 0);
      expect(post.comments, 0);
      expect(post.photoLabel, isNull);
      expect(feed.saved, hasLength(1));
    });

    test('creates a family post from a single child snapshot', () async {
      final feed = _FakeFeedRepository();

      final result = await _useCase(
        feed: feed,
        kids: _FakeKidsRepository(children: [_mateo(), _sofia()]),
      ).execute(
        const PostDraft(
          childIds: ['mateo-fernandez'],
          type: PostType.achievement,
          body: 'Usó el orinal solito',
        ),
      );

      expect(result, isA<PostCreated>());
      final post = (result as PostCreated).post;
      expect(post.childName, 'Mateo');
      expect(post.childInitial, 'M');
      expect(post.childColorToken, 'blue');
      expect(post.recipientNames, ['Mateo']);
      expect(post.audience, PostAudience.family);
    });

    test('creates one post addressed to several children', () async {
      final feed = _FakeFeedRepository();

      final result = await _useCase(
        feed: feed,
        kids: _FakeKidsRepository(children: [_mateo(), _sofia()]),
      ).execute(
        const PostDraft(
          childIds: ['mateo-fernandez', 'sofia-mendez'],
          body: 'Pintamos juntos',
        ),
      );

      expect(result, isA<PostCreated>());
      final post = (result as PostCreated).post;
      expect(post.childName, 'Mateo');
      expect(post.childInitial, 'M');
      expect(post.childColorToken, 'blue');
      expect(post.recipientNames, ['Mateo', 'Sofía']);
      expect(post.audience, PostAudience.family);
      expect(feed.saved, hasLength(1));
    });

    test('deduplicates repeated child ids preserving order', () async {
      final result = await _useCase(
        kids: _FakeKidsRepository(children: [_mateo(), _sofia()]),
      ).execute(
        const PostDraft(
          childIds: ['mateo-fernandez', 'sofia-mendez', 'mateo-fernandez'],
          body: 'Hola',
        ),
      );

      expect(
        (result as PostCreated).post.recipientNames,
        ['Mateo', 'Sofía'],
      );
    });

    test('rejects an empty description without saving', () async {
      final feed = _FakeFeedRepository();

      final result = await _useCase(feed: feed).execute(
        const PostDraft(body: '   '),
      );

      expect(result, isA<PostRejected>());
      expect(
        (result as PostRejected).errors,
        contains(PostDraftError.bodyRequired),
      );
      expect(feed.saved, isEmpty);
    });

    test('rejects an empty child id as a missing recipient', () async {
      final result = await _useCase().execute(
        const PostDraft(childIds: [''], body: 'Hola'),
      );

      expect(result, isA<PostRejected>());
      expect(
        (result as PostRejected).errors,
        contains(PostDraftError.recipientRequired),
      );
    });

    test('fails when any selected child does not exist', () async {
      final feed = _FakeFeedRepository();

      final result = await _useCase(
        feed: feed,
        kids: _FakeKidsRepository(children: [_mateo()]),
      ).execute(
        const PostDraft(
          childIds: ['mateo-fernandez', 'missing'],
          body: 'Hola',
        ),
      );

      expect(result, isA<PostFailed>());
      expect(feed.saved, isEmpty);
    });

    test('fails when loading the children fails', () async {
      final feed = _FakeFeedRepository();

      final result = await _useCase(
        feed: feed,
        kids: _FakeKidsRepository(loadFailure: const DataFailure()),
      ).execute(
        const PostDraft(childIds: ['mateo-fernandez'], body: 'Hola'),
      );

      expect(result, isA<PostFailed>());
      expect(feed.saved, isEmpty);
    });

    test('fails when saving the post fails', () async {
      final result = await _useCase(
        feed: _FakeFeedRepository(saveFailure: const DataFailure()),
      ).execute(const PostDraft(body: 'Hola'));

      expect(result, isA<PostFailed>());
    });
  });
}
