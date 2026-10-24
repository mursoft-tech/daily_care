import 'package:daily_care/app/localization.dart';
import 'package:daily_care/app/router/app_router.dart';
import 'package:daily_care/app/theme/app_theme.dart';
import 'package:daily_care/ui/features/feed/views/home_view.dart';
import 'package:daily_care/ui/features/kids/views/kids_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

Widget _pumpRouter(ProviderContainer container, GoRouter router) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      locale: const Locale('es'),
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: appSupportedLocales,
      theme: buildAppTheme(),
      routerConfig: router,
    ),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets('navigates between feed and kids from the sidebar', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);

    final container = ProviderContainer.test();
    addTearDown(container.dispose);
    await tester.pumpWidget(_pumpRouter(container, container.read(routerProvider)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Niños'));
    await tester.pumpAndSettle();
    expect(find.byType(KidsView), findsOneWidget);

    await tester.tap(find.text('Feed'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeView), findsOneWidget);
  });

  testWidgets('navigates to kids from the rail', (tester) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 900);

    final container = ProviderContainer.test();
    addTearDown(container.dispose);
    await tester.pumpWidget(_pumpRouter(container, container.read(routerProvider)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Niños'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byType(KidsView), findsOneWidget);
  });

  testWidgets('navigates to kids from the compact drawer', (tester) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);

    final container = ProviderContainer.test();
    addTearDown(container.dispose);
    await tester.pumpWidget(_pumpRouter(container, container.read(routerProvider)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('app-menu-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Niños'));
    await tester.pumpAndSettle();

    expect(find.byType(KidsView), findsOneWidget);
    expect(find.byKey(const Key('app-drawer')), findsNothing);
  });
}
