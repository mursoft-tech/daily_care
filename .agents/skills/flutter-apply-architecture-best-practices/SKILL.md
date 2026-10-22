---
name: flutter-apply-architecture-best-practices
description: Architects a Flutter application using the recommended layered approach (UI, Logic, Data). Use when structuring a new project or refactoring for scalability.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Tue, 21 Apr 2026 20:11:20 GMT
---
# Architecting Flutter Applications

## Contents
- [Architectural Layers](#architectural-layers)
- [Project Structure](#project-structure)
- [Workflow: Implementing a New Feature](#workflow-implementing-a-new-feature)
- [Examples](#examples)

## Architectural Layers

Enforce strict Separation of Concerns by dividing the application into distinct layers. Never mix UI rendering with business logic or data fetching.

> Requiere `flutter_riverpod` 3.x. Los ejemplos de UI usan `material_ui`.

### UI Layer (Presentation)
Implement the MVVM (Model-View-ViewModel) pattern with Riverpod 3.
*   **Views:** Write reusable, lean `ConsumerWidget`/`Consumer` widgets. Restrict logic in Views to UI-specific operations (e.g., animations, layout constraints, simple routing). Read state with `ref.watch` and keep the widget free of business logic.
*   **ViewModels:** Implement them as `Notifier` o `AsyncNotifier`; el estado se expone mediante `NotifierProvider`/`AsyncNotifierProvider`. Usa `AsyncValue` para loading/error en lugar de `_isLoading`/`_error` manuales. Inyecta contratos de repositorio o Use Cases a través de providers; nunca implementaciones de `data/`.
*   **Legacy:** No uses `ChangeNotifier`, `ChangeNotifierProvider`, `StateProvider` ni `StateNotifierProvider`; en Riverpod 3 están en `package:flutter_riverpod/legacy.dart` y están desaconsejados.

### Data Layer
Implement the Repository pattern to isolate data access logic and create a single source of truth.
*   **Data Sources / Services:** Create stateless classes to wrap external APIs (`data/datasources/remote`), local persistence (`data/datasources/local`) and platform plugins (`data/services`). Return DTOs or throw infrastructure exceptions; never return domain entities.
*   **Repositories:** Implement the domain contract. Consume one or more data sources, transform DTOs into domain entities, translate exceptions into `Result<T>`, and handle caching, offline synchronization and retry logic.
*   **Sensitive data:** Nunca cachees datos sensibles (PHI, credenciales o datos personales) sin TTL e invalidación explícita al cerrar sesión o cambiar de usuario.

### Logic Layer (Domain)
*   **Use Cases:** Obligatorios cuando la aplicación contiene cálculos, agregaciones, conversiones de unidades, sincronización o reglas compartidas entre ViewModels. Extráelos a clases Use Case entre el ViewModel y el contrato del repositorio. Un CRUD simple puede llamar al repositorio directamente.
*   **Contracts:** Define una clase abstracta por repositorio en `domain/repositories/`; la implementación vive en `data/repositories/`. El dominio no importa nada de `data/`.

## Project Structure

Organize the codebase using a hybrid approach: group UI components by feature, and group Data/Domain components by type.

```text
lib/
├── app/                          # bootstrap, router, theme, l10n, composition root
├── core/                         # Result/Failure, exceptions, logger, config, formatters
├── domain/
│   ├── models/                   # Immutable entities, no JSON
│   ├── value_objects/            # Units, weights, periods, money
│   ├── repositories/             # ABSTRACT contracts (dependency inversion)
│   └── use_cases/                # Reusable business logic
├── data/
│   ├── models/                   # DTOs with fromJson/toJson
│   ├── datasources/remote/       # HTTP clients
│   ├── datasources/local/        # drift/sqflite, persistent cache
│   ├── services/                 # Platform: health, notifications, barcode
│   └── repositories/             # Implement domain contracts
└── ui/
    ├── core/                     # Shared widgets, themes, formatters
    └── features/
        └── [feature_name]/
            ├── view_models/      # Notifier/AsyncNotifier + providers
            ├── views/
            └── widgets/          # Feature-specific widgets
```

### Dependency Rule

Dependencies point inward: `ui → domain` and `data → domain`. `ui` and `domain` never import `data/`. `core/` holds cross-cutting types without depending on any layer.

```dart
// domain/repositories/user_repository.dart
abstract class UserRepository {
  Future<Result<User>> getUser(String id, {bool forceRefresh = false});
}
```

```dart
// data/repositories/user_repository_impl.dart
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<Result<User>> getUser(String id, {bool forceRefresh = false}) async {
    try {
      final dto = await _apiClient.fetchUser(id);
      return Success(User(id: dto.id, name: dto.fullName));
    } on TimeoutException {
      return const Failure(TimeoutFailure());
    } on AppException catch (error) {
      return Failure(NetworkFailure(error.code));
    }
  }
}
```

```dart
// core/result.dart
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.failure);
  final AppFailure failure;
}

sealed class AppFailure {
  const AppFailure();
}

final class TimeoutFailure extends AppFailure {
  const TimeoutFailure();
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure(this.code);
  final int code;
}
```

Rules:
- Every repository has an abstract contract in `domain/repositories/`; providers expose the contract type.
- Use cases are mandatory for calculations, aggregations, unit conversions, synchronization, or rules shared by several ViewModels.
- Repositories and use cases return `Result<T>`; `data` translates exceptions into `Failure` without leaking bodies or internal details.
- `main.dart` only runs `ProviderScope` + `App`; router, theme and l10n live in `lib/app/`.
- `test/` mirrors `lib/` (`test/domain/`, `test/data/`, `test/ui/`); end-to-end flows live in `integration_test/`.

## Workflow: Implementing a New Feature

Follow this sequential workflow when adding a new feature to the application. Copy the checklist to track progress.

### Task Progress
- [ ] **Step 1: Define Domain Models.** Crea entidades inmutables con propiedades `final` y value objects para unidades o medidas. Los `fromJson`/`toJson` van en `data/models` y el modelo de dominio queda libre de JSON; para apps pequeñas, un único modelo inmutable con serialización manual es aceptable (ver skill `flutter-implement-json-serialization`). Usa `freezed` + `json_serializable` solo si necesitas uniones o `copyWith`, y añade `build_runner`; no mezcles ambas estrategias.
- [ ] **Step 2: Define Repository Contracts.** Crea la clase abstracta en `domain/repositories/`; es la única superficie que verán ViewModels y Use Cases.
- [ ] **Step 3: Implement Services and Data Sources.** Añade clientes HTTP en `data/datasources/remote` y persistencia/caché en `data/datasources/local`. Los clients devuelven DTOs o lanzan excepciones de infraestructura.
- [ ] **Step 4: Implement Repositories.** `data/repositories/` implementa el contrato, transforma DTOs a entidades y traduce excepciones a `Result<T>`.
- [ ] **Step 5: Apply Domain Logic.**
  - *Si hay cálculos, agregaciones, conversión de unidades, sincronización o lógica compartida:* crea un Use Case en `domain/use_cases/`.
  - *Si es un CRUD simple:* el ViewModel puede llamar al contrato del repositorio.
- [ ] **Step 6: Implement the ViewModel.** Crea un `Notifier`/`AsyncNotifier` y su provider. Inyecta el Use Case o el contrato del repositorio con `ref.watch`/`ref.read`. Expón `AsyncValue` y comandos; no uses `ChangeNotifier` y mantén el ViewModel libre de reglas de negocio.
- [ ] **Step 7: Implement the View.** Crea un `ConsumerWidget`/`Consumer` y lee el estado con `ref.watch`. Renderiza loading/error/data con pattern matching sobre `AsyncValue`.
- [ ] **Step 8: Inject Dependencies.** Declara los providers en la capa de composición (`lib/app/`), tipados como el contrato de dominio. Envuelve la app en un único `ProviderScope`; no mezcles con `provider` ni `get_it`.
- [ ] **Step 9: Run Validator.** Unit tests de Use Cases y repositorios con `ProviderContainer.test(overrides: [...])` y fakes de Data Sources. Widget tests en `test/ui`, flujos en `integration_test`. No uses red real ni datos de producción.
  - *Feedback Loop:* Run tests -> Review failures -> Fix logic -> Re-run until passing.

## Examples

### Data Layer: Service and Repository

```dart
// 1. Service (Raw API interaction, returns DTO)
class ApiClient {
  Future<UserDto> fetchUser(String id) async {
    // HTTP GET implementation...
  }
}

// 2. Repository (Implements the domain contract, returns Domain Model)
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  static const _cacheTtl = Duration(minutes: 5);
  final ApiClient _apiClient;
  final Map<String, User> _cache = {};
  final Map<String, DateTime> _cachedAt = {};

  @override
  Future<Result<User>> getUser(String id, {bool forceRefresh = false}) async {
    final cached = _cache[id];
    final cachedAt = _cachedAt[id];
    if (!forceRefresh &&
        cached != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < _cacheTtl) {
      return Success(cached);
    }

    try {
      final dto = await _apiClient.fetchUser(id);
      final user = User(id: dto.id, name: dto.fullName); // Transform to Domain Model
      _cache[id] = user;
      _cachedAt[id] = DateTime.now();
      return Success(user);
    } on TimeoutException {
      return const Failure(TimeoutFailure());
    } on AppException catch (error) {
      return Failure(NetworkFailure(error.code));
    }
  }

  // Llama a esto al cerrar sesión o cambiar de usuario.
  void clearCache() {
    _cache.clear();
    _cachedAt.clear();
  }
}
```

### Providers: Services and Repositories

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// El provider expone el contrato de dominio, no la implementación.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});
```

### UI Layer: Notifier and View

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

// 3. ViewModel as AsyncNotifier
class ProfileNotifier extends AsyncNotifier<User> {
  ProfileNotifier(this.id);

  final String id;

  @override
  Future<User> build() => _load();

  Future<void> refreshProfile() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(forceRefresh: true));
  }

  Future<User> _load({bool forceRefresh = false}) async {
    final result = await ref
        .read(userRepositoryProvider)
        .getUser(id, forceRefresh: forceRefresh);
    return switch (result) {
      Success(:final value) => value,
      Failure(:final failure) => throw failure,
    };
  }
}

final profileProvider = AsyncNotifierProvider.autoDispose
    .family<ProfileNotifier, User, String>(ProfileNotifier.new);

// 4. View (ConsumerWidget)
class ProfileView extends ConsumerWidget {
  const ProfileView({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider(id));

    return switch (profile) {
      AsyncData(:final value) => Column(
          children: [
            Text(value.name),
            FilledButton(
              onPressed: () => ref
                  .read(profileProvider(id).notifier)
                  .refreshProfile(),
              child: const Text('Refresh'),
            ),
          ],
        ),
      AsyncError() => const Center(child: Text('No se pudo cargar el perfil')),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}
```

> Usa `ref.read` solo en callbacks (`onPressed`, etc.), nunca dentro de `build`. `ref.invalidate` descarta el estado y vuelve a ejecutar el `build` del notifier; para forzar datos frescos, expón un método como `refreshProfile`. `autoDispose` libera el estado al salir de la pantalla; la caché del repositorio sigue vigente por su TTL.

### Dependency Injection with `ProviderScope`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: App()));
}
```

> Un solo `ProviderScope` en la raíz. No anides `ProviderScope` por feature ni mezcles Riverpod con `provider` o `get_it`.

### Tests with ProviderContainer

```dart
final container = ProviderContainer.test(
  overrides: [
    userRepositoryProvider.overrideWithValue(FakeUserRepository()),
  ],
);

expect(await container.read(profileProvider('1').future), isA<User>());
```

