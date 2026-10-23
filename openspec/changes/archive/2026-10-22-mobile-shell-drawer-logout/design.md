# Design

## Context

Ver `proposal.md` para la motivación. El estado actual relevante:

- `AppShell` usa `LayoutBuilder` con tres ramas (≥900 sidebar, 600-899 rail, <600 `NavigationBar`) y el bloque de cuenta solo existe en el sidebar; el rail muestra un avatar cuyo tooltip dice "Cerrar sesión" pero que ejecuta el `comingSoon` de `AppLink`.
- La identidad simulada está dispersa: `AppShell._accountName = 'Caro Giménez'`, inicial `'C'` literal y `FeedHeader(name: 'Caro')` en `home_view.dart`. El rol sale de `l10n.teacherRole`.
- `routerProvider` solo define `/` y el `errorBuilder` devuelve `HomeView`.
- No hay `SafeArea` ni `MediaQuery` en `lib/`.

Restricciones del proyecto: Riverpod 3 (`Provider` para servicios, sin `StateProvider`), `MaterialApp.router` con `go_router`, `ui → domain` sin importar `data/`, textos de UI desde ARB, `material_ui` en código nuevo, y tests con `ProviderScope(overrides:)`.

## Goals / Non-Goals

**Goals:**

- Un único widget de navegación reutilizado por sidebar y drawer.
- Un único origen del usuario simulado, consumible por el shell y por la cabecera del feed.
- Dejar la acción de logout cablada a navegación real, de modo que auth real solo sustituya la pantalla destino.
- Mantener `AppShell` desacoplado del router.

**Non-Goals:**

- Estado de sesión mutable, guards, persistencia de credenciales y `redirect`.
- Rediseño del sidebar o del rail más allá de alinear la acción de logout.
- Añadir textos de login definitivos (solo placeholder).

## Decisions

### 1. Estructura del layout compacto

`AppShell` en compacto pasa a:

```text
Scaffold
├── appBar: AppBar(surface, sin elevación, borde inferior)
│     leading: botón de menú (abre el drawer)
│     title:   logo + nombre de marca + sala
│     actions: avatar del usuario, acción de logout
├── drawer:  Drawer(width: min(248, 0.85 * ancho))
│     └── contenido de navegación compartido + bloque de cuenta
└── body: SafeArea(child: contenido)
```

En ≥900 y 600-899 el `Scaffold` no tiene `appBar`: se mantiene `Row(sidebar|rail, Expanded(child))`, y el `SafeArea` envuelve solo el `Expanded`, no el `Row`, para que el fondo del sidebar/rail siga ocupando toda la altura.

Se conservan las `Key` existentes (`app-sidebar`, `app-rail`) y se añaden `app-top-bar`, `app-menu-button` y `app-drawer`. La key `app-bottom-nav` desaparece.

Alternativa descartada: `NavigationBar` + hoja de cuenta. Mantiene el patrón actual, pero no resuelve el acceso lateral y obliga a un tap extra para el logout.

### 2. Contenido de navegación compartido

Se extrae el interior del sidebar a `AppNavigationPanel` (`lib/ui/core/widgets/app_navigation_panel.dart`) con: marca, CTA de nueva publicación, destinos y bloque de cuenta. Parámetros: `selectedIndex`, `onDestinationSelected`, `onLogout`, `sessionUser`.

- Sidebar: `Container(width: 248)` que lo envuelve.
- Drawer: `Drawer(width: ...)` que lo envuelve y cierra el panel al elegir destino (`Navigator.pop`).
- El selector de destinos sigue usando `_onDestination` (SnackBar "Próximamente"), sin navegación real.

Esto evita dos copias del bloque de cuenta y garantiza paridad visual entre anchos.

### 3. Usuario simulado en un solo origen

- `lib/domain/models/session_user.dart`: entidad inmutable `SessionUser` con `id`, `firstName`, `fullName`, `initial` y `role` (`SessionRole.teacher | SessionRole.family`). Sin dependencias de Flutter ni textos de UI.
- `lib/app/providers.dart`: `sessionUserProvider = Provider<SessionUser>((ref) => const SessionUser.demo())`.
- El rol se traduce en UI (`teacherRole` / futuro `familyRole`), no se guarda como texto localizado en el dominio.
- `FeedHeader` recibe `name` desde `sessionUser.firstName` en `HomeView`; el avatar del shell usa `initial`.
- El provider no es mutable todavía: no hay `Notifier` de sesión porque no existe auth. Cuando exista, este provider se reemplaza por el estado real sin cambiar los widgets.

Alternativa descartada: constantes en `AppShell`. Es lo que ya existe y provoca la dispersión actual.

### 4. Logout como callback, no como navegación interna

