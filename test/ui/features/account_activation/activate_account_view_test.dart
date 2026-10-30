import 'dart:async';

import 'package:daily_care/app/localization.dart';import 'package:daily_care/app/providers.dart';
import 'package:daily_care/app/router/app_router.dart';
import 'package:daily_care/app/theme/app_colors.dart';
import 'package:daily_care/app/theme/app_theme.dart';
import 'package:daily_care/core/result.dart';
import 'package:daily_care/domain/models/account_invitation.dart';
import 'package:daily_care/domain/repositories/account_activation_repository.dart';
import 'package:daily_care/ui/features/account_activation/views/activate_account_view.dart';
import 'package:daily_care/ui/core/widgets/app_logo_mark.dart';
import 'package:daily_care/ui/features/feed/views/home_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

const _invitation = AccountInvitation(
  code: '7K4P9',
  email: 'lucia.fernandez@gmail.com',
  childName: 'Mateo',
  roomName: 'Sala Soles',
);

class _FakeRepository implements AccountActivationRepository {
  _FakeRepository({this.loadFails = false, this.activateFails = false});

  bool loadFails;
  bool activateFails;

  @override
  Future<Result<AccountInvitation?>> loadInvitation(String code) async {
    return loadFails ? const Failure(DataFailure()) : const Success(_invitation);
  }

  @override
  Future<Result<void>> activate({
    required AccountInvitation invitation,
    required String password,
    required bool photoConsent,
  }) async {
    return activateFails
        ? const Failure(DataFailure())
        : const Success(null);
  }
}

class _PendingRepository implements AccountActivationRepository {
  final completer = Completer<Result<AccountInvitation?>>();

  @override
  Future<Result<AccountInvitation?>> loadInvitation(String code) {
    return completer.future;
  }

  @override
  Future<Result<void>> activate({
    required AccountInvitation invitation,
    required String password,
    required bool photoConsent,
  }) async {
    return const Success(null);
  }
}

