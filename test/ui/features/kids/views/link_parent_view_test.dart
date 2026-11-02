import 'package:daily_care/app/localization.dart';
import 'package:daily_care/app/providers.dart';
import 'package:daily_care/app/router/app_routes.dart';
import 'package:daily_care/app/theme/app_theme.dart';
import 'package:daily_care/core/result.dart';
import 'package:daily_care/data/datasources/local/demo_kids_data_source.dart';
import 'package:daily_care/data/repositories/kids_repository_impl.dart';
import 'package:daily_care/domain/models/child.dart';
import 'package:daily_care/domain/repositories/kids_repository.dart';
import 'package:daily_care/ui/features/kids/views/link_parent_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets('renders link parent form with child name, banner, inputs and invitation code', (
    tester,
  ) async {
    await _pumpLinkParent(tester, 'mateo-fernandez');

    expect(find.text('Vincular padre'), findsOneWidget);
    expect(find.text('a Mateo Fernández'), findsOneWidget);
    expect(
      find.text('Le enviaremos un correo con un código para que active su cuenta. Solo verá el feed de Mateo.'),
      findsOneWidget,
    );
    expect(find.text('NOMBRE DEL PADRE/MADRE'), findsOneWidget);
    expect(find.text('EMAIL'), findsOneWidget);
    expect(find.text('PARENTESCO'), findsOneWidget);
    expect(find.text('Mamá'), findsOneWidget);
    expect(find.text('Papá'), findsOneWidget);
    expect(find.text('Tutor/a'), findsOneWidget);
    expect(find.text('CÓDIGO DE INVITACIÓN'), findsOneWidget);
    final code = tester
        .widget<Text>(find.byKey(const Key('link-parent-invitation-code')))
        .data;
    expect(code, hasLength(5));
    expect(find.text('Vence en 7 días'), findsOneWidget);
    expect(find.text('Enviar invitación'), findsOneWidget);
  });

  testWidgets('validates required name and email before submitting', (tester) async {
    await _pumpLinkParent(tester, 'mateo-fernandez');

    await tester.tap(find.byKey(const Key('link-parent-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Ingresá el nombre completo'), findsOneWidget);
    expect(find.text('Ingresá un correo electrónico'), findsOneWidget);
  });

  testWidgets('validates invalid email format', (tester) async {
    await _pumpLinkParent(tester, 'mateo-fernandez');

    await tester.enterText(
      find.byKey(const Key('link-parent-name-input')),
      'Marcela Gómez',
    );
    await tester.enterText(
      find.byKey(const Key('link-parent-email-input')),
      'correo-invalido',
    );
    await tester.tap(find.byKey(const Key('link-parent-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Ingresá el nombre completo'), findsNothing);
    expect(find.text('Ingresá un correo electrónico válido'), findsOneWidget);
  });

  testWidgets('submits invitation successfully and returns to child profile with snackbar feedback', (
    tester,
  ) async {
    await _pumpLinkParent(tester, 'mateo-fernandez');

    await tester.enterText(
      find.byKey(const Key('link-parent-name-input')),
      'Marcela Gómez',
    );
    await tester.enterText(
      find.byKey(const Key('link-parent-email-input')),
      'marcela@ejemplo.com',
    );
    await tester.tap(find.text('Mamá'));
    await tester.tap(find.byKey(const Key('link-parent-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Invitación enviada a Marcela Gómez'), findsOneWidget);
    expect(find.text('Perfil de Mateo'), findsOneWidget);
  });

  testWidgets('close button returns to child profile', (tester) async {
    await _pumpLinkParent(tester, 'mateo-fernandez');

    await tester.tap(find.byKey(const Key('link-parent-close-button')));
    await tester.pumpAndSettle();

    expect(find.text('Perfil de Mateo'), findsOneWidget);
  });

  testWidgets('rejects an email already linked to the child', (tester) async {
    final repository = KidsRepositoryImpl(DemoKidsDataSource());
    await _pumpLinkParent(
      tester,
      'mateo-fernandez',
      repository: repository,
    );

    await tester.enterText(
      find.byKey(const Key('link-parent-name-input')),
      'Lucía Duplicada',
    );
    await tester.enterText(
      find.byKey(const Key('link-parent-email-input')),
      'LUCIA@EJEMPLO.COM',
    );
    await tester.tap(find.byKey(const Key('link-parent-submit-button')));
    await tester.pumpAndSettle();

    expect(
      find.text('Ese correo ya está vinculado a este niño'),
      findsOneWidget,
    );
    expect(find.text('Vincular padre'), findsOneWidget);
    expect(find.text('Invitación enviada a Lucía Duplicada'), findsNothing);

    final result = await repository.loadChild('mateo-fernandez');
    final child = (result as Success<Child?>).value!;
    expect(child.linkedParents, 2);
  });
}

Future<void> _pumpLinkParent(
  WidgetTester tester,
  String childId, {
  KidsRepository? repository,
}) async {
  addTearDown(tester.view.reset);
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1200, 900);

  final router = GoRouter(
    initialLocation: AppRoutes.linkParentPath(childId),
    routes: [
      GoRoute(
        path: AppRoutes.linkParent,
        builder: (context, state) => LinkParentView(
          childId: state.pathParameters['childId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.childProfile,
        builder: (context, state) => const Scaffold(
          body: Text('Perfil de Mateo'),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        kidsRepositoryProvider.overrideWithValue(
          repository ?? KidsRepositoryImpl(DemoKidsDataSource()),
        ),
      ],
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
}
