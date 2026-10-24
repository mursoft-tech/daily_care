# Proposal

## Why

La pantalla `/kids` ya lista a los niños, pero al tocar una tarjeta solo aparece "Próximamente": la maestra no puede consultar la ficha de cada niño. El template `docs/templates/perfil-nino.dc.html` define esa pantalla y hoy el dominio no tiene los datos que necesita (fecha de nacimiento, ingreso, notas de alergia y padres vinculados). Sin API ni base de datos, esta etapa debe dejar la navegación y los datos de demostración coherentes para que la pantalla sea usable y verificable.

## What Changes

- Nueva ruta `/kids/:childId` con la pantalla de perfil basada en `perfil-nino.dc.html`.
- Las tarjetas de `/kids` dejan de mostrar "Próximamente" y navegan al perfil del niño correspondiente.
- Al volver de una ficha, `/kids` conserva el texto del buscador y el filtro aplicado, de modo que limpiar el campo restaure el listado completo.
- El modelo de dominio se amplía con fecha de nacimiento, sala, fecha de ingreso, notas de alergia y la lista de padres/tutores con rol y estado.
- La edad visible se deriva de la fecha de nacimiento mediante un caso de uso, para que nunca contradiga la ficha.
- El perfil muestra el banner de alergias solo cuando hay notas registradas, y un estado vacío cuando el niño no tiene padres vinculados.
- Se agregan estados de carga, error y "perfil no encontrado", con la navegación del shell siempre disponible.
- "Editar", "Resumen del día" y "Vincular padre" quedan como acciones pendientes ("Próximamente") sin cambiar de ruta; "Volver a Niños" navega a `/kids`.
- Todos los textos nuevos pasan por la localización en español.

## Capabilities

### New Capabilities

- `child-profile`: ficha de un niño en `/kids/:childId`, con identidad, alergias, datos de la sala, padres vinculados y estados de carga, error y no encontrado; incluye la coherencia entre edad y fecha de nacimiento.

### Modified Capabilities

- `kids`: la tarjeta de niño deja de ser un placeholder y navega al perfil; el buscador conserva el texto y el filtro al volver de la ficha.

## Impact

- Dominio: `Child` y nuevo `Guardian`; caso de uso de cálculo de edad; contrato de `KidsRepository` con búsqueda por id.
- Datos: `KidsDataSource` y `DemoKidsDataSource` con fichas completas de los ocho niños de demostración, sin red ni persistencia.
- App: ruta y helper de path del perfil; proveedor del perfil; nuevas claves en `app_es.arb` y archivos generados de l10n.
- UI: nueva feature de perfil, paleta de avatares compartida, `AppShell` reutilizado; las tarjetas de `/kids` pasan a navegar.
- Tests: unitarios de dominio y repositorio, widgets del perfil y la tarjeta, router, persistencia del buscador y flujo de integración `/kids` → perfil → `/kids`.
- Sin nuevas dependencias externas ni cambios de infraestructura.
