# Convenciones del proyecto daily_care

## Estado actual

- El home (`/`) ya está implementado con la estructura por capas: `lib/app`, `lib/core`, `lib/domain`, `lib/data`, `lib/ui` y `lib/l10n`. `lib/main.dart` solo arranca la app; existen `test/` e `integration_test/`.
- Las reglas de abajo son vinculantes para el código nuevo; sigue el árbol de "Estructura de capas".
- Plataformas registradas: solo `android` y `web`. Para otra plataforma usa `flutter create --platforms=<p> .`.

## Entorno

- Flutter 3.47.7 / Dart 3.13.5 (`pubspec.yaml` exige `^3.13.5`).
- `flutter_riverpod 3.4.3`, `go_router 18.1.1`, `material_ui 1.8.0`, `flutter_svg 2.3.0`, `flutter_lints 6.0.0`. `flutter_localizations` (SDK) e `intl` para l10n y fechas.
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

## Estructura de capas

Arquitectura en capas con MVVM + Repository y regla de dependencia explícita.

```text
lib/
├── app/                          # bootstrap, router, tema, l10n, composition root
├── core/                         # Result/Failure, excepciones, logger, config, formatters
├── domain/
│   ├── models/                   # entidades inmutables, sin JSON
│   ├── value_objects/            # unidades, pesos, macros, periodos
│   ├── repositories/             # CONTRATOS (clases abstractas)
│   └── use_cases/                # lógica de negocio reutilizable
├── data/
│   ├── models/                   # DTOs con fromJson/toJson
│   ├── datasources/remote/       # clientes HTTP
│   ├── datasources/local/        # drift/sqflite, caché persistente
│   ├── services/                 # plataforma: health, notificaciones, barcode
│   └── repositories/             # implementan los contratos de domain
└── ui/
    ├── core/                     # widgets, tema y formatters compartidos
    └── features/<feature>/{views, view_models, widgets}
```

- **Regla de dependencia**: `ui → domain`, `data → domain`; `core` sin dependencias de capas. `ui` y `domain` nunca importan `data/`.
- **Contratos obligatorios**: todo repositorio expone una interfaz abstracta en `domain/repositories/`; el provider apunta a la interfaz y se sobreescribe en tests.
- **Use cases obligatorios** cuando haya cálculo, agregación, conversión de unidades, sincronización o regla compartida entre features. Un CRUD simple puede ir directo al repositorio.
- **Errores tipados**: repositorios y use cases devuelven `Result<T>` (`Success`/`Failure` en `core/`); `data` traduce excepciones a `Failure` sin exponer bodies ni detalles internos.
- **Sin lógica de negocio en `views` ni en `view_models`** más allá del estado y la orquestación.
- **Tests**: `test/` replica la estructura de `lib/` (`test/domain/`, `test/data/`, `test/ui/`); los flujos van en `integration_test/`.
- **`main.dart` solo arranca** (`ProviderScope` + `App`); router, tema y l10n viven en `lib/app/`.

## Decisiones vinculantes

- **Modelos**: una sola estrategia. Propiedades `final` con `fromJson`/`toJson` manuales, solo en `data/models` cuando exista capa de dominio. No añadas `freezed` ni `build_runner` sin justificarlo.
- **Capas**: sigue el árbol de "Estructura de capas". La UI nunca importa modelos de API ni implementaciones de `data/`.
- **Estado/DI**: Riverpod 3 (`flutter_riverpod`). Un único `ProviderScope` en la raíz. `Provider` para servicios/repositorios; `Notifier`/`AsyncNotifier` para estado; `AsyncValue` para loading/error. No usar `ChangeNotifierProvider`, `StateProvider` ni `StateNotifierProvider` (legacy) ni mezclar con `provider` o `get_it`.
- **App raíz**: `ProviderScope` > `MaterialApp.router` con `routerConfig`, `localizationsDelegates` y `supportedLocales`.
- **Navegación**: `routerProvider` en `lib/app/` con `authProvider` y `ref.listen(authProvider, ...) => router.refresh()`; valida los `pathParameters`; el `errorBuilder` muestra un mensaje genérico. No usar un `GoRouter` global ni `ValueNotifier` para la sesión.
- **Tests**: `ProviderContainer.test(overrides: [...])` para unit tests en `test/domain` y `test/data`; `ProviderScope(overrides: [...])` para widgets en `test/ui` e integración en `integration_test/`. Nunca usar servicios reales ni datos PHI.
- **l10n**: `flutter: generate: true` + `l10n.yaml` con `arb-dir: lib/l10n` y `nullable-getter: false`. Flutter 3.47 ya no acepta `synthetic-package` (se ignora y avisa); no lo incluyas. Importa el archivo generado en `lib/l10n/`, nunca `package:flutter_gen`.
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
flutter analyze
flutter test
flutter gen-l10n
```

`analysis_options.yaml` usa `flutter_lints` y excluye `build/`, `android/` y `web/` del analyzer.
