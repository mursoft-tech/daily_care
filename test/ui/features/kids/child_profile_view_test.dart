import 'dart:async';

import 'package:daily_care/app/localization.dart';
import 'package:daily_care/app/providers.dart';
import 'package:daily_care/app/router/app_routes.dart';
import 'package:daily_care/app/theme/app_theme.dart';
import 'package:daily_care/core/result.dart';
import 'package:daily_care/data/repositories/kids_repository_impl.dart';
import 'package:daily_care/domain/models/child.dart';
import 'package:daily_care/domain/repositories/kids_repository.dart';
import 'package:daily_care/data/datasources/local/demo_kids_data_source.dart';
import 'package:daily_care/ui/features/kids/views/child_profile_view.dart';
import 'package:daily_care/ui/features/kids/widgets/linked_parents_card.dart';
import 'package:daily_care/ui/features/kids/widgets/profile_info_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

class _FakeKidsRepository implements KidsRepository {
  _FakeKidsRepository({this.child, this.failure, this.completer});

  final Child? child;
  final AppFailure? failure;
  final Completer<Result<Child?>>? completer;
  int childCalls = 0;

  @override
  Future<Result<List<Child>>> loadChildren() async => const Success([]);

  @override
  Future<Result<Child?>> loadChild(String id) async {
    childCalls++;
    final pending = completer;
    if (pending != null) return pending.future;

    final error = failure;
    if (error != null) return Failure(error);
    return Success(child);
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets('renders the full profile of a child with allergy and parents', (
    tester,
  ) async {
    await _pumpProfile(tester, 'mateo-fernandez', size: const Size(1200, 900));

    expect(find.text('Volver a Niños'), findsOneWidget);
    expect(find.text('Mateo Fernández'), findsOneWidget);
    expect(find.text('3 años · Sala Soles'), findsOneWidget);
    expect(find.text('Editar'), findsOneWidget);
    expect(find.text('Alergias y notas'), findsOneWidget);
    expect(find.text('MANÍ'), findsOneWidget);
    expect(
      find.text(
        'Alergia al maní. Evitar frutos secos. '
        'Lleva inhalador en la mochila.',
      ),
      findsOneWidget,
    );
    expect(find.text('Fecha de nacimiento'), findsOneWidget);
    expect(find.text('12 mar 2023'), findsOneWidget);
    expect(find.text('Sala'), findsOneWidget);
    expect(find.text('Soles'), findsOneWidget);
    expect(find.text('Ingreso'), findsOneWidget);
    expect(find.text('feb 2025'), findsOneWidget);
    expect(find.text('PADRES VINCULADOS'), findsOneWidget);
    expect(find.text('Lucía Fernández'), findsOneWidget);
    expect(find.text('Mamá · activa'), findsOneWidget);
    expect(find.text('ACTIVA'), findsOneWidget);
    expect(find.text('Diego Fernández'), findsOneWidget);
    expect(find.text('Papá · invitación enviada'), findsOneWidget);
    expect(find.text('PENDIENTE'), findsOneWidget);
    expect(find.text('Resumen del día'), findsOneWidget);
    expect(find.text('Vincular otro padre'), findsOneWidget);
  });

  testWidgets('hides the allergy block for a child without allergies', (
    tester,
  ) async {
    await _pumpProfile(tester, 'sofia-mendez', size: const Size(1200, 900));

    expect(find.text('Sofía Méndez'), findsOneWidget);
    expect(find.text('Alergias y notas'), findsNothing);
    expect(find.text('Sin padres vinculados'), findsNothing);
  });

  testWidgets('shows the empty parents state for a child without guardians', (
    tester,
  ) async {
    await _pumpProfile(tester, 'valentina-soto', size: const Size(1200, 900));

    expect(find.text('Valentina Soto'), findsOneWidget);
    expect(find.text('Sin padres vinculados'), findsOneWidget);
    expect(find.text('Vincular un padre'), findsOneWidget);
    expect(find.text('ACTIVA'), findsNothing);
    expect(find.text('PENDIENTE'), findsNothing);
  });

  testWidgets('shows the singular age for a one-year-old', (tester) async {
    final child = Child(
      id: 'nina-un-ano',
      firstName: 'Nina',
      lastName: 'Paz',
      birthDate: DateTime(2025, 1, 10),
      room: 'Soles',
      enrolledAt: DateTime(2025, 2),
      colorToken: 'pink',
    );
    await _pumpProfile(
      tester,
      child.id,
      size: const Size(1200, 900),
      repository: _FakeKidsRepository(child: child),
    );

    expect(find.text('1 año · Sala Soles'), findsOneWidget);
  });

  testWidgets('pending actions show the coming soon message without routing', (
    tester,
  ) async {
    await _pumpProfile(tester, 'mateo-fernandez', size: const Size(1200, 900));

    final actions = ['Editar', 'Resumen del día', 'Vincular otro padre'];
    for (final action in actions) {
      await tester.ensureVisible(find.text(action));
      await tester.tap(find.text(action));
      await tester.pumpAndSettle();

      expect(find.text('Próximamente'), findsOneWidget);
      expect(find.text('Mateo Fernández'), findsOneWidget);
    }
  });

  testWidgets('goes back to the kids list', (tester) async {
    await _pumpProfile(tester, 'mateo-fernandez', size: const Size(1200, 900));

    await tester.tap(find.text('Volver a Niños'));
    await tester.pumpAndSettle();

    expect(find.text('Listado de niños'), findsOneWidget);
  });

  testWidgets('shows loading and keeps the shell available', (tester) async {
    final completer = Completer<Result<Child?>>();
    await _pumpProfile(
      tester,
      'mateo-fernandez',
      size: const Size(1200, 900),
      repository: _FakeKidsRepository(completer: completer),
      settle: false,
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byKey(const Key('app-sidebar')), findsOneWidget);

    completer.complete(const Success(null));
    await tester.pumpAndSettle();

    expect(find.text('No encontramos este perfil'), findsOneWidget);
  });

  testWidgets('shows a generic error and retries', (tester) async {
    final repository = _FakeKidsRepository(failure: const DataFailure());
    await _pumpProfile(
      tester,
      'mateo-fernandez',
      size: const Size(1200, 900),
      repository: repository,
    );

    expect(find.text('No se pudo cargar la ficha'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(repository.childCalls, 2);
  });

  testWidgets('shows not found and returns to the list', (tester) async {
    await _pumpProfile(tester, 'inexistente', size: const Size(1200, 900));

    expect(find.text('No encontramos este perfil'), findsOneWidget);
    expect(find.text('El niño que buscás no está en esta sala.'), findsOneWidget);

    await tester.tap(find.text('Volver a Niños').last);
    await tester.pumpAndSettle();

    expect(find.text('Listado de niños'), findsOneWidget);
  });

  testWidgets('uses two columns on wide content and stacks on compact', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1;

    for (final size in [
      const Size(1200, 900),
      const Size(800, 900),
    ]) {
      tester.view.physicalSize = size;
      await _pumpProfile(tester, 'mateo-fernandez', size: size);
      final info = tester.getTopLeft(find.byType(ProfileInfoCard));
      final parents = tester.getTopLeft(find.byType(LinkedParentsCard));
      expect(parents.dx, greaterThan(info.dx));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('stacks the columns on compact content', (tester) async {
    await _pumpProfile(
      tester,
      'mateo-fernandez',
      size: const Size(400, 900),
    );

    final info = tester.getTopLeft(find.byType(ProfileInfoCard));
    final parents = tester.getTopLeft(find.byType(LinkedParentsCard));
    expect(parents.dx, info.dx);
    expect(parents.dy, greaterThan(info.dy));
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpProfile(
  WidgetTester tester,
  String childId, {
  Size size = const Size(1200, 900),
  KidsRepository? repository,
  bool settle = true,
}) async {
  addTearDown(tester.view.reset);
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;

  final router = GoRouter(
    initialLocation: AppRoutes.childProfilePath(childId),
    routes: [
      GoRoute(
        path: AppRoutes.kids,
        builder: (context, state) =>
            const Scaffold(body: Text('Listado de niños')),
      ),
      GoRoute(
        path: AppRoutes.childProfile,
        builder: (context, state) => ChildProfileView(
          childId: state.pathParameters['childId'] ?? '',
        ),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        kidsRepositoryProvider.overrideWithValue(
          repository ?? KidsRepositoryImpl(const DemoKidsDataSource()),
        ),
        todayProvider.overrideWithValue(() => DateTime(2026, 10, 24)),
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
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}
