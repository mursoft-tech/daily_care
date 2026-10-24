# Proposal

## Why

El feed ya muestra publicaciones asociadas a niños, pero la sala no tiene una pantalla para consultar el listado de niños. El destino "Niños" del menú solo muestra "Próximamente", así que una maestra no puede pasar del contexto de una publicación al directorio de la sala. La ruta `/kids` cubre ese vacío con el diseño ya especificado en `docs/templates/ninos.dc.html`.

## What Changes

- Nueva ruta `/kids` accesible desde el destino "Niños" del sidebar, el rail y el menú lateral, con el destino marcado como activo.
- Nueva pantalla de niños con la cabecera "GESTIÓN / Niños", el botón "Agregar niño", el buscador, la etiqueta de sala con el conteo y la grilla de tarjetas del template.
- Ocho niños de demostración con avatar por color, edad, padres vinculados y badge de alergia o "VINCULAR", provistos por la capa de datos sin red ni backend.
- Búsqueda por nombre en el listado, con estado vacío cuando no hay coincidencias.
- Contrato de repositorio y ViewModel siguiendo el patrón del feed, con estados de carga y error.
- Tokens de color y textos de localización nuevos para la pantalla.
- "Agregar niño" y las tarjetas quedan como acciones "Próximamente"; el perfil del niño y el alta no forman parte de este cambio.
- El feed conserva su comportamiento actual; solo cambia la navegación del destino "Niños".

## Capabilities

### New Capabilities

- `kids`: listado de niños de la sala, búsqueda, tarjetas con estado de vinculación y alergias, y estados de carga y error de la pantalla.

### Modified Capabilities

- `feed`: la navegación deja de mostrar "Próximamente" para "Niños" y pasa a abrir `/kids`; el resto de los destinos no implementados conserva el aviso.

## Impact

- `lib/app/router/app_router.dart`: nueva ruta `/kids`.
- `lib/ui/core/widgets/app_navigation_panel.dart` y `app_shell.dart`: destinos con ruta y callback de navegación.
- Nuevos archivos en `lib/domain`, `lib/data` y `lib/ui/features/kids`.
- `lib/app/theme/app_colors.dart` y `app_theme.dart`: colores de avatar y badges.
- `lib/l10n/app_es.arb` y archivos generados de localización.
- Tests de router, shell, repositorio y vista; integración del flujo feed → niños.
