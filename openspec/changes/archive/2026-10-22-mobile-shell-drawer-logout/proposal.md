# Proposal

## Why

En anchos compactos el shell descarta el bloque de cuenta, así que el usuario logueado y la salida de la aplicación no existen en Android; además, el icono de logout del sidebar solo muestra "Próximamente" y el contenido queda bajo la barra de estado por falta de `SafeArea`. Resolverlo ahora fija el patrón de navegación móvil antes de añadir las pantallas restantes y la autenticación real.

## What Changes

- **BREAKING** (visual): en anchos menores a 600 px se reemplaza la `NavigationBar` inferior por un `AppBar` con botón de menú y un `Drawer` modal de 248 px que reúne marca, botón de nueva publicación, destinos y bloque de cuenta.
- El `Drawer` reutiliza el contenido del sidebar para no mantener dos versiones de la navegación y se cierra al elegir un destino.
- El usuario simulado pasa a un único origen: modelo de sesión en `domain/models/` y provider demo en `app/`, reemplazando los literales `'Caro Giménez'`, `'Caro'` y `'C'` dispersos en `app_shell.dart` y `home_view.dart`.
- El icono/botón de logout deja de mostrar "Próximamente": navega a la ruta `/login`, que se crea como pantalla placeholder sin credenciales, sin validación y sin estado de sesión.
- Se aplica `SafeArea` al cuerpo del shell en los tres layouts para respetar la barra de estado y la barra de gestos.
- El sidebar (≥900 px) y el rail (600-899 px) conservan su estructura; el avatar del rail alinea su acción y su tooltip con la salida de la aplicación.
- Se actualiza el test de breakpoints que espera `app-bottom-nav` y se añade el primer test de integración del flujo `/` → `/login`.

Fuera de alcance: autenticación real, validación de credenciales, `flutter_secure_storage`, guard con `authProvider` y `redirect`, diseño definitivo de la pantalla de login, rutas `/ninos`, `/avisos` y `/mi-cuenta`, y migración a `StatefulShellRoute`.

## Capabilities

### New Capabilities

- Ninguna.

### Modified Capabilities

- `feed`: el shell compacto pasa a `AppBar` + `Drawer`, se añade la exposición del usuario logueado y la salida hacia `/login`, y el logout queda exceptuado del aviso "Próximamente".

## Impact

- `lib/ui/core/widgets/app_shell.dart`: nuevo layout compacto, `AppBar`, `Drawer`, `SafeArea` y extracción del contenido de navegación compartido.
- `lib/app/router/app_router.dart`: ruta `/login`.
- Nuevos: vista placeholder de login y modelo de sesión demo con su provider.
- `lib/ui/features/feed/views/home_view.dart` y `lib/ui/features/feed/widgets/feed_header.dart`: consumen el usuario desde el provider en lugar de literales.
- `lib/l10n/app_es.arb`: textos del menú, de la pantalla de login placeholder y etiquetas accesibles; se regenera con `flutter gen-l10n`.
- `test/ui/features/feed/home_view_test.dart`: cambia la aserción de breakpoint y se añade cobertura para drawer y logout.
- `integration_test/`: se activa el flujo `/` → `/login` (la skill de integración estaba diferida por falta de flujos multipantalla).
- Sin dependencias nuevas, sin cambios de backend y sin persistencia.
