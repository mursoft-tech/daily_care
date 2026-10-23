import '../../../domain/models/post.dart';
import '../../../domain/models/post_audience.dart';
import '../../../domain/models/post_type.dart';
import '../feed_data_source.dart';

class DemoFeedDataSource implements FeedDataSource {
  const DemoFeedDataSource();

  static const _posts = <Post>[
    Post(
      id: 'achievement-1',
      childName: 'Mateo',
      childInitial: 'M',
      childColorToken: 'blue',
      timeLabel: '14:20',
      audience: PostAudience.family,
      type: PostType.achievement,
      body:
          '¡Usó el orinal solito por primera vez! Estaba feliz de contárselo a '
          'todos. Un gran paso.',
      likes: 3,
      comments: 1,
    ),
    Post(
      id: 'activity-1',
      childName: 'Mateo',
      childInitial: 'M',
      childColorToken: 'blue',
      timeLabel: '09:40',
      audience: PostAudience.family,
      type: PostType.activity,
      body:
          'Pintamos con témperas esta mañana. Mateo eligió el azul para todo y '
          'se concentró un montón mezclando colores.',
      likes: 5,
      comments: 2,
      photoLabel: 'pintando con témperas',
    ),
    Post(
      id: 'announcement-1',
      childName: 'Anuncio general',
      childInitial: null,
      childColorToken: 'announcement',
      timeLabel: '07:50',
      audience: PostAudience.room,
      type: PostType.announcement,
      body:
          'El viernes salimos al parque por la mañana. Recuerden mandar gorra y '
          'una botellita de agua.',
      likes: 8,
      comments: 0,
    ),
  ];

  @override
  Future<List<Post>> fetchPosts() async => _posts;
}