`AppShell` recibe `onLogout: VoidCallback` obligatorio y lo propaga al panel, al rail y al `AppBar`. `HomeView` pasa `() => context.go('/login')`.

Así `AppShell` sigue sin importar `go_router` (mantiene la decisión del cambio anterior) y el logout es testeable sin router. El aviso "Próximamente" del `AppLink` dejará de aplicar a la acción de logout porque se pasa `onTap` explícito.

En el rail, el avatar deja de tener semántica ambigua: su `onTap` y su tooltip pasan a ser la acción de salida, igual que en el resto de layouts.

### 5. Ruta `/login`

`GoRoute(path: '/login')` con `LoginPlaceholderView` (`lib/ui/features/login/views/login_placeholder_view.dart`), fuera de `AppShell`:

- Muestra logo, marca y un texto del tipo "Pantalla de inicio de sesión en preparación".
- No pide credenciales, no valida y no crea estado de sesión.
- Incluye una acción para volver a `/` con `context.go('/')`.

`errorBuilder` se mantiene devolviendo `HomeView` en esta etapa.

### 6. `SafeArea`

- Compacto: el `AppBar` consume el inset superior; el `SafeArea` del body cubre el inferior (barra de gestos), ahora que no hay `NavigationBar`.
- Medio y grande: `SafeArea` alrededor del contenido cubre barra de estado (tablet Android) y gestos.
- En web y desktop los insets son cero, así que no hay cambio visual.

### 7. Localización

Nuevas claves en `app_es.arb`: `menuTooltip` ("Abrir menú"), `logoutLabel` ("Cerrar sesión" como texto accesible), `loginComingSoonTitle` y `loginComingSoonBody`, `backToFeed` ("Volver al feed"). Se reutiliza `logoutTooltip` para el tooltip y `brandName`/`salaName` en el `AppBar`. Regenerar con `flutter gen-l10n`.

### 8. Assets

Se añade `assets/icons/menu.svg` con el mismo trazo Lucide del resto (líneas de hamburguesa, 24x24, `stroke-width` 2). Se usa vía `AppIcon`, sin `Icons.menu` de Material, por consistencia de trazos.

### 9. Tests

- `home_view_test.dart`: la aserción de 400 px pasa a esperar `app-top-bar` y ausencia de `app-bottom-nav`; se añaden casos de apertura del drawer (`app-drawer`), visibilidad de nombre y rol, y logout navegando a `/login`.
- Los tests que ejercitan logout necesitan router: se pumpea con `MaterialApp.router` y `routerProvider`, o con un `GoRouter` de prueba, en lugar de `MaterialApp(home:)`.
- `integration_test/`: flujo abrir home → abrir drawer → tocar logout → ver la pantalla de login. Es el primer flujo multipantalla real del proyecto.

## Risks / Trade-offs

- **Pérdida de un tap menos en móvil** → Drawer exige abrir menú para cambiar de sección; se compensa con destinos visibles en el `AppBar` no, pero sí con el botón de menú siempre accesible.
- **Nombre duplicado** (franja/drawer + "Buenas, Caro") → Se acepta: el drawer muestra identidad completa y el saludo es contextual.
- **Drawer demasiado ancho en 320 px** → `min(248, 0.85 * ancho)`.
- **`SafeArea` mal ubicado en sidebar/rail** (dejaría franjas sin fondo) → Envolver solo el contenido, nunca el `Row`.
- **Tests existentes con `MaterialApp(home:)`** → Migrarlos a `MaterialApp.router` cuando el caso toque logout; el resto sigue igual.
- **Launch de login como placeholder** → Riesgo de que se lea como auth falsa; la pantalla declara explícitamente que está en preparación y no acepta datos.
- **`AppShell` pasa a `ConsumerWidget`** → Aceptable: lee `sessionUserProvider`; no introduce estado mutable ni acopla a `data/`.

## Migration Plan

1. Añadir `SessionUser`, `sessionUserProvider`, claves ARB e ícono de menú.
2. Extraer `AppNavigationPanel` y hacer que el sidebar lo use (sin cambio visual).
3. Reemplazar el layout compacto por `AppBar` + `Drawer` y aplicar `SafeArea`.
4. Añadir `/login` con la vista placeholder y cablar `onLogout`.
5. Ajustar `HomeView`/`FeedHeader` al usuario del provider.
6. `flutter gen-l10n`, `flutter analyze`, `flutter test`, integración.

Rollback: revertir el cambio; no hay migraciones ni datos persistidos. La ruta `/login` puede quedar sin uso sin afectar al home.

## Open Questions

Ninguna que afecte el alcance. El contenido definitivo del login y la sesión real se resolverán en el cambio de autenticación.
