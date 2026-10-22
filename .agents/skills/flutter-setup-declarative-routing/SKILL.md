---
name: flutter-setup-declarative-routing
description: Configure `MaterialApp.router` using a package like `go_router` for advanced URL-based navigation. Use when developing web applications or mobile apps that require specific deep linking and browser history support.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Tue, 21 Apr 2026 21:08:03 GMT
---
# Implementing Routing and Deep Linking

## Contents
- [Core Concepts](#core-concepts)
- [Workflow: Initializing the Application and Router](#workflow-initializing-the-application-and-router)
- [Workflow: Configuring Platform Deep Linking](#workflow-configuring-platform-deep-linking)
- [Workflow: Implementing Nested Navigation](#workflow-implementing-nested-navigation)
- [Examples](#examples)

## Core Concepts

Use the `go_router` package for declarative routing in Flutter. It provides a robust API for complex routing scenarios, deep linking, and nested navigation. Desde `go_router` 18 el paquete usa `material_ui`/`cupertino_ui` y requiere Flutter 3.44+; migra los imports con `dart fix --apply --code=migrate_design_widgets`.

- **GoRouter**: The central configuration object defining the application's route tree.
- **GoRoute**: A standard route mapping a URL path to a Flutter screen.
- **ShellRoute / StatefulShellRoute**: Wraps child routes in a persistent UI shell (e.g., a `BottomNavigationBar`). `StatefulShellRoute` maintains the state of parallel navigation branches.
- **Path URL Strategy**: Removes the default `#` fragment from web URLs. Solo aplica a web; en mobile no cambia la navegación.

## Workflow: Initializing the Application and Router

Follow this workflow to bootstrap a new Flutter application with `go_router` and configure the root routing mechanism.

### Task Progress
- [ ] Create the Flutter application.
- [ ] Add `go_router`, `material_ui` y `flutter_riverpod` (y `cupertino_ui` si aplica); migra imports con `dart fix`.
- [ ] Configure the URL strategy for web/deep linking (solo web).
- [ ] Implementa `authProvider` y `routerProvider`.
- [ ] Bind the router to `MaterialApp.router` dentro de `ProviderScope`.

### 1. Scaffold the Application
Run the following commands to create the app and add the required routing package:
```bash
flutter create <app-name>
cd <app-name>
flutter pub add go_router material_ui flutter_riverpod
# Solo si usas widgets Cupertino:
flutter pub add cupertino_ui
dart fix --apply --code=migrate_design_widgets
```

Si usas `usePathUrlStrategy`, declara además `flutter_web_plugins` como dependencia SDK (no se puede añadir con `pub add`):
```yaml
dependencies:
  flutter_web_plugins:
    sdk: flutter
```

### 2. Configure the Router
Define un `GoRouter` dentro de un provider de Riverpod y maneja la autenticación con `redirect`. El `redirect` solo protege la navegación; la autorización del recurso (por ejemplo, que el usuario pueda ver ese `id`) debe validarse en el servidor.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  // Solo tiene efecto en web: elimina el '#' de las URLs.
  usePathUrlStrategy();
  runApp(const ProviderScope(child: MyApp()));
}

enum AuthStatus { signedOut, signedIn }

class AuthNotifier extends Notifier<AuthStatus> {
  @override
  AuthStatus build() => AuthStatus.signedOut;

  void signIn() => state = AuthStatus.signedIn;
  void signOut() => state = AuthStatus.signedOut;
}

final authProvider = NotifierProvider<AuthNotifier, AuthStatus>(
  AuthNotifier.new,
);

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isSignedIn = ref.read(authProvider) == AuthStatus.signedIn;
      final isLoginRoute = state.matchedLocation == '/login';
      if (!isSignedIn && !isLoginRoute) return '/login';
      if (isSignedIn && isLoginRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            name: 'details',
            path: 'details/:id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              if (id == null) return const InvalidLinkScreen();
              return DetailsScreen(id: id);
            },
          ),
        ],
      ),
    ],
    // No renderices state.error: puede filtrar rutas o detalles internos.
    errorBuilder: (context, state) => const ErrorScreen(),
  );

  // Re-evalúa el redirect cuando cambia la sesión.
  ref.listen(authProvider, (_, __) => router.refresh());
  ref.onDispose(router.dispose);
  return router;
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: ref.watch(routerProvider),
      title: 'Routing App',
    );
  }
}
```

> No uses un `GoRouter` global ni un `ValueNotifier` para la sesión. `routerProvider` se crea una sola vez y `router.refresh()` re-evalúa el `redirect` cuando cambia `authProvider`. En tests, envuelve la app con `ProviderScope(overrides: [...])` y crea un container nuevo por test.

> Con `usePathUrlStrategy`, configura el servidor web para reescribir todas las rutas a `index.html`; de lo contrario las deep links devuelven 404 en producción.

> Si aplicas `flutter-setup-localization`, añade también `localizationsDelegates` y `supportedLocales` al mismo `MaterialApp.router`. Si alguna dependencia todavía importa `package:flutter/material.dart`, envuélvela con `MaterialUiCompatibilityBridge` en `MaterialApp.builder` solo durante la migración.

## Workflow: Configuring Platform Deep Linking

Configure the native platforms to intercept specific URLs and route them into the Flutter application.

### Task Progress
- [ ] Determine target platforms (iOS, Android, or both).
- [ ] Apply conditional configuration for Android (Manifest + Asset Links).
- [ ] Apply conditional configuration for iOS (Plist + Entitlements + AASA).
- [ ] Run validator -> review errors -> fix.

### If configuring for Android:
1. **Modify `AndroidManifest.xml`**: Add the intent filter inside the `<activity>` tag for `.MainActivity`.
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="http" android:host="yourdomain.com" />
    <data android:scheme="https" />
</intent-filter>
```
2. **Host `assetlinks.json`**: Serve the following JSON at `https://yourdomain.com/.well-known/assetlinks.json`.
```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.yourcompany.yourapp",
    "sha256_cert_fingerprints": ["YOUR_SHA256_FINGERPRINT"]
  }
}]
```

