# Tasks

## 1. Base visual y localización

- [x] 1.1 Agregar a `lib/app/theme/app_colors.dart` los pares de color de avatar rosa, verde, amarillo y morado, más los colores de badge de alergia y vinculación; verificar que `flutter analyze` no reporte constantes sin usar.
- [x] 1.2 Crear `assets/icons/search.svg` y `assets/icons/chevron-right.svg` a partir de la plantilla; verificar que la app renderice ambos íconos con `AppIcon`.
- [x] 1.3 Agregar a `lib/l10n/app_es.arb` las claves `kidsEyebrow`, `kidsTitle`, `addChild`, `searchChildHint`, `kidsRoomLabel`, `kidsCount`, `childAge`, `linkedParents`, `linkParentBadge`, `noKidsResults`, `kidsError` y `loadingKids`; ejecutar `flutter gen-l10n` y verificar que `app_localizations.dart` incluya los getters nuevos.

## 2. Dominio y datos

- [x] 2.1 Crear `lib/domain/models/child.dart` con `id`, `firstName`, `lastName`, `ageYears`, `linkedParents`, `allergyLabel?` y `colorToken`, más `fullName` e `initial`; verificar con un test unitario que `fullName` e `initial` se construyan correctamente.
- [x] 2.2 Crear el contrato `lib/domain/repositories/kids_repository.dart` y el contrato del datasource en `lib/data/datasources/kids_data_source.dart`; verificar que compilen con `flutter analyze`.
- [x] 2.3 Implementar `lib/data/datasources/local/demo_kids_data_source.dart` con los ocho niños del template (Mateo Fernández, Sofía Méndez, Benjamín Ruiz, Valentina Soto, Tomás Díaz, Emma Castro, Lucas Romero y Olivia Vega); verificar que el listado incluya alergias, vinculaciones y tokens de color.
- [x] 2.4 Implementar `lib/data/repositories/kids_repository_impl.dart` y registrar `kidsDataSourceProvider` y `kidsRepositoryProvider` en `lib/app/providers.dart`; verificar con `test/data/repositories/kids_repository_test.dart` que devuelva `Success` con ocho niños y `Failure(DataFailure)` ante excepción del datasource.

## 3. Filtrado y estado

- [x] 3.1 Crear `lib/domain/use_cases/filter_children.dart` con normalización de mayúsculas, tildes españolas y ñ; verificar con `test/domain/use_cases/filter_children_test.dart` que "sofia" encuentre "Sofía" y que un texto sin coincidencias devuelva una lista vacía.
- [x] 3.2 Crear `lib/ui/features/kids/view_models/kids_view_model.dart` con `KidsState(all, query)` y `AsyncNotifier`, incluyendo `build()`, `search(query)` y `retry()`; verificar que la búsqueda no vuelva a invocar el repositorio y que `retry()` recargue.

## 4. Pantalla de niños

- [x] 4.1 Implementar `lib/ui/features/kids/widgets/kids_header.dart` con la etiqueta "GESTIÓN", el título "Niños" y el botón "Agregar niño" como `AppLink`; verificar que en menos de 480 px de contenido el botón pase debajo del título sin overflow.
- [x] 4.2 Implementar `lib/ui/features/kids/widgets/kids_search_field.dart` con el contenedor del template, ícono de búsqueda, etiqueta semántica y acción de limpiar; verificar que escribir actualice el ViewModel y que el texto se pueda borrar.
- [x] 4.3 Implementar `lib/ui/features/kids/widgets/child_card.dart` con avatar de 48 px, nombre, edad, vinculación, badge de alergia, badge "VINCULAR" o chevron, y hover con elevación; verificar con un widget test que la alergia tenga prioridad sobre "VINCULAR".
- [x] 4.4 Implementar `lib/ui/features/kids/views/kids_view.dart` con `AppShell(selectedIndex: 1)`, cabecera, buscador, sección con total, grilla y estados de carga, error, reintento y vacío; verificar con `test/ui/features/kids/kids_view_test.dart` el render de las ocho tarjetas, el filtro, el estado vacío y el reintento.
- [x] 4.5 Verificar el layout de la grilla en `test/ui/features/kids/kids_view_test.dart`: dos columnas con contenido de 700 px o más, una columna por debajo y sin excepciones de overflow en 400 px.

## 5. Navegación

- [x] 5.1 Crear `lib/app/router/app_routes.dart` con las constantes de `/`, `/kids` y `/login` y reemplazar los strings sueltos del router; verificar con `flutter analyze`.
- [x] 5.2 Agregar la ruta `/kids` a `lib/app/router/app_router.dart`; verificar con `test/app/router/app_router_test.dart` que la ruta resuelva `KidsView`.
- [x] 5.3 Agregar la ruta opcional a `AppDestination` y hacer que `AppShell` navegue con `context.go` para los destinos implementados, conservando "Próximamente" para el resto; verificar que "Niños" navegue a `/kids` desde sidebar, rail y drawer, y que "Avisos" siga mostrando el aviso.
- [x] 5.4 Actualizar `test/ui/core/widgets/app_shell_test.dart` y `test/ui/features/feed/home_view_test.dart` para el nuevo comportamiento de "Niños"; verificar que `flutter test test/ui/core test/ui/features/feed` pase completo.

## 6. Verificación de integración

- [x] 6.1 Crear `integration_test/kids_flow_test.dart` que abra `/`, active "Niños", compruebe el listado y vuelva al feed con "Feed"; verificar que el test pase en el entorno de integración del proyecto.
- [x] 6.2 Ejecutar `flutter gen-l10n`, `flutter analyze` y `flutter test`; verificar que los tres terminen sin errores ni advertencias nuevas.
