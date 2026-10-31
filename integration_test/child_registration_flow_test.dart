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

  testWidgets('registers a child and returns to the list', (tester) async {
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

    await tester.tap(find.text('Agregar niño'));
    await tester.pumpAndSettle();
    expect(find.text('NOMBRE COMPLETO'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('child-form-name')),
      'Martina López',
    );
    await tester.enterText(
      find.byKey(const Key('child-form-birth-date')),
      '12032023',
    );
    await tester.enterText(
      find.byKey(const Key('child-form-allergies')),
      'Maní',
    );

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    final saveButton = find.byKey(const Key('child-form-save'));
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('SALA SOLES'), findsOneWidget);
    expect(find.text('9 niños'), findsOneWidget);
    expect(find.text('Martina López'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
  });
}
