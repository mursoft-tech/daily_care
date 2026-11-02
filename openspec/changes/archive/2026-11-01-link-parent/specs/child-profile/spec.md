# Spec Delta

## MODIFIED Requirements

### Requirement: Child profile actions

Las acciones "Editar" y "Resumen del día" SHALL mostrar el aviso "Próximamente" sin cambiar de ruta, mientras que la acción "Vincular un padre" o "Vincular otro padre" SHALL navegar a `/kids/:childId/vincular-padre` y SHALL permanecer disponible después de cada vinculación.

#### Scenario: Acción pendiente

- **WHEN** el usuario activa "Editar" o "Resumen del día"
- **THEN** aparece el aviso "Próximamente" y la ruta no cambia

#### Scenario: Acción vincular padre

- **WHEN** el usuario activa "Vincular un padre" o "Vincular otro padre" en la ficha de un niño
- **THEN** la aplicación navega a `/kids/:childId/vincular-padre` mostrando la pantalla de vinculación para ese niño

#### Scenario: Vincular otro padre tras la primera vinculación

- **WHEN** el niño ya tiene un tutor vinculado y el usuario regresa a su ficha
- **THEN** la acción muestra "Vincular otro padre" y abre el formulario para agregar un tutor adicional

### Requirement: Linked parents

La ficha SHALL listar a los padres o tutores vinculados con avatar, nombre, rol y estado, y SHALL mostrar el badge "ACTIVA" para una cuenta activa y "PENDIENTE" para una invitación enviada.

#### Scenario: Padres con estados distintos

- **WHEN** el usuario abre la ficha de Mateo Fernández
- **THEN** ve a "Lucía Fernández · Mamá · activa" con el badge "ACTIVA" y a "Diego Fernández · Papá · invitación enviada" con el badge "PENDIENTE"

#### Scenario: Un solo padre

- **WHEN** el usuario abre una ficha con un único padre vinculado
- **THEN** se lista ese padre y no aparecen badges de estado de otros padres

#### Scenario: Varios tutores tras vinculaciones sucesivas

- **WHEN** el usuario vincula un segundo tutor a un niño que ya tenía uno
- **THEN** la ficha lista a ambos tutores con su rol y estado, y la cantidad de padres vinculados coincide con la lista

## ADDED Requirements

### Requirement: Link parent form and invitation

La pantalla SHALL mostrar el niño, el nombre y el correo del tutor, el parentesco y un código de invitación propio de esa invitación con su vigencia. Cada envío SHALL registrar un tutor adicional en estado "PENDIENTE" sin reemplazar a los existentes y SHALL rechazar un correo ya vinculado al mismo niño.

#### Scenario: Acceso y visualización de la pantalla de vinculación

- **WHEN** el usuario abre `/kids/mateo-fernandez/vincular-padre`
- **THEN** ve la cabecera "Vincular padre" con "a Mateo Fernández", los campos de nombre y correo, las opciones de parentesco y el código de invitación de esa invitación con "Vence en 7 días"

#### Scenario: Segunda invitación con código propio

- **WHEN** el usuario vincula un tutor, vuelve a abrir la pantalla de vinculación y completa los datos de un segundo tutor
- **THEN** el formulario muestra un código de invitación distinto al de la primera invitación y ambos tutores quedan en estado "PENDIENTE"

#### Scenario: Correo ya vinculado

- **WHEN** el usuario ingresa el correo de un tutor que ya está vinculado al mismo niño, sin importar mayúsculas, y activa "Enviar invitación"
- **THEN** ve el mensaje localizado de correo ya vinculado y la lista de tutores no incorpora un duplicado

#### Scenario: Cancelar o cerrar vinculación

- **WHEN** el usuario activa el botón de cerrar en la pantalla de vinculación
- **THEN** la aplicación regresa a la ficha del niño `/kids/:childId`

#### Scenario: Envío exitoso de invitación

- **WHEN** el usuario completa los datos requeridos y activa "Enviar invitación"
- **THEN** el sistema registra al nuevo tutor con estado "PENDIENTE", muestra una confirmación y navega de regreso a la ficha del niño
