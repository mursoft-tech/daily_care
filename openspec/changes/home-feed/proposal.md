# Proposal

## Why

El repositorio es todavía la plantilla de Flutter y no tiene una pantalla real que valide la identidad visual del producto. La plantilla `docs/templates/feed.dc.html` define el look & feel definitivo del home (colores, tipografía, tarjetas y sidebar). Implementarlo ahora como primer corte visual permite fijar el design system, el shell de navegación y la estructura por capas antes de añadir autenticación, API o persistencia.

## What Changes

- Crear desde el inicio la estructura completa de carpetas definida en `AGENTS.md` y en la skill de arquitectura, con placeholders `.gitkeep` para las capas que aún no tienen código:
  - `lib/app/{router,theme}`.
  - `lib/core/`.
  - `lib/domain/{models,value_objects,repositories,use_cases}`.
  - `lib/data/{models,datasources/{remote,local},services,repositories}`.
  - `lib/ui/{core/widgets,features/feed/{views,view_models,widgets}}`.
  - `lib/l10n/` para ARB y código generado.
  - `test/{domain,data,ui}` e `integration_test/`.
- Aplicar las skills en este orden y solo donde aportan a este cambio:
  1. `flutter-apply-architecture-best-practices` → esqueleto completo y reglas de dependencia.
  2. `flutter-setup-localization` → `l10n.yaml`, ARB en español y `AppLocalizations` en `App`.
  3. `flutter-setup-declarative-routing` → `routerProvider`, `MaterialApp.router` y `App`.
  4. `flutter-build-responsive-layout` → shell adaptable y breakpoints.
  5. `flutter-implement-json-serialization` y `flutter-add-integration-test` quedan diferidas: no hay JSON ni flujos multipantalla que justifiquen `integration_test`.
- Antes de generar código, validar con Context7 la configuración vigente de `gen-l10n`, `go_router` 18 y `flutter_riverpod` 3.4.1; toda navegación y todo estado se implementan con esas APIs, sin `Navigator` directo ni gestores alternativos.
- Configurar l10n en español (`es`) con `generate: true` y `nullable-getter: false` (`synthetic-package` ya no existe en Flutter 3.47). Todos los textos visibles del home (navegación, cabecera, composer, badges, acciones, estados y aviso "Próximamente") provienen de ARB; la fecha se formatea con `intl`/`DateFormat` en locale `es`.
- Implementar la pantalla Home (`/`) con fidelidad visual a `docs/templates/feed.dc.html`: sidebar, cabecera, composer, etiqueta de sección y las tres tarjetas de publicación.
- Crear el shell responsive:
  - `>= 900 px`: sidebar completo de 248 px.
  - `600–899 px`: rail de íconos.
  - `< 600 px`: `NavigationBar` inferior con los cuatro destinos.
- Definir el design system en `lib/app/theme`: paleta, tipografía (Fredoka + Nunito bundleadas como assets), radios, sombras y alturas.
- Bundlear las fuentes Fredoka y Nunito en `assets/fonts` para evitar dependencia de red y FOUT.
- Usar íconos SVG equivalentes a los inline de la plantilla, extraídos a `assets/icons`.
- Convertir cada `<a>` de la plantilla en un enlace con cursor `click` que muestra un aviso "Próximamente"; no navega todavía a otras pantallas.
- Servir las publicaciones desde un repositorio demo detrás de un contrato de dominio. Sin autenticación, sin base de datos, sin HTTP y sin serialización JSON por ahora.
- Añadir pruebas de widget para el render del feed y para el comportamiento de los enlaces, y tests unitarios del repositorio demo.

Fuera de alcance: las pantallas enlazadas (`crear-publicacion`, `ninos`, `avisos`, `mi-cuenta`, `login`, `detalle-publicacion`, `foto`), autenticación, persistencia, API y lógica de negocio de likes/comentarios (los contadores permanecen estáticos).

## Capabilities

### New Capabilities

- `feed`: visualización del feed del home con sus publicaciones, metadatos, tipos (logro, actividad, anuncio), composer y estado de carga/error proveniente del repositorio.

### Modified Capabilities

- Ninguna.

## Impact

- `lib/main.dart`: pasa a ser solo el arranque (`ProviderScope` + `App`).
- Nuevos: `lib/app/` (app, router, tema), `lib/core/`, `lib/domain/` (modelos, value objects, contratos, use cases), `lib/data/` (models, datasources remote/local, services, repositories), `lib/ui/` (shell y feature feed), `lib/l10n/` (ARB y generados), `test/{domain,data,ui}` e `integration_test/`. Las carpetas sin contenido quedan con `.gitkeep` para conservar la estructura.
- `pubspec.yaml`: fuentes bundleadas, assets de íconos, `flutter_svg`, `flutter_localizations` (SDK) e `intl`; `flutter: generate: true`. No se añaden aún `http` ni `integration_test`.
- `l10n.yaml` en la raíz con `arb-dir: lib/l10n`, template `app_es.arb` y `nullable-getter: false`; sin `synthetic-package` porque Flutter 3.47 lo ignora.
- `test/`: pruebas de widget y unitarias del repositorio demo, con delegates de localización.
- Skills diferidas con su justificación: serialización JSON (no hay JSON) e integración (no hay flujo multipantalla).
- Sin impacto en backend, autenticación ni almacenamiento.
