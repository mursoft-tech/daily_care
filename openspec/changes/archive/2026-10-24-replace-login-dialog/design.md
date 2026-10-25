# Design

## Context
Ver `proposal.md` para la motivación. Actualmente la ruta `/login` presenta un `LoginPlaceholderView` estático con un botón para regresar al feed. El proyecto cuenta con un sistema de tokens de diseño (`AppColors`, `AppTypography`), soporte de l10n con `flutter_localizations` y navegación con `go_router`.

## Goals / Non-Goals

**Goals:**
- Implementar una interfaz de login fiel a `docs/templates/login.dc.html` con soporte responsivo (panel dividido en pantalla ancha y banner superior en pantalla estrecha).
- Manejar estado local para la selección de rol (`personal` vs `familia`), sugerencia de correo y validación de formato.
- Validar las credenciales provisionales hardcodeadas (`admin` / `admin123` o `admin@opendaycare.com` / `admin123`) y redirigir a `/` ante éxito.
- Presentar mensajes de error claros en caso de formato incorrecto o credenciales no coincidentes.

**Non-Goals:**
- Conectar con un backend real o base de datos de usuarios (la persistencia real y JWT se implementarán en etapas posteriores).
- Implementar flujos reales de recuperación de contraseña o registro/activación de cuenta (los enlaces se mantendrán visualmente como en la plantilla).

## Decisions

### 1. Estado y orquestación con Riverpod y MVVM
- **Decisión**: Crear un `LoginNotifier` (o `AsyncNotifier`/`Notifier` de Riverpod) junto a un `LoginState` inmutable que gestione:
  - Rol seleccionado (`LoginRole.staff` o `LoginRole.family`).
  - Estado del formulario (email, password, estado de carga, errores de validación y de autenticación).
- **Alternativa considerada**: Manejarlo como `StatefulWidget` puro. Se descarta para adherirse a las convenciones de arquitectura del proyecto (`MVVM` con Riverpod 3 y separación UI / State).

### 2. Layout Adaptativo (Mobile vs Desktop)
- **Decisión**: Utilizar `LayoutBuilder` inspeccionando `constraints.maxWidth` con un umbral de 768px:
  - `maxWidth >= 768`: Layout horizontal (`Row`) con panel decorativo Hero (gradiente coral, círculos decorativos, claim de marca) a la izquierda y el formulario centrado a la derecha.
  - `maxWidth < 768`: Layout vertical con un `HeroBanner` compacto arriba y el formulario con scroll debajo.
- **Alternativa considerada**: Ocultar el panel decorativo en móvil por completo. Se descartó porque el usuario solicitó explícitamente mantenerlo como banner superior.

### 3. Autocompletado y validación de correo
- **Decisión**: Al conmutar el rol a Personal, se autocompleta el campo de correo con `admin@opendaycare.com` (o `caro@opendaycare.com`), y al conmutar a Familia con `lucia.fernandez@gmail.com`. Se valida formato de email mediante expresión regular estándar antes del submit. Las credenciales aceptadas serán `admin` o `admin@opendaycare.com` con `admin123`.

## Risks / Trade-offs

- **[Riesgo: Desbordamiento de pantalla con teclado virtual en móvil]** → **Mitigación**: Envolver la columna del formulario en un `SingleChildScrollView` asegurando padding suficiente contra el `viewInsets.bottom`.
- **[Riesgo: Duplicación de colores y estilos]** → **Mitigación**: Reutilizar `AppColors` existentes (`primary`, `primarySoft`, `primaryDark`, `textStrong`, `textMuted`, `surface`, etc.) y añadir constantes específicas en `AppColors` si se requiere granularidad idéntica a la plantilla.
