import 'package:daily_care/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets('navigates from the feed to the kids list and back', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    final width =
        tester.view.physicalSize.width / tester.view.devicePixelRatio;
    if (width < 600) {
      await tester.tap(find.byKey(const Key('app-menu-button')));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Niños').first, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('SALA SOLES'), findsOneWidget);
    expect(find.text('Mateo Fernández'), findsOneWidget);
    expect(find.text('Agregar niño'), findsOneWidget);

    if (width < 600) {
      await tester.tap(find.byKey(const Key('app-menu-button')));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Feed').first, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('PUBLICADO HOY'), findsOneWidget);
  });
}
