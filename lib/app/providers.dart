import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/account_activation_data_source.dart';
import '../data/datasources/feed_data_source.dart';
import '../data/datasources/kids_data_source.dart';
import '../data/datasources/local/demo_account_activation_data_source.dart';
import '../data/datasources/local/demo_feed_datasource.dart';
import '../data/datasources/local/demo_kids_data_source.dart';
import '../data/repositories/account_activation_repository_impl.dart';
import '../data/repositories/feed_repository_impl.dart';
import '../data/repositories/kids_repository_impl.dart';
import '../domain/models/session_user.dart';
import '../domain/repositories/account_activation_repository.dart';
import '../domain/repositories/feed_repository.dart';
import '../domain/repositories/kids_repository.dart';
import '../domain/use_cases/activate_account.dart';
import '../domain/use_cases/create_child.dart';

final sessionUserProvider = Provider<SessionUser>(
  (ref) => const SessionUser.demo(),
);

final todayProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final feedDataSourceProvider = Provider<FeedDataSource>(
  (ref) => const DemoFeedDataSource(),
);

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepositoryImpl(ref.watch(feedDataSourceProvider));
});

final kidsDataSourceProvider = Provider<KidsDataSource>(
  (ref) => DemoKidsDataSource(),
);

final kidsRepositoryProvider = Provider<KidsRepository>((ref) {
  return KidsRepositoryImpl(ref.watch(kidsDataSourceProvider));
});

final createChildUseCaseProvider = Provider<CreateChild>((ref) {
  return CreateChild(
    ref.watch(kidsRepositoryProvider),
    ref.watch(todayProvider),
  );
});

final accountActivationDataSourceProvider = Provider<AccountActivationDataSource>(
  (ref) => const DemoAccountActivationDataSource(),
);

final demoInvitationCodeProvider = Provider<String>(
  (ref) => DemoAccountActivationDataSource.invitation.code,
);

final accountActivationRepositoryProvider = Provider<AccountActivationRepository>(
  (ref) => AccountActivationRepositoryImpl(
    ref.watch(accountActivationDataSourceProvider),
  ),
);

final activateAccountUseCaseProvider = Provider<ActivateAccount>(
  (ref) => ActivateAccount(ref.watch(accountActivationRepositoryProvider)),
);
