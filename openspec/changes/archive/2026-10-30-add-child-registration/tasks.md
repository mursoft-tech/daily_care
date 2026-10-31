# Tasks

## 1. Modelo de alergias y notas médicas

- [x] 1.1 Reemplazar `Child.allergy` por `Child.allergies : List<Allergy>` y agregar `Child.medicalNotes : String` (por defecto vacío), con `hasAllergy => allergies.isNotEmpty` y `fullName` recortado; verificar con `flutter test test/domain/models/child_test.dart` actualizado a listas y notas.
- [x] 1.2 Actualizar `DemoKidsDataSource` a lista de instancia (constructor no `const`) conservando los ocho niños, con las alergias de Mateo y Tomás como listas; verificar con `flutter test test/data/repositories/kids_repository_test.dart` (ocho niños, `allergies.first.notes` de Mateo).
- [x] 1.3 Ajustar `ChildCard` para el badge con primera etiqueta y ` +N` cuando hay varias alergias, y `ProfileAllergyBanner` para recibir `allergies` y `medicalNotes`, pintar un chip por alergia y mostrar el bloque cuando hay alergias o notas; verificar con `flutter test test/ui/features/kids/child_card_test.dart test/ui/features/kids/child_profile_view_test.dart`.
- [x] 1.4 Actualizar `child_profile_view.dart` al nuevo contrato del banner y verificar que Sofía no muestre el bloque y un niño con varias alergias muestre un chip por etiqueta (`flutter test test/ui/features/kids/child_profile_view_test.dart`).

## 2. Dominio y datos del alta

- [x] 2.1 Crear `ChildDraft` en `domain/value_objects/` con `fullName`, `birthDateText`, `room`, `allergyLabels` y `medicalNotes`; verificar con tests unitarios de normalización de nombre (una palabra, nombre compuesto).
- [x] 2.2 Agregar `parseBirthDate(String)` en `core/formatters/app_date_formatter.dart` que valide `dd/MM/yyyy` y la existencia real de la fecha (rechaza `31/02/2023`, acepta `29/02/2024`); verificar con `flutter test test/core/formatters/app_date_formatter_test.dart`.
- [x] 2.3 Crear la lista de salas en `domain` (`kRooms = ['Soles']`) y verificar que el alta preseleccione `kRooms.first` en los tests del caso de uso.
- [x] 2.4 Implementar `CreateChild` (use case) con validaciones (obligatorios, fecha inválida, futura, edad > 6 vía `calculateAge` y `todayProvider`), armado de `Child` (id slug con sufijo ante colisión, `enrolledAt` hoy, `colorToken` rotado, `guardians` vacío, alergias desde etiquetas) y `Result` tipado; verificar con `flutter test test/domain/use_cases/create_child_test.dart`.
- [x] 2.5 Sumar `addChild(Child)` a `KidsRepository`, `KidsRepositoryImpl`, `KidsDataSource` y `DemoKidsDataSource`, traduciendo excepciones a `Failure`; verificar con tests de repositorio (agrega y luego se lee por id) y `flutter test test/data/repositories/kids_repository_test.dart`.
- [x] 2.6 Registrar `createChildUseCaseProvider` en `app/providers.dart`; verificar con `flutter test test/app/providers_test.dart`.

## 3. Formulario de alta

- [x] 3.1 Extender `AppTextField` con `maxLines` e `inputFormatters` opcionales sin romper los usos actuales; verificar con `flutter test test/ui/core/widgets/app_text_field_test.dart`.
- [x] 3.2 Crear `BirthDateInputFormatter` en `lib/ui/core/formatters/` (solo dígitos, barras automáticas, pegado normalizado); verificar con tests unitarios del formatter para tecleo, pegado y borrado.
- [x] 3.3 Crear `AppSelectField` con el estilo del template para el campo "Sala"; verificar con un widget test que muestre `Soles` preseleccionado.
- [x] 3.4 Implementar `NewChildState`/`NewChildViewModel` con `isSaving`, `RegistrationError?` y `submit(ChildDraft)` que llame al caso de uso y devuelva éxito/errores tipados; verificar con `test/ui/features/kids/new_child_view_model_test.dart`.
- [x] 3.5 Implementar la vista y el formulario de alta (cabecera Cancelar/Guardar, cinco campos, errores por campo, layout de una columna bajo 600 px) parametrizado con `initialDraft` y `onSubmit`; verificar con `test/ui/features/kids/new_child_view_test.dart` (campos obligatorios, errores de fecha y edad, cancelar).
- [x] 3.6 Agregar las claves `childForm*` a `lib/l10n/app_es.arb` y regenerar; verificar con `flutter gen-l10n` y que la vista no tenga textos hardcodeados (`flutter analyze`).

## 4. Navegación y conexión con el listado

- [x] 4.1 Agregar `AppRoutes.newChild = '/kids/nuevo'` y la `GoRoute` **antes** de `/kids/:childId`; verificar con `flutter test test/app/router/app_router_test.dart` que `/kids/nuevo` muestra el formulario y no "no encontrado".
- [x] 4.2 Cambiar `KidsHeader` a `onAddChild` callback y cablearlo en `KidsView` a `context.go(AppRoutes.newChild)`; verificar con `test/ui/features/kids/kids_view_test.dart` que la acción navega y ya no muestra "Próximamente".
- [x] 4.3 Al guardar con éxito, invalidar `kidsViewModelProvider`, volver a `/kids` con el buscador vacío y mostrar el niño nuevo en la grilla; verificar con un widget test que parte de una búsqueda activa y comprueba tarjetas y contador actualizados.
- [x] 4.4 Cubrir el estado del niño nuevo (sin padres -> "VINCULAR", edad calculada, sin badge si no hay alergias); verificar en el mismo test de listado.

## 5. Verificación integral

- [x] 5.1 Agregar `integration_test/child_registration_flow_test.dart` (listado -> Agregar niño -> completar -> Guardar -> vuelve a `/kids` con el niño visible y buscador vacío); verificar con `flutter test integration_test/child_registration_flow_test.dart`.
- [x] 5.2 Ejecutar `flutter analyze`, `flutter test` y `flutter gen-l10n` sin errores ni warnings nuevos.
