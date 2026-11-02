# Proposal

## Why

Permite a las maestras y administradores vincular uno o más padres, madres o tutores a la ficha de un niño mediante un formulario y la generación de un código de invitación. Actualmente el flujo contempla una sola invitación por envío, reutiliza el mismo código para todas las invitaciones y no define qué ocurre al incorporar un segundo tutor ni cómo evitar invitar dos veces a la misma persona.

## What Changes

- Navegación declarativa: Agregar la ruta `/kids/:childId/vincular-padre` asociada a la ficha del niño.
- Vincular la acción "Vincular un padre" / "Vincular otro padre" en `LinkedParentsCard` para navegar directamente a `/kids/:childId/vincular-padre`.
- Nueva vista `LinkParentView` adaptativa (con contenedor centrado de hasta 480 px, respetando estilos y paleta de `vincular-padre.dc.html`).
- Formulario de vinculación con campos: Nombre del padre/madre, Correo electrónico, Selector de parentesco (Mamá, Papá, Tutor/a) y caja con código de invitación.
- Vinculación múltiple secuencial: cada envío agrega un tutor adicional sin reemplazar a los existentes, la ficha lista a todos los tutores y la acción "Vincular otro padre" sigue disponible después de cada vinculación.
- Código de invitación propio por tutor: se genera al abrir el formulario, vence en 7 días y queda asociado al tutor invitado.
- Rechazo de un correo ya vinculado al mismo niño, sin distinguir mayúsculas, mostrando un mensaje localizado y sin agregar duplicados.
- Soporte en memoria / mock: registrar cada nuevo tutor con estado `PENDIENTE` en el repositorio en memoria de niños para que se refleje inmediatamente en la ficha.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `child-profile`: Modificar las acciones de la ficha para que "Vincular padre" / "Vincular otro padre" navegue a `/kids/:childId/vincular-padre` y permanezca disponible tras cada vinculación; precisar que la lista de padres vinculados muestra y cuenta a todos los tutores, y agregar el requisito del formulario de invitación con código propio por tutor y rechazo de correos duplicados.

## Impact

- Rutas: Modificación de `AppRoutes` y `routerProvider` en `lib/app/router/`.
- Dominio: Extensión de `Guardian` con `email` e `invitationCode`; caso de uso para generar el código de invitación; contrato de `KidsRepository.linkGuardian` con `Failure` tipado para correos duplicados.
- Datos: Implementación en memoria que agrega el nuevo `Guardian` con estado `isActive: false` (pendiente) asociado al niño, conserva los tutores existentes y valida la unicidad del correo.
- UI: Modificación de `LinkedParentsCard` e implementación de la nueva pantalla `LinkParentView` y sus widgets/view model, incluyendo el error localizado de correo duplicado.
- Localización: Nuevas claves en arb/l10n para los títulos, campos, mensajes, feedback y error de correo duplicado de la vista de vinculación.
- Tests: Actualización de fixtures de `Guardian` y nuevas pruebas de duplicados, generación de código y vinculaciones sucesivas.
