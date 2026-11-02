import 'package:daily_care/core/result.dart';
import 'package:daily_care/data/datasources/feed_data_source.dart';
import 'package:daily_care/data/datasources/local/demo_feed_datasource.dart';
import 'package:daily_care/data/repositories/feed_repository_impl.dart';
import 'package:daily_care/domain/models/post.dart';
import 'package:daily_care/domain/models/post_audience.dart';
import 'package:daily_care/domain/models/post_type.dart';
import 'package:flutter_test/flutter_test.dart';

class _FailingDataSource implements FeedDataSource {
  @override
  Future<List<Post>> fetchPosts() async => throw Exception('boom');

  @override
  Future<void> addPost(Post post) async => throw Exception('boom');
}

Post _newPost() => const Post(
  id: 'post-new',
  childName: 'Toda la sala',
  childInitial: null,
  childColorToken: 'announcement',
  timeLabel: '09:05',
  audience: PostAudience.room,
  type: PostType.food,
  body: 'Almorzaron guiso',
  likes: 0,
  comments: 0,
);

void main() {
  group('FeedRepositoryImpl', () {
    test('returns Success with the demo posts', () async {
      final repository = FeedRepositoryImpl(DemoFeedDataSource());

      final result = await repository.loadPosts();

      expect(result, isA<Success<List<Post>>>());
      final posts = (result as Success<List<Post>>).value;
      expect(posts, hasLength(3));
      expect(posts.first.childName, 'Mateo');
    });

    test('returns Failure when the data source fails', () async {
      final repository = FeedRepositoryImpl(_FailingDataSource());

      final result = await repository.loadPosts();

      expect(result, isA<Failure<List<Post>>>());
      expect((result as Failure<List<Post>>).failure, isA<DataFailure>());
    });

    test('creates a post and lists it first', () async {
      final repository = FeedRepositoryImpl(DemoFeedDataSource());
      final post = _newPost();

      final created = await repository.createPost(post);
      final loaded = await repository.loadPosts();

      expect(created, isA<Success<Post>>());
      expect((created as Success<Post>).value, same(post));
      final posts = (loaded as Success<List<Post>>).value;
      expect(posts.first.id, post.id);
      expect(posts, hasLength(4));
    });

    test('returns Failure when creating a post fails', () async {
      final repository = FeedRepositoryImpl(_FailingDataSource());

      final result = await repository.createPost(_newPost());

      expect(result, isA<Failure<Post>>());
      expect((result as Failure<Post>).failure, isA<DataFailure>());
    });
  });
}
