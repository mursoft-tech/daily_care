# Design

## Context

Ver `proposal.md` para la motivación. El repo solo contiene la plantilla de Flutter; no hay router, tema, capas ni tests. La referencia visual es `docs/templates/feed.dc.html` y el screenshot `docs/desing/feed.png` (920×540). El trabajo se hace en la rama `pagina_inicial` y es el primer cambio OpenSpec del proyecto.

Restricciones del proyecto (`AGENTS.md`): Riverpod 3, `MaterialApp.router`, capas `app/core/domain/data/ui`, contratos de repositorio, `Result<T>`, `main.dart` mínimo y tests con `ProviderScope`/`ProviderContainer`.

## Goals / Non-Goals

**Goals:**

- Reproducir el home con la mayor fidelidad posible en colores, tipografía, espaciados, radios y sombras.
- Dejar creada desde el primer commit la estructura completa de carpetas de la arquitectura objetivo, no solo las carpetas que el home usa.
- Configurar l10n desde el inicio: todos los textos de UI salen de ARB en español, con fecha formateada por `intl`.
- Dejar un shell reutilizable y adaptable para futuras pantallas.
- Fijar el patrón de feature (modelo de dominio → contrato → repositorio demo → ViewModel → View) sin sobreingeniería.
- Validar el comportamiento de enlaces (cursor + aviso) con tests.

**Non-Goals:**

- Rutas de las pantallas enlazadas, autenticación, base de datos, HTTP y serialización JSON.
- Traducciones a otros idiomas; solo se configura el locale `es` y se deja listo para añadir ARB.
- Golden tests como requisito de CI; se pueden añadir después.
- Animaciones, dark mode y hover visual avanzado (solo cursor y foco).

## Decisions

### 0. Estructura inicial y skills aplicadas

Se crea el árbol completo al inicio del cambio, con `.gitkeep` en las hojas vacías para que Git conserve las carpetas:

```text
lib/
├── app/
│   ├── app.dart
│   ├── router/app_router.dart
│   └── theme/{app_colors.dart, app_typography.dart, app_theme.dart}
├── core/
│   └── result.dart
├── domain/
│   ├── models/{post.dart, post_type.dart}
│   ├── value_objects/.gitkeep
│   ├── repositories/feed_repository.dart
│   └── use_cases/.gitkeep
├── data/
│   ├── models/.gitkeep
│   ├── datasources/
│   │   ├── remote/.gitkeep
│   │   └── local/demo_feed_datasource.dart
│   ├── services/.gitkeep
│   └── repositories/feed_repository_impl.dart
└── ui/
    ├── core/widgets/{app_shell.dart, app_link.dart, app_avatar.dart, dashed_box.dart}
    └── features/feed/
        ├── views/home_view.dart
        ├── view_models/feed_view_model.dart
        └── widgets/{feed_header.dart, composer_bar.dart, feed_section_label.dart, post_type_badge.dart, feed_post_card.dart}
l10n.yaml
lib/l10n/
├── app_es.arb
└── app_localizations.dart          # generado por flutter gen-l10n
test/
├── domain/.gitkeep
├── data/repositories/feed_repository_test.dart
└── ui/features/feed/home_view_test.dart
integration_test/.gitkeep
```

Skills aplicadas y justificación:

| Skill | Se aplica | Motivo |
|---|---|---|
| `flutter-apply-architecture-best-practices` | Sí | Crea el esqueleto, la regla de dependencia y el contrato de repositorio. |
| `flutter-setup-declarative-routing` | Sí | `ProviderScope` + `MaterialApp.router` + `routerProvider` para `/`. |
| `flutter-build-responsive-layout` | Sí | Shell con breakpoints y contenido con `maxWidth`. |
| `flutter-setup-localization` | Sí | `l10n.yaml`, ARB en `es`, `AppLocalizations` y delegates en `App`. |
| `flutter-implement-json-serialization` | No | No hay API ni JSON; los datos demo se construyen como entidades. |
| `flutter-add-integration-test` | No | Los flujos multipantalla aún no existen; se cubre con widget tests y se activará al añadir rutas. |

Las carpetas vacías no se eliminan: `.gitkeep` mantiene el compromiso de estructura y evita recrearlas en cada feature.

Antes de escribir código se consulta **Context7** para confirmar las APIs vigentes de `gen-l10n`, `go_router` y `flutter_riverpod`; las decisiones de este documento se basan en (consulta: 2026-10-21):
- Flutter: `generate: true`, `synthetic-package: false` y salida en `arb-dir`.
- `go_router` 18: `MaterialApp.router` + `GoRouter`, sin `Navigator` directo.
- `flutter_riverpod` 3.4.1: `ProviderScope`, `AsyncNotifierProvider`, `ProviderContainer.test`, `AsyncValue` con pattern matching.

### 1. Arranque y navegación

