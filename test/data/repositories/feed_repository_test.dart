import 'package:daily_care/core/result.dart';
import 'package:daily_care/data/datasources/feed_data_source.dart';
import 'package:daily_care/data/datasources/local/demo_feed_datasource.dart';
import 'package:daily_care/data/repositories/feed_repository_impl.dart';
import 'package:daily_care/domain/models/post.dart';
import 'package:flutter_test/flutter_test.dart';

class _FailingDataSource implements FeedDataSource {
  @override
  Future<List<Post>> fetchPosts() async => throw Exception('boom');
}

void main() {
  group('FeedRepositoryImpl', () {
    test('returns Success with the demo posts', () async {
      final repository = FeedRepositoryImpl(const DemoFeedDataSource());

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
  });
}
