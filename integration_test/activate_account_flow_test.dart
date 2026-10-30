import 'package:daily_care/app/app.dart';
import 'package:daily_care/app/router/app_router.dart';
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

  testWidgets(
    'activates an invited account from the login screen',
    (tester) async {
      await tester.pumpWidget(const ProviderScope(child: App()));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(App)),
      );
      container.read(routerProvider).go('/login');
      await tester.pumpAndSettle();

      expect(find.text('Ingresá para ver el día de hoy.'), findsOneWidget);

      final activateLink = find.byKey(const Key('login-activate-account-link'));
      await tester.ensureVisible(activateLink);
      await tester.pumpAndSettle();
      await tester.tap(activateLink);
      await tester.pumpAndSettle();

      expect(find.text('Bienvenida a OpenDayCare'), findsOneWidget);
      expect(find.text('Mateo · Sala Soles'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('activate-password-input')),
        'secreto123',
      );
      await tester.pump(const Duration(milliseconds: 300));

      final consent = find.byKey(const Key('activate-consent-checkbox'));
      await tester.ensureVisible(consent);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(consent);
      await tester.pump(const Duration(milliseconds: 300));

      final submit = find.byKey(const Key('activate-submit-button'));
      await tester.ensureVisible(submit);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(submit);
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('PUBLICADO HOY'), findsOneWidget);
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
