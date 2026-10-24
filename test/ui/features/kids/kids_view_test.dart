import 'dart:async';

import 'package:daily_care/app/localization.dart';
import 'package:daily_care/app/providers.dart';
import 'package:daily_care/app/router/app_routes.dart';
import 'package:daily_care/app/theme/app_theme.dart';
import 'package:daily_care/core/result.dart';
import 'package:daily_care/data/datasources/local/demo_kids_data_source.dart';
import 'package:daily_care/domain/models/child.dart';
import 'package:daily_care/domain/repositories/kids_repository.dart';
import 'package:daily_care/ui/features/kids/views/kids_view.dart';
import 'package:daily_care/ui/features/kids/widgets/child_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class _FakeKidsRepository implements KidsRepository {
  _FakeKidsRepository({this.result, this.completer});

  final Result<List<Child>>? result;
  final Completer<Result<List<Child>>>? completer;
  int calls = 0;

  @override
  Future<Result<List<Child>>> loadChildren() async {
    calls++;
    final pending = completer;
    if (pending != null) return pending.future;

    final failure = result;
    if (failure != null) return failure;

    return Success(await const DemoKidsDataSource().fetchChildren());
  }

  @override
  Future<Result<Child?>> loadChild(String id) async {
    return const Success(null);
  }
}

Widget _pumpKids(KidsRepository repository) {
  final router = GoRouter(
    initialLocation: AppRoutes.kids,
    routes: [
      GoRoute(
        path: AppRoutes.kids,
        builder: (context, state) => const KidsView(),
      ),
      GoRoute(
        path: AppRoutes.childProfile,
        builder: (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Perfil ${state.pathParameters['childId']}'),
                TextButton(
                  onPressed: () => context.go(AppRoutes.kids),
                  child: const Text('Volver al listado'),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  return ProviderScope(
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
  );
}

String _searchText(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).controller!.text;

void main() {
  testWidgets('renders the kids header, section and eight cards', (
    tester,
  ) async {
    await tester.pumpWidget(_pumpKids(_FakeKidsRepository()));
    await tester.pumpAndSettle();

    expect(find.text('GESTIÓN'), findsOneWidget);
    expect(find.text('Niños'), findsWidgets);
    expect(find.text('Agregar niño'), findsOneWidget);
    expect(find.text('SALA SOLES'), findsOneWidget);
    expect(find.text('8 niños'), findsOneWidget);
    expect(find.byType(ChildCard), findsNWidgets(8));
    expect(find.text('MANÍ'), findsOneWidget);
    expect(find.text('LACTOSA'), findsOneWidget);
    expect(find.text('VINCULAR'), findsOneWidget);
    expect(find.text('3 años · 2 padres vinculados'), findsNWidgets(2));
    expect(find.text('2 años · sin padres vinculados'), findsOneWidget);
  });

  testWidgets('filters by name, shows the empty state and clears', (
    tester,
  ) async {
    await tester.pumpWidget(_pumpKids(_FakeKidsRepository()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'sofia');
    await tester.pumpAndSettle();

    expect(find.byType(ChildCard), findsOneWidget);
    expect(find.text('Sofía Méndez'), findsOneWidget);
    expect(find.text('8 niños'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();

    expect(find.byType(ChildCard), findsNothing);
    expect(find.text('No encontramos niños con ese nombre'), findsOneWidget);

    await tester.tap(find.byKey(const Key('kids-search-clear')));
    await tester.pumpAndSettle();

    expect(find.byType(ChildCard), findsNWidgets(8));
  });

  testWidgets('navigates to the child profile when a card is tapped', (
    tester,
  ) async {
    await tester.pumpWidget(_pumpKids(_FakeKidsRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ChildCard).first);
    await tester.pumpAndSettle();

    expect(find.text('Perfil mateo-fernandez'), findsOneWidget);
  });

  testWidgets('keeps the search text and filter after returning from a profile', (
    tester,
  ) async {
    await tester.pumpWidget(_pumpKids(_FakeKidsRepository()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'so');
    await tester.pumpAndSettle();
    expect(_searchText(tester), 'so');
    expect(find.byType(ChildCard), findsNWidgets(2));

    await tester.tap(find.byType(ChildCard).first);
    await tester.pumpAndSettle();
    expect(find.text('Perfil sofia-mendez'), findsOneWidget);

    await tester.tap(find.text('Volver al listado'));
    await tester.pumpAndSettle();

    expect(_searchText(tester), 'so');
    expect(find.byType(ChildCard), findsNWidgets(2));
    expect(find.text('Sofía Méndez'), findsOneWidget);

    await tester.tap(find.byKey(const Key('kids-search-clear')));
    await tester.pumpAndSettle();

    expect(_searchText(tester), '');
    expect(find.byType(ChildCard), findsNWidgets(8));
  });

  testWidgets('returns without a search to an empty field and the full list', (
    tester,
  ) async {
    await tester.pumpWidget(_pumpKids(_FakeKidsRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ChildCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Volver al listado'));
    await tester.pumpAndSettle();

    expect(_searchText(tester), '');
    expect(find.byType(ChildCard), findsNWidgets(8));
  });

  testWidgets('shows loading and keeps the shell available', (tester) async {
    final completer = Completer<Result<List<Child>>>();
    await tester.pumpWidget(
      _pumpKids(_FakeKidsRepository(completer: completer)),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byKey(const Key('app-rail')), findsOneWidget);

    completer.complete(const Success(<Child>[]));
    await tester.pumpAndSettle();

    expect(find.text('No encontramos niños con ese nombre'), findsOneWidget);
  });

  testWidgets('shows a generic error and retries', (tester) async {
    final repository = _FakeKidsRepository(
      result: const Failure(DataFailure()),
    );
    await tester.pumpWidget(_pumpKids(repository));
    await tester.pumpAndSettle();

    expect(find.text('No se pudo cargar el listado de niños'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(repository.calls, 2);
  });

  testWidgets('uses two columns on wide content and one on compact', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1;

    tester.view.physicalSize = const Size(1200, 900);
    await tester.pumpWidget(_pumpKids(_FakeKidsRepository()));
    await tester.pumpAndSettle();

    final wideFirst = tester.getTopLeft(find.byType(ChildCard).at(0));
    final wideSecond = tester.getTopLeft(find.byType(ChildCard).at(1));
    expect(wideSecond.dy, wideFirst.dy);
    expect(wideSecond.dx, greaterThan(wideFirst.dx));

    tester.view.physicalSize = const Size(400, 800);
    await tester.pumpAndSettle();

    final compactFirst = tester.getTopLeft(find.byType(ChildCard).at(0));
    final compactSecond = tester.getTopLeft(find.byType(ChildCard).at(1));
    expect(compactSecond.dx, compactFirst.dx);
    expect(compactSecond.dy, greaterThan(compactFirst.dy));
    expect(tester.takeException(), isNull);
  });
}
