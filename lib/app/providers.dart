import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/feed_data_source.dart';
import '../data/datasources/local/demo_feed_datasource.dart';
import '../data/repositories/feed_repository_impl.dart';
import '../domain/repositories/feed_repository.dart';

final feedDataSourceProvider = Provider<FeedDataSource>(
  (ref) => const DemoFeedDataSource(),
);

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepositoryImpl(ref.watch(feedDataSourceProvider));
});
