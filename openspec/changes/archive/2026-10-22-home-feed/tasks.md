# Tasks

## 1. Estructura, dependencias y bootstrap

- [x] 1.1 Crear el árbol completo de carpetas de `design.md` (sección 0) con `.gitkeep` en las hojas vacías; verificar que `lib/app`, `lib/core`, `lib/domain`, `lib/data`, `lib/ui`, `lib/l10n`, `test` e `integration_test` existen con la jerarquía acordada.
- [x] 1.2 Consultar Context7 para `gen-l10n`, `go_router` y `flutter_riverpod` antes de escribir código; verificar que las APIs y firmas usadas coinciden con `go_router` 18 y `flutter_riverpod` 3.4.1, y dejar constancia de la versión consultada en `design.md`.
- [x] 1.3 Añadir `flutter_localizations`, `intl` y `flutter_svg`; crear `l10n.yaml` (`arb-dir: lib/l10n`, `app_es.arb`, `nullable-getter: false`; sin `synthetic-package` porque Flutter 3.47 lo ignora) y `lib/l10n/app_es.arb` con todas las claves de UI; verificar con `flutter gen-l10n` que se genera `lib/l10n/app_localizations.dart` sin mensajes sin traducir.
- [x] 1.4 Reemplazar `lib/main.dart` por `initializeDateFormatting('es')` + `ProviderScope` + `App`, y crear `lib/app/app.dart` con `MaterialApp.router`, delegates de localización y `supportedLocales: [Locale('es')]`; crear `lib/app/router/app_router.dart` con la ruta `/`; verificar con `flutter analyze` y un widget test que la app arranca.
- [x] 1.5 Extraer los íconos de la plantilla a `assets/icons/` y declararlos en `pubspec.yaml`; verificar que `flutter pub get` resuelve y que `flutter analyze` pasa.
- [x] 1.6 Descargar Fredoka y Nunito (pesos usados) a `assets/fonts/` y declararlas en `pubspec.yaml`; verificar que la app compila y que las fuentes aparecen en el bundle de assets.
- [x] 1.7 Crear `lib/app/theme/{app_colors.dart, app_typography.dart, app_theme.dart}` con los tokens del HTML, `ScrollbarTheme` y la extensión de tema para badges; verificar con `flutter analyze` y un test que compruebe los valores principales de `AppColors`.

## 2. Widgets compartidos del shell

- [x] 2.1 Implementar `lib/ui/core/widgets/app_link.dart` con `MouseRegion(cursor: click)`, foco/teclado, `Semantics` y `SnackBar` con la clave `comingSoon`; verificar con widget test que un tap muestra el aviso localizado y no cambia de ruta.
- [x] 2.2 Implementar `lib/ui/core/widgets/dashed_box.dart` (borde punteado con `CustomPainter`) y `app_avatar.dart`; verificar con widget test de render sin excepciones y con el radio/color esperados.
- [x] 2.3 Implementar el sidebar, rail y `NavigationBar` en `lib/ui/core/widgets/app_shell.dart` con breakpoints 900/600 y etiquetas desde ARB; verificar con tests a 1200, 800 y 400 px que se muestra el shell correcto y no hay overflow.

## 3. Dominio, datos y estado

- [x] 3.1 Crear `lib/domain/models/post.dart` y `post_type.dart` con entidad inmutable y token de color (sin imports de Flutter); verificar con `flutter analyze` que el dominio no depende de `data/` ni de Flutter.
- [x] 3.2 Crear el contrato `lib/domain/repositories/feed_repository.dart` y `lib/core/result.dart` con `Result`/`Failure`; verificar con `flutter analyze`.
- [x] 3.3 Implementar `data/datasources/local/demo_feed_datasource.dart` y `data/repositories/feed_repository_impl.dart` con los tres posts de demostración; verificar con unit test que devuelve `Success` con 3 elementos y `Failure` cuando el datasource falla.
- [x] 3.4 Implementar `ui/features/feed/view_models/feed_view_model.dart` como `AsyncNotifier` con `retry()`; verificar con `ProviderContainer.test` que expone datos y que un fallo se refleja en `AsyncError`.

## 4. Home feed

- [x] 4.1 Implementar `feed_header.dart` y `feed_section_label.dart` con claves de ARB y fecha `DateFormat('EEEE d MMM', 'es')`; verificar con widget test de los textos localizados ("Buenas, Caro", "12 niños · …", "PUBLICADO HOY") y de la fecha en español.
- [x] 4.2 Implementar `composer_bar.dart` con avatar, hint, cámara y enlace a nueva publicación; verificar con widget test de render y de aviso "Próximamente" al activarlo.
- [x] 4.3 Implementar `post_type_badge.dart` y `feed_post_card.dart` con los tres tipos, metadatos, foto punteada, contadores y "Editar"; verificar con widget tests para logro, actividad con foto y anuncio.
- [x] 4.4 Componer `home_view.dart` con `AsyncValue` (loading/error/data) sobre `AppShell`; verificar con widget test que muestra los tres posts con un repositorio fake y el mensaje de error localizado con uno que falla.

## 5. Verificación de integración

- [x] 5.1 Ejecutar `flutter gen-l10n`, `flutter analyze` y `flutter test`; verificar que los tres terminan sin errores.
- [x] 5.2 Ejecutar `dart format --output=none --set-exit-if-changed lib test`; verificar que no hay archivos sin formatear.
- [x] 5.3 Levantar la app en Chrome y comparar a 920×540 y 1440×900 contra `docs/templates/feed.dc.html` y `docs/desing/feed.png`; ajustar espaciados, fuentes o sombras hasta que no haya diferencias visibles.
- [x] 5.4 Revisar manualmente cursor, foco por teclado y aviso "Próximamente" en todos los enlaces del home y del sidebar.

## Workflow follow-up

- Archivar el cambio después de la revisión visual y cuando `flutter analyze` y `flutter test` pasen.
- Verificar el resultado archivado y mover `home-feed` a `openspec/changes/archive/`.
