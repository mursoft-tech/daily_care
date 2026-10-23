import 'package:daily_care/app/localization.dart';
import 'package:daily_care/app/theme/app_theme.dart';
import 'package:daily_care/ui/core/widgets/app_link.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('uses a click cursor and shows the coming soon message', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: appSupportedLocales,
        theme: buildAppTheme(),
        home: Scaffold(
          body: Center(child: AppLink(child: const Text('Abrir'))),
        ),
      ),
    );

    final mouseRegion = tester.widget<MouseRegion>(
      find
          .descendant(
            of: find.byType(AppLink),
            matching: find.byType(MouseRegion),
          )
          .first,
    );
    expect(mouseRegion.cursor, SystemMouseCursors.click);

    await tester.tap(find.text('Abrir'));
    await tester.pump();

    expect(find.text('Próximamente'), findsOneWidget);
  });
}
