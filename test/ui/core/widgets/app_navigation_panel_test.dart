import 'package:daily_care/app/localization.dart';
import 'package:daily_care/app/theme/app_theme.dart';
import 'package:daily_care/domain/models/session_user.dart';
import 'package:daily_care/ui/core/widgets/app_navigation_panel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _pumpPanel({VoidCallback? onLogout, VoidCallback? onDestination}) {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: appSupportedLocales,
    theme: buildAppTheme(),
    home: Scaffold(
      body: SizedBox(
        width: 248,
        height: 700,
        child: AppNavigationPanel(
          selectedIndex: 0,
          onDestinationSelected: (_) => onDestination?.call(),
          onLogout: onLogout ?? () {},
          sessionUser: const SessionUser.demo(),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows the simulated user name and role', (tester) async {
    await tester.pumpWidget(_pumpPanel());
    await tester.pumpAndSettle();

    expect(find.text('Caro Giménez'), findsOneWidget);
    expect(find.text('Maestra · Soles'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
  });

  testWidgets('logout invokes the callback instead of coming soon', (
    tester,
  ) async {
    var logouts = 0;
    await tester.pumpWidget(_pumpPanel(onLogout: () => logouts++));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('app-panel-logout')));
    await tester.pumpAndSettle();

    expect(logouts, 1);
    expect(find.text('Próximamente'), findsNothing);
  });
}
