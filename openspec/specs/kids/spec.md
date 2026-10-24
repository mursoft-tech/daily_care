# kids Specification

## Purpose

Permite a la maestra consultar el directorio de niños de la sala, buscar por nombre y detectar de un vistazo alergias y vinculaciones pendientes.

## Requirements

### Requirement: Kids route access

El sistema SHALL exponer el listado de niños en la ruta `/kids`, accesible desde el destino "Niños" del sidebar, del rail y del menú lateral en los tres anchos del shell, y SHALL marcar ese destino como activo mientras la ruta esté abierta.

#### Scenario: Acceso directo

- **WHEN** el usuario abre `/kids`
- **THEN** ve la pantalla de niños con el destino "Niños" marcado como activo

#### Scenario: Acceso desde el sidebar

- **WHEN** el usuario activa "Niños" desde el sidebar en un ancho de 900 px o más
- **THEN** la aplicación navega a `/kids` y el destino queda resaltado

#### Scenario: Acceso desde el rail

- **WHEN** el usuario activa "Niños" desde el rail entre 600 y 899 px
- **THEN** la aplicación navega a `/kids` y el destino queda resaltado

#### Scenario: Acceso desde el menú lateral

- **WHEN** el usuario activa "Niños" desde el menú lateral en un ancho menor a 600 px
- **THEN** el menú se cierra y la aplicación navega a `/kids`

#### Scenario: Regreso al feed

- **WHEN** el usuario activa "Feed" estando en `/kids`
- **THEN** la aplicación navega a `/` y el destino "Feed" queda resaltado

### Requirement: Kids page content

La pantalla `/kids` SHALL mostrar la etiqueta "GESTIÓN", el título "Niños", la acción "Agregar niño", el buscador, la etiqueta de la sala con el total de niños y la grilla de tarjetas de la sala.

#### Scenario: Cabecera de la pantalla

- **WHEN** el usuario abre `/kids`
- **THEN** ve "GESTIÓN", el título "Niños" y el botón "Agregar niño"

#### Scenario: Listado de la sala

- **WHEN** la pantalla termina de cargar
- **THEN** muestra "SALA SOLES", el total "8 niños" y las ocho tarjetas de demostración

#### Scenario: Total de la sala

- **WHEN** el usuario escribe en el buscador
- **THEN** el total de la sección sigue mostrando la cantidad total de niños de la sala

### Requirement: Child card content

Cada tarjeta SHALL mostrar el avatar con la inicial y el color del niño, el nombre completo, la edad, el estado de vinculación de padres y un badge de alergia, un badge "VINCULAR" o un indicador de navegación.

#### Scenario: Niño con padres vinculados

- **WHEN** se renderiza una tarjeta de un niño con al menos un padre vinculado y sin alergia
- **THEN** la tarjeta muestra la edad, "1 padre vinculado" o "2 padres vinculados" según corresponda, y un indicador de navegación a la derecha

#### Scenario: Niño con alergia

- **WHEN** se renderiza una tarjeta de un niño con alergia registrada
- **THEN** la tarjeta muestra el badge con el nombre de la alergia ("MANÍ" o "LACTOSA")

#### Scenario: Niño sin padres vinculados

- **WHEN** se renderiza una tarjeta de un niño sin padres vinculados y sin alergia
- **THEN** la tarjeta muestra "sin padres vinculados" y el badge "VINCULAR"

#### Scenario: Prioridad del badge de alergia

- **WHEN** un niño tiene alergia y además no tiene padres vinculados
- **THEN** la tarjeta muestra el badge de alergia antes que el badge "VINCULAR"

### Requirement: Kids search

El buscador SHALL filtrar las tarjetas por nombre completo sin distinguir mayúsculas ni tildes, y SHALL mostrar un estado vacío cuando ninguna tarjeta coincida.

#### Scenario: Filtro por nombre

- **WHEN** el usuario escribe "so" en el buscador
- **THEN** solo se muestran las tarjetas cuyo nombre completo contiene "so"

#### Scenario: Sin coincidencias

- **WHEN** el usuario escribe un texto que no coincide con ningún niño
- **THEN** se muestra el mensaje "No encontramos niños con ese nombre" en lugar de la grilla

#### Scenario: Limpiar la búsqueda

- **WHEN** el usuario borra el texto del buscador
- **THEN** vuelven a mostrarse las ocho tarjetas

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

### Requirement: Kids states

El sistema SHALL representar los estados de carga, error y datos del listado de niños sin bloquear el shell de navegación.

#### Scenario: Carga inicial

- **WHEN** el listado aún no tiene datos
- **THEN** se muestra un indicador de progreso en el área de contenido y la navegación sigue disponible

#### Scenario: Error de carga

- **WHEN** el listado falla
- **THEN** se muestra un mensaje genérico sin detalles internos y una acción para reintentar

### Requirement: Kids demo availability

La pantalla `/kids` SHALL renderizar el listado sin depender de red, autenticación ni base de datos.

#### Scenario: Sin conectividad

- **WHEN** el dispositivo no tiene red
- **THEN** los ocho niños de demostración se muestran igualmente

### Requirement: Kids adaptive layout

La grilla SHALL usar dos columnas cuando el ancho disponible del contenido sea suficiente y una columna en anchos menores, sin desbordar horizontalmente.

#### Scenario: Ancho amplio

- **WHEN** el contenido dispone de al menos 700 px de ancho
- **THEN** las tarjetas se distribuyen en dos columnas

#### Scenario: Ancho reducido

- **WHEN** el contenido dispone de menos de 700 px de ancho
- **THEN** las tarjetas se distribuyen en una columna y no hay overflow horizontal

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

### Requirement: Kids Spanish localization

La pantalla `/kids` SHALL presentar todos sus textos de interfaz en español provenientes de la localización, sin claves crudas.

#### Scenario: Textos localizados

- **WHEN** el usuario abre `/kids`
- **THEN** la cabecera, el buscador, la sección, las edades, la vinculación, el estado vacío y los errores aparecen en español

#### Scenario: Plurales

- **WHEN** se muestra la edad o la cantidad de padres vinculados
- **THEN** el texto concuerda en singular o plural según el valor
