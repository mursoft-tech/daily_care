# Tasks

## 1. Usuario simulado y recursos base

- [x] 1.1 Crear `lib/domain/models/session_user.dart` con `SessionUser` inmutable (`id`, `firstName`, `fullName`, `initial`, `role`) y `SessionRole`, sin imports de Flutter; verificar con `flutter analyze` que `domain/` no depende de `material_ui`.
- [x] 1.2 Añadir `sessionUserProvider` en `lib/app/providers.dart` devolviendo el usuario demo; verificar con un test en `test/app/providers_test.dart` que retorna el mismo usuario y que el `fullName` es "Caro Giménez".
- [x] 1.3 Añadir a `lib/l10n/app_es.arb` las claves `menuTooltip`, `logoutLabel`, `loginComingSoonTitle`, `loginComingSoonBody` y `backToFeed`; verificar con `flutter gen-l10n` que no hay mensajes sin traducir y que `app_localizations.dart` las expone.
- [x] 1.4 Crear `assets/icons/menu.svg` con trazo Lucide 24x24 y registrarlo en `pubspec.yaml` si el glob actual no lo cubre; verificar que `flutter test` renderiza el ícono en un widget de prueba o que el asset aparece en `AssetManifest`.

## 2. Panel de navegación compartido

- [x] 2.1 Extraer el contenido del sidebar a `lib/ui/core/widgets/app_navigation_panel.dart` con `selectedIndex`, `onDestinationSelected`, `onLogout` y `sessionUser`; verificar que el sidebar (`app-sidebar`, 248 px) se ve igual y que los tests existentes de enlaces siguen pasando.
- [x] 2.2 Mostrar nombre, rol e inicial desde `sessionUser` en el panel y eliminar `AppShell._accountName`; verificar con un test de widget que el panel renderiza "Caro Giménez" y "Maestra · Soles".
- [x] 2.3 Cablar el logout del rail y del panel al callback `onLogout` (sin `comingSoon`) y alinear el tooltip del avatar del rail con la salida; verificar con un test de widget que tocar el avatar del rail invoca el callback y no muestra "Próximamente".

## 3. Layout compacto con AppBar y Drawer

- [x] 3.1 Reemplazar la rama `<600 px` de `AppShell` por `AppBar` + `Drawer` con `AppNavigationPanel`, `Drawer(width: min(248, 0.85 * ancho))` y cierre al elegir destino; verificar a 400x800 que aparece `app-top-bar`, no existe `app-bottom-nav` y no hay overflow.
- [x] 3.2 Envolver el contenido en `SafeArea` en las tres ramas (solo el contenido, no el `Row` del sidebar/rail); verificar con `MediaQuery` con insets simulados en un widget test que la cabecera no queda tapada y el fondo del sidebar sigue a altura completa.
- [x] 3.3 Añadir al `AppBar` el avatar y la acción de logout accesibles, con el nombre del usuario en el drawer; verificar con un test a 400 px que abrir el menú muestra nombre, rol y la acción de salida.
- [x] 3.4 Actualizar `test/ui/features/feed/home_view_test.dart` con las nuevas keys y los casos de drawer; verificar con `flutter test test/ui/features/feed/home_view_test.dart`.
- [x] 3.5 Verificar visualmente en Chrome a 400, 800 y 1440 px contra `docs/templates/feed.dc.html` y registrar diferencias aceptadas en el resumen del cambio.

## 4. Ruta de login y logout funcional

- [x] 4.1 Crear `lib/ui/features/login/views/login_placeholder_view.dart` sin campos de credenciales, con marca, mensaje de "en preparación" y acción para volver a `/`; verificar con un widget test que no existen campos de texto ni botón de envío.
- [x] 4.2 Registrar `GoRoute('/login')` en `lib/app/router/app_router.dart`; verificar con un test que `routerProvider` resuelve `/login` y que el `errorBuilder` sigue devolviendo el home.
- [x] 4.3 Pasar `onLogout: () => context.go('/login')` desde `HomeView` al `AppShell`; verificar con un test de widget con `MaterialApp.router` que tras tocar logout se muestra la vista de login.
- [x] 4.4 Consumir `sessionUserProvider` en `HomeView`/`FeedHeader` y eliminar el literal `'Caro'`; verificar con el test del home que el saludo sigue siendo "Buenas, Caro" sin literales en la vista.

## 5. Integración y validación final

- [x] 5.1 Añadir `integration_test/` con el flujo home → abrir drawer → logout → pantalla de login, usando `ProviderScope(overrides:)` y datos fake; verificar con `flutter test integration_test` en un dispositivo o emulador Android.
- [x] 5.2 Ejecutar `flutter analyze`, `flutter test` y `flutter gen-l10n` sin errores ni warnings nuevos; verificar que el árbol de `test/` replica la estructura de `lib/` para los archivos nuevos.

## Workflow follow-up

- Archivar el cambio cuando la revisión esté aprobada, para que la delta de `feed` actualice `openspec/specs/feed/spec.md`.
- Abrir el cambio de autenticación real: estado de sesión, guard en `routerProvider`, `flutter_secure_storage` y pantalla de login definitiva.
