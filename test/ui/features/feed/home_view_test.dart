import 'dart:async';

import 'package:daily_care/app/localization.dart';
import 'package:daily_care/app/providers.dart';
import 'package:daily_care/app/router/app_router.dart';
import 'package:daily_care/app/theme/app_theme.dart';
import 'package:daily_care/core/result.dart';
import 'package:daily_care/domain/models/post.dart';
import 'package:daily_care/domain/models/post_audience.dart';
import 'package:daily_care/domain/models/post_type.dart';
import 'package:daily_care/domain/repositories/feed_repository.dart';
import 'package:daily_care/ui/core/widgets/app_shell.dart';
import 'package:daily_care/ui/features/feed/views/home_view.dart';
import 'package:daily_care/ui/features/login/views/login_placeholder_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

const _posts = <Post>[
  Post(
    id: 'achievement',
    childName: 'Mateo',
    childInitial: 'M',
    childColorToken: 'blue',
    timeLabel: '14:20',
    audience: PostAudience.family,
    type: PostType.achievement,
    body: '¡Usó el orinal solito por primera vez!',
    likes: 3,
    comments: 1,
  ),
  Post(
    id: 'activity',
    childName: 'Mateo',
    childInitial: 'M',
    childColorToken: 'blue',
    timeLabel: '09:40',
    audience: PostAudience.family,
    type: PostType.activity,
    body: 'Pintamos con témperas esta mañana.',
    likes: 5,
    comments: 2,
    photoLabel: 'pintando con témperas',
  ),
  Post(
    id: 'announcement',
    childName: 'Anuncio general',
    childInitial: null,
    childColorToken: 'announcement',
    timeLabel: '07:50',
    audience: PostAudience.room,
    type: PostType.announcement,
    body: 'El viernes salimos al parque.',
    likes: 8,
    comments: 0,
  ),
];

class _FakeFeedRepository implements FeedRepository {
  _FakeFeedRepository({this.result, this.completer});

  final Result<List<Post>>? result;
  final Completer<Result<List<Post>>>? completer;
  int calls = 0;

  @override
  Future<Result<List<Post>>> loadPosts() {
    calls++;
    final pending = completer;
    if (pending != null) return pending.future;
    return Future.value(result ?? const Success(_posts));
  }
}

Widget _pumpHome(FeedRepository repository) {
  return ProviderScope(
    overrides: [feedRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: appSupportedLocales,
      theme: buildAppTheme(),
      home: const HomeView(),
    ),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets('renders the localized feed and the three post types', (
    tester,
  ) async {
    await tester.pumpWidget(_pumpHome(_FakeFeedRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Buenas, Caro'), findsOneWidget);
    expect(find.text('12 niños · martes 17 jun'), findsOneWidget);
    expect(find.text('PUBLICADO HOY'), findsOneWidget);
    expect(find.text('LOGRO'), findsOneWidget);
    expect(find.text('ACTIVIDAD'), findsOneWidget);
    expect(find.text('ANUNCIO'), findsOneWidget);
    expect(find.text('Para: familia de Mateo'), findsNWidgets(2));
    expect(find.text('Para: toda la sala'), findsOneWidget);
    expect(find.text('Foto · pintando con témperas'), findsOneWidget);
    expect(find.text('Editar'), findsNWidgets(3));
  });

  testWidgets('shows loading while the repository is pending', (tester) async {
    final completer = Completer<Result<List<Post>>>();
    await tester.pumpWidget(
      _pumpHome(_FakeFeedRepository(completer: completer)),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byKey(const Key('app-rail')), findsOneWidget);

    completer.complete(const Success(_posts));
    await tester.pumpAndSettle();
    expect(find.text('PUBLICADO HOY'), findsOneWidget);
  });

  testWidgets('shows a generic error and retries', (tester) async {
    final repository = _FakeFeedRepository(
      result: const Failure(DataFailure()),
    );
    await tester.pumpWidget(_pumpHome(repository));
    await tester.pumpAndSettle();

    expect(find.text('No se pudo cargar el feed'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(repository.calls, 2);
  });

  testWidgets('uses sidebar, rail and app bar at the breakpoints', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    final repository = _FakeFeedRepository();

    tester.view.physicalSize = const Size(1200, 900);
    await tester.pumpWidget(_pumpHome(repository));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('app-sidebar')), findsOneWidget);
    expect(find.byType(AppShell), findsOneWidget);

    tester.view.physicalSize = const Size(800, 900);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('app-rail')), findsOneWidget);

    tester.view.physicalSize = const Size(400, 800);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('app-top-bar')), findsOneWidget);
    expect(find.byKey(const Key('app-bottom-nav')), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('app-menu-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('app-drawer')), findsOneWidget);
    expect(find.text('Caro Giménez'), findsOneWidget);
    expect(find.text('Maestra · Soles'), findsOneWidget);
  });

  testWidgets('logout opens the login placeholder', (tester) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);

    final container = ProviderContainer.test(
      overrides: [feedRepositoryProvider.overrideWithValue(_FakeFeedRepository())],
    );
    final router = container.read(routerProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          locale: const Locale('es'),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: appSupportedLocales,
          theme: buildAppTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('app-menu-button')));
    await tester.pumpAndSettle();
    final logoutRect = tester.getRect(
      find.byKey(const Key('app-panel-logout')),
    );
    await tester.tapAt(logoutRect.topLeft + const Offset(3, 3));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPlaceholderView), findsOneWidget);
    expect(find.byKey(const Key('app-drawer')), findsNothing);
  });
}
