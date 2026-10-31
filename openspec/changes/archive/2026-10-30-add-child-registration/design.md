# Design

## Context

Ver `proposal.md`. Puntos del estado actual que condicionan el diseño:

- `KidsHeader` construye el botón "Agregar niño" con `AppLink` sin `onTap`, y `AppLink` cae en el aviso "Próximamente".
- `KidsRepository`/`KidsDataSource` solo leen (`loadChildren`, `loadChild`); `DemoKidsDataSource` guarda `static final List<Child> _children`.
- `Child` exige `id`, `firstName`, `lastName`, `birthDate`, `room`, `enrolledAt`, `colorToken`, `allergy?` y `guardians`.
- `AppTextField` no soporta `maxLines` ni `inputFormatters`; no existe un select con el estilo del template.
- `KidsViewModel` es un `AsyncNotifier` que guarda `query` y expone `search(...)`; `KidsSectionHeader` usa `state.all.length`.
- `calculateAge(birthDate, today)` ya existe y `todayProvider` permite fechas deterministas en tests.
- `kids` fija hoy que "Agregar niño" muestra "Próximamente"; este cambio lo reemplaza.

## Goals / Non-Goals

**Goals:**

- Alta de un niño end-to-end sobre datos en memoria, con las tres validaciones de negocio (fecha real, no futura, edad <= 6) en el dominio.
- Modelo de alergias que soporte varias etiquetas y notas médicas sin perder información.
- Formulario preparado para "Editar" sin implementarlo.
- Cero regresiones en el listado, la ficha y el shell.

**Non-Goals:**

- Editar o eliminar niños, vincular padres, persistencia real (drift/sqflite/API).
- Autocompletado de salas, ordenamiento o paginación del listado.
- Migrar el resto del código a un nuevo patrón de formularios.

## Decisions

### 1. Ruta estática declarada antes de la ficha

`AppRoutes.newChild = '/kids/nuevo'` y la `GoRoute` se declara **antes** de `/kids/:childId`; go_router resuelve por orden de declaración y de lo contrario "nuevo" se interpretaría como un `childId` y caería en "no encontrado". La vista usa `AppShell(selectedIndex: 1)` para mantener "Niños" resaltado.

Alternativa descartada: `/kids?nuevo=1` o un modal, que no soportan enlace directo ni encajan con el template.

### 2. Validación y construcción del niño en el dominio

Se introduce `ChildDraft` (value object puro) con lo que el formulario captura:

```text
ChildDraft
  fullName       : String
  birthDateText  : String      // tal como se teclea, dd/mm/aaaa
  room           : String
  allergyLabels  : List<String> // separadas por coma
  medicalNotes   : String
```

`CreateChild` (use case) es el único lugar que:

- valida campos obligatorios, formato, fecha real, no futura y edad <= 6 (usa `calculateAge` y `todayProvider`);
- normaliza el nombre: `firstName` = primera palabra, `lastName` = resto (vacío si hay una sola); `fullName` recorta espacios;
- genera `id` (slug sin tildes del nombre + sufijo `-2`, `-3`… si colisiona con el listado);
- fija `enrolledAt` = hoy y `colorToken` rotando la paleta existente;
- arma `List<Allergy>` desde las etiquetas (cada una con `notes` vacío) y `guardians: const []`;
- devuelve `Result<Child>` con `Failure` tipado.

Alternativas descartadas: validar en el `view_model` (duplica reglas cuando llegue "Editar") y que el datasource asigne id/color (mete reglas de negocio en `data/`).

### 3. Contrato de repositorio: `addChild(Child)`

`KidsRepository` suma `Future<Result<Child>> addChild(Child child)`. El caso de uso necesita `loadChildren()` de todos modos para calcular id y color, así que el repositorio recibe un `Child` ya completo y solo lo persiste; `KidsRepositoryImpl` traduce excepciones a `Failure` como el resto de los métodos.

Alternativa descartada: `createChild(ChildDraft)` en el repositorio, que obligaría a repetir validación en la capa de datos.

### 4. Persistencia demo con lista por instancia

`DemoKidsDataSource` deja de ser `const` y `_children` pasa a ser una lista de instancia sembrada desde una plantilla, para que cada `ProviderScope` de test tenga su propio listado (hoy un `static` mutable filtraría niños entre tests). `addChild` hace `_children.add(child)` y resuelve `fetchChild`/`fetchChildren` sobre esa lista.

Los datos viven solo en memoria: reiniciar la app vuelve a los ocho niños de demostración. Nada se escribe en disco ni se loguea (datos de salud).

### 5. Estado del formulario: `Notifier` + controladores, errores tipados

Se sigue el patrón de `ActivateForm`/`ActivateAccountViewModel`: `ConsumerStatefulWidget` con `TextEditingController` para los textos y un `Notifier<NewChildState>` para `isSaving`, `savedChildId` y una lista de `RegistrationError` tipados. Los textos no se espejan en el estado (los controladores son la fuente); el `Notifier` solo recibe el `ChildDraft` al guardar y traduce el `Result` a errores de campo.

