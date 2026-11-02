import 'package:daily_care/app/localization.dart';
import 'package:daily_care/app/providers.dart';
import 'package:daily_care/app/router/app_router.dart';
import 'package:daily_care/app/router/app_routes.dart';
import 'package:daily_care/app/theme/app_theme.dart';
import 'package:daily_care/core/result.dart';
import 'package:daily_care/domain/models/child.dart';
import 'package:daily_care/domain/models/guardian.dart';
import 'package:daily_care/domain/models/post.dart';
import 'package:daily_care/domain/repositories/feed_repository.dart';
import 'package:daily_care/domain/repositories/kids_repository.dart';
import 'package:daily_care/ui/features/feed/views/create_post_view.dart';
import 'package:daily_care/ui/features/feed/views/home_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

class _FakeFeedRepository implements FeedRepository {
  final List<Post> posts = <Post>[];

  @override
  Future<Result<List<Post>>> loadPosts() async =>
      Success(List.unmodifiable(posts));

  @override
  Future<Result<Post>> createPost(Post post) async {
    posts.insert(0, post);
    return Success(post);
  }
}

class _FakeKidsRepository implements KidsRepository {
  final List<Child> children = [
    Child(
      id: 'mateo-fernandez',
      firstName: 'Mateo',
      lastName: 'Fernández',
      birthDate: DateTime(2023, 3, 12),
      room: 'Soles',
      enrolledAt: DateTime(2025, 2),
      colorToken: 'blue',
    ),
    Child(
      id: 'sofia-mendez',
      firstName: 'Sofía',
      lastName: 'Méndez',
      birthDate: DateTime(2024, 5, 9),
      room: 'Soles',
      enrolledAt: DateTime(2025, 2),
      colorToken: 'pink',
    ),
  ];

  @override
  Future<Result<List<Child>>> loadChildren() async => Success(children);

  @override
  Future<Result<Child?>> loadChild(String id) async {
    for (final child in children) {
      if (child.id == id) return Success(child);
    }
    return const Success(null);
  }

  @override
  Future<Result<Child>> addChild(Child child) async => Success(child);

  @override
  Future<Result<Guardian>> linkGuardian({
    required String childId,
    required String fullName,
    required String email,
    required GuardianRelationship relationship,
    required String invitationCode,
  }) async {
    throw UnimplementedError();
  }
}

List<Override> _overrides(_FakeFeedRepository feed) => [
  feedRepositoryProvider.overrideWithValue(feed),
  kidsRepositoryProvider.overrideWithValue(_FakeKidsRepository()),
  todayProvider.overrideWithValue(() => DateTime(2026, 11, 1, 9, 5)),
];

MaterialApp _routerApp(ProviderContainer container) {
  return MaterialApp.router(
    locale: const Locale('es'),
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: appSupportedLocales,
    theme: buildAppTheme(),
    routerConfig: container.read(routerProvider),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets('publishing navigates to the feed with the post first', (
    tester,
  ) async {
    final feed = _FakeFeedRepository();
    final container = ProviderContainer.test(overrides: _overrides(feed));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _routerApp(container),
      ),
    );
    container.read(routerProvider).go(AppRoutes.newPost);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('composer-description')),
      'Almorzaron guiso',
    );
    await tester.tap(
      find.byKey(const Key('composer-recipient-mateo-fernandez')),
    );
    await tester.tap(
      find.byKey(const Key('composer-recipient-sofia-mendez')),
    );
    await tester.tap(find.byKey(const Key('composer-type-food')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('composer-publish')));
    await tester.pumpAndSettle();

    expect(find.byType(HomeView), findsOneWidget);
    expect(find.text('PUBLICADO HOY'), findsOneWidget);
    expect(find.text('Almorzaron guiso'), findsOneWidget);
    expect(find.text('COMIDA'), findsOneWidget);
    expect(find.text('Para: familias de Mateo y Sofía'), findsOneWidget);
    expect(feed.posts, hasLength(1));
    expect(feed.posts.first.body, 'Almorzaron guiso');
    expect(feed.posts.first.recipientNames, ['Mateo', 'Sofía']);
  });

  testWidgets('renders without overflow at compact, medium and wide widths', (
    tester,
  ) async {
    addTearDown(tester.view.reset);

    for (final width in [400.0, 800.0, 1200.0]) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);

      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(_FakeFeedRepository()),
          child: MaterialApp(
            locale: const Locale('es'),
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: appSupportedLocales,
            theme: buildAppTheme(),
            home: const CreatePostView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: 'width $width');
      expect(find.text('Nueva publicación'), findsWidgets);
    }
  });
}
