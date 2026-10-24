import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/feed_data_source.dart';
import '../data/datasources/kids_data_source.dart';
import '../data/datasources/local/demo_feed_datasource.dart';
import '../data/datasources/local/demo_kids_data_source.dart';
import '../data/repositories/feed_repository_impl.dart';
import '../data/repositories/kids_repository_impl.dart';
import '../domain/models/session_user.dart';
import '../domain/repositories/feed_repository.dart';
import '../domain/repositories/kids_repository.dart';

final sessionUserProvider = Provider<SessionUser>(
  (ref) => const SessionUser.demo(),
);

final feedDataSourceProvider = Provider<FeedDataSource>(
  (ref) => const DemoFeedDataSource(),
);

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepositoryImpl(ref.watch(feedDataSourceProvider));
});

final kidsDataSourceProvider = Provider<KidsDataSource>(
  (ref) => const DemoKidsDataSource(),
);

final kidsRepositoryProvider = Provider<KidsRepository>((ref) {
  return KidsRepositoryImpl(ref.watch(kidsDataSourceProvider));
});
