import 'package:daily_care/app/localization.dart';
import 'package:daily_care/app/theme/app_theme.dart';
import 'package:daily_care/ui/core/widgets/app_logout_button.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _pumpButton({required VoidCallback onLogout}) {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: appSupportedLocales,
    theme: buildAppTheme(),
    home: Scaffold(
      body: Center(
        child: AppLogoutButton(
          key: const Key('logout'),
          onLogout: onLogout,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('exposes a 48x48 touch target without a tooltip', (tester) async {
    await tester.pumpWidget(_pumpButton(onLogout: () {}));

    expect(tester.getSize(find.byKey(const Key('logout'))), const Size(48, 48));
    expect(find.byType(Tooltip), findsNothing);
  });

  testWidgets('exposes the logout label to semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_pumpButton(onLogout: () {}));

    expect(find.bySemanticsLabel('Cerrar sesión'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('a tap on the edge of the target triggers logout', (
    tester,
  ) async {
    var logouts = 0;
    await tester.pumpWidget(_pumpButton(onLogout: () => logouts++));

    final rect = tester.getRect(find.byKey(const Key('logout')));
    await tester.tapAt(rect.topLeft + const Offset(3, 3));
    await tester.pumpAndSettle();

    expect(logouts, 1);
  });

  testWidgets('a long press still triggers logout', (tester) async {
    var logouts = 0;
    await tester.pumpWidget(_pumpButton(onLogout: () => logouts++));

    await tester.longPress(find.byKey(const Key('logout')));
    await tester.pumpAndSettle();

    expect(logouts, 1);
  });

  testWidgets('activates with the keyboard when focused', (tester) async {
    var logouts = 0;
    await tester.pumpWidget(_pumpButton(onLogout: () => logouts++));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(logouts, 1);
  });
}
