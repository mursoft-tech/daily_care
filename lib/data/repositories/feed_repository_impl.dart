import '../../core/result.dart';
import '../../domain/models/post.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_data_source.dart';

class FeedRepositoryImpl implements FeedRepository {
  const FeedRepositoryImpl(this._dataSource);

  final FeedDataSource _dataSource;

  @override
  Future<Result<List<Post>>> loadPosts() async {
    try {
      return Success(await _dataSource.fetchPosts());
    } on Exception {
      return const Failure(DataFailure());
    } catch (_) {
      return const Failure(UnexpectedFailure());
    }
  }
}
