# Proposal

## Why

Actualmente la pantalla de inicio de sesión (`/login`) es un diálogo provisional (`LoginPlaceholderView`) con un mensaje estático de "próximamente". Se requiere reemplazar este marcador por una pantalla completa de autenticación que replique con fidelidad el diseño, paleta y tipografía de la plantilla oficial (`docs/templates/login.dc.html`), permitiendo la alternancia de roles (Personal/Familia), autocompletado de sugerencias, validación de formato de correo y autenticación local provisional con credenciales fijas (`admin` / `admin123`).

## What Changes

- Reemplazar la vista provisional `LoginPlaceholderView` por una vista interactiva de inicio de sesión fiel a la plantilla `login.dc.html`.
- Incorporar layout adaptativo:
  - En escritorio/tablets (ancho ≥ 768px): dos columnas con panel lateral decorativo izquierdo (gradiente coral/naranja, círculos traslúcidos, claim de marca) y panel de formulario derecho.
  - En pantallas móviles (< 768px): banner superior compacto con gradiente y claim, seguido por el formulario desplazable.
- Selector interactivo de rol ("Personal" y "Familia"): actualiza el estado visual del selector y autocompleta el campo de correo con un valor sugerido (`admin@opendaycare.com` para Personal, `lucia.fernandez@gmail.com` para Familia).
- Validación de formato de correo y verificación de credenciales fijas (`admin` o `admin@opendaycare.com` con contraseña `admin123`).
- Redirección al feed tras autenticación exitosa o mensaje de error visual accesible cuando las credenciales no coincidan.
- Soporte para textos localizados vía `lib/l10n/`.

## Capabilities

### New Capabilities
- `auth`: Gestión de autenticación, control de sesión de usuario y pantalla de inicio de sesión interactiva.

### Modified Capabilities
<!-- No requirements changing in existing specs -->

## Impact

- `lib/ui/features/login/views/`: reemplazo y evolución de `login_placeholder_view.dart` hacia la nueva pantalla interactiva.
- `lib/ui/features/login/view_models/` o componentes de estado asociados para la gestión del rol seleccionado y validaciones.
- `lib/app/router/`: confirmación de la ruta `/login`.
- `lib/l10n/`: incorporación de las cadenas de texto del login en `app_es.arb`.
- `test/ui/features/login/`: actualización y adición de tests de widgets para el nuevo flujo y validación de credenciales.
