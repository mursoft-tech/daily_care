# post-creation Specification

## Purpose

Permite a la maestra redactar una publicación del día, elegir sus destinatarios y tipo, y verla reflejada en el feed, usando datos de demostración en memoria.

## Requirements

### Requirement: Composer route and shell

El sistema SHALL exponer el formulario en la ruta `/publicaciones/nueva`, dentro del shell compartido y con el destino "Feed" resaltado, respetando la identidad visual del template `crear-publicacion.dc.html`.

#### Scenario: Abrir el formulario

- **WHEN** el usuario llega a `/publicaciones/nueva`
- **THEN** ve el título "Nueva publicación", las acciones "Cancelar" y "Publicar", y los bloques PARA, TIPO, DESCRIPCIÓN y FOTOS, con "Feed" resaltado en la navegación

#### Scenario: Cancelar la publicación

- **WHEN** el usuario activa "Cancelar"
- **THEN** la aplicación vuelve a `/` sin crear ninguna publicación

#### Scenario: Formulario en ancho compacto

- **WHEN** el ancho disponible es menor a 600 px
- **THEN** el formulario ocupa una columna, conserva sus bloques y no produce overflow

### Requirement: Recipient selection

El formulario SHALL permitir seleccionar varios niños de la sala a la vez. "Toda la sala" SHALL estar seleccionada al abrir, activarla SHALL deseleccionar a todos los niños y elegir un niño SHALL deseleccionar "Toda la sala". Siempre SHALL quedar al menos un destinatario.

#### Scenario: Destinatario por defecto

- **WHEN** el usuario abre el formulario
- **THEN** "Toda la sala" aparece seleccionada y ningún niño lo está

#### Scenario: Elegir un niño

- **WHEN** el usuario activa el chip de un niño
- **THEN** ese niño queda seleccionado y "Toda la sala" deja de estarlo

#### Scenario: Elegir varios niños

- **WHEN** el usuario activa el chip de un segundo niño
- **THEN** ambos niños quedan seleccionados y "Toda la sala" sigue sin seleccionar

#### Scenario: Quitar uno de varios niños

- **WHEN** el usuario activa el chip de un niño ya seleccionado mientras hay otros seleccionados
- **THEN** ese niño se deselecciona y los demás conservan su selección

#### Scenario: Quitar el último niño

- **WHEN** el usuario deselecciona el único niño seleccionado
- **THEN** "Toda la sala" vuelve a quedar seleccionada

#### Scenario: Volver a toda la sala

- **WHEN** el usuario activa "Toda la sala" después de elegir uno o varios niños
- **THEN** todos los niños se deseleccionan y "Toda la sala" queda como único destinatario

#### Scenario: Sala sin niños

- **WHEN** la sala no tiene niños disponibles
- **THEN** el bloque PARA muestra solo "Toda la sala" sin errores de renderizado

### Requirement: Post type selection

El formulario SHALL ofrecer los siete tipos del template (comida, siesta, actividad, logro, ánimo, foto y anuncio) con sus etiquetas en español y un único tipo seleccionado, por defecto "Actividad".

#### Scenario: Tipo por defecto

- **WHEN** el usuario abre el formulario
- **THEN** "Actividad" aparece seleccionada

#### Scenario: Cambiar de tipo

- **WHEN** el usuario activa otro tipo
- **THEN** solo el tipo elegido queda seleccionado y conserva el color de su categoría

#### Scenario: Tipos operables con teclado

- **WHEN** el usuario recorre los chips de tipo con el teclado y activa uno
- **THEN** el tipo cambia igual que con un clic

### Requirement: Description validation

El formulario SHALL exigir una descripción no vacía, ignorando espacios en los extremos, y SHALL impedir publicar mientras no la haya, mostrando un mensaje localizado.

#### Scenario: Publicar sin descripción

- **WHEN** el usuario activa "Publicar" con la descripción vacía
- **THEN** se muestra el error de descripción obligatoria y no se crea ninguna publicación

#### Scenario: Descripción con solo espacios

- **WHEN** el usuario activa "Publicar" con una descripción compuesta solo por espacios
- **THEN** se muestra el error de descripción obligatoria y no se crea ninguna publicación

#### Scenario: Limpiar el error al escribir

- **WHEN** el usuario escribe en la descripción después de un error
- **THEN** el mensaje de error desaparece

### Requirement: Publishing a post

Al publicar, el sistema SHALL crear una publicación con la hora actual, cero likes y cero comentarios, guardarla en los datos de demostración en memoria y volver a `/`, mostrándola primera en el feed.

#### Scenario: Publicación para un niño

- **WHEN** el usuario elige un niño, un tipo y una descripción válida, y activa "Publicar"
- **THEN** la aplicación vuelve a `/` y la publicación aparece primera en el feed con el nombre y avatar del niño, su tipo y la audiencia "Para: familia de {nombre}"

#### Scenario: Publicación para varios niños

- **WHEN** el usuario elige dos o más niños, un tipo y una descripción válida, y activa "Publicar"
- **THEN** la aplicación vuelve a `/` y la publicación aparece primera con el nombre y avatar del primer niño, su tipo y la audiencia "Para: familias de Mateo y Sofía"

#### Scenario: Publicación para toda la sala

- **WHEN** el usuario publica con "Toda la sala" seleccionada
- **THEN** la publicación aparece primera en el feed con la audiencia "Para: toda la sala"

#### Scenario: Fallo al guardar

- **WHEN** la persistencia de demostración falla
- **THEN** se muestra un mensaje genérico, se conserva el contenido del formulario y no se navega al feed

#### Scenario: Persistencia solo en memoria

- **WHEN** la aplicación se reinicia
- **THEN** el feed vuelve a las publicaciones de demostración y las publicaciones creadas en la sesión desaparecen

### Requirement: Photo block

El formulario SHALL mostrar el bloque FOTOS del template con la acción "Agregar", que en esta etapa SHALL avisar "Próximamente" sin adjuntar ninguna imagen.

#### Scenario: Agregar foto no disponible

- **WHEN** el usuario activa "Agregar" en el bloque FOTOS
- **THEN** aparece el aviso "Próximamente" y no se adjunta ninguna imagen

#### Scenario: Publicar sin foto

- **WHEN** el usuario publica sin adjuntar imágenes
- **THEN** la publicación se crea sin foto y la tarjeta no muestra el bloque de imagen

### Requirement: Spanish localization

Todos los textos del formulario SHALL provenir de la localización en español, sin cadenas crudas ni claves visibles.

#### Scenario: Textos localizados

- **WHEN** el usuario abre el formulario
- **THEN** títulos, acciones, bloques, tipos, destinatarios y errores aparecen en español
