# Design

## Context

Ver `proposal.md`. El estado actual relevante:

- El router no tiene guard de sesión: `login` navega con `context.go('/')` y `sessionUserProvider` es un `Provider` con un usuario demo de maestra. No hay autenticación real todavía.
- `login_form.dart` construye dos `TextField` con el mismo `InputDecoration` duplicado (borde 1.5 `#EADFD0`, radio 14, fill blanco, padding 14/16).
- `docs/templates/activar-cuenta.dc.html` define la pantalla completa con valores medibles; `docs/templates/login.dc.html` enlaza a ella.
- `AppColors` ya contiene los colores del template de login; faltan solo los del bloque de consentimiento.
- La capability `auth` existe y describe el login; la activación de una cuenta invitada pertenece a la misma capability.
- No hay API ni base de datos: todo se resuelve con datos demo, pero los contratos deben permitir sustituirlos después.

## Goals / Non-Goals

**Goals:**

- Reproducir la pantalla de activación del template con fidelidad verificable (medidas, colores, tipografías y jerarquía).
- Aislar las reglas de activación del widget, de modo que mañana una API reemplace la demo sin tocar la UI.
- Mantener consistencia con el resto del proyecto: `Result`, contratos abstractos, `AsyncNotifier`, l10n por ARB y tests por capa.

**Non-Goals:**

- Backend, persistencia, envío de emails de invitación o generación de códigos.
- Sesión real, guard de rutas y feed familiar. Tras activar se reutiliza el feed actual.
- Rediseñar la pantalla de login más allá de extraer el campo compartido y conectar el enlace.
- Añadir una pantalla de "cuenta activada" o pasos adicionales del template no presentes.

## Decisions

### Capability `auth` en lugar de una nueva `account-activation`

La activación crea credenciales para una cuenta invitada: es parte del mismo dominio que el login. Añadirla a `auth` evita una capability casi duplicada y permite que los requisitos de credenciales vivan juntos. Alternativa descartada: una capability nueva por pantalla, que fragmentaría el comportamiento de autenticación.

### Página única centrada, fiel al template

El template es una página de 440 px centrada sobre `#FBF4EC`, sin hero. Se implementa así aunque el login sea un split de dos columnas, porque ese contraste es el del propio template y su enlace. Alternativa descartada: reutilizar la columna derecha del split del login, que se vería más continuo pero se aleja del diseño aprobado.

Medidas a respetar: padding de página 40 (24 en móvil), max 440; logo 58 con gap 22; título Fredoka 32/1.15; subtítulo 15.5/1.55 `#94887B`; tarjeta de invitación con borde 1.5 `#EADFD0`, radio 16, padding 14/16; labels 12 w700 con letter-spacing .7 y gap 8; código en Fredoka 18 w700 con letter-spacing 3; consentimiento con fondo `#FBF1D6`, radio 14, caja 24×24 radio 8 `#5FB97E`; CTA padding 15, radio 15, gradiente `#F4977E → #EE8164` y la sombra del template; pie a 22 px con link `#C5503A`.

### Consentimiento desmarcado y obligatorio

El diseño se conserva al píxel, pero el estado inicial es vacío y la activación lo exige. Un consentimiento de imagen de un menor premarcado no es una acción afirmativa válida. El control se implementa con `Semantics(checked: ...)` y área táctil completa, no con el `Checkbox` de Material, para no heredar su estilo. Alternativa descartada: copiar el check premarcado del template.

### Capas: modelo, contrato, caso de uso, demo

```
account_invitation.dart        # code, email, childName, roomName
account_activation_repository  # loadInvitation(code) / activate(...)
activate_account.dart          # reglas puras y resultado tipado
demo_account_activation_*      # datos demo const
account_activation_repository_impl
```

`loadInvitation` devuelve `Result<AccountInvitation?>`; `null` significa código inexistente. `activate` devuelve `Result<void>`. La demo no persiste nada.

