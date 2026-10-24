# Tasks

## 1. Domain

- [x] 1.1 Crear el value object `Allergy` con `label` y `notes` en `lib/domain/value_objects/`, y verificar con `test/domain/value_objects/allergy_test.dart` que etiqueta y notas quedan inmutables.
- [x] 1.2 Crear `Guardian` con `GuardianRelationship` y `GuardianStatus` en `lib/domain/models/`, y verificar con tests que un padre activo y uno invitado se distinguen.
- [x] 1.3 Extender `Child` con `birthDate`, `room`, `enrolledAt`, `allergy` y `guardians`, con `linkedParents` derivado de la lista, y actualizar `test/domain/models/child_test.dart` para cubrir cero, uno y dos padres.
- [x] 1.4 Implementar el caso de uso `calculateAge(birthDate, today)` con años cumplidos, y verificar con tests los casos de cumpleaños cumplido, no cumplido y nacido un 29 de febrero.
- [x] 1.5 Ejecutar `flutter test test/domain` y confirmar que toda la capa de dominio pasa.

## 2. Data and providers

- [x] 2.1 Agregar `fetchChild(id)` a `KidsDataSource` y completar `DemoKidsDataSource` con las ocho fichas (fechas coherentes con las edades del template, ingreso, alergias con notas y padres con rol/estado); verificar con `test/data/repositories/kids_repository_test.dart`.
- [x] 2.2 Implementar `KidsRepository.loadChild(id)` devolviendo `Success(null)` para un id inexistente y `Failure` ante una excepción; actualizar los fakes de los tests y cubrir los tres casos.
- [x] 2.3 Exponer `todayProvider` en `lib/app/providers.dart` y verificar en `test/app/providers_test.dart` que se puede sobreescribir con una fecha fija.
- [x] 2.4 Ejecutar `flutter test test/data test/app/providers_test.dart` y confirmar que datos y providers pasan.

## 3. Shared UI foundations

- [x] 3.1 Agregar las claves nuevas a `lib/l10n/app_es.arb` (ficha, alergias, datos, padres, roles, estados, badges, acciones, carga/error/no encontrado) y ejecutar `flutter gen-l10n`; verificar que los getters generados existen y que no quedan claves crudas.
- [x] 3.2 Agregar a `AppColors` los tokens del banner de alergias, el avatar azul de padre y los estados activo/pendiente, y crear `assets/icons/alert-triangle.svg` y `assets/icons/chevron-left.svg`; verificar que `pubspec.yaml` ya incluye la carpeta y que la app compila.
- [x] 3.3 Crear los formateadores de fecha `d MMM y` y `MMM y` en `lib/core/formatters/` y verificarlos con tests para "12 mar 2023" y "feb 2025".
- [x] 3.4 Extraer el mapeo de paletas de avatar de `child_card.dart` a un helper compartido de la feature `kids` y verificar que `child_card_test.dart` sigue pasando sin cambios de comportamiento.

## 4. Routing and kids navigation

- [x] 4.1 Agregar `AppRoutes.childProfile` y `AppRoutes.childProfilePath(id)`, registrar `/kids/:childId` en `app_router.dart` y verificar con `test/app/router/app_router_test.dart` el acceso directo a una ficha y que las rutas existentes siguen resolviendo.
- [x] 4.2 Pasar la edad calculada y un callback de navegación a `ChildCard` desde `KidsView`, y verificar con `kids_view_test.dart` que tocar una tarjeta navega a `/kids/:childId` usando un harness con `GoRouter`.
- [x] 4.3 Actualizar los tests de `/kids` para sobreescribir `todayProvider` con una fecha fija y conservar las expectativas de edad y de padres; ejecutar `flutter test test/ui/features/kids test/app/router` y confirmar que pasan.

## 5. Child profile screen

- [x] 5.1 Implementar `ChildProfileViewModel` con familia por id, estado con `Child?`/`ageYears`, `retry` y distinción entre no encontrado y error; verificarlo con tests de éxito, no encontrado, error y reintento.
- [x] 5.2 Crear los widgets de cabecera, enlace de volver, banner de alergias condicional y tarjeta de datos con fechas localizadas; verificar con tests de contenido para Mateo (con alergia) y Sofía (sin alergia).
- [x] 5.3 Crear la tarjeta de padres con avatar, rol, estado, badges ACTIVA/PENDIENTE, estado vacío y acción de vincular; verificar con tests para Mateo, un solo padre y Valentina sin padres.
- [x] 5.4 Componer `ChildProfileView` con `AppShell`, CTA "Resumen del día", acciones "Próximamente" y estados de carga, error y no encontrado; verificar con tests que las acciones muestran el aviso sin cambiar de ruta y que "Volver a Niños" navega a `/kids`.
- [x] 5.5 Aplicar el layout de dos columnas desde 640 px y apilado por debajo, y verificar con tests en 1200, 800 y 400 px que no hay overflow horizontal ni excepciones.
- [x] 5.6 Ejecutar `flutter analyze` y `flutter test test/ui/features/kids` y confirmar que la feature completa pasa sin warnings.

## 6. Integration

- [x] 6.1 Agregar `integration_test/child_profile_flow_test.dart` que navegue de `/kids` a la ficha de Mateo, compruebe sus datos y vuelva al listado; ejecutarlo en al menos un ancho de escritorio y uno compacto.
- [x] 6.2 Ejecutar `flutter analyze` y `flutter test` completos y confirmar que no hay regresiones en feed, navegación ni l10n.

## 7. Search persistence

- [x] 7.1 Pasar la consulta activa de `KidsState` a `KidsSearchField` y sincronizar su controller sin reemitir `onChanged`; verificar con un test que al volver de una ficha se conservan el texto "so" y el filtro aplicado.
- [x] 7.2 Cubrir volver sin búsqueda y limpiar después de volver; verificar que reaparecen las ocho tarjetas con `flutter test test/ui/features/kids` y `flutter analyze`.

## Workflow follow-up

- Archivar el change cuando la revisión del proyecto esté aprobada.
- Verificar el resultado archivado y que las specs principales reflejen el perfil y la navegación de tarjetas.