El caso de uso valida todos los campos y devuelve la lista completa de errores, de modo que nombre y fecha faltantes se señalan a la vez. `RegistrationError` (enum del dominio, sin strings): `nameRequired`, `birthDateRequired`, `birthDateInvalid`, `birthDateFuture`, `birthDateTooOld`, `roomRequired`, `saveFailed`. La UI mapea cada valor a una clave de l10n.

El `Notifier` se resetea en un `addPostFrameCallback` del formulario: resetearlo en `initState` notificaba al `ConsumerWidget` que lo estaba construyendo.

### 6. Fecha: máscara en UI, parseo estricto en core

- `BirthDateInputFormatter` (en `lib/ui/core/formatters/`) acepta solo dígitos y arma `dd/mm/aaaa`; al pegar `12/03/2023` descarta separadores y vuelve a enmascarar.
- `parseBirthDate(String)` en `lib/core/formatters/app_date_formatter.dart` parsea `dd/MM/yyyy` y valida existencia real comparando el `DateTime` reconstruido (rechaza `31/02/2023`); devuelve `null` si no es válido.
- El dominio no depende de widgets: recibe el texto, no el input formatter.

Alternativa descartada: `showDatePicker`, que contradice el requisito de tecleo y el template.

### 7. Badge y bloque de alergias

- `Child.hasAllergy => allergies.isNotEmpty`; `ChildCard` muestra `allergies.first.label` y, si hay más, ` +N` (una sola pastilla, sin romper el layout).
- `ProfileAllergyBanner` recibe `allergies` y `medicalNotes`: un `Wrap` de chips por etiqueta y, debajo, el detalle de cada alergia seguido de las notas médicas no vacías. Se renderiza si hay alergias **o** notas.
- `Child.allergy` desaparece; los llamados pasan a `allergies`/`medicalNotes`.

### 8. Acción del header vía callback

`KidsHeader` recibe `VoidCallback onAddChild` y `KidsView` lo cablea a `context.go(AppRoutes.newChild)`. Mantiene el widget sin dependencia de router y testable como el resto (`ChildCard`, `ProfileBackLink`).

### 9. Volver al listado limpia búsqueda con `invalidate`

Al guardar: `ref.invalidate(kidsViewModelProvider)` y `context.go('/kids')`. El provider no es autoDispose, así que el `query` anterior sobreviviría; invalidar reconstruye el estado con `query: ''`, lo que cumple "buscador limpio" y refresca la grilla y el contador en una sola operación. No se agrega `clearSearch()`.

### 10. Formulario reutilizable para "Editar"

`NewChildForm` recibe `initialDraft` (por defecto vacío) y un `Future<bool> Function(ChildDraft) onSubmit`; la vista de alta pasa el borrador vacío. "Editar" queda fuera de alcance y sigue con "Próximamente"; cuando se implemente, reutiliza el form y un `UpdateChild` con las mismas reglas.

### 11. Localización

Todas las claves nuevas van en `lib/l10n/app_es.arb` (`childForm*`): título, cancelar, guardar, nombre, fecha, ayuda, sala, alergias, notas, errores de cada regla y etiqueta accesible de guardado en curso. Sin claves en la UI.

## Risks / Trade-offs

- **Ruta estática tapada por la dinámica** -> test de router que abre `/kids/nuevo` y espera el formulario; declaración antes de `/kids/:childId`.
- **Lista estática compartida entre tests** -> lista de instancia en el datasource; los tests crean su propio `DemoKidsDataSource`.
- **Refactor de alergias rompe tarjeta, ficha y tests** -> cambio mecánico y centralizado en `Child`; se ajustan demo, widgets y pruebas en la misma tarea.
- **`invalidate` también resetea la búsqueda del usuario** -> es el comportamiento pedido; se documenta en la spec y se cubre con test.
- **Máscara de fecha y pegado** -> el formatter normaliza siempre desde los dígitos; test con pegado y con borrado.
- **Datos de salud en memoria** -> no se loguean ni se muestran en errores; los mensajes son genéricos.
- **Sin persistencia real** -> aceptado y especificado como demo; el contrato `addChild` es el punto de reemplazo cuando exista API.

## Migration Plan

1. Modelo (`Child`, `Allergy`, demo, tarjeta, ficha) y tests ajustados.
2. Dominio del alta (`ChildDraft`, `CreateChild`, `addChild` en contrato/repositorio/datasource) con tests.
3. Ruta, vista, form, formatter y l10n.
4. Wiring de la acción del header, provider del alta y vuelta al listado.
5. Tests de widget, router e integración.

Sin migración de datos: no hay almacenamiento previo que convertir. Rollback = revertir el cambio; los niños creados en memoria se pierden de todos modos.

## Open Questions

Ninguna que afecte specs, enfoque o tareas.
