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

  testWidgets('opens Mateo profile and returns from the desktop layout', (
    tester,
  ) async {
    await _runProfileFlow(tester, const Size(1280, 900));
  });

  testWidgets('opens Mateo profile and returns from the compact layout', (
    tester,
  ) async {
    await _runProfileFlow(tester, const Size(400, 800));
  });
}

Future<void> _runProfileFlow(WidgetTester tester, Size size) async {
  addTearDown(tester.view.reset);
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;

  await tester.pumpWidget(const ProviderScope(child: App()));
  await tester.pumpAndSettle();

  if (size.width < 600) {
    await tester.tap(find.byKey(const Key('app-menu-button')));
    await tester.pumpAndSettle();
  }
  await tester.tap(find.text('Niños').first, warnIfMissed: false);
  await tester.pumpAndSettle();

  await tester.tap(find.text('Mateo Fernández'));
  await tester.pumpAndSettle();

  expect(find.text('Volver a Niños'), findsOneWidget);
  expect(find.text('Alergias y notas'), findsOneWidget);
  expect(find.text('12 mar 2023'), findsOneWidget);
  expect(find.text('PADRES VINCULADOS'), findsOneWidget);
  expect(find.text('Lucía Fernández'), findsOneWidget);
  expect(find.text('Diego Fernández'), findsOneWidget);

  await tester.tap(find.text('Volver a Niños'));
  await tester.pumpAndSettle();

  expect(find.text('SALA SOLES'), findsOneWidget);
  expect(find.text('Agregar niño'), findsOneWidget);
}