### If configuring for iOS:
1. **Modify `Info.plist`**: desde Flutter 3.27 el handler por defecto está activo. No necesitas declararlo; solo ponlo en `false` si usas un plugin de terceros (e.g., `app_links`) para evitar conflictos.
```xml
<key>FlutterDeepLinkingEnabled</key>
<false/>
```
2. **Modify `Runner.entitlements`**: Add the associated domain.
```xml
<key>com.apple.developer.associated-domains</key>
<array>
  <string>applinks:yourdomain.com</string>
</array>
```
3. **Host `apple-app-site-association`**: Serve the following JSON (without a `.json` extension) at `https://yourdomain.com/.well-known/apple-app-site-association`.
```json
{
  "applinks": {
    "apps": [],
    "details": [{
      "appIDs": ["TEAM_ID.com.yourcompany.yourapp"],
      "components": [{"/": "/*"}]
    }]
  }
}
```
> `paths` está obsoleto en Apple desde iOS 13; usa solo `components`.

### Validation Loop
Run validator -> review errors -> fix.
- Valida y autoriza cada parámetro de la deep link; no confíes en el `id` recibido.
- **Android**: Test using ADB.
  ```bash
  adb shell 'am start -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "https://yourdomain.com/details/123"' com.yourcompany.yourapp
  ```
- **iOS**: Test using `xcrun` on a booted simulator.
  ```bash
  xcrun simctl openurl booted https://yourdomain.com/details/123
  ```

## Workflow: Implementing Nested Navigation

Use `StatefulShellRoute` to implement persistent UI shells (like a bottom navigation bar) that maintain the state of their child routes.

### Task Progress
- [ ] Define `StatefulShellRoute.indexedStack` dentro de `routes` en `routerProvider`.
- [ ] Create `StatefulShellBranch` instances for each navigation tab.
- [ ] Implement the shell widget using `StatefulNavigationShell`.

```dart
// Fragmento de routes dentro de routerProvider.
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) {
    return ScaffoldWithNavBar(navigationShell: navigationShell);
  },
  branches: [
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
),
```

## Examples

### High-Fidelity Shell Widget Implementation
Implement the UI shell that consumes the `StatefulNavigationShell` to handle branch switching. El shell debe adaptarse al ancho disponible: `NavigationRail` en pantallas grandes y `NavigationBar` en pequeñas.

```dart
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  static const double _largeScreenMinWidth = 600;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      // Support navigating to the initial location when tapping the active tab.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth > _largeScreenMinWidth;
        return Scaffold(
          body: useRail
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: navigationShell.currentIndex,
                      onDestinationSelected: _goBranch,
                      labelType: NavigationRailLabelType.all,
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.home),
                          label: Text('Home'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.settings),
                          label: Text('Settings'),
                        ),
                      ],
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: navigationShell),
                  ],
                )
              : navigationShell,
          bottomNavigationBar: useRail
              ? null
              : NavigationBar(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _goBranch,
                  destinations: const [
                    NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                    NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
                  ],
                ),
        );
      },
    );
  }
}
```

### Programmatic Navigation
Use the `context.go()` and `context.push()` extension methods provided by `go_router`.

```dart
// Replaces the current route stack with the target route (Declarative)
context.go('/details/123');

// Pushes the target route onto the existing stack (Imperative)
context.push('/details/123');

// Navigates using a named route and path parameters
context.goNamed('details', pathParameters: {'id': '123'});

// Pops the current route
context.pop();
```
