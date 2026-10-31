# child-registration Specification

## Purpose

Permite a la maestra dar de alta un niño en la sala desde el listado de niños, registrando sus datos obligatorios, su fecha de nacimiento y sus alergias y notas médicas, aunque todavía no exista una base de datos ni una API.

## Requirements

### Requirement: Child registration route access

El sistema SHALL exponer el alta de niños en `/kids/nuevo`, accesible desde la acción "Agregar niño" de `/kids` y por enlace directo, y SHALL mantener el destino "Niños" activo mientras la ruta esté abierta.

#### Scenario: Alta desde el listado

- **WHEN** el usuario activa "Agregar niño" en `/kids`
- **THEN** la aplicación navega a `/kids/nuevo` y el destino "Niños" sigue resaltado

#### Scenario: Enlace directo

- **WHEN** el usuario abre `/kids/nuevo` directamente
- **THEN** ve el formulario de alta sin pasar por el listado

#### Scenario: La ruta no se confunde con una ficha

- **WHEN** el usuario navega a `/kids/nuevo`
- **THEN** se muestra el formulario de alta y no el estado "no encontrado" de una ficha

### Requirement: Registration form content

El formulario SHALL mostrar la cabecera de la plantilla con "Cancelar", el título "Agregar niño" y "Guardar", y los campos nombre completo, fecha de nacimiento, sala, alergias y notas médicas.

#### Scenario: Formulario completo

- **WHEN** el usuario abre `/kids/nuevo`
- **THEN** ve los cinco campos, la ayuda `dd/mm/aaaa` en la fecha y las acciones "Cancelar" y "Guardar"

#### Scenario: Formulario adaptativo

- **WHEN** el formulario se muestra en un ancho menor a 600 px
- **THEN** los campos se apilan en una columna, no hay desbordamiento horizontal y el botón de guardar sigue accesible

### Requirement: Required registration fields

El sistema SHALL exigir nombre completo, fecha de nacimiento y sala para guardar, y SHALL tratar alergias y notas médicas como opcionales.

#### Scenario: Campos obligatorios vacíos

- **WHEN** el usuario activa "Guardar" sin nombre, sin fecha o sin sala
- **THEN** no se crea el niño, se mantiene en `/kids/nuevo` y cada campo faltante muestra su mensaje de error

#### Scenario: Solo datos obligatorios

- **WHEN** el usuario completa nombre, fecha y sala y deja alergias y notas vacías
- **THEN** el niño se guarda sin alergias y sin notas médicas

#### Scenario: Nombre con un solo apellido

- **WHEN** el usuario ingresa "Martina" como nombre completo
- **THEN** el niño se guarda y su nombre visible es "Martina"

### Requirement: Birth date typed format

El campo de fecha de nacimiento SHALL aceptar solo dígitos e insertar las barras automáticamente, de modo que el valor visible quede en formato `dd/mm/aaaa`.

#### Scenario: Barras automáticas

- **WHEN** el usuario teclea `12032023` en el campo de fecha
- **THEN** el campo muestra `12/03/2023`

#### Scenario: Caracteres no numéricos

- **WHEN** el usuario intenta escribir letras o símbolos en el campo de fecha
- **THEN** el campo no los acepta y conserva los dígitos ya ingresados

#### Scenario: Fecha incompleta

- **WHEN** el usuario escribe `12/03` y activa "Guardar"
- **THEN** el campo muestra el error de formato de fecha y no se crea el niño

### Requirement: Birth date validity

El sistema SHALL rechazar fechas de nacimiento que no existan en el calendario o que sean posteriores a la fecha actual, mostrando un mensaje de error en el campo.

#### Scenario: Fecha inexistente

- **WHEN** el usuario ingresa `31/02/2023` y activa "Guardar"
- **THEN** el campo muestra el error de fecha inválida y no se crea el niño

#### Scenario: Fecha futura

- **WHEN** el usuario ingresa una fecha posterior a hoy y activa "Guardar"
- **THEN** el campo muestra el error de fecha futura y no se crea el niño

### Requirement: Age limit at registration

El sistema SHALL rechazar el alta cuando la edad cumplida del niño supere los 6 años, calculada desde la fecha de nacimiento y la fecha actual.

#### Scenario: Niño de 6 años

- **WHEN** el usuario registra un niño que hoy tiene 6 años cumplidos
- **THEN** el alta se acepta

#### Scenario: Niño de 7 años

- **WHEN** el usuario registra un niño que hoy tiene 7 años cumplidos
- **THEN** el campo de fecha muestra el error de edad máxima y no se crea el niño

### Requirement: Room selection

El formulario SHALL ofrecer la selección de sala con las salas disponibles y SHALL preseleccionar la única sala existente, "Soles".

#### Scenario: Selector de sala preseleccionado

- **WHEN** el usuario abre `/kids/nuevo`
- **THEN** el selector de sala muestra "Soles" seleccionado y permite cambiarlo cuando exista más de una sala

### Requirement: Save creates the child in the list

Al guardar un alta válida, el sistema SHALL agregar el niño al listado de la sala, volver a `/kids`, limpiar el buscador y reflejar al niño nuevo en la grilla y en el total de la sala.

#### Scenario: Alta exitosa

- **WHEN** el usuario completa datos válidos y activa "Guardar"
- **THEN** la aplicación vuelve a `/kids`, el buscador está vacío y el niño nuevo aparece en la grilla con el total incrementado

#### Scenario: Búsqueda activa antes del alta

- **WHEN** el usuario tenía un texto en el buscador, completa un alta válida y guarda
- **THEN** al volver a `/kids` el buscador está vacío y todas las tarjetas, incluida la nueva, son visibles

#### Scenario: Estado inicial del niño nuevo

- **WHEN** el niño nuevo aparece en el listado sin padres vinculados
- **THEN** su tarjeta muestra la edad calculada desde la fecha registrada y el badge "VINCULAR"

#### Scenario: Niño nuevo sin alergias

- **WHEN** el usuario registra un niño sin alergias
- **THEN** su tarjeta no muestra badge de alergia

#### Scenario: Niño nuevo con alergias

- **WHEN** el usuario registra un niño con las etiquetas "Maní" y "Lactosa"
- **THEN** su ficha muestra ambas etiquetas como chips

### Requirement: Registration demo persistence

El alta SHALL funcionar sin red, autenticación ni base de datos, guardando el niño en memoria durante la sesión de la aplicación.

#### Scenario: Alta sin conectividad

- **WHEN** el dispositivo no tiene red y el usuario completa un alta válida
- **THEN** el niño nuevo se agrega igualmente al listado

#### Scenario: Reinicio de la aplicación

- **WHEN** la aplicación se reinicia después de un alta
- **THEN** el listado vuelve a los ocho niños de demostración

### Requirement: Cancel registration

La acción "Cancelar" SHALL volver a `/kids` descartando los datos ingresados sin crear el niño.

#### Scenario: Cancelar un alta

- **WHEN** el usuario completa datos y activa "Cancelar"
- **THEN** la aplicación vuelve a `/kids`, el total de niños no cambia y el niño no se crea

### Requirement: Registration localization

El formulario SHALL presentar sus etiquetas, ayudas y errores en español desde la localización, sin claves crudas ni detalles internos de error.

#### Scenario: Mensajes localizados

- **WHEN** el usuario provoca un error de guardado
- **THEN** el mensaje aparece en español y no expone nombres de excepciones ni detalles internos
