# Convenciones del proyecto daily_care

## Estado actual

- El repo es un esqueleto Flutter: solo existe `lib/main.dart` (plantilla "Hello World", aún con `package:flutter/material.dart` y sin `ProviderScope`). No hay `test/`, `l10n.yaml` ni capas `data/`/`domain/`/`ui/`.
- Las reglas de abajo son vinculantes para el código nuevo; migra `main.dart` cuando lo toques.
- Plataformas registradas: solo `android` y `web`. Para otra plataforma usa `flutter create --platforms=<p> .`.

## Entorno

- Flutter 3.47.7 / Dart 3.13.5 (`pubspec.yaml` exige `^3.13.5`).
- `flutter_riverpod 3.4.3`, `go_router 18.1.1`, `material_ui 1.8.0`, `flutter_lints 6.0.0`.
- `package:flutter/material.dart` y `package:flutter/cupertino.dart` están congelados y serán deprecados en noviembre de 2026. El código nuevo importa `package:material_ui/material_ui.dart` o `package:cupertino_ui/cupertino_ui.dart`; migra un archivo legacy con `dart fix --apply --code=migrate_design_widgets` solo cuando lo modifiques, salvo que se pida una migración completa.
- `cupertino_ui` (1.1.4) es hoy dependencia transitiva: añádela con `flutter pub add cupertino_ui` antes de importarla o `depend_on_referenced_packages` fallará.
- Si una dependencia todavía usa los imports legacy, envuélvela con `MaterialUiCompatibilityBridge` en `MaterialApp.builder` solo durante la transición.

## Orden de aplicación de skills

1. `flutter-apply-architecture-best-practices`
2. `flutter-implement-json-serialization`
3. `flutter-setup-localization`
4. `flutter-setup-declarative-routing`
5. `flutter-build-responsive-layout`
6. `flutter-add-integration-test`

No apliques una skill si la funcionalidad no la necesita.

## Decisiones vinculantes

- **Modelos**: una sola estrategia. Propiedades `final` con `fromJson`/`toJson` manuales. No añadas `freezed` ni `build_runner` sin justificarlo.
- **Capas**: `data/models` (API), `data/services` (HTTP), `data/repositories`, `domain/models`, `ui/features/<feature>/{views,view_models}`. La UI nunca importa modelos de API.
- **Estado/DI**: Riverpod 3 (`flutter_riverpod`). Un único `ProviderScope` en la raíz. `Provider` para servicios/repositorios; `Notifier`/`AsyncNotifier` para estado; `AsyncValue` para loading/error. No usar `ChangeNotifierProvider`, `StateProvider` ni `StateNotifierProvider` (legacy) ni mezclar con `provider` o `get_it`.
- **App raíz**: `ProviderScope` > `MaterialApp.router` con `routerConfig`, `localizationsDelegates` y `supportedLocales`.
- **Navegación**: `routerProvider` con `authProvider` y `ref.listen(authProvider, ...) => router.refresh()`; valida los `pathParameters`; el `errorBuilder` muestra un mensaje genérico. No usar un `GoRouter` global ni `ValueNotifier` para la sesión.
- **Tests**: `ProviderScope(overrides: [...])` para widgets e integración; `ProviderContainer.test(overrides: [...])` para unit tests. Nunca usar servicios reales ni datos PHI.
- **l10n**: `flutter: generate: true` + `l10n.yaml` con `synthetic-package: false` y `nullable-getter: false`; importa el archivo generado, nunca `package:flutter_gen`.
- **Layout**: `LayoutBuilder` o `MediaQuery.sizeOf`; shell con `NavigationBar` por debajo de 600 px y `NavigationRail` desde 600 px.

## Seguridad (datos de salud)

- No loggear modelos, tokens ni PHI; no mostrar bodies de error crudos en la UI.
- Guardar tokens en `flutter_secure_storage`, nunca en `SharedPreferences`.
- Validar y autorizar cada recurso en el servidor; el `redirect` de `go_router` no autoriza datos.
- Toda petición HTTP: HTTPS, timeout, límite de tamaño, `Content-Type` validado y `utf8.decode(response.bodyBytes)`.
- Cachear datos de paciente solo con TTL y limpiar la caché al cerrar sesión.
- Tests con datos anonimizados y servicios fake.

## OpenSpec

- El repo usa OpenSpec (`openspec/config.yaml`, schema `spec-driven`). Los cambios viven en `openspec/changes/` y las specs principales en `openspec/specs/`; no edites specs principales a mano durante un cambio.
- Comandos disponibles: `.opencode/commands/opsx-*.md` (`/opsx-new`, `/opsx-propose`, `/opsx-apply`, `/opsx-archive`, ...).
- Los flujos de planificación (`propose`, `new`) no editan código: no implementes en el mismo paso; espera a que se pida `apply`.

## Skills

- Las copias locales de `.agents/skills` incluyen correcciones sobre upstream (`l10n`, `integration_test`, `go_router`, Riverpod 3, serialización y layout adaptativo). Los skills de OpenSpec están en `.opencode/skills`.
- `skills-lock.json` no refleja estas ediciones ni lista los skills de OpenSpec. Regenera el lock con el instalador antes de actualizar desde `flutter/agent-plugins` para no perder los cambios.

## Validación

```bash
flutter analyze                      # único paso que pasa hoy tal cual
flutter test                         # requiere crear test/ primero
flutter gen-l10n                     # requiere generate: true y l10n.yaml primero
```

`analysis_options.yaml` usa `flutter_lints` y excluye `build/`, `android/` y `web/` del analyzer.
