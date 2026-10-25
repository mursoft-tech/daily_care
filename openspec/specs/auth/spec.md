# Capability: auth

## Purpose
Proporcionar mecanismos de autenticación de usuarios, selección de rol y verificación de credenciales con soporte de diseño responsivo fiel a la plantilla del sistema.

## Requirements

### Requirement: Interfaz visual responsiva de inicio de sesión
La pantalla de inicio de sesión DEBE adaptarse al ancho disponible de pantalla conservando la identidad visual y colores de la plantilla oficial.

#### Scenario: Visualización en pantallas amplias (Desktop / Tablet)
- **WHEN** el usuario accede a `/login` con un ancho de pantalla mayor o igual a 768 píxeles
- **THEN** se muestra un diseño de dos columnas: a la izquierda un panel hero decorativo con gradiente coral, círculos y el lema de OpenDayCare, y a la derecha el formulario de acceso.

#### Scenario: Visualización en pantallas móviles
- **WHEN** el usuario accede a `/login` con un ancho de pantalla menor a 768 píxeles
- **THEN** se muestra un banner superior compacto con el gradiente coral y claim, seguido verticalmente por el formulario con soporte de desplazamiento.

### Requirement: Selector interactivo de rol
El usuario DEBE poder alternar entre los roles de Personal y Familia, visualizando el estado seleccionado y recibiendo una sugerencia automática de correo electrónico.

#### Scenario: Selección de rol Personal
- **WHEN** el usuario presiona el botón "Personal"
- **THEN** el botón de Personal se resalta como activo y el campo de email se precompleta con el correo administrativo o sugerido (`admin@opendaycare.com`).

#### Scenario: Selección de rol Familia
- **WHEN** el usuario presiona el botón "Familia"
- **THEN** el botón de Familia se resalta como activo y el campo de email se precompleta con el correo familiar sugerido (`lucia.fernandez@gmail.com`).

### Requirement: Validación y autenticación de credenciales
El sistema DEBE validar el formato del correo ingresado y verificar las credenciales hardcodeadas provisionales.

#### Scenario: Formato de correo inválido
- **WHEN** el usuario ingresa un texto que no cumple con el formato estándar de correo y presiona "Iniciar sesión"
- **THEN** el sistema impide el envío y muestra un mensaje indicando que el formato de correo no es válido.

#### Scenario: Autenticación exitosa con credenciales provisionales
- **WHEN** el usuario ingresa un usuario/correo válido (`admin` o `admin@opendaycare.com`) con la contraseña `admin123` y presiona "Iniciar sesión"
- **THEN** el sistema autentica al usuario y lo redirige a la pantalla principal del feed (`/`).

#### Scenario: Autenticación fallida por credenciales incorrectas
- **WHEN** el usuario ingresa una combinación de usuario y contraseña distinta a las credenciales hardcodeadas
- **THEN** se muestra un mensaje de error accesible indicando que las credenciales son incorrectas y se mantiene en la pantalla de inicio de sesión.