El caso de uso devuelve un `sealed ActivationResult` (`ActivationAccepted` | `ActivationRejected(ActivationError)`), no un `AppFailure`. `AppFailure` está sellado en `core/result.dart`, por lo que no puede especializarse desde `domain/`, y los errores de validación no son fallos de datos ni de infraestructura. Alternativa descartada: ampliar `core/result.dart` con errores de negocio, que acoplaría `core` a cada feature.

Orden de validación (primer fallo gana): código → formato de email → coincidencia con la invitación → contraseña vacía → contraseña de menos de 8 caracteres → consentimiento. El primer fallo se muestra inline bajo su campo, como hace el login.

### Resolución de la invitación y prellenado

La ruta acepta `?codigo=`; sin parámetro usa `7K4P9`. El email y el nombre del niño salen de la invitación resuelta, de modo que hay una sola fuente de verdad y el email editable permite que la validación de coincidencia sea real. Alternativa descartada: fijar código y email en la pantalla, que impediría representar invitaciones distintas.

Datos demo alineados con el resto del seed: código `7K4P9`, `lucia.fernandez@gmail.com`, Mateo de la sala Soles (coincide con `DemoKidsDataSource` y con el rol Familia del login).

### `AsyncNotifier` para el view model

La carga de la invitación es asíncrona aunque hoy sea local; usar `AsyncNotifier` evita reescribir el view model al conectar la API. Estados: carga, error con reintento, y formulario con `isSubmitting` y `errorType`. Sin lógica de negocio: solo orquesta el caso de uso y guarda estado. Alternativa descartada: `Notifier` síncrono con datos inyectados, que obligaría a cambiar el contrato al aparecer la red.

### Campo de texto compartido

Se extrae `AppTextField` (label 12 w700 + campo) a `ui/core/widgets` y se reutiliza en login y activación. Se conservan los keys actuales (`login-email-input`, `login-password-input`). Alternativa descartada: duplicar el `InputDecoration` cinco veces.

### Éxito navega a `/`

Es el mismo destino que un login exitoso y el único feed disponible. Cuando exista feed familiar, cambia solo la ruta de destino. Alternativa descartada: volver a `/login` con aviso, que añade un paso que el template no tiene.

### l10n y tema

Todas las cadenas nuevas van a `app_es.arb` con sus descripciones, incluidos los mensajes de error y las etiquetas accesibles; el nombre del niño y la sala se componen con placeholders. Se añaden a `AppColors` solo los tres valores del consentimiento (`#FBF1D6`, `#8A7234`, `#5FB97E`). No se añaden assets: el logo y el avatar ya existen.

### Context7 y validación de APIs

Antes de escribir código se consultará Context7 para go_router 18 (lectura de query params con `state.uri.queryParameters`) y Riverpod 3.4 (uso de `AsyncNotifier`), una consulta por concepto. `material_ui` no está indexado en Context7 (devuelve el MUI de React); su API se valida contra el paquete instalado (`material_ui-1.8.0`, que exporta `text_field.dart`, `checkbox.dart` e `ink_well.dart`) y la documentación del SDK de Flutter.

### Limpieza incluida

Se elimina `login_placeholder_view.dart`, que ya no se referencia, y se corrige `integration_test/logout_flow_test.dart`, que espera el texto del placeholder en `/login`.

## Risks / Trade-offs

- **El salto visual de login (split) a activación (página plana) puede leerse como inconsistencia** → es el flujo del template; se conserva y se documenta en la spec.
- **La demo no persiste la activación** → al recargar, la cuenta vuelve a estar inactiva. Aceptable mientras no exista backend; el contrato del repositorio ya prevé el reemplazo.
- **La contraseña mínima de 8 caracteres no está en el template** → se elige un mínimo razonable y se muestra inline; si se define otra política, cambia solo la constante del caso de uso.
- **Extraer `AppTextField` toca el login** → se conservan keys y estilos, y los widget tests existentes cubren la pantalla.
- **Los textos de error no tienen diseño en el template** → se reutiliza el estilo de error del login (coral `primaryDark`, 12.5 w600) para no inventar un lenguaje visual nuevo.
- **La spec existente usa "DEBE" en español y `openspec validate` avisa por RFC 2119 en inglés** → se mantiene el español por consistencia con el resto de las specs; el aviso no invalida el cambio.