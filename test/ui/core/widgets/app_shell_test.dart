import 'package:daily_care/app/localization.dart';
import 'package:daily_care/app/theme/app_theme.dart';
import 'package:daily_care/ui/core/widgets/app_shell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _pumpShell({required VoidCallback onLogout}) {
  return ProviderScope(
    child: MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: appSupportedLocales,
      theme: buildAppTheme(),
      home: AppShell(
        onLogout: onLogout,
        child: const SizedBox.expand(key: Key('shell-content')),
      ),
    ),
  );
}

void _configureView(
  WidgetTester tester, {
  required double width,
  double topPadding = 0,
  double bottomPadding = 0,
}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 900);
  tester.view.padding = FakeViewPadding(top: topPadding, bottom: bottomPadding);
}

void main() {
  testWidgets('rail avatar triggers logout without the coming soon notice', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    _configureView(tester, width: 800);
    var logouts = 0;

    await tester.pumpWidget(_pumpShell(onLogout: () => logouts++));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('app-rail')), findsOneWidget);
    await tester.tap(find.byKey(const Key('app-rail-logout')));
    await tester.pumpAndSettle();

    expect(logouts, 1);
    expect(find.text('Próximamente'), findsNothing);
  });

  testWidgets('compact width uses an app bar and drawer instead of a bottom bar', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    _configureView(tester, width: 400);
    var logouts = 0;

    await tester.pumpWidget(_pumpShell(onLogout: () => logouts++));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('app-top-bar')), findsOneWidget);
    expect(find.byKey(const Key('app-bottom-nav')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('drawer shows the user, closes on selection and exposes logout', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    _configureView(tester, width: 400);
    var logouts = 0;

    await tester.pumpWidget(_pumpShell(onLogout: () => logouts++));
    await tester.pumpAndSettle();

    final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold).first);
    await tester.tap(find.byKey(const Key('app-menu-button')));
    await tester.pumpAndSettle();

    expect(scaffold.isDrawerOpen, isTrue);
    expect(find.text('Caro Giménez'), findsOneWidget);
    expect(find.text('Maestra · Soles'), findsOneWidget);
    expect(find.byKey(const Key('app-panel-logout')), findsOneWidget);

    await tester.tap(find.text('Niños'));
    await tester.pumpAndSettle();

    expect(scaffold.isDrawerOpen, isFalse);
    expect(find.text('Próximamente'), findsOneWidget);

    await tester.tap(find.byKey(const Key('app-menu-button')));
    await tester.pumpAndSettle();
    final logoutRect = tester.getRect(
      find.byKey(const Key('app-panel-logout')),
    );
    await tester.tapAt(logoutRect.topLeft + const Offset(3, 3));
    await tester.pumpAndSettle();

    expect(logouts, 1);
    expect(scaffold.isDrawerOpen, isFalse);
  });

  testWidgets('drawer logout is tappable at the right edge of its target', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    _configureView(tester, width: 400);
    var logouts = 0;

    await tester.pumpWidget(_pumpShell(onLogout: () => logouts++));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('app-menu-button')));
    await tester.pumpAndSettle();

    final rect = tester.getRect(find.byKey(const Key('app-panel-logout')));
    await tester.tapAt(rect.topRight + const Offset(-3, 3));
    await tester.pumpAndSettle();

    expect(logouts, 1);
  });

  testWidgets('safe area keeps content below the status bar', (tester) async {
    addTearDown(tester.view.reset);
    _configureView(tester, width: 1200, topPadding: 24, bottomPadding: 20);

    await tester.pumpWidget(_pumpShell(onLogout: () {}));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.byKey(const Key('shell-content'))).dy, 24);
    expect(tester.getBottomLeft(find.byKey(const Key('shell-content'))).dy, 880);
    expect(
      tester.getSize(find.byKey(const Key('app-sidebar'))).height,
      900,
    );
  });

  testWidgets('compact safe area keeps content clear of system bars', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    _configureView(tester, width: 400, topPadding: 24, bottomPadding: 20);

    await tester.pumpWidget(_pumpShell(onLogout: () {}));
    await tester.pumpAndSettle();

    final contentTop = tester
        .getTopLeft(find.byKey(const Key('shell-content')))
        .dy;
    expect(contentTop, greaterThanOrEqualTo(24 + kToolbarHeight));
    expect(
      tester.getBottomLeft(find.byKey(const Key('shell-content'))).dy,
      880,
    );
    expect(tester.takeException(), isNull);
  });
}
