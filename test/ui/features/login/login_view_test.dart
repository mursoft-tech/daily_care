import 'package:daily_care/app/localization.dart';
import 'package:daily_care/app/theme/app_theme.dart';
import 'package:daily_care/ui/features/login/views/login_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _buildTestableLoginView({Size size = const Size(1024, 768)}) {
  return ProviderScope(
    child: MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: appSupportedLocales,
      theme: buildAppTheme(),
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: const LoginView(),
      ),
    ),
  );
}

void main() {
  group('LoginView Widget Tests', () {
    testWidgets('renders desktop two-column layout on wide screens', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_buildTestableLoginView(size: const Size(1200, 800)));
      await tester.pumpAndSettle();

      expect(find.text('Iniciar sesión'), findsNWidgets(2)); // Heading & Submit button
      expect(find.text('El día de cada niño,\ncompartido con su familia.'), findsOneWidget);
      expect(find.byKey(const Key('login-role-staff')), findsOneWidget);
      expect(find.byKey(const Key('login-role-parent')), findsOneWidget);
      expect(find.byKey(const Key('login-email-input')), findsOneWidget);
      expect(find.byKey(const Key('login-password-input')), findsOneWidget);
      expect(find.byKey(const Key('login-submit-button')), findsOneWidget);
      expect(find.byKey(const Key('login-forgot-password-link')), findsOneWidget);
      expect(find.byKey(const Key('login-activate-account-link')), findsOneWidget);
    });

    testWidgets('renders mobile banner layout on narrow screens', (tester) async {
      tester.view.physicalSize = const Size(500, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_buildTestableLoginView(size: const Size(500, 1000)));
      await tester.pumpAndSettle();

      expect(find.text('Iniciar sesión'), findsNWidgets(2));
      expect(find.text('El día de cada niño,\ncompartido con su familia.'), findsOneWidget);
      expect(find.byKey(const Key('login-role-staff')), findsOneWidget);
      expect(find.byKey(const Key('login-email-input')), findsOneWidget);
    });

    testWidgets('switching role updates suggested email', (tester) async {
      await tester.pumpWidget(_buildTestableLoginView());
      await tester.pumpAndSettle();

      expect(find.text('caro@opendaycare.com'), findsOneWidget);

      await tester.tap(find.byKey(const Key('login-role-parent')));
      await tester.pumpAndSettle();

      expect(find.text('lucia.fernandez@gmail.com'), findsOneWidget);

      await tester.tap(find.byKey(const Key('login-role-staff')));
      await tester.pumpAndSettle();

      expect(find.text('caro@opendaycare.com'), findsOneWidget);
    });

    testWidgets('shows validation error when email format is invalid', (tester) async {
      await tester.pumpWidget(_buildTestableLoginView());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('login-email-input')), 'invalido');
      await tester.enterText(find.byKey(const Key('login-password-input')), 'admin123');
      await tester.tap(find.byKey(const Key('login-submit-button')));
      await tester.pumpAndSettle();

      expect(find.text('Ingresá un correo electrónico válido'), findsOneWidget);
    });

    testWidgets('shows validation error when credentials do not match', (tester) async {
      await tester.pumpWidget(_buildTestableLoginView());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('login-email-input')), 'admin@opendaycare.com');
      await tester.enterText(find.byKey(const Key('login-password-input')), 'wrongpass');
      await tester.tap(find.byKey(const Key('login-submit-button')));
      await tester.pumpAndSettle();

      expect(
        find.text('Credenciales incorrectas. Verificá tu usuario y contraseña'),
        findsOneWidget,
      );
    });
  });
}
