# child-profile Specification

## Purpose

Permite a la maestra consultar la ficha completa de un niño de la sala, con sus alergias, datos de ingreso y padres vinculados, desde el listado de niños.

## Requirements

### Requirement: Child profile route access

El sistema SHALL exponer la ficha de cada niño en `/kids/:childId`, accesible desde su tarjeta en `/kids` y por enlace directo, y SHALL mantener el destino "Niños" activo mientras la ficha esté abierta.

#### Scenario: Acceso desde la tarjeta

- **WHEN** el usuario activa la tarjeta de Mateo Fernández en `/kids`
- **THEN** la aplicación navega a `/kids/mateo-fernandez` y muestra su ficha con el destino "Niños" resaltado

#### Scenario: Enlace directo

- **WHEN** el usuario abre `/kids/sofia-mendez` directamente
- **THEN** ve la ficha de Sofía Méndez sin pasar por el listado

#### Scenario: Volver al listado

- **WHEN** el usuario activa "Volver a Niños" en una ficha
- **THEN** la aplicación navega a `/kids` y restaura el texto y el filtro de búsqueda previos, o el listado completo si no había búsqueda

### Requirement: Child profile identity

La ficha SHALL mostrar en su cabecera el avatar con la inicial y el color del niño, el nombre completo, la edad en años, la sala y la acción "Editar".

#### Scenario: Cabecera de la ficha

- **WHEN** el usuario abre la ficha de Mateo Fernández
- **THEN** ve el avatar con "M", "Mateo Fernández", "3 años · Sala Soles" y la acción "Editar"

### Requirement: Age coherence

La edad visible SHALL calcularse desde la fecha de nacimiento registrada y la fecha actual, de modo que nunca contradiga la fecha de nacimiento que muestra la ficha.

#### Scenario: Cumpleaños ya cumplido

- **WHEN** la fecha de nacimiento es el 12 de marzo de 2023 y la fecha actual es el 24 de octubre de 2026
- **THEN** la ficha muestra "3 años"

#### Scenario: Cumpleaños aún no cumplido

- **WHEN** la fecha de nacimiento es el 30 de diciembre de 2023 y la fecha actual es el 24 de octubre de 2026
- **THEN** la ficha muestra "2 años"

### Requirement: Child profile dates

La ficha SHALL mostrar la fecha de nacimiento, la sala y el mes de ingreso con formato español abreviado, por ejemplo "12 mar 2023" y "feb 2025".

#### Scenario: Datos de la sala

- **WHEN** el usuario abre una ficha con fecha de nacimiento, sala e ingreso registrados
- **THEN** ve las filas "Fecha de nacimiento", "Sala" e "Ingreso" con sus valores formateados en español

### Requirement: Allergy notes

La ficha SHALL mostrar el bloque "Alergias y notas" con la etiqueta corta y el texto completo cuando el niño tiene notas de alergia, y SHALL omitir el bloque cuando no las tiene.

#### Scenario: Niño con alergia

- **WHEN** el usuario abre la ficha de Mateo Fernández
- **THEN** ve "Alergias y notas", la etiqueta "MANÍ" y el detalle "Alergia al maní. Evitar frutos secos. Lleva inhalador en la mochila."

#### Scenario: Niño sin alergia

- **WHEN** el usuario abre la ficha de Sofía Méndez
- **THEN** no se muestra el bloque "Alergias y notas"

### Requirement: Linked parents

La ficha SHALL listar a los padres o tutores vinculados con avatar, nombre, rol y estado, y SHALL mostrar el badge "ACTIVA" para una cuenta activa y "PENDIENTE" para una invitación enviada.

#### Scenario: Padres con estados distintos

- **WHEN** el usuario abre la ficha de Mateo Fernández
- **THEN** ve a "Lucía Fernández · Mamá · activa" con el badge "ACTIVA" y a "Diego Fernández · Papá · invitación enviada" con el badge "PENDIENTE"

#### Scenario: Un solo padre

- **WHEN** el usuario abre una ficha con un único padre vinculado
- **THEN** se lista ese padre y no aparecen badges de estado de otros padres

### Requirement: No linked parents

La ficha SHALL mostrar un estado vacío cuando el niño no tiene padres vinculados y SHALL ofrecer la acción "Vincular un padre".

#### Scenario: Niño sin padres

- **WHEN** el usuario abre la ficha de Valentina Soto
- **THEN** ve el estado vacío de padres y la acción "Vincular un padre"

### Requirement: Parent count consistency

La cantidad de padres vinculados que muestra el listado de `/kids` SHALL coincidir con la cantidad de padres listados en la ficha, incluyendo las invitaciones enviadas.

#### Scenario: Coincidencia con el listado

- **WHEN** el listado muestra "2 padres vinculados" para Mateo Fernández
- **THEN** su ficha lista exactamente dos padres, uno activo y uno pendiente

### Requirement: Child profile actions

Las acciones "Editar", "Resumen del día" y "Vincular padre" SHALL mostrar el aviso "Próximamente" sin cambiar de ruta, mientras la ficha permanezca en `/kids/:childId`.

#### Scenario: Acción pendiente

- **WHEN** el usuario activa "Editar", "Resumen del día" o "Vincular padre"
- **THEN** aparece el aviso "Próximamente" y la ruta no cambia

### Requirement: Child profile states

La ficha SHALL representar carga y error sin bloquear el shell; el error SHALL ser genérico, sin detalles internos, y ofrecer reintentar.

#### Scenario: Carga inicial

- **WHEN** la ficha aún no tiene datos
- **THEN** se muestra un indicador de progreso en el contenido y la navegación sigue disponible

#### Scenario: Error de carga

- **WHEN** la ficha falla
- **THEN** se muestra un mensaje genérico con la acción "Reintentar"

### Requirement: Child profile not found

La ficha SHALL mostrar un estado "no encontrado" con una acción para volver al listado cuando el identificador no corresponde a ningún niño, sin exponer detalles internos.

#### Scenario: Identificador inexistente

- **WHEN** el usuario abre `/kids/inexistente`
- **THEN** ve un mensaje de perfil no encontrado y la acción para volver a `/kids`

### Requirement: Child profile demo availability

La ficha SHALL renderizar los datos de demostración sin depender de red, autenticación ni base de datos.

#### Scenario: Sin conectividad

- **WHEN** el dispositivo no tiene red
- **THEN** las ocho fichas de demostración se muestran igualmente

### Requirement: Child profile adaptive layout

La ficha SHALL usar dos columnas cuando el contenido dispone de ancho suficiente y una columna apilada en anchos menores, sin desbordar horizontalmente.

#### Scenario: Contenido amplio

- **WHEN** el contenido dispone de al menos 640 px de ancho
- **THEN** los datos del niño y la columna de acciones y padres se muestran lado a lado

#### Scenario: Contenido reducido

- **WHEN** el contenido dispone de menos de 640 px de ancho
- **THEN** las columnas se apilan y no hay overflow horizontal

### Requirement: Child profile localization

La ficha SHALL presentar todos sus textos de interfaz en español desde la localización, sin claves crudas, y SHALL concordar en singular o plural según los valores.

#### Scenario: Textos localizados

- **WHEN** el usuario abre cualquier ficha
- **THEN** cabecera, acciones, datos, alergias, padres, estados y errores aparecen en español

#### Scenario: Concordancia de edad

- **WHEN** la edad es de un año
- **THEN** el texto dice "1 año" y no "1 años"
