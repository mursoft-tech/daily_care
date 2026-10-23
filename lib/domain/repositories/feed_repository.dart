import '../../core/result.dart';
import '../models/post.dart';

abstract class FeedRepository {
  Future<Result<List<Post>>> loadPosts();
}
