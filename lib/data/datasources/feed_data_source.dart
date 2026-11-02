import '../../domain/models/post.dart';

abstract interface class FeedDataSource {
  Future<List<Post>> fetchPosts();

  Future<void> addPost(Post post);
}