`main.dart` queda en `runApp(const ProviderScope(child: App()))`. `App` vive en `lib/app/app.dart` y usa `MaterialApp.router` con `routerProvider` en `lib/app/router/`. `GoRouter` define solo `/` → `HomeView`; las rutas futuras se añadirán al mismo router.

Alternativa descartada: `Navigator` con `home:`. Impide deep links y contradice las convenciones del proyecto.

No se usa `StatefulShellRoute` todavía: hay una sola ruta. `AppShell` envuelve el contenido y recibe el destino activo; cuando existan las demás pantallas se migra a `StatefulShellRoute.indexedStack`.

### 2. Design system en `lib/app/theme`

- `app_colors.dart`: tokens del HTML (`background #F6ECDF`, `surface #FFFDF9`, `border #ECE0D0`, `textStrong #3F362E`, `textMuted #94887B`, `textSoft #A89A8B`, `primary #EE8164`, `primarySoft #F4977E`, `accent #D9583C`, etc.).
- `app_typography.dart`: `TextTheme` con Fredoka para títulos/nombres/números y Nunito para cuerpo y UI.
- `app_theme.dart`: `ThemeData` con `scaffoldBackgroundColor`, radios, sombras, `ScrollbarTheme` y `ThemeExtension` para los colores de badge por tipo de publicación.
- Ningún hex suelto en widgets; los badges usan una extensión de tema, no colores en el dominio.

### 3. Fuentes bundleadas

Se descargan Fredoka y Nunito (licencia OFL) a `assets/fonts/` y se declaran en `pubspec.yaml`. Se incluyen solo los pesos usados: Fredoka 500/600; Nunito 400/600/700/800 y su itálica 400 si se necesita.

Alternativas: `google_fonts` (descarga en runtime, FOUT y dependencia de red) y fuentes del sistema (no fieles). Se descartan por fidelidad y funcionamiento offline.

### 4. Íconos SVG

Se extraen los SVG inline de la plantilla a `assets/icons/` y se renderizan con `flutter_svg`, aplicando color con `ColorFilter`/`currentColor`. Incluye logo, navegación, cámara, corazón, comentario, imagen y logout.

Alternativa descartada: `Icons.*` de Material. Reduce fidelidad en trazos y proporciones. Un paquete de íconos Lucide añadiría dependencia y posiblemente variantes distintas.

### 5. Shell adaptativo

`AppShell` en `lib/ui/core/widgets/app_shell.dart` usa `LayoutBuilder`:

```
>= 900  -> Sidebar 248 px + Expanded(content)
600-899 -> NavigationRail (solo íconos) + Expanded(content)
< 600   -> content + NavigationBar inferior
```

`NavigationBar` y `NavigationRail` comparten los cuatro destinos. El sidebar replica el bloque de marca, CTA, navegación y cuenta. El contenido del home mantiene `maxWidth: 760`, centrado y con padding 34/40/80.

No se usa `MediaQuery.orientationOf` ni se detecta tipo de dispositivo.

### 6. Capa de datos demo

- `domain/models/post.dart`: entidad inmutable con `id`, `childName`, `childInitial`, `childColorToken`, `timeLabel`, `audience`, `type`, `body`, `likes`, `comments`, `photoLabel`.
- `domain/models/post_type.dart`: enum `achievement`, `activity`, `announcement`.
- `domain/repositories/feed_repository.dart`: `Future<Result<List<Post>>> loadPosts()`.
- `data/datasources/local/demo_feed_datasource.dart`: lista inmutable con las tres publicaciones.
- `data/repositories/feed_repository_impl.dart`: implementa el contrato, simula una carga breve y devuelve `Success`/`Failure`; nunca lanza hacia la UI.
- Sin DTO ni `fromJson` porque no hay JSON todavía.

El color del avatar se modela como token (`childColorToken`) para que el dominio no dependa de Flutter.

### 7. Estado

`FeedNotifier extends AsyncNotifier<List<Post>>` en `ui/features/feed/view_models/`, con provider. `build()` llama al contrato; `retry()` refresca. La vista hace pattern matching sobre `AsyncValue` y muestra loading/error/data. El repositorio/provider puede sobrescribirse en tests.

### 8. Enlaces

Widget reutilizable `AppLink` en `lib/ui/core/widgets/app_link.dart`:

- `MouseRegion(cursor: SystemMouseCursors.click)`.
- `InkWell`/`FocusableActionDetector` para teclado y foco.
- `Semantics(link: true, button: true)` y tooltip opcional.
- `onTap` por defecto muestra un `SnackBar` con la clave `comingSoon` de `AppLocalizations`; no cambia de ruta.
- Se usa en sidebar, CTA, composer, "Editar", detalle y el placeholder de foto.

### 9. Fidelidad y detalles

