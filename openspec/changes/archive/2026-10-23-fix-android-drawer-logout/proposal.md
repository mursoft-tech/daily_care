# Proposal

## Why

En Android, el icono de logout del drawer no inicia sesión: la aplicación queda en el feed. En Chrome no se reproduce. La acción mide 32x32 dp (por debajo del mínimo táctil de 48), está envuelta en un `Tooltip` que puede ganar el gesto de pulsación larga, y el drawer no se cierra antes de navegar; los tests actuales tocan el centro exacto y solo comprueban que la vista de login existe, así que no detectan ninguno de esos fallos. Hay que hacer la salida robusta a toques imprecisos y dejar una prueba que falle si el drawer tapa la pantalla destino.

## What Changes

- Extraer un único botón de cierre de sesión reutilizable por drawer, barra superior, sidebar y rail, con área táctil mínima de 48x48 dp y etiqueta accesible explícita.
- Cerrar el menú lateral de forma explícita antes de navegar a `/login`, en lugar de depender de que el cambio de ruta desmonte el drawer.
- Quitar la dependencia del gesto de pulsación larga para activar la salida: el tooltip deja de ser el único nombre accesible de la acción.
- Añadir tests de widget que toquen el borde del área táctil, verifiquen `isDrawerOpen == false` después de navegar y midan el tamaño mínimo del botón.
- Añadir un integration test en Android que abra el drawer, toque el logout con un desplazamiento respecto al centro y confirme la pantalla de login sin drawer.
- Registrar una matriz de verificación manual Android y Chrome para el cambio.

Fuera de alcance: autenticación real, guard de `/login`, persistencia de sesión, limpieza de credenciales y cualquier rediseño del drawer más allá del bloque de cuenta.

## Capabilities

### New Capabilities

- Ninguna.

### Modified Capabilities

- `feed`: la requirement de cierre de sesión exige cerrar el menú lateral antes de navegar y garantizar un área táctil mínima para la acción.

## Impact

- `lib/ui/core/widgets/app_navigation_panel.dart`: logout del drawer y del sidebar con el botón compartido.
- `lib/ui/core/widgets/app_shell.dart`: acción de la barra superior, avatar del rail y cierre del drawer antes de navegar.
- Nuevo widget compartido de acción de logout en `lib/ui/core/widgets/`.
- `lib/l10n/app_es.arb`: etiqueta accesible de la acción si la clave actual no alcanza.
- `test/ui/core/widgets/` y `test/ui/features/feed/`: cobertura nueva de área táctil, cierre del drawer y navegación.
- `integration_test/`: caso de regresión en Android con toque desplazado.
- Sin dependencias nuevas, sin backend y sin migraciones.
