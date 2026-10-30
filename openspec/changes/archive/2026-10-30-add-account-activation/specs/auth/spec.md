# Spec Delta

## ADDED Requirements

### Requirement: Acceso a la activación de cuenta desde el inicio de sesión

La pantalla de inicio de sesión DEBE incluir el enlace "Activá tu cuenta" y, al activarlo, DEBE navegar a la ruta de activación de cuenta.

#### Scenario: Enlace visible y accesible en el login
- **WHEN** el usuario abre `/login`
- **THEN** ve el enlace "Activá tu cuenta" junto al texto de invitación y el enlace se comporta como enlace (cursor de mano, foco por teclado y semántica de enlace)

#### Scenario: Navegación hacia la activación
- **WHEN** el usuario activa el enlace "Activá tu cuenta"
- **THEN** la app navega a `/activar-cuenta`

### Requirement: Pantalla de activación fiel a la plantilla

La pantalla de activación DEBE conservar la composición, tipografías y colores de `activar-cuenta.dc.html` y DEBE mantenerse legible y desplazable en cualquier ancho de pantalla.

#### Scenario: Composición en pantalla amplia
- **WHEN** el usuario abre `/activar-cuenta` con un ancho mayor o igual a 768 píxeles
- **THEN** ve una página centrada de ancho máximo 440 píxeles con el logo, el título "Bienvenida a OpenDayCare", la tarjeta de invitación, los campos de código, email y contraseña, la autorización de fotos, el botón "Activar mi cuenta" y la vuelta al inicio de sesión

#### Scenario: Composición en pantalla móvil
- **WHEN** el usuario abre `/activar-cuenta` con un ancho menor a 768 píxeles
- **THEN** la misma composición se muestra en una sola columna con márgenes reducidos y desplazamiento vertical cuando el alto no alcanza

### Requirement: Contexto de invitación resuelto por código

La pantalla DEBE resolver la invitación a partir del código recibido en la URL y DEBE mostrar el niño y la sala invitados junto con el email asociado.

#### Scenario: Código recibido por parámetro
- **WHEN** el usuario abre `/activar-cuenta?codigo=7K4P9`
- **THEN** la tarjeta muestra "Mateo · Sala Soles" y el campo de email aparece precargado con el email de la invitación

#### Scenario: Apertura sin código
- **WHEN** el usuario abre `/activar-cuenta` sin el parámetro `codigo`
- **THEN** la pantalla usa el código de invitación de demostración y muestra la misma información de invitación

### Requirement: Validación de los datos de activación

El sistema DEBE validar el código de invitación, el formato del email, la coincidencia del email con la invitación, la contraseña y la autorización de fotos antes de activar la cuenta, y DEBE impedir la activación mostrando un mensaje asociado al campo inválido.

#### Scenario: Código de invitación inexistente
- **WHEN** el usuario envía un código que no corresponde a ninguna invitación
- **THEN** la activación no se completa y se muestra un mensaje indicando que no se encontró la invitación

#### Scenario: Formato de email inválido
- **WHEN** el usuario envía un email que no cumple el formato estándar
- **THEN** la activación no se completa y se muestra un mensaje indicando que el email no es válido

#### Scenario: Email distinto al de la invitación
- **WHEN** el usuario envía un email válido que no coincide con el email de la invitación
- **THEN** la activación no se completa y se muestra un mensaje indicando que el email no corresponde a la invitación

#### Scenario: Contraseña demasiado corta
- **WHEN** el usuario envía una contraseña de menos de 8 caracteres
- **THEN** la activación no se completa y se muestra un mensaje indicando la longitud mínima

#### Scenario: Contraseña vacía
- **WHEN** el usuario envía el formulario sin contraseña
- **THEN** la activación no se completa y se muestra un mensaje pidiendo la contraseña

### Requirement: Autorización de fotos obligatoria

La autorización para tomar y compartir fotos del niño DEBE aparecer desmarcada y DEBE ser obligatoria para activar la cuenta, conservando el bloque visual de la plantilla.

#### Scenario: Autorización desmarcada al abrir la pantalla
- **WHEN** el usuario abre `/activar-cuenta`
- **THEN** la casilla de autorización de fotos aparece desmarcada y puede marcarse o desmarcarse como un control accesible

#### Scenario: Activación sin autorización
- **WHEN** el usuario envía el formulario con datos válidos pero sin marcar la autorización de fotos
- **THEN** la activación no se completa y se muestra un mensaje pidiendo la autorización

#### Scenario: Activación con autorización
- **WHEN** el usuario envía el formulario con datos válidos y la autorización marcada
- **THEN** la cuenta se activa

### Requirement: Destino tras activar la cuenta

Al completarse la activación, la app DEBE navegar al feed principal.

#### Scenario: Activación exitosa
- **WHEN** el usuario envía datos válidos con la autorización marcada y la activación se completa
- **THEN** la app navega a `/` y el usuario ve el feed

### Requirement: Vuelta al inicio de sesión desde la activación

La pantalla de activación DEBE ofrecer un enlace para volver al inicio de sesión.

#### Scenario: Enlace de vuelta al login
- **WHEN** el usuario activa el enlace "Iniciar sesión" del pie de la pantalla de activación
- **THEN** la app navega a `/login`

### Requirement: Fallo de carga de la invitación

Si la invitación no puede cargarse, la pantalla DEBE informar el problema sin exponer detalles internos y DEBE permitir reintentar.

#### Scenario: Error al cargar la invitación
- **WHEN** la carga de la invitación falla
- **THEN** la pantalla muestra un mensaje genérico de error y una acción para reintentar la carga