- Sombra de tarjetas: `BoxShadow(color: Color(0x1A785A3C), blurRadius: 16, offset: Offset(0, 4), spreadRadius: -12)`.
- Placeholder de foto: `CustomPainter` con borde punteado `#DBCDBA`, radio 16, fondo `#F4ECE1`.
- Scrollbar: thumb `#E4D6C4`, 10 px, borde transparente de 3 px.
- Avatares circulares con inicial y color por niño.
- Badges con punto de 8 px y mayúsculas con letter-spacing 0.5.

### 10. Localización

- Dependencias: `flutter_localizations` (SDK) e `intl`.
- `l10n.yaml`:
  ```yaml
  arb-dir: lib/l10n
  template-arb-file: app_es.arb
  output-localization-file: app_localizations.dart
  nullable-getter: false
  ```
  > Flutter 3.47 ignora y marca como obsoleto `synthetic-package`; se omite.
- `app_es.arb` es la fuente de verdad. Incluye al menos: marca y sala, navegación, "Nueva publicación", saludo con nombre, resumen con cantidad y fecha, "PUBLICADO HOY", audiencias, tipos de publicación, "Editar", "Próximamente", composer, estados de error/reintento y etiquetas de foto.
- Placeholders con metadata y plurales donde aplique (por ejemplo, cantidad de niños).
- `App` configura `localizationsDelegates` (`AppLocalizations.delegate`, `GlobalMaterialLocalizations.delegate`, `GlobalWidgetsLocalizations.delegate`, `GlobalCupertinoLocalizations.delegate`) y `supportedLocales: [Locale('es')]`.
- La fecha se formatea con `DateFormat('EEEE d MMM', 'es')`; `main()` llama `initializeDateFormatting('es')` antes de `runApp` y por eso es `async`.
- Los textos de contenido de las publicaciones demo permanecen en el datasource; los textos de UI salen de ARB.
- Import del generado: `package:daily_care/l10n/app_localizations.dart`, nunca `package:flutter_gen`.

### 11. Tests

- `test/ui/features/feed/home_view_test.dart`: render de cabecera, composer y tres tarjetas con `ProviderScope(overrides: [feedRepositoryProvider.overrideWithValue(FakeFeedRepository())])` y los delegates de localización (`AppLocalizations.delegate` y globales).
- Test de enlaces: `find.byType(AppLink)` + tap → `SnackBar` con el texto de `comingSoon`; verificar `MouseRegion.cursor == SystemMouseCursors.click`.
- Test de breakpoints con `tester.view.physicalSize` y `devicePixelRatio`: presencia de sidebar, rail y `NavigationBar` en 1200/800/400 px.
- `test/data/repositories/feed_repository_test.dart`: devuelve `Success` con datos y `Failure` cuando el datasource falla.
- Verificar que `flutter gen-l10n` genera `app_localizations.dart` sin mensajes sin traducir.

## Risks / Trade-offs

- **Métricas tipográficas distintas al navegador** → Usar los mismos tamaños/line-height del HTML y comparar screenshots a 920 y 1440 px; ajustar `height` del `TextStyle` si hace falta.
- **Colores/estilos dispersos** → Tokens centralizados y lint de revisión; prohibido hex en widgets.
- **SVGs con `currentColor`** → Verificar render de cada ícono y usar `ColorFilter` cuando no herede color.
- **Peso de assets** → Incluir solo pesos de fuente usados y optimizar SVGs.
- **SnackBar repetida al hacer clic rápido** → `hideCurrentSnackBar()` antes de mostrar.
- **Futuro cambio a `StatefulShellRoute`** → Mantener `AppShell` desacoplado del router mediante `selectedIndex` y callbacks.
- **Código generado de l10n fuera de sincronía** → Ejecutar `flutter gen-l10n` tras cada cambio de ARB y no editar el archivo generado a mano.
- **Fecha sin datos de locale** → `initializeDateFormatting('es')` antes de `runApp`; test que renderiza la fecha en español.

## Migration Plan

1. Reemplazar `lib/main.dart` por el bootstrap mínimo (`initializeDateFormatting` + `ProviderScope` + `App`).
2. Crear el árbol completo de `app/`, `core/`, `domain/`, `data/`, `ui/` y `l10n/` con los archivos anteriores.
3. Añadir fuentes, íconos y dependencias (`flutter_svg`, `flutter_localizations`, `intl`); configurar `l10n.yaml` y generar `AppLocalizations`.
4. Implementar el home y el shell usando claves de ARB.
5. `flutter gen-l10n` + `flutter analyze` + `flutter test`.
6. Verificación visual con la app en Chrome a 920×540 y 1440×900 contra `feed.png` y la plantilla HTML.

Rollback: revertir la rama `pagina_inicial`; no hay migraciones de datos ni cambios de backend.

## Open Questions

Ninguna que afecte el alcance actual. El reemplazo de rutas placeholder y las traducciones a otros idiomas se resolverán en cambios posteriores.
