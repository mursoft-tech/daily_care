---
name: flutter-add-integration-test
description: Configures integration_test and converts MCP actions into permanent integration tests. Use when adding integration testing to a project, exploring UI components via MCP, or automating user flows with the integration_test package.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Tue, 21 Apr 2026 18:29:20 GMT
---
# Implementing Flutter Integration Tests

## Contents
- [Project Setup and Dependencies](#project-setup-and-dependencies)
- [Interactive Exploration via MCP](#interactive-exploration-via-mcp)
- [Test Authoring Guidelines](#test-authoring-guidelines)
- [Execution and Profiling](#execution-and-profiling)
- [Workflow: End-to-End Integration Testing](#workflow-end-to-end-integration-testing)
- [Examples](#examples)

## Project Setup and Dependencies

Configure the project to support integration testing with `integration_test`.

1. Add required development dependencies to `pubspec.yaml`:
   ```bash
   flutter pub add 'dev:integration_test@{sdk: flutter}'
   ```
   `flutter_test` ya viene en el template; agrégalo solo si falta:
   ```bash
   flutter pub add 'dev:flutter_test@{sdk: flutter}'
   ```
2. No habilites `flutter_driver` para `integration_test`. El binding se inicializa dentro del propio test con `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`. `enableFlutterDriverExtension()` pertenece a la API legacy de `flutter_driver` y no debe añadirse al entry point de la aplicación.
3. Add `Key` parameters (e.g., `ValueKey('login_button')`) to critical widgets in the application code to ensure reliable targeting during tests.
4. Organiza los tests por capa: `test/domain/` para use cases, `test/data/` para repositorios y datasources, `test/ui/` para widgets. `test/` replica la estructura de `lib/`. Reserva `integration_test/` para flujos completos.

## Interactive Exploration via MCP

Use the Dart/Flutter MCP server tools to interactively explore and manipulate the application state before writing static tests. Estos tools requieren un servidor MCP de Dart/Flutter configurado; si el proyecto no lo tiene, escribe los tests directamente y valídalos con `flutter test` o `flutter drive`.

- **Launch**: Execute `launch_app` with `target: "lib/main.dart"` to start the application and acquire the DTD URI.
- **Inspect**: Execute `get_widget_tree` to discover available `Key`s, `Text` nodes, and widget `Type`s.
- **Interact**: Execute `tap`, `enter_text`, and `scroll` to simulate user flows.
- **Wait**: Always execute `waitFor` or verify state with `get_health` when navigating or triggering animations.
- **Troubleshoot Unmounted Widgets**: If a widget is not found in the tree, it may be lazily loaded in a `SliverList` or `ListView`. Execute `scroll` or `scrollIntoView` to force the widget to mount before interacting with it.

## Test Authoring Guidelines

Structure integration tests using the `flutter_test` API paradigm. 

- Create a dedicated `integration_test/` directory at the project root.
- Name all test files using the `<name>_test.dart` convention.
- Initialize the binding by calling `IntegrationTestWidgetsFlutterBinding.ensureInitialized();` at the start of `main()`.
- Load the application UI inside a test `ProviderScope` with fakes: `await tester.pumpWidget(ProviderScope(overrides: [...], child: const App()));`.
- Trigger frames and wait for animations to complete using `await tester.pumpAndSettle();` after interactions like `tester.tap()`.
- Assert widget visibility using `expect(find.byKey(ValueKey('foo')), findsOneWidget);` or `findsNothing`.
- Scroll to specific off-screen widgets using `await tester.scrollUntilVisible(itemFinder, 500.0, scrollable: listFinder);`.
- Inyecta fakes de repositorios y servicios con `overrideWithValue`/`overrideWith`. No llames APIs reales ni uses datos PHI en fixtures.
- No reutilices el `ProviderScope` de `main.dart`. Crea uno nuevo por test para que el estado de Riverpod y del router no se filtre entre casos.

**Legacy `flutter_driver`:**
- `flutter_driver` está en mantenimiento y la ruta recomendada es migrar a `integration_test`.
- Si mantienes tests existentes, usa `driver.waitFor()`, `driver.waitForAbsent()`, `driver.tap()` y `driver.scroll()`, pero **no mezcles** `enableFlutterDriverExtension()` con `IntegrationTestWidgetsFlutterBinding` en el mismo entry point.

## Execution and Profiling

Para mobile y desktop puedes ejecutar `flutter test integration_test` sin driver script. Para web (y para profiling) usa `flutter drive`, que requiere un host driver script en `test_driver/integration_test.dart` que llame a `integrationDriver()`.

**Conditional Execution Targets:**
- **If testing on Chrome:** Launch `chromedriver --port=4444` in a separate terminal, then run:
  `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d chrome`
- **If testing headless web:** Run with `-d web-server`.
- **If testing on Android (Local):** Run `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart`.
- **If testing on Firebase Test Lab (Android):** 
  1. Build debug APK: `flutter build apk --debug`
  2. Build test APK: `./gradlew app:assembleAndroidTest`
  3. Upload both APKs to the Firebase Test Lab console.

## Workflow: End-to-End Integration Testing

Copy and follow this checklist to implement and verify integration tests.

- [ ] **Task Progress: Setup**
  - [ ] Add `integration_test` (y `flutter_test` si falta) con la sintaxis `@{sdk: flutter}`.
  - [ ] No añadir `enableFlutterDriverExtension()`; inicializar `IntegrationTestWidgetsFlutterBinding` en el test.
  - [ ] Prepare fakes de repositorios/servicios (sin red real ni datos PHI).
  - [ ] Crea un `ProviderScope` por test con `overrides`; no uses el de `main.dart`.
  - [ ] Assign `ValueKey`s to target widgets.
- [ ] **Task Progress: Exploration**
  - [ ] Run `launch_app` via MCP.
  - [ ] Map the widget tree using `get_widget_tree`.
  - [ ] Validate interaction paths using MCP tools (`tap`, `enter_text`).
- [ ] **Task Progress: Authoring**
  - [ ] Create `integration_test/app_test.dart`.
  - [ ] Write test cases using `WidgetTester` APIs.
  - [ ] Create `test_driver/integration_test.dart` with `integrationDriver()` solo si usarás `flutter drive` (web/profiling).
- [ ] **Task Progress: Execution & Feedback Loop**
  - [ ] Run `flutter test integration_test` (mobile/desktop) o `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart` (web/profiling).
  - [ ] **Feedback Loop**: Review test output -> If `PumpAndSettleTimedOutException` occurs, check for infinite animations -> If widget not found, add `scrollUntilVisible` -> Re-run test until passing.

## Examples

### Standard Integration Test (`integration_test/app_test.dart`)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/app/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end test', () {
    testWidgets('tap on the floating action button, verify counter', (tester) async {
      // Load app widget with its own ProviderScope and fakes.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Ejemplo:
            // userRepositoryProvider.overrideWithValue(FakeUserRepository()),
          ],
          child: const App(),
        ),
      );

      // Verify the counter starts at 0.
      expect(find.text('0'), findsOneWidget);

      // Find the floating action button to tap on.
      final fab = find.byKey(const ValueKey('increment'));

      // Emulate a tap on the floating action button.
      await tester.tap(fab);

      // Trigger a frame and wait for animations.
      await tester.pumpAndSettle();

      // Verify the counter increments by 1.
      expect(find.text('1'), findsOneWidget);
    });
  });
}
```

### Host Driver Script (`test_driver/integration_test.dart`)

```dart
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
```

### Performance Profiling Driver Script (`test_driver/perf_driver.dart`)

Use this driver script if you wrap your test actions in `binding.traceAction()` to capture performance metrics. Requiere declarar `flutter_driver` explícitamente con `flutter pub add 'dev:flutter_driver@{sdk: flutter}'`; es la única parte de esta skill que sigue usando la API legacy de `flutter_driver`.

```dart
import 'package:flutter_driver/flutter_driver.dart' as driver;
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() {
  return integrationDriver(
    responseDataCallback: (data) async {
      if (data != null) {
        final timeline = driver.Timeline.fromJson(
          data['scrolling_timeline'] as Map<String, dynamic>,
        );

        final summary = driver.TimelineSummary.summarize(timeline);

        await summary.writeTimelineToFile(
          'scrolling_timeline',
          pretty: true,
          includeSummary: true,
        );
      }
    },
  );
}
```
