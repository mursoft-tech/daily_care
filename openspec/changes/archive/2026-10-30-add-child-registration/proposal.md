# Proposal

## Why

Hoy la acción "Agregar niño" de `/kids` solo muestra el aviso "Próximamente": no existe ruta de alta ni forma de sumar un niño a la sala. La plantilla `docs/templates/agregar-nino.dc.html` ya define el formulario, así que conectar esa acción permite completar el flujo de gestión de la sala sin esperar a una base de datos ni a una API.

Además, el modelo actual guarda una sola alergia (`Allergy?`), mientras la plantilla pide varias etiquetas de alergia y un campo aparte de notas médicas. Registrar un niño con el modelo actual perdería datos o los mezclaría.

## What Changes

- **Nueva ruta `/kids/nuevo`** con el formulario de la plantilla: cabecera con "Cancelar" y "Guardar", nombre completo, fecha de nacimiento, sala, alergias y notas médicas.
- **La acción "Agregar niño" navega a `/kids/nuevo`** en lugar de mostrar "Próximamente". Los enlaces de tarjeta y el comportamiento de hover no cambian.
- **Campos obligatorios**: nombre completo, fecha de nacimiento y sala. Alergias y notas médicas son opcionales.
- **Fecha tecleada con auto-formato `dd/mm/aaaa`**: solo se aceptan dígitos y las barras aparecen solas. Se valida formato, existencia real de la fecha, que no sea futura y que la edad cumplida no supere 6 años.
- **Persistencia en memoria**: guardar agrega el niño al datasource de demostración, invalida el listado, limpia el buscador y vuelve a `/kids`, donde aparece la tarjeta nueva. Los datos se pierden al reiniciar la app (no hay BD ni API todavía).
- **Modelo de alergias múltiples**: `Child.allergies` pasa a ser una lista y se agrega `Child.medicalNotes`. La ficha muestra un chip por alergia y las notas médicas por separado, incluso cuando no hay alergias.
- **El formulario se prepara para "Editar"**: recibe un borrador inicial y una acción de envío, pero en este cambio solo se usa para el alta. "Editar" en la ficha sigue mostrando "Próximamente".
- **Nuevos textos en la localización** para etiquetas, ayudas y errores del formulario.

## Capabilities

### New Capabilities

- `child-registration`: alta de un niño de la sala desde el listado, con campos obligatorios, fecha tecleada validada, tope de edad, persistencia de demostración y regreso al listado.

### Modified Capabilities

- `kids`: la acción "Agregar niño" deja de ser un placeholder y navega al alta; el badge de alergia de la tarjeta pasa a reflejar una lista de alergias.
- `child-profile`: el bloque "Alergias y notas" pasa a mostrar varias etiquetas y notas médicas independientes, y se muestra cuando hay notas aunque no haya alergias.

## Impact

- **Rutas**: `AppRoutes` y `app_router.dart` (la ruta de alta debe declararse antes de `/kids/:childId`).
- **UI**: `kids_header.dart` (acción con navegación), nueva vista/formulario de alta, `child_card.dart` (badge de múltiples alergias), `profile_allergy_banner.dart` (chips + notas).
- **Dominio**: `Child` (`allergies`, `medicalNotes`), nuevo borrador y caso de uso de alta, lista de salas, contrato `KidsRepository`.
- **Datos**: `KidsDataSource`, `DemoKidsDataSource` (lista mutable en memoria), `KidsRepositoryImpl`.
- **Localización**: nuevas claves en `lib/l10n/app_es.arb` y regeneración.
- **Pruebas**: unitarias de validación y parseo de fecha, de repositorio y caso de uso; de widget del formulario y del listado; de integración del flujo alta -> listado. Se ajustan las pruebas existentes de `Child`, tarjeta y ficha por el cambio de modelo.
