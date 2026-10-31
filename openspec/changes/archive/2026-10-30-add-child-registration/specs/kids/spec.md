# Spec Delta

## RENAMED Requirements

- FROM: `### Requirement: Kids placeholder actions`
- TO: `### Requirement: Kids navigation actions`

## MODIFIED Requirements

### Requirement: Child card content

Cada tarjeta SHALL mostrar el avatar con la inicial y el color del niño, el nombre completo, la edad, el estado de vinculación de padres y un badge de alergia, un badge "VINCULAR" o un indicador de navegación.

#### Scenario: Niño con padres vinculados

- **WHEN** se renderiza una tarjeta de un niño con al menos un padre vinculado y sin alergia
- **THEN** la tarjeta muestra la edad, "1 padre vinculado" o "2 padres vinculados" según corresponda, y un indicador de navegación a la derecha

#### Scenario: Niño con alergia

- **WHEN** se renderiza una tarjeta de un niño con alergia registrada
- **THEN** la tarjeta muestra el badge con el nombre de la alergia ("MANÍ" o "LACTOSA")

#### Scenario: Niño con varias alergias

- **WHEN** se renderiza una tarjeta de un niño con más de una alergia registrada
- **THEN** el badge muestra la primera etiqueta seguida de la cantidad restante, por ejemplo "MANÍ +1"

#### Scenario: Niño sin padres vinculados

- **WHEN** se renderiza una tarjeta de un niño sin padres vinculados y sin alergia
- **THEN** la tarjeta muestra "sin padres vinculados" y el badge "VINCULAR"

#### Scenario: Prioridad del badge de alergia

- **WHEN** un niño tiene alergia y además no tiene padres vinculados
- **THEN** la tarjeta muestra el badge de alergia antes que el badge "VINCULAR"

### Requirement: Kids navigation actions

La acción "Agregar niño" SHALL navegar a `/kids/nuevo`. Cada tarjeta de niño SHALL navegar a la ficha de ese niño al activarse y SHALL mostrar cursor de mano y una elevación ligera al pasar el puntero.

#### Scenario: Agregar niño

- **WHEN** el usuario activa "Agregar niño"
- **THEN** la aplicación navega a `/kids/nuevo` y muestra el formulario de alta

#### Scenario: Abrir una tarjeta

- **WHEN** el usuario activa la tarjeta de Mateo Fernández
- **THEN** la aplicación navega a `/kids/mateo-fernandez` y muestra la ficha de Mateo

#### Scenario: Hover sobre una tarjeta

- **WHEN** el puntero se posiciona sobre una tarjeta de niño
- **THEN** el cursor cambia a mano y la tarjeta se eleva ligeramente
