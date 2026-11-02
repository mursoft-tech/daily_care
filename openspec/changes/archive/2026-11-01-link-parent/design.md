# Design

## Context

El proyecto utiliza Flutter con Riverpod 3, GoRouter y Material UI (`package:material_ui/material_ui.dart`). La aplicación opera con datos de demostración en memoria, sin backend ni base de datos activa. La ficha del niño se encuentra en `/kids/:childId` y su componente `LinkedParentsCard` ya itera la lista de `Guardian`, pero el flujo de vinculación se construyó para una sola invitación: el código es fijo (`7K4P9`) y `Guardian` no guarda correo ni código, por lo que no se puede identificar a un tutor ya invitado ni asociarle su propio código. Ver `proposal.md` para la motivación.

## Goals / Non-Goals

**Goals:**
- Permitir vinculaciones sucesivas ilimitadas, agregando tutores sin reemplazar a los existentes y reflejando la lista completa en la ficha.
- Garantizar que cada invitación tenga su propio código, vigente 7 días y asociado al tutor invitado.
- Evitar tutores duplicados por correo dentro del mismo niño, con un error localizado y tipado.
- Mantener la regla de dependencia `ui → domain` y `data → domain` sin lógica de negocio en vistas ni ViewModels.

**Non-Goals:**
- Envío real de correos electrónicos mediante SMTP o backend API.
- Persistencia duradera en SQLite/PostgreSQL (fuera de memoria de sesión/demo).
- Activación real de la cuenta del tutor con el código generado (el flujo de activación sigue siendo demostrativo).
- Modificar el flujo de autenticación o roles de maestras/administradores.

## Decisions

### 1. Ruta y Jerarquía en GoRouter
- **Decisión**: Mantener `/kids/:childId/vincular-padre` con `childId` como path parameter.
- **Alternativa considerada**: Ruta plana `/kids/vincular-padre` con query parameters o paso de objetos en `extra`.
- **Razón**: Permite accesos directos, recargas de página en Flutter Web y compatibilidad con el breadcrumb/regreso a la ficha del niño sin depender de estado volátil fuera de la URL.

### 2. Estructura de UI y Compatibilidad
- **Decisión**: Mantener el contenedor con `ConstrainedBox(maxWidth: 480)` y centrado vertical/horizontal dentro de `Scaffold`, siguiendo la arquitectura y componentes compartidos del proyecto (`AppColors`, `AppTypography`, `material_ui`). `LinkedParentsCard` sigue iterando la lista completa de tutores, de modo que cada vinculación agrega una fila.
- **Alternativa considerada**: Dialog o BottomSheet flotante.
- **Razón**: La experiencia en pantalla completa responsive se adapta mejor a dispositivos móviles y escritorios, manteniendo la fidelidad exacta al template `vincular-padre.dc.html`; la tarjeta existente ya soporta listas de cualquier longitud.

### 3. Modelo y Mutación de Datos
- **Decisión**: Agregar `email` e `invitationCode` a `Guardian` y mantener `KidsRepository.linkGuardian` devolviendo `Future<Result<Guardian>>`. La implementación en memoria agrega el tutor a `child.guardians` preservando los existentes, con identificador derivado del niño y del correo normalizado para evitar colisiones entre fichas.
- **Alternativa considerada**: Mantener el nuevo tutor en un ViewModel local de UI sin tocar el repositorio.
- **Razón**: Respeta la arquitectura por capas y permite que `childProfileViewModelProvider` refleje la lista completa de forma consistente. Guardar el correo es requisito para detectar duplicados y guardar el código permite asociar cada invitación a su tutor.

### 4. Unicidad por correo
- **Decisión**: Rechazar la vinculación cuando el correo normalizado (recortado y en minúsculas) ya pertenece a un `Guardian` del mismo niño. El repositorio devuelve `Failure(GuardianAlreadyLinkedFailure())`, definido en `core/`.
- **Alternativa considerada**: Filtrar duplicados solo en el data source o en la vista.
- **Razón**: La regla es de negocio y debe validarse igual en cualquier implementación del repositorio; un failure tipado permite que el ViewModel asocie el error al campo de correo sin exponer detalles internos.

### 5. Código de invitación por tutor
- **Decisión**: Generar el código al abrir el formulario mediante un caso de uso de dominio (`GenerateInvitationCode`), con 5 caracteres de un alfabeto sin caracteres ambiguos y regeneración si colisiona con un código vigente del mismo niño. El ViewModel solo conserva el código generado y lo envía a `linkGuardian`, que lo persiste en el `Guardian`.
- **Alternativa considerada**: Un código fijo o un código compartido por niño.
- **Razón**: Cada invitación debe poder rastrearse hasta su tutor; el caso de uso mantiene la generación fuera de la UI y es testeable de forma aislada.

### 6. Errores y feedback
- **Decisión**: Mapear `GuardianAlreadyLinkedFailure` a `emailError = 'alreadyLinked'` y mostrar `linkParentEmailAlreadyLinked` bajo el campo; los fallos restantes conservan el estado `submitFailed` existente.
- **Alternativa considerada**: Mostrar solo un SnackBar genérico.
- **Razón**: El error pertenece a un campo concreto y el mensaje localizado evita exponer detalles técnicos.

## Risks / Trade-offs

- [Dos correos distintos para la misma persona] → La unicidad es por correo; se acepta en el alcance demo y se documenta como limitación.
- [Colisión de códigos generados] → Se regenera el código hasta obtener uno no vigente para el niño.
- [Código persistido pero activación todavía estática] → Se asume el alcance actual: la activación real queda fuera del cambio.
- [Crecimiento de la tarjeta con muchos tutores] → La tarjeta y la página ya admiten scroll vertical; no se limita la cantidad en esta iteración.
- [Pérdida de datos en recarga completa] → Se mitiga asumiendo el alcance actual del proyecto (demo en memoria sin backend persistente).
- [Niño inexistente en la ruta `/kids/:invalid/vincular-padre`] → Se valida la existencia de `childId` en el ViewModel; si el niño no existe, se muestra el estado de error o redirección correspondiente.
