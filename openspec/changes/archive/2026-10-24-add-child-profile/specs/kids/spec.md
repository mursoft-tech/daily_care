# Spec Delta

## MODIFIED Requirements

### Requirement: Kids placeholder actions

La acción "Agregar niño" SHALL mostrar el aviso "Próximamente" sin cambiar de ruta. Cada tarjeta de niño SHALL navegar a la ficha de ese niño al activarse y SHALL mostrar cursor de mano y una elevación ligera al pasar el puntero.

#### Scenario: Agregar niño

- **WHEN** el usuario activa "Agregar niño"
- **THEN** aparece el aviso "Próximamente" y la ruta sigue siendo `/kids`

#### Scenario: Abrir una tarjeta

- **WHEN** el usuario activa la tarjeta de Mateo Fernández
- **THEN** la aplicación navega a `/kids/mateo-fernandez` y muestra la ficha de Mateo

#### Scenario: Hover sobre una tarjeta

- **WHEN** el puntero se posiciona sobre una tarjeta de niño
- **THEN** el cursor cambia a mano y la tarjeta se eleva ligeramente

## ADDED Requirements

### Requirement: Kids search persistence

El buscador SHALL conservar el texto ingresado y el filtro aplicado al volver de una ficha de niño, de modo que el campo y el listado permanezcan sincronizados.

#### Scenario: Volver con búsqueda activa

- **WHEN** el usuario escribe "so", abre la ficha de Sofía y vuelve a `/kids`
- **THEN** el buscador muestra "so" y solo se ven las tarjetas que coinciden con esa búsqueda

#### Scenario: Limpiar después de volver

- **WHEN** el usuario vuelve con la búsqueda "so" y borra el texto del buscador
- **THEN** se muestran las ocho tarjetas de la sala

#### Scenario: Volver sin búsqueda

- **WHEN** el usuario no escribió nada, abre una ficha y vuelve a `/kids`
- **THEN** el buscador está vacío y se muestran las ocho tarjetas
