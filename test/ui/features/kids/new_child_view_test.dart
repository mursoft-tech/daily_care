import 'package:daily_care/app/localization.dart';
import 'package:daily_care/app/providers.dart';
import 'package:daily_care/app/router/app_routes.dart';
import 'package:daily_care/app/theme/app_theme.dart';
import 'package:daily_care/core/result.dart';
import 'package:daily_care/domain/models/child.dart';
import 'package:daily_care/domain/repositories/kids_repository.dart';
import 'package:daily_care/ui/features/kids/views/kids_view.dart';
import 'package:daily_care/ui/features/kids/views/new_child_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class _FakeKidsRepository implements KidsRepository {
  final List<Child> children = <Child>[];

  @override
  Future<Result<List<Child>>> loadChildren() async =>
      Success(List.unmodifiable(children));

  @override
  Future<Result<Child?>> loadChild(String id) async => const Success(null);

  @override
  Future<Result<Child>> addChild(Child child) async {
    children.add(child);
    return Success(child);
  }
}

Future<void> _pumpNewChild(
  WidgetTester tester, {
  KidsRepository? repository,
  Size size = const Size(1200, 900),
}) async {
  addTearDown(tester.view.reset);
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;

  final router = GoRouter(
    initialLocation: AppRoutes.newChild,
    routes: [
      GoRoute(
        path: AppRoutes.kids,
        builder: (context, state) =>
            const Scaffold(body: Text('Listado de niños')),
      ),
      GoRoute(
        path: AppRoutes.newChild,
        builder: (context, state) => const NewChildView(),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        kidsRepositoryProvider.overrideWithValue(
          repository ?? _FakeKidsRepository(),
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
  await tester.pumpAndSettle();
}

Future<void> _submit(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('child-form-save')));
  await tester.pumpAndSettle();
}

Future<void> _pumpFlow(
  WidgetTester tester,
  _FakeKidsRepository repository,
) async {
  addTearDown(tester.view.reset);
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1200, 900);

  final router = GoRouter(
    initialLocation: AppRoutes.kids,
    routes: [
      GoRoute(
        path: AppRoutes.kids,
        builder: (context, state) => const KidsView(),
      ),
      GoRoute(
        path: AppRoutes.newChild,
        builder: (context, state) => const NewChildView(),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        kidsRepositoryProvider.overrideWithValue(repository),
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
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the form of the template', (tester) async {
    await _pumpNewChild(tester);

    expect(find.text('Agregar niño'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Guardar'), findsOneWidget);
    expect(find.text('NOMBRE COMPLETO'), findsOneWidget);
    expect(find.text('FECHA DE NACIMIENTO'), findsOneWidget);
    expect(find.text('dd/mm/aaaa'), findsOneWidget);
    expect(find.text('SALA'), findsOneWidget);
    expect(find.text('Soles'), findsOneWidget);
    expect(find.text('ALERGIAS (ETIQUETAS)'), findsOneWidget);
    expect(find.text('NOTAS MÉDICAS'), findsOneWidget);
  });

  testWidgets('requires the name and the birth date', (tester) async {
    await _pumpNewChild(tester);

    await _submit(tester);

    expect(find.text('Ingresá el nombre completo'), findsOneWidget);
    expect(find.text('Ingresá la fecha de nacimiento'), findsOneWidget);
    expect(find.text('Listado de niños'), findsNothing);
  });

  testWidgets('rejects a date that does not exist', (tester) async {
    await _pumpNewChild(tester);

    await tester.enterText(
      find.byKey(const Key('child-form-name')),
      'Martina López',
    );
    await tester.enterText(
      find.byKey(const Key('child-form-birth-date')),
      '31/02/2023',
    );
    await _submit(tester);

    expect(find.text('Ingresá una fecha válida (dd/mm/aaaa)'), findsOneWidget);
    expect(find.text('Listado de niños'), findsNothing);
  });

  testWidgets('rejects a child older than six years', (tester) async {
    await _pumpNewChild(tester);

    await tester.enterText(
      find.byKey(const Key('child-form-name')),
      'Martina López',
    );
    await tester.enterText(
      find.byKey(const Key('child-form-birth-date')),
      '23/10/2019',
    );
    await _submit(tester);

    expect(
      find.text('Solo se pueden registrar niños de hasta 6 años'),
      findsOneWidget,
    );
  });

  testWidgets('cancels and returns to the list without creating the child', (
    tester,
  ) async {
    final repository = _FakeKidsRepository();
    await _pumpNewChild(tester, repository: repository);

    await tester.enterText(
      find.byKey(const Key('child-form-name')),
      'Martina López',
    );
    await tester.tap(find.byKey(const Key('child-form-cancel')));
    await tester.pumpAndSettle();

    expect(find.text('Listado de niños'), findsOneWidget);
    expect(repository.children, isEmpty);
  });

  testWidgets('saves a valid child and returns to the list', (tester) async {
    final repository = _FakeKidsRepository();
    await _pumpNewChild(tester, repository: repository);

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
      'Maní, Lactosa',
    );
    await _submit(tester);

    expect(find.text('Listado de niños'), findsOneWidget);
    expect(repository.children, hasLength(1));
    final child = repository.children.single;
    expect(child.fullName, 'Martina López');
    expect(child.birthDate, DateTime(2023, 3, 12));
    expect(child.allergies.map((allergy) => allergy.label), [
      'MANÍ',
      'LACTOSA',
    ]);
  });

  testWidgets('stacks the fields on a narrow screen without overflow', (
    tester,
  ) async {
    await _pumpNewChild(tester, size: const Size(400, 900));

    final date = tester.getTopLeft(
      find.byKey(const Key('child-form-birth-date')),
    );
    final room = tester.getTopLeft(find.byKey(const Key('child-form-room')));

    expect(room.dx, date.dx);
    expect(room.dy, greaterThan(date.dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('adds the child to the list and clears the search', (
    tester,
  ) async {
    final repository = _FakeKidsRepository()
      ..children.add(
        Child(
          id: 'mateo-fernandez',
          firstName: 'Mateo',
          lastName: 'Fernández',
          birthDate: DateTime(2023, 3, 12),
          room: 'Soles',
          enrolledAt: DateTime(2025, 2),
          colorToken: 'blue',
        ),
      );
    await _pumpFlow(tester, repository);

    await tester.enterText(find.byType(TextField), 'mat');
    await tester.pumpAndSettle();
    expect(find.text('Mateo Fernández'), findsOneWidget);

    await tester.tap(find.byKey(const Key('kids-add-child')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('child-form-name')),
      'Martina López',
    );
    await tester.enterText(
      find.byKey(const Key('child-form-birth-date')),
      '15062022',
    );
    await _submit(tester);

    expect(find.text('SALA SOLES'), findsOneWidget);
    expect(find.byKey(const Key('kids-search-clear')), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
    expect(find.text('Martina López'), findsOneWidget);
    expect(find.text('2 niños'), findsOneWidget);
    expect(find.text('4 años · sin padres vinculados'), findsOneWidget);
    expect(find.text('VINCULAR'), findsWidgets);
  });
}
