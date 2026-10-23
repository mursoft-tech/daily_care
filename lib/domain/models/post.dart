import 'post_audience.dart';
import 'post_type.dart';

class Post {
  const Post({
    required this.id,
    required this.childName,
    required this.childInitial,
    required this.childColorToken,
    required this.timeLabel,
    required this.audience,
    required this.type,
    required this.body,
    required this.likes,
    required this.comments,
    this.photoLabel,
  });

  final String id;
  final String childName;
  final String? childInitial;
  final String childColorToken;
  final String timeLabel;
  final PostAudience audience;
  final PostType type;
  final String body;
  final int likes;
  final int comments;
  final String? photoLabel;

  bool get hasPhoto => photoLabel != null;
}