Future<GoRouter> _pumpActivation(
  WidgetTester tester, {
  required AccountActivationRepository repository,
  Size size = const Size(1200, 900),
  String path = '/activar-cuenta?codigo=7K4P9',
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final container = ProviderContainer.test(
    overrides: [accountActivationRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
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

  router.go(path);
  await tester.pumpAndSettle();

  return router;
}

Future<void> _fillValidData(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(const Key('activate-password-input')),
    'secreto123',
  );
  await _tapKey(tester, const Key('activate-consent-checkbox'));
}

Future<void> _tapKey(WidgetTester tester, Key key) async {
  final finder = find.byKey(key);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets('renders the template pieces on a wide screen', (tester) async {
    await _pumpActivation(tester, repository: _FakeRepository());

    expect(find.byType(ActivateAccountView), findsOneWidget);
    expect(find.byType(AppLogoMark), findsOneWidget);
    expect(find.text('Bienvenida a OpenDayCare'), findsOneWidget);
    expect(
      find.text(
        'Te invitaron a seguir el día de tu hijo. Creá tu contraseña para activar la cuenta.',
      ),
      findsOneWidget,
    );
    expect(find.text('Te invitaron a seguir a'), findsOneWidget);
    expect(find.text('Mateo · Sala Soles'), findsOneWidget);
    expect(find.text('CÓDIGO DE INVITACIÓN'), findsOneWidget);
    expect(find.text('EMAIL'), findsOneWidget);
    expect(find.text('CREAR CONTRASEÑA'), findsOneWidget);
    expect(find.text('7K4P9'), findsOneWidget);
    expect(find.text('lucia.fernandez@gmail.com'), findsOneWidget);
    expect(find.text('Activar mi cuenta'), findsOneWidget);
    expect(find.textContaining('¿Ya tenés cuenta?'), findsOneWidget);
    expect(find.byKey(const Key('activate-consent-checkbox')), findsOneWidget);
  });

  testWidgets('keeps the composition on a narrow screen', (tester) async {
    await _pumpActivation(
      tester,
      repository: _FakeRepository(),
      size: const Size(400, 800),
    );

    expect(find.text('Bienvenida a OpenDayCare'), findsOneWidget);
    expect(find.text('Mateo · Sala Soles'), findsOneWidget);
    expect(find.byKey(const Key('activate-code-input')), findsOneWidget);
    expect(find.byKey(const Key('activate-submit-button')), findsOneWidget);
  });

  testWidgets('uses the template gradient on the submit button', (
    tester,
  ) async {
    await _pumpActivation(tester, repository: _FakeRepository());

    final container = tester.widget<Container>(
      find
          .ancestor(
            of: find.byKey(const Key('activate-submit-button')),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = container.decoration! as BoxDecoration;
    final gradient = decoration.gradient! as LinearGradient;

    expect(gradient.colors, [AppColors.primarySoft, AppColors.primary]);
    expect(gradient.begin, Alignment.topCenter);
    expect(gradient.end, Alignment.bottomCenter);
    expect(decoration.borderRadius, BorderRadius.circular(15));
  });

  testWidgets('the footer link returns to the login screen', (tester) async {
    final router = await _pumpActivation(
      tester,
      repository: _FakeRepository(),
    );

    await _tapKey(tester, const Key('activate-sign-in-link'));

    expect(router.routerDelegate.currentConfiguration.uri.path, '/login');
    expect(find.text('Ingresá para ver el día de hoy.'), findsOneWidget);
  });

  testWidgets('shows each validation error under its field', (tester) async {
    await _pumpActivation(tester, repository: _FakeRepository());

    await _tapKey(tester, const Key('activate-submit-button'));
    expect(find.text('Ingresá tu contraseña'), findsOneWidget);
    expect(
      find.text('Necesitamos tu autorización para continuar'),
      findsNothing,
    );

    await tester.enterText(
      find.byKey(const Key('activate-password-input')),
      'corta',
    );
    await _tapKey(tester, const Key('activate-submit-button'));
    expect(
      find.text('La contraseña debe tener al menos 8 caracteres'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('activate-password-input')),
      'secreto123',
    );
    await tester.enterText(
      find.byKey(const Key('activate-email-input')),
      'correo-invalido',
    );
    await _tapKey(tester, const Key('activate-submit-button'));
    expect(find.text('Ingresá un correo electrónico válido'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('activate-email-input')),
      'otra@correo.com',
    );
    await _tapKey(tester, const Key('activate-submit-button'));
    expect(
      find.text('Ese email no coincide con la invitación'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('activate-email-input')),
      'lucia.fernandez@gmail.com',
    );
    await tester.enterText(
      find.byKey(const Key('activate-code-input')),
      'XXXXX',
    );
    await _tapKey(tester, const Key('activate-submit-button'));
    expect(
      find.text('No encontramos una invitación con ese código'),
      findsOneWidget,
    );

    await tester.enterText(find.byKey(const Key('activate-code-input')), '7K4P9');
    await _tapKey(tester, const Key('activate-submit-button'));
    expect(
      find.text('Necesitamos tu autorización para continuar'),
      findsOneWidget,
    );
  });

  testWidgets('navigates to the feed after a valid activation', (tester) async {
    final router = await _pumpActivation(
      tester,
      repository: _FakeRepository(),
    );

    await _fillValidData(tester);
    await _tapKey(tester, const Key('activate-submit-button'));

    expect(router.routerDelegate.currentConfiguration.uri.path, '/');
    expect(find.byType(HomeView), findsOneWidget);
  });

  testWidgets('keeps the screen when the activation is rejected', (
    tester,
  ) async {
    final router = await _pumpActivation(
      tester,
      repository: _FakeRepository(),
    );

    await _fillValidData(tester);
    await tester.enterText(
      find.byKey(const Key('activate-code-input')),
      'XXXXX',
    );
    await _tapKey(tester, const Key('activate-submit-button'));

    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/activar-cuenta',
    );
    expect(
      find.text('No encontramos una invitación con ese código'),
      findsOneWidget,
    );
  });

  testWidgets('shows the generic message when activation fails', (
    tester,
  ) async {
    await _pumpActivation(
      tester,
      repository: _FakeRepository(activateFails: true),
    );

    await _fillValidData(tester);
    await _tapKey(tester, const Key('activate-submit-button'));

    expect(
      find.text('No pudimos completar la activación. Probá de nuevo.'),
      findsOneWidget,
    );
  });

  testWidgets('shows a load error with a retry action', (tester) async {
    final repository = _FakeRepository(loadFails: true);
    await _pumpActivation(tester, repository: repository);

    expect(find.text('No pudimos cargar tu invitación'), findsOneWidget);

    repository.loadFails = false;
    await _tapKey(tester, const Key('activate-retry-button'));

    expect(find.text('Bienvenida a OpenDayCare'), findsOneWidget);
  });

  testWidgets('falls back to the demo code without a query parameter', (
    tester,
  ) async {
    await _pumpActivation(
      tester,
      repository: _FakeRepository(),
      path: '/activar-cuenta',
    );

    expect(find.text('Mateo · Sala Soles'), findsOneWidget);
  });

  testWidgets('announces the invitation loading state', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repository = _PendingRepository();
    final container = ProviderContainer.test(
      overrides: [
        accountActivationRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
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
    router.go('/activar-cuenta?codigo=7K4P9');
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final loadingSemantics = tester.widget<Semantics>(
      find
          .ancestor(
            of: find.byType(CircularProgressIndicator),
            matching: find.byType(Semantics),
          )
          .first,
    );
    expect(loadingSemantics.properties.label, 'Cargando invitación');

    repository.completer.complete(const Success(_invitation));
    await tester.pumpAndSettle();

    expect(find.text('Bienvenida a OpenDayCare'), findsOneWidget);
  });
}
