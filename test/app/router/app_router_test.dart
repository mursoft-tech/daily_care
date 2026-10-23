import 'package:daily_care/app/localization.dart';
import 'package:daily_care/app/router/app_router.dart';
import 'package:daily_care/app/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets('resolves /login and falls back to the home on unknown routes', (
    tester,
  ) async {
    final container = ProviderContainer.test();
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

    router.go('/login');
    await tester.pumpAndSettle();
    expect(find.text('Inicio de sesión en preparación'), findsOneWidget);

    router.go('/ruta-inexistente');
    await tester.pumpAndSettle();
    expect(find.text('Buenas, Caro'), findsOneWidget);
  });
}
